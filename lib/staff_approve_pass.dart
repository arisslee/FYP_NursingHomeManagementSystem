import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_generate_pass.dart';

class StaffApprovePassPage extends StatefulWidget {
  final String userUID;
  final String userName;
  final String gender;
  final String approvalStatus;

  StaffApprovePassPage({
    required this.userUID,
    required this.userName,
    required this.gender,
    required this.approvalStatus,
  });

  @override
  _StaffApprovePassPageState createState() => _StaffApprovePassPageState();
}

class _StaffApprovePassPageState extends State<StaffApprovePassPage> {
  late Stream<QuerySnapshot> approveAppointmentsStream;
  late Stream<QuerySnapshot> disapproveAppointmentsStream;

  late bool isFirstTimeInApproveTab;

  @override
  void initState() {
    super.initState();

    isFirstTimeInApproveTab = true;

    // Fetch data based on the approval status and userUID for 'approve' tab
    approveAppointmentsStream = FirebaseFirestore.instance
        .collection('approve_appointment')
        .where('userUID', isEqualTo: widget.userUID)
        .orderBy('date')
        .snapshots();

    // Fetch data based on the approval status and userUID for 'disapprove' tab
    disapproveAppointmentsStream = FirebaseFirestore.instance
        .collection('disapprove_appointment')
        .where('userUID', isEqualTo: widget.userUID)
        .orderBy('date')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Visitor Pass Approval'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Approve'),
              Tab(text: 'Disapprove'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Approve Tab Content
            buildAppointmentsList(
                context, 'approve', approveAppointmentsStream),

            // Disapprove Tab Content
            buildAppointmentsList(
                context, 'disapprove', disapproveAppointmentsStream),
          ],
        ),
      ),
    );
  }

  Widget buildAppointmentsList(
    BuildContext context,
    String status,
    Stream<QuerySnapshot> appointmentsStream,
  ) {
    // Check if it's the first time in the 'approve' tab
    if (status == 'approve' && isFirstTimeInApproveTab) {
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
              final date = appointment['date'] as Timestamp;
              final startTime = appointment['startTime'] as String;
              final endTime = appointment['endTime'] as String;

              return GestureDetector(
                onTap: status == 'approve'
                    ? () {
                        // Handle 'approve' tab item click
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffGeneratePassPage(
                              context: context,
                              date: date.toDate(),
                              startTime: startTime,
                              endTime: endTime,
                              userName: appointment['userName'],
                              userPhone: appointment['userPhone'],
                              userUID: appointment['userUID'],
                            ),
                          ),
                        );
                      }
                    : null, // Disable onTap for 'disapprove' tab
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
                    title: Text('Date: ${_formatDate(date.toDate())}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time: $startTime - $endTime'),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy  (EEEE)');
    return formatter.format(dateTime);
  }
}
