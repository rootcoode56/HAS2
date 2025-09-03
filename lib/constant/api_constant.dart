import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static String get apiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';
  static String get apiUrl => dotenv.env['GOOGLE_API_URL'] ?? 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
}
