import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'doctor_view_medical_records.dart';

class MedicalCalendarPage extends StatefulWidget {
  final String residentName;

  MedicalCalendarPage({required this.residentName});

  @override
  _MedicalCalendarPageState createState() => _MedicalCalendarPageState();
}

class _MedicalCalendarPageState extends State<MedicalCalendarPage> {
  List<MedicalRecord> medicalRecords = [];
  DateTime selectedDate = DateTime.now(); // Default date

  @override
  void initState() {
    super.initState();
    fetchMedicalRecords();
  }

  void fetchMedicalRecords() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('medical_record')
              .where('residentName', isEqualTo: widget.residentName)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Convert documents to MedicalRecord objects
        medicalRecords = querySnapshot.docs.map((doc) {
          return MedicalRecord.fromMap(
            doc.data(),
            doc.id, // Pass the document ID
          );
        }).toList();

        // Sort the medical records by uploadDate in ascending order
        medicalRecords.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));

        setState(() {});
      } else {
        print('No medical records found for ${widget.residentName}');
      }
    } catch (e, stackTrace) {
      print('Error fetching medical records: $e\n$stackTrace');
    }
  }

  void sortMedicalRecords(int index) {
    setState(() {
      switch (index) {
        case 0:
          // Sort by upload date in ascending order
          medicalRecords.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
          break;
        case 1:
          // Sort by upload date in descending order
          medicalRecords.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
          break;
        // Add more cases for additional sorting options if needed
      }
    });
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      print('Selected date: $picked');
      setState(() {
        selectedDate = picked;
      });

      // Fetch and display medical records for the selected date
      fetchMedicalRecordsForDate();
    } else {
      // Handle case where user canceled date selection
      // You can choose to show a message or take other actions
    }
  }

  void fetchMedicalRecordsForDate() async {
    try {
      DateTime startDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endDate = startDate.add(Duration(days: 1));

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('medical_record')
              .where('residentName', isEqualTo: widget.residentName)
              .where('uploadDate', isGreaterThanOrEqualTo: startDate)
              .where('uploadDate', isLessThan: endDate)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Convert documents to MedicalRecord objects
        medicalRecords = querySnapshot.docs.map((doc) {
          return MedicalRecord.fromMap(
            doc.data(),
            doc.id, // Pass the document ID
          );
        }).toList();

        // Sort the medical records by uploadDate in ascending order
        medicalRecords.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));

        setState(() {});
      } else {
        // No medical records found for the selected date
        medicalRecords.clear();

        // Show a SnackBar with the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No medical records found for the selected date'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching medical records: $e\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: medicalRecords.isEmpty
          ? Center(child: Text('No medical records found.'))
          : ListView.builder(
              itemCount: medicalRecords.length,
              itemBuilder: (context, index) {
                return MedicalRecordCard(medicalRecord: medicalRecords[index]);
              },
            ),
    );
  }
}

class MedicalRecord {
  final String residentName;
  final DateTime uploadDate;
  final String documentId;

  MedicalRecord({
    required this.residentName,
    required this.uploadDate,
    required this.documentId,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return MedicalRecord(
      residentName: map['residentName'] as String,
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      documentId: documentId,
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord medicalRecord;

  MedicalRecordCard({required this.medicalRecord});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMd().format(medicalRecord.uploadDate);

    return GestureDetector(
      onTap: () {
        // Navigate to DoctorViewMedicalRecordsPage with the selected medical record
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DoctorViewMedicalRecords(
            medicalRecord: medicalRecord,
            selectedDate: medicalRecord.uploadDate,
            residentName: medicalRecord.residentName,
          ),
        ));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text('Resident: ${medicalRecord.residentName}'),
          subtitle: Text('Upload Date: $formattedDate'),
        ),
      ),
    );
  }
}
