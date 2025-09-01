import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MessageController extends GetxController {
  RxString responseText = ''.obs;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  RxBool isTypeing = false.obs;

  List symptomsData = [];
  List docsData = [];

  // RESET chat
  void resetChat() {
    messages.clear();
    messages.add({
      'text': '👋 Hi! How can I help you today?',
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    });
  }

  @override
  void onInit() {
    super.onInit();
    resetChat();
    loadJsonData();
  }

  /// Load JSON data
  Future<void> loadJsonData() async {
    try {
      final symptomsJson = await rootBundle.loadString(
        'assets/symptoms_diseases.json',
      );
      final docsJson = await rootBundle.loadString('assets/DocsInfo.json');

      final decodedSymptoms = json.decode(symptomsJson);
      if (decodedSymptoms is List) {
        symptomsData = decodedSymptoms;
      } else if (decodedSymptoms is Map) {
        symptomsData = [decodedSymptoms];
      }

      final decodedDocs = json.decode(docsJson);
      if (decodedDocs is List) {
        docsData = decodedDocs;
      } else if (decodedDocs is Map) {
        docsData = [decodedDocs];
      }

      print('✅ Symptoms loaded: ${symptomsData.length}');
      print('✅ Docs loaded: ${docsData.length}');
    } catch (e, st) {
      print('❌ Error loading JSON: $e');
      print(st);
    }
  }

  /// Process user input
  Future<void> sendMessage(String message) async {
    messages.add({
      'text': message,
      'isUser': true,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    });

    responseText.value = 'Thinking...';
    isTypeing.value = true;
    update();

    // 🔹 Step 1: Try local JSON match
    var reply = _checkLocalData(message);

    // 🔹 Step 2: If not found in JSON, fallback to Gemini
    if (reply == null) {
      final geminiReply = await GoogleApiService.getApiResponse(message);
      reply = geminiReply;
    }

    responseText.value = reply;

    messages.add({
      'text': reply,
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    });

    isTypeing.value = false;
    update();
  }

  /// Local data matching (with styled replies)
  String? _checkLocalData(String userMessage) {
    userMessage = userMessage.toLowerCase();

    // Match by disease/symptoms
    for (final item in symptomsData) {
      final disease = (item['disease'] ?? '').toString().trim();
      final List symptoms = item['symptoms'] ?? [];

      if (userMessage.contains(disease.toLowerCase())) {
        return '🦠 *Disease Found*: **$disease**\n\n'
            "📋 *Symptoms include:*\n${symptoms.map((s) => "• $s").join("\n")}";
      }

      for (final s in symptoms) {
        if (userMessage.contains(s.toString().toLowerCase())) {
          return '⚠️ *Symptom Match*: **$s**\n\n'
              '🦠 This may relate to **$disease**.\n'
              "📋 Other symptoms:\n${symptoms.map((sym) => "• $sym").join("\n")}";
        }
      }
    }

    // Match by doctor name or specialty
    for (final doc in docsData) {
      final specialist = (doc['Specialist'] ?? '').toString().toLowerCase();
      final name = (doc['Name'] ?? '').toString().toLowerCase();

      if (userMessage.contains(name) || userMessage.contains(specialist)) {
        return '👨‍⚕️ *Doctor Information*\n\n'
            "🧑 Name: ${doc['Name']}\n"
            "🏷️ Specialist: ${doc['Specialist']}\n"
            "🎓 Qualification: ${doc['Speciality']}\n"
            "🏥 Chamber & Location:\n${doc['Chamber & Location']}";
      }
    }

    return null; // nothing matched
  }
}
