import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_approve_pass.dart';
import 'staff_visitor_pass.dart';
import 'staff_show_all_approve_appointment.dart';
import 'package:intl/intl.dart';

class StaffAppointmentPage extends StatefulWidget {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String userUID;
  final Map<String, dynamic> userInfo;

  StaffAppointmentPage({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.userUID,
    required this.userInfo,
  });

  @override
  _StaffAppointmentPageState createState() => _StaffAppointmentPageState();
}

class _StaffAppointmentPageState extends State<StaffAppointmentPage> {
  Future<Map<String, String>> getUserInfo(String userUID) async {
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userUID', isEqualTo: userUID)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs[0].data() as Map<String, dynamic>;
        final userName = userData['name'] as String? ?? 'Unknown User';
        final userPhone = userData['phone'] as String? ?? 'Unknown Phone';
        return {
          'name': userName,
          'phone': userPhone,
        };
      } else {
        return {
          'name': 'Unknown User',
          'phone': 'Unknown Phone',
        };
      }
    } catch (e) {
      return {
        'name': 'Unknown User',
        'phone': 'Unknown Phone',
      };
    }
  }

  Stream<QuerySnapshot>? upcomingAppointmentsStream;

  // Method to fetch "Upcoming" appointments
  Future<void> fetchUpcomingAppointments() async {
    upcomingAppointmentsStream = FirebaseFirestore.instance
        .collection('upcoming_appointment')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date')
        .snapshots();
  }

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffShowAllApproveAppointmentPage(),
              ),
            );
          },
          child: Icon(Icons.list), // Use the list icon
        ),
        body: TabBarView(
          children: [
            buildAppointmentsList(
                context, 'Upcoming', upcomingAppointmentsStream),
          ],
        ),
      ),
    );
  }

  Widget buildAppointmentsList(BuildContext context, String status,
      Stream<QuerySnapshot>? appointmentsStream) {
    if (status == 'Upcoming') {
      appointmentsStream = FirebaseFirestore.instance
          .collection('upcoming_appointment')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final appointments = snapshot.data!.docs;

        if (appointments.isEmpty) {
          return Center(
            child: Text('No appointments pending for approval'),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appointments.map((appointment) {
              final docId = appointment.id;
              final date = appointment['date'] as Timestamp;
              final startTime = appointment['startTime'] as String;
              final endTime = appointment['endTime'] as String;
              final userUID = appointment['userUID'] as String;

              return FutureBuilder<Map<String, String>>(
                future: getUserInfo(userUID),
                builder: (context, userInfoSnapshot) {
                  if (userInfoSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  final userInfo = userInfoSnapshot.data ??
                      {'name': 'Unknown User', 'phone': 'Unknown Phone'};

                  return GestureDetector(
                    onTap: () {
                      _showConfirmationDialog(
                          context, docId, date, startTime, endTime, userInfo);
                    },
                    child: AppointmentItem(
                      date: '${_formatDate(date.toDate())}',
                      time: '$startTime - $endTime',
                      userName: userInfo['name'],
                      userPhone: userInfo['phone'],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String docId,
    Timestamp date,
    String startTime,
    String endTime,
    Map<String, String> userInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                _buildInfoRow('Date', _formatDate(date.toDate())),
                _buildInfoRow('Time', '$startTime - $endTime'),
                _buildInfoRow('User', userInfo['name'] ?? 'Unknown User'),
                _buildInfoRow('Phone', userInfo['phone'] ?? 'Unknown Phone'),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Disapprove'),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Close the confirmation dialog
                        _showDisapprovalReasonDialog(
                            context, docId, date, startTime, endTime, userInfo);
                      },
                    ),
                    TextButton(
                      child: Text('Approve'),
                      onPressed: () {
                        _handleAppointmentApproval(
                          context,
                          docId,
                          userInfo,
                          'approve',
                          startTime,
                          endTime,
                          date,
                          gender: userInfo['gender'] ?? 'Unknown Gender',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDisapprovalReasonDialog(
    BuildContext context,
    String docId,
    Timestamp date,
    String startTime,
    String endTime,
    Map<String, String> userInfo,
  ) {
    TextEditingController reasonController = TextEditingController();
    bool showError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Disapproval Reason',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Please state the reason',
                        errorText: showError ? 'Please enter a reason' : null,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: showError ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the disapproval reason dialog
                          },
                        ),
                        TextButton(
                          child: Text('Submit'),
                          onPressed: () {
                            if (reasonController.text.isEmpty) {
                              setState(() {
                                showError = true;
                              });
                            } else {
                              setState(() {
                                showError = false;
                              });
                              _handleAppointmentApproval(
                                context,
                                docId,
                                userInfo,
                                'disapprove',
                                startTime,
                                endTime,
                                date,
                                gender: userInfo['gender'] ?? 'Unknown Gender',
                                reason: reasonController.text,
                              );
                              Navigator.of(context)
                                  .pop(); // Close the disapproval reason dialog
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Update _handleAppointmentApproval method
  void _handleAppointmentApproval(
      BuildContext context,
      String docId,
      Map<String, String> userInfo,
      String approvalStatus,
      String startTime,
      String endTime,
      Timestamp originalDate,
      {required String gender,
      String? reason} // Add this line
      ) async {
    try {
      // Fetch userUID from 'users' collection using the user's name
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: userInfo['name'])
          .get();

      String userUID;

      if (userQuery.docs.isNotEmpty) {
        userUID = userQuery.docs[0]['userUID'];
      } else {
        // Handle the case where userUID is not found
        print('Error: userUID not found for user ${userInfo['name']}');
        return;
      }

      final Map<String, dynamic> data = {
        'date': originalDate, // Use the original date
        'startTime': startTime,
        'endTime': endTime,
        'userUID': userUID,
        'userName': userInfo['name'],
        'userPhone': userInfo['phone'],
        'gender': gender,
        'reason': reason, // Add this line
        // Add other fields as needed
      };

      final String collectionName = approvalStatus == 'approve'
          ? 'approve_appointment'
          : 'disapprove_appointment';

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .set(data, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('upcoming_appointment')
          .doc(docId)
          .delete();

      Navigator.of(context).pop(); // Close the dialog

      // Show a message based on the approval status
      final String message = approvalStatus == 'approve'
          ? 'Appointment approved!'
          : 'Appointment disapproved!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    } catch (e) {
      print('Error handling appointment approval: $e');
      // Handle error, show a snackbar, etc.
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(value),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> getCancelledAppointments() {
    return FirebaseFirestore.instance
        .collection('cancelled_appointment')
        .orderBy('date')
        .snapshots();
  }

  // Add a new function to get user information based on userUID from the "profile" database
  Future<Map<String, String>> getUserInfoFromProfile(String userUID) async {
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('profile')
          .where('userUID', isEqualTo: userUID)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs[0].data() as Map<String, dynamic>;
        final userName = userData['name'] as String? ?? 'Unknown User';
        final userPhone = userData['phone'] as String? ?? 'Unknown Phone';
        return {
          'name': userName,
          'phone': userPhone,
        };
      } else {
        return {
          'name': 'Unknown User',
          'phone': 'Unknown Phone',
        };
      }
    } catch (e) {
      return {
        'name': 'Unknown User',
        'phone': 'Unknown Phone',
      };
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this appointment?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy  (EEEE)');
    return formatter.format(dateTime);
  }
}

class AppointmentItem extends StatelessWidget {
  final String date;
  final String time;
  final String? userName; // Nullable
  final String? userPhone; // Nullable

  AppointmentItem({
    required this.date,
    required this.time,
    this.userName,
    this.userPhone, // Update the parameter type
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        title: Text(date),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time),
            Text('User: $userName'),
            if (userPhone != null) Text('Phone: $userPhone'),
          ],
        ),
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: StaffAppointmentPage(
        date: DateTime.now(),
        startTime: '9:00 AM',
        endTime: '10:00 AM',
        userUID: 'user_id', // Replace 'user_id' with the actual user UID
        userInfo: {
          'name': 'John Doe',
          'phone': '123-456-7890'
        }, // Replace with actual user info
      ),
    ));
  }
}
