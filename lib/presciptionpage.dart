import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

// For picking PDF
import 'uploadprescriptionpage.dart'; // New page

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  // Sample prescription data
  final List<Map<String, dynamic>> prescriptions = [
    {
      'doctorName': 'Prof. Dr. Syed Ali Ahsan',
      'date': '2024-08-05',
      'medicines': ['Paracetamol 500mg', 'Omeprazole 20mg', 'Vitamin D3'],
      'instructions': 'Take after meals, 3 times daily',
    },
    {
      'doctorName': 'Dr. Md. Habibur Rahman',
      'date': '2024-08-01',
      'medicines': ['Metformin 500mg', 'Atorvastatin 20mg'],
      'instructions': 'Take before meals, 2 times daily',
    },
  ];

  // Store uploaded prescriptions (PDFs)
  final List<Map<String, dynamic>> uploadedPrescriptions = [];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
          ),
          child: Stack(
            children: [
              // Background blur
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/Prescription.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'Prescription',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        'Prescription History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  children: [
                                    // Default prescriptions
                                    ...prescriptions.map(
                                      _buildPrescriptionTile,
                                    ),
                                    // Uploaded prescriptions
                                    ...uploadedPrescriptions.map(
                                      _buildUploadedTile,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Upload Prescription Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Prescription'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UploadPrescriptionPage(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                uploadedPrescriptions.add(result);
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Small Go Back Button bottom left
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Go Back',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPrescriptionTile(Map<String, dynamic> prescription) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prescription['doctorName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${prescription['date']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  if (prescription['medicines'] != null)
                    Text(
                      'Medicines: ${prescription['medicines'].join(', ')}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.green),
              onPressed: () => _downloadPrescription(prescription),
            ),
          ],
        ),
      );

  Widget _buildUploadedTile(Map<String, dynamic> upload) => ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(
          upload['doctorName'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          upload['fileName'],
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        onTap: () => OpenFile.open(upload['filePath']),
      );

  Future<void> _downloadPrescription(Map<String, dynamic> prescription) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating PDF for ${prescription['doctorName']}...'),
        backgroundColor: Colors.green.withOpacity(0.8),
      ),
    );

    try {
      final file = await _generateAndSavePDF(prescription);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved PDF at: ${file.path}'),
          backgroundColor: Colors.green.withOpacity(0.8),
        ),
      );
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<File> _generateAndSavePDF(Map<String, dynamic> prescription) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Prescription',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Doctor: ${prescription['doctorName']}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.Text(
                'Date: ${prescription['date']}',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/prescription_${prescription['doctorName'].replaceAll(' ', '_')}_${prescription['date']}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
