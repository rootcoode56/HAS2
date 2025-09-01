import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DoctorListPage());
}

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();

  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];

  final double _resultBoxWidth = 400;
  final double _resultBoxHeight = 500;

  String? extractPhone(String text) {
    final phoneRegExp = RegExp(r'Appointment:\s*(\+?\d+)');
    final match = phoneRegExp.firstMatch(text);
    if (match != null) return match.group(1);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorsFromAssets();
    _nameController.addListener(_onSearchChanged);
    _specialityController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onSearchChanged);
    _specialityController.removeListener(_onSearchChanged);
    _nameController.dispose();
    _specialityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(_filterDoctors);
  }

  Future<void> _loadDoctorsFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/DocsInfo.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final loadedDoctors = <Map<String, dynamic>>[];

      for (final item in jsonData) {
        if (item is Map<String, dynamic>) {
          loadedDoctors.add({
            'name': item['Name']?.toString() ?? 'Unknown',
            'title':
                item['Specialist']?.toString() ?? '', // JSON field "Specialist"
            'specialties': [item['Speciality']?.toString() ?? ''],
            'chamberLocation':
                item['Chamber & Location']?.toString() ?? 'Not Available',
            'phoneNumber': item['Appointment']?.toString() ?? '',
          });
        }
      }

      setState(() {
        _allDoctors = loadedDoctors;
        _filterDoctors();
      });
    } catch (e) {
      print('Error loading JSON asset: $e');
    }
  }

  void _filterDoctors() {
    final nameSearch = _nameController.text.toLowerCase();
    final specialitySearch = _specialityController.text.toLowerCase();

    if (nameSearch.isNotEmpty) {
      // Filter by doctor name
      _filteredDoctors = _allDoctors
          .where((doctor) =>
              doctor['name'].toString().toLowerCase().contains(nameSearch))
          .toList();
    } else if (specialitySearch.isNotEmpty) {
      // Filter by Specialist field
      _filteredDoctors = _allDoctors.where((doctor) {
        final specialist = (doctor['title'] ?? '').toLowerCase();
        return specialist.contains(specialitySearch);
      }).toList();
    } else {
      _filteredDoctors = List.from(_allDoctors);
    }
  }

  Future<void> _launchDialer(String rawText, BuildContext context) async {
    final phoneNumber = extractPhone(rawText);
    if (phoneNumber != null) {
      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the dialer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('HAS')),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Sergeon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'All Doctors are Here',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  // Search by Doctor Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Doctor Name',
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color.fromARGB(115, 248, 244, 244),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search by Specialist Name
                  TextField(
                    controller: _specialityController,
                    decoration: InputDecoration(
                      hintText: 'Enter Speciality Name',
                      suffixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color.fromARGB(115, 248, 244, 244),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Result Box
                  Container(
                    width: _resultBoxWidth,
                    height: _resultBoxHeight,
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _filteredDoctors.isEmpty
                        ? Center(
                            child: Text(
                              _nameController.text.isEmpty &&
                                      _specialityController.text.isEmpty
                                  ? 'No doctors available'
                                  : 'No doctors found',
                              style: const TextStyle(
                                fontFamily: 'TanjimFonts',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              final name = doctor['name'] ?? 'Unknown';
                              final specialties =
                                  doctor['specialties'] as List<String>? ?? [];
                              final phoneNumber = doctor['phoneNumber'] ?? '';

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontFamily: 'TanjimFonts',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Specialties:',
                                      style: TextStyle(
                                        fontFamily: 'TanjimFonts',
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ...specialties.map(
                                      (spec) => Text(
                                        '• $spec',
                                        style: const TextStyle(
                                          fontFamily: 'TanjimFonts',
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DoctorDetailsPage(
                                                  doctorName: name,
                                                  doctorTitle:
                                                      doctor['title'] ?? '',
                                                  doctorSpecialties:
                                                      specialties,
                                                  chamberLocation: doctor[
                                                          'chamberLocation'] ??
                                                      'Not Available',
                                                  phoneNumber: phoneNumber,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('See Details'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () => _launchDialer(
                                            doctor['chamberLocation'] ?? '',
                                            context,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                              0,
                                              255,
                                              255,
                                              255,
                                            ).withOpacity(0.8),
                                          ),
                                          child: const Text('Call Now'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      );
}

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({
    super.key,
    required this.doctorName,
    required this.doctorTitle,
    required this.doctorSpecialties,
    required this.chamberLocation,
    required this.phoneNumber,
  });
  final String doctorName;
  final String doctorTitle;
  final List<String> doctorSpecialties;
  final String chamberLocation;
  final String phoneNumber;

  Future<void> _launchDialer(String phoneNumber, BuildContext context) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return Scaffold(
      appBar: AppBar(title: Text(doctorName)),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Sergeon.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  doctorTitle,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const Divider(color: Colors.white),
                const Text(
                  'Specialities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                ...doctorSpecialties.map(
                  (spec) => Text(
                    '• $spec',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chamber & Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  chamberLocation,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                if (cleanedNumber.isNotEmpty)
                  Row(
                    children: [
                      const Text(
                        'Appointment: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          cleanedNumber,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _launchDialer(cleanedNumber, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Call Now'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ),
        ],
      ),
    );
  }
}
