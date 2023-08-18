import 'package:flutter/material.dart';

class MedicalRecordsPage extends StatefulWidget {
  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  List<LabResult> _filteredLabResults = List.from(labResults);
  bool _sortAscending = true;

  void _sortResults() {
    setState(() {
      _filteredLabResults.sort((a, b) {
        if (_sortAscending) {
          return a.testDate.compareTo(b.testDate);
        } else {
          return b.testDate.compareTo(a.testDate);
        }
      });
      _sortAscending = !_sortAscending;
    });
  }

  void _filterResults(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredLabResults = List.from(labResults);
      } else {
        _filteredLabResults = labResults
            .where((result) => result.testName
                .toLowerCase()
                .contains(searchTerm.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: John Doe'),
                        Text('Date of Birth: January 15, 1985'),
                        Text('Gender: Male'),
                        Text('Blood Type: A+'),
                        // Add more patient information here
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Medical History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Diagnosis: Hypertension'),
                        Text('Treatment: Medication, Diet Control'),
                        Text('Date: July 10, 2023'),
                        // Add more medical history entries here
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Lab Results',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredLabResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                            'Test: ${_filteredLabResults[index].testName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Date: ${_filteredLabResults[index].testDate}'),
                            Text(
                                'Value: ${_filteredLabResults[index].testValue}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Add more sections for other types of medical records
            ],
          ),
        ),
      ),
    );
  }
}

class LabResult {
  final String testName;
  final String testDate;
  final String testValue;

  LabResult(this.testName, this.testDate, this.testValue);
}

// Sample lab results data
List<LabResult> labResults = [
  LabResult('Blood Pressure', 'July 15, 2023', '120/80 mmHg'),
  LabResult('Cholesterol', 'July 20, 2023', '200 mg/dL'),
  // Add more lab results entries here
];
