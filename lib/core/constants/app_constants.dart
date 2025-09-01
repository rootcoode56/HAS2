import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'HAS';
  static const String appVersion = '1.0.0';

  // Firebase Configuration
  static const int firebaseTimeout = 30; // seconds

  // UI Constants
  static const String fontFamily = 'TanjimFonts';
  static const double defaultPadding = 16;
  static const double defaultRadius = 12;

  // Image Assets
  static const String _imagePath = 'assets/images/';
  static const String logoImage = '${_imagePath}HAS.png';
  static const String logoTransparent = '${_imagePath}HASTrans.png';
  static const String backgroundImage = '${_imagePath}background.jpg';
  static const String receptionImage = '${_imagePath}Reception.jpg';
  static const String googleLogoImage = '${_imagePath}google_logo.jpg';
  static const String avatarImage = '${_imagePath}avater.png';
  static const String magnifyingGlassImage = '${_imagePath}Mag.jpg';
  static const String specialistImage = '${_imagePath}Specialist.jpg';
  static const String bookingImage = '${_imagePath}Booking.jpg';
  static const String mapImage = '${_imagePath}Map.jpg';
  static const String prescriptionImage = '${_imagePath}Prescription.jpg';
  static const String botImage = '${_imagePath}Bot.jpg';
  static const String chatBotImage = '${_imagePath}ChatBot.jpg';
  static const String chatBgImage = '${_imagePath}ChatBG.jpg';
  static const String surgeonImage = '${_imagePath}Sergeon.jpg';
  static const String nurseImage = '${_imagePath}Nurse.jpg';
  static const String appointmentImage = '${_imagePath}appointment.jpg';
  static const String sbgImage = '${_imagePath}SBG.jpg';
  static const String caBgImage = '${_imagePath}ca_bg.jpg';

  // Data Assets
  static const String _dataPath = 'assets/data/';
  static const String docsInfoFile = '${_dataPath}DocsInfo.json';
  static const String symptomsDiseasesFile =
      '${_dataPath}symptoms_diseases.json';

  // Error Messages
  static const String genericErrorMessage =
      'An error occurred. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String accountCreatedMessage = 'Account created successfully!';
  static const String passwordResetMessage = 'Password reset email sent!';

  // Validation Messages
  static const String emptyFieldsMessage = 'Please fill all required fields';
  static const String invalidEmailMessage =
      'Please enter a valid email address';
  static const String passwordMismatchMessage = 'Passwords do not match';
  static const String passwordTooShortMessage =
      'Password must be at least 6 characters';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // API Configuration
  static const String baseUrl =
      'https://api.has.com'; // Replace with actual API URL
  static const int apiTimeout = 30; // seconds

  // SharedPreferences Keys
  static const String userProfileKey = 'user_profile';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Features Flags
  static const bool enableGoogleSignIn = true;
  static const bool enableBiometrics = false;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = false;
}

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorDark = Color(0xFF1565C0);
  static const Color primaryColorLight = Color(0xFF42A5F5);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryColorDark = Color(0xFF018786);
  static const Color secondaryColorLight = Color(0xFF66FFF9);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color hintTextColor = Color(0xFF9E9E9E);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color infoColor = Color(0xFF2196F3);

  // Glass Morphism
  static const Color glassMorphismBackground = Color(0x33000000);
  static const Color glassMorphismBorder = Color(0x33FFFFFF);
}

class AppSizes {
  // Padding
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Icon Sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Font Sizes
  static const double fontXs = 10;
  static const double fontSm = 12;
  static const double fontMd = 14;
  static const double fontLg = 16;
  static const double fontXl = 18;
  static const double fontXxl = 20;
  static const double fontTitle = 24;
  static const double fontHeading = 32;

  // Button Sizes
  static const double buttonHeight = 48;
  static const double buttonRadius = 24;

  // Border Radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusCircular = 100;
}
