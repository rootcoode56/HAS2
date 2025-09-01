import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SearchSymptomsPage extends StatefulWidget {
  const SearchSymptomsPage({super.key});

  @override
  State<SearchSymptomsPage> createState() => _SearchSymptomsPageState();
}

class _SearchSymptomsPageState extends State<SearchSymptomsPage> {
  final String _selectedOption = 'Search By Symptoms';
  String _searchText = '';
  List<Map<String, dynamic>> _allDiseases = [];
  List<Map<String, dynamic>> _results = [];

  final double _resultBoxWidth = 400;
  final double _resultBoxHeight = 450;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndLoadSymptoms();
  }

  Future<void> _initFirebaseAndLoadSymptoms() async {
    try {
      await Firebase.initializeApp();
      await _fetchAllSymptoms();
    } catch (e) {
      print('🔥 Firebase Init Error: $e');
    }
  }

  Future<void> _fetchAllSymptoms() async {
    print('🟡 Fetching all diseases...');
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://hospital-access-system-d902d-default-rtdb.firebaseio.com/',
      );

      final snapshot = await database.ref('').get();

      if (!snapshot.exists) {
        print('🔴 Firebase snapshot does not exist.');
        setState(() {
          _allDiseases = [];
          _results = [];
        });
        return;
      }

      final data = snapshot.value;

      final diseases = <Map<String, dynamic>>[];

      if (data is List) {
        for (final item in data) {
          if (item is Map) {
            final diseaseName = item['disease']?.toString() ?? 'Unknown';
            final symptoms = item['symptoms'];

            if (symptoms is List) {
              diseases.add({
                'disease': diseaseName,
                'symptoms': symptoms.cast<String>(),
              });
            }
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final diseaseName = value['disease']?.toString() ?? 'Unknown';
            final symptoms = value['symptoms'];

            if (symptoms is List) {
              diseases.add({
                'disease': diseaseName,
                'symptoms': symptoms.cast<String>(),
              });
            }
          }
        });
      } else {
        print('⚠ Unexpected data type: ${data.runtimeType}');
      }

      setState(() {
        _allDiseases = diseases;
        _results = diseases;
      });

      print('✅ Loaded ${diseases.length} diseases');
    } catch (e) {
      print('🔥 Error fetching diseases: $e');
    }
  }

  void _searchSymptoms() {
    if (_searchText.isEmpty) {
      setState(() {
        _results = _allDiseases;
      });
      return;
    }

    // Split input by comma and trim spaces
    final searchTerms = _searchText
        .toLowerCase()
        .split(',')
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty)
        .toList();

    final filteredDiseases = _allDiseases.where((disease) {
      final diseaseName = disease['disease']?.toString().toLowerCase() ?? '';
      final symptoms = (disease['symptoms'] as List<dynamic>?)
              ?.map((s) => s.toString().toLowerCase())
              .toList() ??
          [];

      // Match if ANY of the search terms is found in name or symptoms
      return searchTerms.any((term) {
        final matchesDiseaseName = diseaseName.contains(term);
        final matchesSymptom = symptoms.any(
          (symptom) => symptom.contains(term),
        );
        return matchesDiseaseName || matchesSymptom;
      });
    }).toList();

    setState(() {
      _results = filteredDiseases;
    });

    print(
      '🔍 Found ${filteredDiseases.length} diseases matching "$_searchText"',
    );
  }

  Widget _buildBlurBox(
          {required Widget child, double? width, double? height}) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Nurse.jpg', fit: BoxFit.cover),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBlurBox(
                        child: const Text(
                          'Symptom Checker',
                          style: TextStyle(
                            fontFamily: 'TanjimFonts',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: _buildBlurBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        _selectedOption,
                                        style: const TextStyle(
                                          fontFamily: 'TanjimFonts',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      style: const TextStyle(
                                        fontFamily: 'TanjimFonts',
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your search',
                                        hintStyle: TextStyle(
                                          fontFamily: 'TanjimFonts',
                                          color: Colors.white54,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _searchText = value;
                                        });
                                        _searchSymptoms();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: _buildBlurBox(
                                width: _resultBoxWidth,
                                height: _resultBoxHeight,
                                child: _results.isEmpty
                                    ? Text(
                                        _searchText.isEmpty
                                            ? 'All Diseases will be shown here'
                                            : 'No diseases found for "$_searchText"',
                                        style: const TextStyle(
                                          fontFamily: 'TanjimFonts',
                                          color: Colors.white,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Possible Disease',
                                            style: TextStyle(
                                              fontFamily: 'TanjimFonts',
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: _results.length,
                                              itemBuilder: (context, index) {
                                                final disease = _results[index];
                                                final diseaseName =
                                                    disease['disease'] ??
                                                        'Unknown';
                                                final symptoms =
                                                    disease['symptoms']
                                                            as List<dynamic>? ??
                                                        [];

                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 6,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Disease Name: $diseaseName',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'TanjimFonts',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Symptoms:',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'TanjimFonts',
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      ...symptoms.map(
                                                        (symptom) => Text(
                                                          '- $symptom',
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'TanjimFonts',
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ),
                                                      const Divider(
                                                        color: Colors.white30,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              shrinkWrap: true,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/dashboard'),
                          child: _buildBlurBox(
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                'Go Back',
                                style: TextStyle(
                                  fontFamily: 'TanjimFonts',
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
