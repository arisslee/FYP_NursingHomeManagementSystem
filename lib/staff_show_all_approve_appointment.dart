import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaffShowAllApproveAppointmentPage extends StatefulWidget {
  @override
  _StaffShowAllApproveAppointmentPageState createState() =>
      _StaffShowAllApproveAppointmentPageState();
}

class _StaffShowAllApproveAppointmentPageState
    extends State<StaffShowAllApproveAppointmentPage> {
  // Stream to listen for changes in the 'approve_appointment' collection
  late Stream<QuerySnapshot> approveAppointmentsStream;

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for changes in the 'approve_appointment' collection
    approveAppointmentsStream = FirebaseFirestore.instance
        .collection('approve_appointment')
        .orderBy('date')
        .snapshots(); // Initially, show all appointments ordered by date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Appointments List'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context); // Call function to show date picker
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: approveAppointmentsStream,
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

          // Extract the documents from the snapshot and sort them by date
          List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (selectedDate != null) {
            // If a date is selected, filter the documents based on the selected date
            documents = documents
                .where((doc) =>
                    _formatDate(doc['date'].toDate()) ==
                    _formatDate(selectedDate!))
                .toList();
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              // Extract fields from the document data
              final date = documents[index]['date'] as Timestamp;
              final startTime = documents[index]['startTime'] as String;
              final endTime = documents[index]['endTime'] as String;
              final userName = documents[index]['userName'] as String;
              final userPhone = documents[index]['userPhone'] as String;
              final userUID = documents[index]['userUID'] as String;

              // Check if it's the first item or the date has changed
              bool showDateSeparator = index == 0 ||
                  _formatDate(date.toDate()) !=
                      _formatDate(documents[index - 1]['date'].toDate());

              return Column(
                children: [
                  if (showDateSeparator)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.grey.withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          '${_formatDate(date.toDate())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // Center align the text
                        ),
                      ),
                    ),
                  Card(
                    elevation: 4, // Add elevation for shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set border radius
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Time: $startTime - $endTime'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User: $userName'),
                          Text('Phone: $userPhone'),
                          Text('User UID: $userUID'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy  (EEEE)');
    return formatter.format(dateTime);
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        selectedDate = pickedDate;
      });
      // Update the stream with a query for the selected date
      approveAppointmentsStream = FirebaseFirestore.instance
          .collection('approve_appointment')
          .where('date', isEqualTo: Timestamp.fromDate(pickedDate))
          .orderBy('date')
          .snapshots();
    }
  }
}
