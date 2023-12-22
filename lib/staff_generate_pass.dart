import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:typed_data';

class StaffGeneratePassPage extends StatelessWidget {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String userName;
  final String userPhone;
  final String userUID;
  final BuildContext context;

  Future<Uint8List> _loadAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  } // Add this line

  StaffGeneratePassPage({
    required this.context, // Add this line
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.userName,
    required this.userPhone,
    required this.userUID,
  });

  Future<void> _printVisitorPass() async {
    final pdf = pw.Document();

    final checkmarkImage =
        pw.MemoryImage(await _loadAsset('assets/checkmark.png'));

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                '--- Visitor Pass ---',
                style: pw.TextStyle(
                  fontSize: 24.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 30.0),
            _buildSectionTitlePdf('Visitor Detail'),
            _buildPassDetailPdf('User ID', '$userUID', context),
            _buildPassDetailPdf('User', '$userName', context),
            _buildPassDetailPdf('Phone', '$userPhone', context),
            pw.SizedBox(height: 10.0),
            pw.Divider(
              height: 20,
              thickness: 2,
            ),
            pw.SizedBox(height: 10.0),
            _buildSectionTitlePdf('Appointment Detail'),
            _buildPassDetailPdf('Date', '${_formatDate(date)}', context),
            _buildPassDetailPdf('Time', '$startTime - $endTime', context),
            pw.SizedBox(height: 10.0),
            pw.Divider(
              height: 20,
              thickness: 2,
            ),
            pw.SizedBox(height: 10.0),
            _buildSectionTitlePdf('Approval Status'),
            pw.SizedBox(height: 30.0),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  width: 48.0,
                  height: 48.0,
                  child: pw.Image(checkmarkImage),
                ),
                pw.SizedBox(height: 10.0),
                pw.Text(
                  'Approved',
                  style: pw.TextStyle(
                    fontSize: 24.0,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(Colors.green.value),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Pass'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _printVisitorPass,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '【 Visitor Pass 】',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoMono',
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                _buildSectionTitle('Visitor Detail'),
                _buildPassDetail('User ID', '$userUID'),
                _buildPassDetail('User', '$userName'),
                _buildPassDetail('Phone', '$userPhone'),
                SizedBox(height: 10.0),
                Divider(
                  height: 20,
                  thickness: 2,
                ),
                SizedBox(height: 10.0),
                _buildSectionTitle('Appointment Detail'),
                _buildPassDetail('Date', '${_formatDate(date)}'),
                _buildPassDetail('Time', '$startTime - $endTime'),
                SizedBox(height: 10.0),
                Divider(
                  height: 20,
                  thickness: 2,
                ),
                SizedBox(height: 10.0),
                _buildSectionTitle('Approval Status'),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48.0,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Approved',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter =
        DateFormat('dd MMMM yyyy'); // You can adjust the format as needed
    return formatter.format(dateTime);
  }

  Widget _buildPassDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  pw.Widget _buildPassDetailPdf(
      String label, String value, pw.Context context) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          pw.SizedBox(width: 8.0),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitlePdf(String title) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8.0),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18.0,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
}
