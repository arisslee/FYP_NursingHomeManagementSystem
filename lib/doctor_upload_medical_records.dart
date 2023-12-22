import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_menu_medical_records.dart'; // Import the DoctorMedicalRecordsPage

class DoctorMedicalDetailPage extends StatefulWidget {
  final String documentId;

  DoctorMedicalDetailPage({required this.documentId});

  @override
  _DoctorMedicalDetailPageState createState() =>
      _DoctorMedicalDetailPageState();
}

class _DoctorMedicalDetailPageState extends State<DoctorMedicalDetailPage> {
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController prescriptionsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String residentName = '';
  String profilePictureUrl = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, bool> _errors = {
    'temperature': false,
    'bloodPressure': false,
    'heartRate': false,
    'symptoms': false,
    'diagnosis': false,
    'prescriptions': false,
    'notes': false,
  };

  @override
  void initState() {
    super.initState();
    fetchResidentData();
  }

  void fetchResidentData() async {
    final DocumentSnapshot residentData = await FirebaseFirestore.instance
        .collection('resident')
        .doc(widget.documentId)
        .get();

    if (residentData.exists) {
      setState(() {
        residentName = residentData['name'];
        profilePictureUrl = residentData['profilePictureUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Record'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                if (residentName.isNotEmpty && profilePictureUrl.isNotEmpty)
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePictureUrl),
                          radius: 40.0,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          residentName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20.0),
                Divider(),
                SizedBox(height: 20.0),
                Text(
                  'Vital Signs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Temperature (°C)',
                  Icons.thermostat,
                  temperatureController,
                  'temperature',
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Blood Pressure',
                  Icons.favorite,
                  bloodPressureController,
                  'bloodPressure',
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Heart Rate (bpm)',
                  Icons.favorite,
                  heartRateController,
                  'heartRate',
                ),
                SizedBox(height: 20.0),
                Divider(),
                SizedBox(height: 20.0),
                Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Symptoms',
                  Icons.warning,
                  symptomsController,
                  'symptoms',
                  maxLines: 3,
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Diagnosis',
                  Icons.local_hospital,
                  diagnosisController,
                  'diagnosis',
                  maxLines: 3,
                ),
                buildTextField(
                  'Prescriptions',
                  Icons.description,
                  prescriptionsController,
                  'prescriptions',
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                Divider(),
                SizedBox(height: 20.0),
                Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10.0),
                buildTextField(
                  'Notes',
                  Icons.notes,
                  notesController,
                  'notes',
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Create a map with the data to be uploaded
                        Map<String, dynamic> medicalRecordData = {
                          'temperature':
                              double.parse(temperatureController.text),
                          'bloodPressure': bloodPressureController.text,
                          'heartRate': int.parse(heartRateController.text),
                          'symptoms': symptomsController.text,
                          'diagnosis': diagnosisController.text,
                          'prescriptions': prescriptionsController.text,
                          'notes': notesController.text,
                          'residentName': residentName,
                        };

                        // Get the current date and time
                        DateTime now = DateTime.now();
                        medicalRecordData['uploadDate'] = now;

                        // Add the data to the "medical_record" collection with an auto-generated document ID
                        FirebaseFirestore.instance
                            .collection('medical_record')
                            .add(medicalRecordData)
                            .then((value) {
                          // Data added successfully
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Record uploaded !'),
                            ),
                          );

                          // Navigate back to DoctorMedicalRecordsPage
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          // Error occurred while adding data
                          // Handle the error as needed
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text('Upload Medical Record'),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    String fieldName, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.red,
            ),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errors[fieldName]! ? Colors.red : Colors.black,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errors[fieldName]! ? Colors.red : Colors.black,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
            errorText: _errors[fieldName]! ? 'This field is required' : null,
          ),
          onChanged: (_) {
            if (_errors[fieldName]!) {
              setState(() {
                _errors[fieldName] = false;
              });
            }
          },
          validator: (value) {
            if (value!.isEmpty) {
              setState(() {
                _errors[fieldName] = true;
              });
              return 'This field is required';
            }
            if (fieldName == 'temperature') {
              final temperature = double.tryParse(value);
              if (temperature == null || temperature.isNaN) {
                setState(() {
                  _errors[fieldName] = true;
                });
                return 'Invalid temperature input';
              }
            }
            // Add similar validation for other fields
            return null;
          },
        ),
        SizedBox(height: 12.0),
      ],
    );
  }
}
