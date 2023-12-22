import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_upload_medical_records.dart';
import 'doctor_medical_listview.dart';
import 'doctor_view_medical_records.dart';

class DoctorMedicalRecordsPage extends StatefulWidget {
  @override
  _DoctorMedicalRecordsState createState() => _DoctorMedicalRecordsState();
}

class _DoctorMedicalRecordsState extends State<DoctorMedicalRecordsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Resident>>(
        future: fetchResidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Text('No residents found.');
          } else {
            final residents = snapshot.data!;

            return ListView.builder(
              itemCount: residents.length,
              itemBuilder: (context, index) {
                final resident = residents[index];

                return ResidentCard(
                  name: resident.name,
                  profilePictureUrl: resident.profilePicture,
                  age: resident.age,
                  documentId: resident.documentId,
                  onUploadMedicalRecord: () {
                    // Navigate to DoctorMedicalDetailPage with the documentId
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DoctorMedicalDetailPage(
                        documentId: resident.documentId,
                      ),
                    ));
                  },
                  onCalendarIconPressed: () {
                    // Navigate to MedicalCalendarPage with resident name
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MedicalCalendarPage(
                        residentName: resident.name,
                      ),
                    ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Resident {
  final String name;
  final String profilePicture;
  final int age;
  final String documentId;

  Resident({
    required this.name,
    required this.profilePicture,
    required this.age,
    required this.documentId,
  });
}

class ResidentCard extends StatelessWidget {
  final String name;
  final String profilePictureUrl;
  final int age;
  final String documentId;
  final VoidCallback onUploadMedicalRecord;
  final VoidCallback onCalendarIconPressed; // Add this callback

  ResidentCard({
    required this.name,
    required this.profilePictureUrl,
    required this.age,
    required this.documentId,
    required this.onUploadMedicalRecord,
    required this.onCalendarIconPressed, // Initialize the callback in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profilePictureUrl),
        ),
        title: Text(name),
        subtitle: Text('Age: $age'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                // Pass the resident's name when navigating to MedicalCalendarPage
                onCalendarIconPressed(); // Corrected this line
              },
            ),
            IconButton(
              icon: Icon(Icons.upload),
              onPressed: onUploadMedicalRecord,
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Resident>> fetchResidents() async {
  final residents = <Resident>[];
  final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('resident').get();

  for (final doc in querySnapshot.docs) {
    final name = doc['name'] as String;
    final profilePicture = doc['profilePictureUrl'] as String;
    final age = doc['age'] as int;
    final documentId = doc.id;
    final resident = Resident(
      name: name,
      profilePicture: profilePicture,
      age: age,
      documentId: documentId,
    );
    residents.add(resident);
  }

  return residents;
}

void main() {
  runApp(MaterialApp(
    home: DoctorMedicalRecordsPage(),
  ));
}
