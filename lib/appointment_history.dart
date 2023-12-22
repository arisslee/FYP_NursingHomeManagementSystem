import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentHistoryPage extends StatelessWidget {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String userUID;

  AppointmentHistoryPage({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.userUID,
    // Add other relevant fields here
  });

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot>? appointmentsStream;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Appointment'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Upcoming',
                icon: Icon(Icons.access_time),
              ),
              Tab(
                text: 'Past',
                icon: Icon(Icons.history),
              ),
              Tab(
                text: 'Cancelled',
                icon: Icon(Icons.cancel),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildAppointmentsList(context, 'Upcoming', appointmentsStream),
            buildAppointmentsList(context, 'Past', appointmentsStream),
            buildAppointmentsList(context, 'Cancelled', appointmentsStream),
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
          .where('userUID', isEqualTo: userUID) // Filter by user's UID
          .orderBy('date')
          .snapshots();
    } else if (status == 'Past') {
      appointmentsStream = FirebaseFirestore.instance
          .collection('upcoming_appointment')
          .where('date', isLessThan: DateTime.now())
          .where('userUID', isEqualTo: userUID) // Filter by user's UID
          .orderBy('date')
          .snapshots();
    } else if (status == 'Cancelled') {
      appointmentsStream = FirebaseFirestore.instance
          .collection('cancelled_appointment')
          .where('userUID', isEqualTo: userUID) // Filter by user's UID
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

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appointments.map((appointment) {
              final docId = appointment.id; // Get the document ID
              final date = appointment['date'] as Timestamp;
              final startTime = appointment['startTime'] as String;
              final endTime = appointment['endTime'] as String;

              if (status == 'Upcoming') {
                return Dismissible(
                  key: UniqueKey(),
                  confirmDismiss: (direction) async {
                    bool? deleteConfirmed =
                        await _showDeleteConfirmationDialog(context);

                    if (deleteConfirmed == true) {
                      // Fetch user information from the "profile" database
                      final userSnapshot = await FirebaseFirestore.instance
                          .collection('profile')
                          .doc(
                              userUID) // Assuming userUID corresponds to the document ID
                          .get();

                      if (userSnapshot.exists) {
                        final userData =
                            userSnapshot.data() as Map<String, dynamic>;
                        final userName = userData['name'] as String;
                        final userPhone = userData['contactNumber'] as String;

                        // Update "cancelled_appointment" with user information
                        await FirebaseFirestore.instance
                            .collection('cancelled_appointment')
                            .add({
                          'date': date,
                          'startTime': startTime,
                          'endTime': endTime,
                          'userUID': userUID,
                          'userName': userName,
                          'userPhone': userPhone,
                        });

                        // Delete the appointment from "upcoming_appointment"
                        await FirebaseFirestore.instance
                            .collection('upcoming_appointment')
                            .doc(docId)
                            .delete();

                        return true; // Allow the dismissal
                      } else {
                        // Handle the case where user data is not found in the "profile" database
                        print('User data not found in the "profile" database.');
                        return false; // Cancel the dismissal
                      }
                    } else {
                      // Handle the case where the user is not found in the "profile" database
                      print('User not found in the "profile" database.');
                      return false; // Cancel the dismissal
                      // Cancel the dismissal
                    }
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: AppointmentItem(
                    date: '${_formatDate(date.toDate())}',
                    time: '$startTime - $endTime',
                  ),
                );
              } else {
                return AppointmentItem(
                  date: '${_formatDate(date.toDate())}',
                  time: '$startTime - $endTime',
                );
              }
            }).toList(),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancel?'),
          content: Text('Are you sure you want to cancel this appointment?'),
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

  AppointmentItem({
    required this.date,
    required this.time,
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
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        title: Text(date),
        subtitle: Text(time),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AppointmentHistoryPage(
      date: DateTime.now(),
      startTime: '9:00 AM',
      endTime: '10:00 AM',
      userUID: '', // Replace with the actual user's UID
    ),
  ));
}
