import 'doctor_medical_listview.dart'; // Import the file where MedicalRecord is defined if it's not in the same file
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as pdfPrinting;
import 'dart:typed_data';
import 'doctor_view_medical_records.dart';

class DoctorViewMedicalRecords extends StatefulWidget {
  final MedicalRecord medicalRecord;
  final DateTime selectedDate;
  final String? residentName;

  DoctorViewMedicalRecords({
    required this.medicalRecord,
    required this.selectedDate,
    this.residentName,
  });

  @override
  _DoctorViewMedicalRecordsState createState() =>
      _DoctorViewMedicalRecordsState();
}

class _DoctorViewMedicalRecordsState extends State<DoctorViewMedicalRecords> {
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController prescriptionsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  late bool isEditMode;
  String? documentId;

  @override
  void initState() {
    super.initState();
    isEditMode = false;
    // Fetch medical record data when the widget is initialized
    fetchMedicalRecordData();
  }

  void fetchMedicalRecordData() async {
    try {
      // Convert selectedDate to a Timestamp
      Timestamp selectedTimestamp = Timestamp.fromDate(widget.selectedDate);

      // Query to get medical record data based on residentName and selectedDate
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('medical_record')
              .where('residentName', isEqualTo: widget.residentName)
              .where('uploadDate', isEqualTo: selectedTimestamp)
              .get();

      print('Selected Timestamp: $selectedTimestamp');

      // Check if there's any data
      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        print('Fetched data: $data');
        // Update text controllers with fetched data
        temperatureController.text = data['temperature'].toString();
        bloodPressureController.text = data['bloodPressure'].toString();
        heartRateController.text = data['heartRate'].toString();
        symptomsController.text = data['symptoms'].toString();
        diagnosisController.text = data['diagnosis'].toString();
        prescriptionsController.text = data['prescriptions'].toString();
        notesController.text = data['notes'].toString();

        // Get the document ID
        documentId = querySnapshot.docs.first.id;

        // Update the UI with the document ID
        setState(() {});
      } else {
        // Handle the case where no data is found
        print('No medical record found for ${widget.residentName}');
      }
    } catch (e, stackTrace) {
      // Handle errors
      print('Error fetching medical record data: $e\n$stackTrace');
    }
  }

  Future<void> _generateAndPreviewPDF() async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add content to the first page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => _buildFirstPage(context),
      ),
    );

    // Add content to the second page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => _buildSecondPage(context),
      ),
    );

    // Save the PDF to a List<int>
    final List<int> pdfBytes = await pdf.save();

    // Convert List<int> to Uint8List
    final Uint8List uint8List = Uint8List.fromList(pdfBytes);

    // Show the preview
    await pdfPrinting.Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => uint8List,
    );
  }

  pw.Widget _buildFirstPage(pw.Context context) {
    // Build content for the first page here
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20.0),
        pw.Container(
          width: 360.0, // Specify the width as per your requirement
          padding: pw.EdgeInsets.all(16.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
            borderRadius: pw.BorderRadius.circular(8.0),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (documentId != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Document ID:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      '${widget.medicalRecord.documentId ?? documentId}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 18.0),
              if (widget.residentName != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Resident Name:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      '${widget.residentName}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 18.0),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Record Date:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Text(
                    '${widget.selectedDate.toLocal().toString().split(' ')[0]}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20.0),
        _buildDivider(),
        _buildSection(
          'Vital Signs',
          [
            _buildTextField(
              'Temperature (°C)',
              Icons.thermostat,
              temperatureController,
              'temperature',
            ),
            _buildTextField(
              'Blood Pressure',
              Icons.favorite,
              bloodPressureController,
              'bloodPressure',
            ),
            _buildTextField(
              'Heart Rate (bpm)',
              Icons.favorite,
              heartRateController,
              'heartRate',
            ),
          ],
        ),
        _buildDivider(),
        _buildSection(
          'Patient Information',
          [
            _buildTextField(
              'Symptoms',
              Icons.warning,
              symptomsController,
              'symptoms',
              maxLines: 3,
            ),
            _buildTextField(
              'Diagnosis',
              Icons.local_hospital,
              diagnosisController,
              'diagnosis',
              maxLines: 3,
            ),
            _buildTextField(
              'Prescriptions',
              Icons.description,
              prescriptionsController,
              'prescriptions',
              maxLines: 3,
            ),
          ],
        ),
        pw.SizedBox(height: 20.0),
      ],
    );
  }

  pw.Widget _buildSecondPage(pw.Context context) {
    // Build content for the second page here
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Additional Notes',
          [
            _buildTextField(
              'Notes',
              Icons.notes,
              notesController,
              'notes',
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
        pw.SizedBox(height: 20.0),
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

  pw.Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    String fieldName, {
    int maxLines = 1,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.Text(
          controller.text,
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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _generateAndPreviewPDF,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              // Display Record Date, Resident Name, and Document ID
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
                        if (documentId != null)
                          Column(
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
                              SizedBox(height: 8.0),
                              Text(
                                '${widget.medicalRecord.documentId ?? documentId}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 18.0),
                        if (widget.residentName != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resident Name:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '${widget.residentName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 18.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Record Date:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${widget.selectedDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ])),
              SizedBox(height: 20.0),
              buildDivider(),
              buildSection(
                'Vital Signs',
                [
                  buildTextField(
                    'Temperature (°C)',
                    Icons.thermostat,
                    temperatureController,
                    'temperature',
                    isEditable: isEditMode,
                  ),
                  buildTextField(
                    'Blood Pressure',
                    Icons.favorite,
                    bloodPressureController,
                    'bloodPressure',
                    isEditable: isEditMode,
                  ),
                  buildTextField(
                    'Heart Rate (bpm)',
                    Icons.favorite,
                    heartRateController,
                    'heartRate',
                    isEditable: isEditMode,
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
                    isEditable: isEditMode,
                  ),
                  buildTextField(
                    'Diagnosis',
                    Icons.local_hospital,
                    diagnosisController,
                    'diagnosis',
                    maxLines: 3,
                    isEditable: isEditMode,
                  ),
                  buildTextField(
                    'Prescriptions',
                    Icons.description,
                    prescriptionsController,
                    'prescriptions',
                    maxLines: 3,
                    isEditable: isEditMode,
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
                    isEditable: isEditMode,
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              if (isEditMode)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press, e.g., save changes
                      print('Save Changes pressed');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text('Save Changes'),
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
    bool isEditable = false,
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
          readOnly: !isEditable,
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
