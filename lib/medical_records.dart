import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_medical_record.dart';

class MedicalRecordsPage extends StatefulWidget {
  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  late User _user; // Variable to hold the current user
  List<Map<String, dynamic>> linkedResidentsData = [];
  List<Map<String, dynamic>> medicalRecordsData = [];
  bool isLoading = false;
  DateTime? selectedDate; // Variable to store the selected date

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    // Retrieve the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });
      _fetchLinkedResidents();
    } else {
      // Handle the case where the user is not logged in
      // You may want to navigate to the login screen or take appropriate action
    }
  }

  Future<void> _fetchLinkedResidents() async {
    try {
      final linkResidentUserCollection =
          FirebaseFirestore.instance.collection('link_resident_user');

      // Query 'link_resident_user' collection to find documents where selectedUsers contain user UID
      final querySnapshot = await linkResidentUserCollection.get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          linkedResidentsData = querySnapshot.docs
              .where((doc) => (doc['selectedUsers'] as List)
                  .any((user) => user['userId'] == _user.uid))
              .map((doc) {
            return {
              'residentId': doc['residentId'],
              'residentName': doc['residentName'],
            };
          }).toList();
        });

        // Fetch medical records data after retrieving linked residents
        _fetchMedicalRecords();
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching linked residents: $e');
    }
  }

  Future<void> _fetchMedicalRecords() async {
    try {
      final medicalRecordsCollection =
          FirebaseFirestore.instance.collection('medical_record');

      for (final residentData in linkedResidentsData) {
        Query query = medicalRecordsCollection.where(
          'residentName',
          isEqualTo: residentData['residentName'],
        );

        if (selectedDate != null) {
          // If a date is selected, filter records by that date
          DateTime startDate = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
          );
          DateTime endDate = startDate.add(Duration(days: 1));

          query = query
              .where(
                'uploadDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'uploadDate',
                isLessThan: Timestamp.fromDate(endDate),
              );
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            medicalRecordsData = querySnapshot.docs
                .map((doc) => {
                      'uploadDate': _formatTimestamp(doc['uploadDate']),
                      'documentId': doc.id, // Added documentId
                      // Add more fields if needed
                    })
                .toList();

            // Sort the list by 'uploadDate' in ascending order
            medicalRecordsData.sort(
              (a, b) => DateTime.parse(a['uploadDate'])
                  .compareTo(DateTime.parse(b['uploadDate'])),
            );
          });

          if (medicalRecordsData.isEmpty) {
            // Show a Snackbar when no medical records are found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No medical records found for the selected date'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching medical records: $e');
    } finally {
      // Set isLoading to false when data fetching is complete
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the date as "yyyy-MM-dd"
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    return formattedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Format the selected date before setting it and printing
      String formattedDate = _formatTimestamp(Timestamp.fromDate(pickedDate));
      print('Selected date: $formattedDate');

      setState(() {
        selectedDate = pickedDate;
      });

      // Fetch medical records for the selected date
      _fetchMedicalRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                if (linkedResidentsData.isNotEmpty)
                  Column(
                    children: linkedResidentsData.map((residentData) {
                      return GestureDetector(
                        onTap: () {
                          // Handle tap, e.g., navigate to a detailed view
                          _showMedicalRecordDetails(residentData);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 201, 183, 251),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Linked Resident ID: ${residentData['residentId']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Resident Name: ${residentData['residentName']}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (linkedResidentsData.isEmpty)
                  Text('No linked residents found'),
              ],
            ),
          ),
          Divider(
            // Add a horizontal line below the container
            color: Colors.black,
            thickness: 0.5,
          ),
          isLoading
              ? CircularProgressIndicator()
              : medicalRecordsData.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                        itemCount: medicalRecordsData.length,
                        separatorBuilder: (context, index) => SizedBox
                            .shrink(), // Return an empty SizedBox for non-month items

                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Handle tap, e.g., show all data of the document
                              _showDocumentDetails(medicalRecordsData[index]);
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
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
                                title: Text(
                                  'Record Date: ${medicalRecordsData[index]['uploadDate']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Add more fields to display if needed
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Text('No medical records found'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the press event, e.g., show a calendar or navigate to a calendar page
          _selectDate(context);
        },
        child: Icon(Icons.calendar_today),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showMedicalRecordDetails(Map<String, dynamic> residentData) {
    // Handle tap on linked resident item, e.g., navigate to a detailed view
  }

  void _showDocumentDetails(Map<String, dynamic> documentData) {
    // Handle tap on medical record item, e.g., show all data of the document
    String documentId = documentData['documentId'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMedicalRecord(documentId: documentId),
      ),
    );
  }
}
