import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'view_visitor_pass.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class VisitorPassPage extends StatefulWidget {
  @override
  _VisitorPassPageState createState() => _VisitorPassPageState();
}

class _VisitorPassPageState extends State<VisitorPassPage> {
  bool isFirstTimeInApproveTab = true;
  late final LocalAuthentication auth;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
  }

  Future<List<Map<String, dynamic>>> fetchData(String collection) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy  (EEEE)');
    return formatter.format(dateTime);
  }

  // Function to get the current user UID from Firebase Authentication
  String getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // Handle the case when the user is not logged in
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserUID = getCurrentUserUID();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Approve'),
              Tab(text: 'Disapprove'),
            ],
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.5),
          ),
          toolbarHeight: 8.0,
        ),
        body: TabBarView(
          children: [
            // Content for the 'Approve' tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData('approve_appointment'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the data for 'approve' tab only for the current user
                  List<Map<String, dynamic>> approveData = snapshot.data!;
                  List<Map<String, dynamic>> currentUserApproveData =
                      approveData
                          .where((data) => data['userUID'] == currentUserUID)
                          .toList();

                  // Check if it's the first time in the 'approve' tab
                  if (isFirstTimeInApproveTab) {
                    isFirstTimeInApproveTab = false;
                    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                      // Show the status message after the frame has been rendered
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Click to view visitor pass'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    });
                  }

                  return ListView.builder(
                    itemCount: currentUserApproveData.length,
                    itemBuilder: (context, index) {
                      // Sort the list in ascending order based on the 'date' field
                      currentUserApproveData.sort((a, b) =>
                          a['date'].toDate().compareTo(b['date'].toDate()));

                      Map<String, dynamic> data = currentUserApproveData[index];
                      Timestamp timestamp = data['date'];
                      DateTime dateTime = timestamp.toDate();

                      return GestureDetector(
                        onTap: () async {
                          bool isAuthenticated = await _authenticate();

                          if (isAuthenticated) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewVisitorPassPage(
                                  data: data,
                                  dateTime: dateTime,
                                  userName: data['userName'],
                                  userPhone: data['userPhone'],
                                  userUID: data['userUID'],
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Biometric authentication failed.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text('Date: ${_formatDate(dateTime)}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Time: ${data['startTime']} - ${data['endTime']}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            // Content for the 'Disapprove' tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData('disapprove_appointment'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the data for 'disapprove' tab only for the current user
                  List<Map<String, dynamic>> disapproveData = snapshot.data!;
                  List<Map<String, dynamic>> currentUserDisapproveData =
                      disapproveData
                          .where((data) => data['userUID'] == currentUserUID)
                          .toList();

                  return ListView.builder(
                    itemCount: currentUserDisapproveData.length,
                    itemBuilder: (context, index) {
                      // Sort the list in ascending order based on the 'date' field
                      currentUserDisapproveData.sort((a, b) =>
                          a['date'].toDate().compareTo(b['date'].toDate()));

                      Map<String, dynamic> data =
                          currentUserDisapproveData[index];
                      Timestamp timestamp = data['date'];
                      DateTime dateTime = timestamp.toDate();

                      return Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('Date: ${_formatDate(dateTime)}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Time: ${data['startTime']} - ${data['endTime']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: ' ',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      print("Authenticated: $authenticated");
      return authenticated;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    print("List of availableBiometrics: $availableBiometrics");

    if (!mounted) {
      return;
    }
    // Call setState or any other logic here
  }
}
