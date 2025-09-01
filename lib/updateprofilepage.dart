import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _dobController = TextEditingController();
  File? _imageFile;
  bool _loading = false;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/user_profile.json';
  }

  Future<void> _loadUserProfile() async {
    try {
      final path = await _getLocalFilePath();
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> userData = jsonDecode(jsonString);

        // Populate controllers
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _ageController.text = userData['age'] ?? '';
        _dobController.text = userData['dob'] ?? '';

        final imagePath = userData['profileImagePath'] ?? '';
        if (imagePath.isNotEmpty) {
          final imgFile = File(imagePath);
          if (await imgFile.exists()) {
            setState(() {
              _imageFile = imgFile;
            });
          }
        }
      }
    } catch (e) {
      // Ignore errors or show some message
      debugPrint('Failed to load user profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveUserProfileToJson(Map<String, dynamic> userData) async {
    final path = await _getLocalFilePath();
    final file = File(path);
    final jsonString = jsonEncode(userData);
    await file.writeAsString(jsonString);
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Prepare user data
      final userData = <String, dynamic>{
        'email': user.email ?? '',
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'age': _ageController.text.trim(),
        'dob': _dobController.text.trim(),
        'profileImagePath': _imageFile?.path ?? '',
      };

      // Save JSON file locally
      await _saveUserProfileToJson(userData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved locally!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input fields container with black blurred background
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              _dobController.text =
                                  '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                            }
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _updateProfile,
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Update Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Go Back button bottom left
            Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
}
