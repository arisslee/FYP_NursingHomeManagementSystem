import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:printing/printing.dart' as pdfPrinting;

class ViewMedicalRecord extends StatefulWidget {
  final String documentId;
  final String? residentName;

  ViewMedicalRecord({required this.documentId, this.residentName});

  @override
  _ViewMedicalRecordState createState() => _ViewMedicalRecordState();
}

class _ViewMedicalRecordState extends State<ViewMedicalRecord> {
  late Future<void> medicalRecordData;

  String? residentName;
  DateTime? recordDate;
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController prescriptionsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the Future once, so it's not recreated on every build
    medicalRecordData = fetchMedicalRecordData();
  }

  Future<void> fetchMedicalRecordData() async {
    try {
      // Reference to the 'medical_record' collection
      final medicalRecordCollection =
          FirebaseFirestore.instance.collection('medical_record');

      // Get the document snapshot based on the documentId
      DocumentSnapshot documentSnapshot =
          await medicalRecordCollection.doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        // Explicitly cast data to Map<String, dynamic>
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        // Update residentName and text controllers with fetched data
        residentName = data?['residentName']?.toString() ?? '';
        recordDate = (data?['uploadDate'] as Timestamp?)?.toDate();
        temperatureController.text = data?['temperature']?.toString() ?? '';
        bloodPressureController.text = data?['bloodPressure']?.toString() ?? '';
        heartRateController.text = data?['heartRate']?.toString() ?? '';
        symptomsController.text = data?['symptoms']?.toString() ?? '';
        diagnosisController.text = data?['diagnosis']?.toString() ?? '';
        prescriptionsController.text = data?['prescriptions']?.toString() ?? '';
        notesController.text = data?['notes']?.toString() ?? '';
      } else {
        // Handle the case where the document doesn't exist
        print('No medical record found for document ID: ${widget.documentId}');
      }
    } catch (e, stackTrace) {
      // Handle errors
      print('Error fetching medical record data: $e\n$stackTrace');
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => _buildPdfContent(context),
      ),
    );

    // Save the PDF to a Uint8List
    final Uint8List pdfBytes = await pdf.save();

    // Show the preview using PdfPreview
    await pdfPrinting.Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  pw.Widget _buildPdfContent(pw.Context context) {
    // Build the content of the PDF here
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Container to display resident name, upload date, and document ID
        pw.Container(
          width: 360.0,
          padding: pw.EdgeInsets.all(16.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
            borderRadius: pw.BorderRadius.circular(8.0),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Document ID: ${widget.documentId}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 18.0),
              pw.Text(
                'Resident Name: ${residentName ?? "N/A"}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 18.0),
              pw.Text(
                'Upload Date: ${recordDate?.toLocal().toString().split(' ')[0] ?? "N/A"}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20.0),
        // Display other medical record details based on your data structure
        _buildSection(
          'Vital Signs',
          [
            _buildTextField(
              'Temperature (°C)',
              'temperature',
              temperatureController.text,
            ),
            _buildTextField(
              'Blood Pressure',
              'bloodPressure',
              bloodPressureController.text,
            ),
            _buildTextField(
              'Heart Rate (bpm)',
              'heartRate',
              heartRateController.text,
            ),
          ],
        ),
        _buildDivider(),
        _buildSection(
          'Patient Information',
          [
            _buildTextField(
              'Symptoms',
              'symptoms',
              symptomsController.text,
              maxLines: 3,
            ),
            _buildTextField(
              'Diagnosis',
              'diagnosis',
              diagnosisController.text,
              maxLines: 3,
            ),
            _buildTextField(
              'Prescriptions',
              'prescriptions',
              prescriptionsController.text,
              maxLines: 3,
            ),
          ],
        ),
        _buildDivider(),
        _buildSection(
          'Additional Notes',
          [
            _buildTextField(
              'Notes',
              'notes',
              notesController.text,
              maxLines: 3,
            ),
          ],
        ),
        pw.SizedBox(height: 20.0),
      ],
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> fields) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 10.0),
        ...fields,
        pw.SizedBox(height: 10.0),
      ],
    );
  }

  pw.Widget _buildDivider() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 20.0),
      ],
    );
  }

  pw.Widget _buildTextField(String label, String fieldName, String value,
      {int maxLines = 1}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold, // Make the text bold
              ),
            ),
          ],
        ),
        pw.Text(
          value,
          maxLines: maxLines,
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 12.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _generateAndDownloadPDF,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder<void>(
            future: medicalRecordData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Display the UI with the fetched data
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    // Container to display resident name, upload date, and document ID
                    Container(
                      width: 360.0, // Specify the width as per your requirement
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document ID:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${widget.documentId}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 18.0),
                          Text(
                            'Resident Name:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${residentName ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 18.0),
                          Text(
                            'Upload Date:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${recordDate?.toLocal().toString().split(' ')[0] ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // Display other medical record details based on your data structure
                    buildSection(
                      'Vital Signs',
                      [
                        buildTextField(
                          'Temperature (°C)',
                          Icons.thermostat,
                          temperatureController,
                          'temperature',
                        ),
                        buildTextField(
                          'Blood Pressure',
                          Icons.favorite,
                          bloodPressureController,
                          'bloodPressure',
                        ),
                        buildTextField(
                          'Heart Rate (bpm)',
                          Icons.favorite,
                          heartRateController,
                          'heartRate',
                        ),
                      ],
                    ),
                    buildDivider(),
                    buildSection(
                      'Patient Information',
                      [
                        buildTextField(
                          'Symptoms',
                          Icons.warning,
                          symptomsController,
                          'symptoms',
                          maxLines: 3,
                        ),
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
                      ],
                    ),
                    buildDivider(),
                    buildSection(
                      'Additional Notes',
                      [
                        buildTextField(
                          'Notes',
                          Icons.notes,
                          notesController,
                          'notes',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ],
                );
              } else if (snapshot.hasError) {
                // Handle error state
                return Center(
                  child: Text('Error fetching medical record data'),
                );
              } else {
                // Show a loading indicator while fetching data
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10.0),
        ...fields,
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget buildDivider() {
    return Column(
      children: [
        Divider(),
        SizedBox(height: 20.0),
      ],
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
          readOnly: true, // Make it read-only for viewing
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.0),
      ],
    );
  }
}
