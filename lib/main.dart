import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'askmepage.dart';
import 'booking.dart';
import 'dashboard.dart';
import 'doctorsearch.dart';
import 'hasnearme.dart';
import 'presciptionpage.dart';
import 'searchsymptompspage.dart';
import 'settings.dart';
import 'updateprofilepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          fontFamily: 'TanjimFonts',
          // Enable Material 3 for better performance
          useMaterial3: true,
          // Disable expensive animations globally
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const CroppedBackgroundScreen(),
          '/dashboard': (context) => const DashboardPage(),
          '/forget_password': (context) => const ForgetPasswordScreen(),
          '/create_account': (context) => const CreateAccountScreen(),
          '/search': (context) => const SearchSymptomsPage(),
          '/specialist': (context) => const DoctorListPage(),
          '/booking': (context) => const BookAppointmentPage(),
          '/nearby': (context) => const HasNearMe(),
          '/askmepage': (context) => const Askmepage(),
          '/prescriptions': (context) => const PrescriptionPage(),
          '/settings': (context) => const SettingsPage(),
          '/updateProfile': (context) => const UpdateProfilePage(),
        },
      );
}

class CroppedBackgroundScreen extends StatefulWidget {
  const CroppedBackgroundScreen({super.key});

  @override
  State<CroppedBackgroundScreen> createState() =>
      _CroppedBackgroundScreenState();
}

class _CroppedBackgroundScreenState extends State<CroppedBackgroundScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      var errorMessage =
          'Login failed. Please try again with right email or password.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Google Sign-In method - Placeholder for proper Firebase configuration
  // TODO: Configure Google Sign-In properly with Firebase Console
  Future<UserCredential?> signInWithGoogle() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Google Sign-In not configured yet. Please use email/password login.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;

    // Commented out for now - uncomment after Firebase is properly configured
    /*
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User canceled
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
          
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.message}'),
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In failed. Please try again.'),
          ),
        );
      }
      return null;
    }
    */
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Reception.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Center content: HAS logo + glassy box
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HAS Logo with rounded rectangle background, shadow, border
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          222,
                          222,
                          229,
                        ).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/HAS.png',
                        height: 85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Glassy blackish box with reduced top padding
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        width: 370,
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextLabel('Username'),
                            _buildTextInput(
                              'Enter Your Username',
                              controller: _emailController,
                            ),
                            const SizedBox(height: 20),
                            _buildTextLabel('Password'),
                            _buildTextInput(
                              'Enter Your Password',
                              obscureText: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLink(context, 'Forget Password?'),
                                InkWell(
                                  onTap: () {
                                    Feedback.forTap(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateAccountScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Create Account?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      fontFamily: 'TanjimFonts',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildButton(
                              text: 'Login',
                              onPressed: () {
                                Feedback.forTap(context);
                                _login(); // call your login function here
                              },
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'or',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 15),
                            _buildButton(
                              text: 'Continue with Google',
                              icon: 'assets/images/google_logo.jpg',
                              onPressed: () async {
                                Feedback.forTap(context);
                                final user = await signInWithGoogle();
                                if (user != null) {
                                  print(
                                    'Google Sign-In Success! Welcome: ${user.user?.displayName}',
                                  );
                                  // TODO: Navigate to dashboard screen
                                } else {
                                  print('Google Sign-In failed or canceled.');
                                }
                              },
                              backgroundColor: Colors.white,
                              textColor: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ===================== Helper Widgets =====================

  Widget _buildTextLabel(String label) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'TanjimFonts',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _buildTextInput(
    String hint, {
    bool obscureText = false,
    required TextEditingController controller,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.25),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildLink(BuildContext context, String text) => InkWell(
        onTap: () {
          Feedback.forTap(context);
          if (text == 'Forget Password?') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
            );
          } else {
            print('$text tapped');
          }
        },
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'TanjimFonts',
            fontSize: 14,
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
      );

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    String? icon,
    required Color backgroundColor,
    required Color textColor,
  }) =>
      GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset(icon, width: 24, height: 24),
                ),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'TanjimFonts',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // ✅ Create user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // ✅ Send verification email
      await userCredential.user?.sendEmailVerification();

      if (mounted) {
        // Optionally show a success message before navigating
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(); // Back to login
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create Account')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      );
}

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  String? _message;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your email';
      });
      return;
    }

    try {
      setState(() {
        _isSending = true;
        _message = null;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Forget Password')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSending ? null : _sendResetEmail,
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Link'),
              ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('sent')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
