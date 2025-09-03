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

class _DoctorListPageState extends State<DoctorListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];

  final Set<String> _selectedSpecialties = {};
  final Set<String> _selectedLocations = {};

  List<String> _allSpecialties = [];
  final List<String> _allLocations = ['Dhaka', 'Rajshahi', 'Kushtia'];

  final double _resultBoxWidth = 400;
  final double _resultBoxHeight = 500;

  // Slide-in filter panel
  late final AnimationController _panelController;
  late final Animation<Offset> _panelSlide;
  bool _isFilterOpen = false;

  String? extractPhone(String text) {
    final phoneRegExp = RegExp(r'Appointment:\s*(\+?\d+)');
    final match = phoneRegExp.firstMatch(text);
    if (match != null) return match.group(1);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _panelSlide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _panelController, curve: Curves.easeOutCubic));

    _loadDoctorsFromAssets();
    _nameController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onSearchChanged);
    _nameController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(_filterDoctors);
  }

  Future<void> _loadDoctorsFromAssets() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/DocsInfoNew.json');
      final decoded = json.decode(jsonString);

      final loadedDoctors = <Map<String, dynamic>>[];
      final specialtiesSet = <String>{};

      Iterable items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic>) {
        items = decoded.values;
      } else {
        items = const [];
      }

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final specialist = (item['Specialist'] ?? '').toString();
          final name = (item['Name'] ?? 'Unknown').toString();
          final chamber = (item['Chamber & Location'] ?? '').toString();
          final phone = (item['Appointment'] ?? '').toString();

          // Extract specialty (text before "Specialist")
          var specialty = specialist;
          final m = RegExp(r'^(.*?)\s*Specialist', caseSensitive: false)
              .firstMatch(specialist);
          if (m != null &&
              m.group(1) != null &&
              m.group(1)!.trim().isNotEmpty) {
            specialty = m.group(1)!.trim();
          }

          // Detect location from chamber text
          var location = 'Unknown';
          for (final city in _allLocations) {
            if (chamber.toLowerCase().contains(city.toLowerCase())) {
              location = city;
              break;
            }
          }

          if (specialty.isNotEmpty) specialtiesSet.add(specialty);

          loadedDoctors.add({
            'name': name,
            'title': specialist,
            'specialty': specialty,
            'chamberLocation': chamber,
            'phoneNumber': phone,
            'location': location,
          });
        }
      }

      setState(() {
        _allDoctors = loadedDoctors;
        _allSpecialties = specialtiesSet.toList()..sort();
        _filterDoctors();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading JSON asset: $e');
    }
  }

  void _filterDoctors() {
    final nameSearch = _nameController.text.toLowerCase();

    _filteredDoctors = _allDoctors.where((doctor) {
      final matchesName =
          doctor['name'].toString().toLowerCase().contains(nameSearch);

      final matchesSpecialty = _selectedSpecialties.isEmpty ||
          _selectedSpecialties.contains(doctor['specialty']);

      final matchesLocation = _selectedLocations.isEmpty ||
          _selectedLocations.contains(doctor['location']);

      return matchesName && matchesSpecialty && matchesLocation;
    }).toList();
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

  void _openFilterPanel() {
    setState(() => _isFilterOpen = true);
    _panelController.forward();
  }

  void _closeFilterPanel() {
    _panelController.reverse().whenComplete(() {
      if (mounted) setState(() => _isFilterOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // no hamburger/back auto icon
          title: const Text('HAS'),
        ),
        // No drawer here -> no hamburger icon
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Sergeon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
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
                  // Search by Name only
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
                                      _selectedSpecialties.isEmpty &&
                                      _selectedLocations.isEmpty
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
                                    Text(
                                      doctor['title'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'TanjimFonts',
                                        color: Colors.white70,
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
                                                  doctorSpecialties: [
                                                    doctor['specialty']
                                                  ],
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
                                                        0, 255, 255, 255)
                                                    .withOpacity(0.8),
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

            // Go Back (bottom-left)
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

            // Filter FAB (bottom-right)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _openFilterPanel,
                child: const Icon(Icons.filter_list),
              ),
            ),

            // Scrim + Slide-in Filter Panel (left)
            if (_isFilterOpen) ...[
              // Scrim
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeFilterPanel,
                  child: Container(color: Colors.black54),
                ),
              ),

              // Panel
              Align(
                alignment: Alignment.centerLeft,
                child: SlideTransition(
                  position: _panelSlide,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8 > 360
                        ? 360
                        : MediaQuery.of(context).size.width * 0.8,
                    child: Material(
                      elevation: 12,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Panel header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Filter Options',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _closeFilterPanel,
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Scrollable content
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.all(12),
                                children: [
                                  // Specialties dropdown
                                  ExpansionTile(
                                    title: const Text(
                                      'Specialties',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    children: _allSpecialties
                                        .map((spec) => CheckboxListTile(
                                              title: Text(spec),
                                              value: _selectedSpecialties
                                                  .contains(spec),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    _selectedSpecialties
                                                        .add(spec);
                                                  } else {
                                                    _selectedSpecialties
                                                        .remove(spec);
                                                  }
                                                  _filterDoctors();
                                                });
                                              },
                                            ))
                                        .toList(),
                                  ),

                                  const Divider(),

                                  // Locations dropdown
                                  ExpansionTile(
                                    title: const Text(
                                      'Locations',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    children: _allLocations
                                        .map((loc) => CheckboxListTile(
                                              title: Text(loc),
                                              value: _selectedLocations
                                                  .contains(loc),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    _selectedLocations.add(loc);
                                                  } else {
                                                    _selectedLocations
                                                        .remove(loc);
                                                  }
                                                  _filterDoctors();
                                                });
                                              },
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            // Footer apply/clear (optional quick actions)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSpecialties.clear();
                                        _selectedLocations.clear();
                                        _filterDoctors();
                                      });
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _closeFilterPanel,
                                    icon: const Icon(Icons.check),
                                    label: const Text('Apply'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
