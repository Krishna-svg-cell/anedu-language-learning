import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';

class ModelRouter {
  static final ModelRouter instance = ModelRouter._internal();
  ModelRouter._internal();

  /// Routes complex tasks to Gemini API. Instructs Gemini to return a structured JSON block.
  /// Validates that the returned string is valid JSON before returning it.
  Future<Map<String, dynamic>?> queryStructuredJson({
    required String systemInstruction,
    required String prompt,
  }) async {
    try {
      final conversationHistory = [
        {'isUser': true, 'text': prompt}
      ];

      final rawResponse = await GeminiService.instance.generateContent(
        conversationHistory: conversationHistory,
        systemInstruction: '$systemInstruction\n\nIMPORTANT: You MUST respond ONLY with a single JSON block. Do not include markdown code block characters like ```json ... ```. Do not output any text before or after the JSON payload. Ensure your JSON syntax is 100% correct.',
      );

      if (rawResponse == null || rawResponse.trim().isEmpty) {
        debugPrint("ModelRouter Error: Empty response from Gemini API.");
        return null;
      }

      // Strip potential markdown wrappers
      String cleaned = rawResponse.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'^```(json)?'), '');
        cleaned = cleaned.replaceAll(RegExp(r'```$'), '');
        cleaned = cleaned.trim();
      }

      // Try parsing JSON
      final Map<String, dynamic> parsed = jsonDecode(cleaned);
      debugPrint("ModelRouter Success: Parsed structured JSON response.");
      return parsed;
    } catch (e) {
      debugPrint("ModelRouter JSON parsing exception: $e");
      return null;
    }
  }
}
