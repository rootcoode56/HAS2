import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final TextEditingController _doctorController = TextEditingController();

  List<String> _allDoctors = [];
  List<String> _filteredDoctors = [];

  final List<String> _appointmentSlots = [
    'Wednesday 3PM',
    'Thursday 3/4PM',
    'Saturday 4PM',
  ];

  String? _selectedSlot;
  bool _bookingConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorsFromJson();
    _doctorController.addListener(_onDoctorSearch);
  }

  @override
  void dispose() {
    _doctorController.removeListener(_onDoctorSearch);
    _doctorController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/DocsInfo.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final doctors = <String>[];
      for (final item in jsonData) {
        if (item is Map<String, dynamic>) {
          doctors.add(item['Name']?.toString() ?? 'Unknown');
        }
      }

      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = List.from(_allDoctors);
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  void _onDoctorSearch() {
    final query = _doctorController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = List.from(_allDoctors);
      } else {
        _filteredDoctors = _allDoctors
            .where((doctor) => doctor.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _bookAppointment() {
    if (_selectedSlot != null) {
      setState(() {
        _bookingConfirmed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset('assets/images/appointment.jpg',
                  fit: BoxFit.cover),
            ),

            // Glassmorphism overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: Container(
                  color: const Color.fromARGB(255, 32, 31, 31).withOpacity(0.2),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _glassContainer(
                        width: 180,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Center(
                          child: Text(
                            'Appointment',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 160),

                    // Doctor Name Input
                    _glassContainer(
                      child: TextField(
                        controller: _doctorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter the Doctor’s Name',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(179, 58, 55, 55),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Filtered Doctor Names List
                    if (_filteredDoctors.isNotEmpty)
                      _glassContainer(
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _filteredDoctors[index];
                            return GestureDetector(
                              onTap: () {
                                _doctorController.text = doctor;
                                setState(() {
                                  _filteredDoctors = [doctor];
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  doctor,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    _glassContainer(
                      child: const Text(
                        'Times and Dates will be\ngiven here',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Appointment slots
                    ..._appointmentSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSlot = slot;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.grey.withOpacity(0.6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '• $slot',
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: _bookAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    if (_bookingConfirmed)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            '✅ Booking Confirmed!',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Go Back button at bottom-left
            Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double? width,
    double? height,
  }) =>
      Container(
        width: width ?? double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      );
}
