//Riya Settings
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLocation = 'Bangladesh';
  final List<String> locations = ['Bangladesh', 'USA', 'India', 'UK', 'Canada'];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            // Background image
            SizedBox.expand(
              child: Image.asset('assets/images/SBG.jpg', fit: BoxFit.cover),
            ),
            // Foreground UI
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glossy App Preferences title
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              101,
                              99,
                              99,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'App Preferences',
                            style: TextStyle(
                              fontFamily: 'TanjimFonts',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),

                    // Settings content with blackish blurry background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Location Dropdown
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontFamily: 'TanjimFonts',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: DropdownButton<String>(
                                  dropdownColor: Colors.black87,
                                  value: selectedLocation,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  underline: const SizedBox(),
                                  items: locations
                                      .map((value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLocation = value!;
                                    });
                                  },
                                ),
                              ),

                              _settingsTile(
                                  'Share Feedback', _openFeedbackForm),
                              _settingsTile('Rate Us', _rateUs),

                              // Delete Account
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    fontFamily: 'TanjimFonts',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: _confirmDeleteAccount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Align(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(fontFamily: 'TanjimFonts'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _settingsTile(String title, VoidCallback onTap) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'TanjimFonts',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white,
        ),
        onTap: onTap,
      );

  Future<void> _openFeedbackForm() async {
    const url = 'https://forms.gle/ZriLWYZjt6URY67W9';
    try {
      final success = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!success) throw 'Could not launch $url';
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open form: $e')));
    }
  }

  void _rateUs() {
    // TODO: Add your app store link here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete'),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
                );
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
