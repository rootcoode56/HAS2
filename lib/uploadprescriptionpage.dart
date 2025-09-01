import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class UploadPrescriptionPage extends StatefulWidget {
  const UploadPrescriptionPage({super.key});

  @override
  State<UploadPrescriptionPage> createState() => _UploadPrescriptionPageState();
}

class _UploadPrescriptionPageState extends State<UploadPrescriptionPage> {
  final TextEditingController doctorController = TextEditingController();
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];

  Map<String, dynamic>? selectedDoctor;
  File? selectedFile;

  @override
  void initState() {
    super.initState();
    loadDoctorNames();
    doctorController.addListener(_filterDoctors);
  }

  Future<void> loadDoctorNames() async {
    final jsonString = await rootBundle.loadString('assets/data/DocsInfo.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      allDoctors =
          jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
    });
  }

  void _filterDoctors() {
    final query = doctorController.text.toLowerCase();
    setState(() {
      filteredDoctors = allDoctors
          .where((doc) => doc['Name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Upload Prescription')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Doctor name input
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(
                  labelText: 'Enter Doctor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Result box
              if (filteredDoctors.isNotEmpty && selectedDoctor == null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(filteredDoctors[index]['Name']),
                      onTap: () {
                        setState(() {
                          selectedDoctor = filteredDoctors[index];
                          doctorController.text = selectedDoctor!['Name'];
                          filteredDoctors.clear();
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Show doctor details
              if (selectedDoctor != null) ...[
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDoctor!['Name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(selectedDoctor!['Specialist'] ?? ''),
                        const SizedBox(height: 5),
                        Text(selectedDoctor!['Speciality'] ?? ''),
                        const SizedBox(height: 5),
                        Text(selectedDoctor!['Chamber & Location'] ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // File upload section
                if (selectedFile != null)
                  Text('Selected: ${selectedFile!.path.split('/').last}')
                else
                  const Text('No file selected'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickFile,
                  child: const Text('Choose Prescription File'),
                ),
              ],
            ],
          ),
        ),
      );
}
