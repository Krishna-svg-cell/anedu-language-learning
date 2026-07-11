import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../database/local_db.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  /// Queries the Gemini-1.5-Flash model using raw HTTP.
  /// Passes conversation history and system instructions.
  Future<String?> generateContent({
    required List<Map<String, dynamic>> conversationHistory,
    required String systemInstruction,
  }) async {
    final backendUrl = LocalDb.geminiBackendUrl;
    if (backendUrl.isNotEmpty) {
      try {
        String cleanUrl = backendUrl.trim();
        if (cleanUrl.endsWith('/')) {
          cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
        }
        if (cleanUrl.endsWith('/api/generate')) {
          cleanUrl = cleanUrl.substring(0, cleanUrl.length - '/api/generate'.length);
        }
        if (cleanUrl.endsWith('/api/chat')) {
          cleanUrl = cleanUrl.substring(0, cleanUrl.length - '/api/chat'.length);
        }

        final uri = Uri.parse('$cleanUrl/api/generate');
        debugPrint("Attempting backend proxy request to: $uri");
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'conversationHistory': conversationHistory,
            'systemInstruction': systemInstruction,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['text'] != null) {
            debugPrint("Gemini Success using backend proxy: $cleanUrl");
            return data['text'] as String;
          }
        } else {
          debugPrint("Backend proxy returned status code: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        debugPrint("Exception querying backend proxy: $e. Falling back to direct Gemini API call.");
      }
    }

    debugPrint("Direct client-side Gemini requests are disabled for security. Enforcing Express Proxy server.");
    return null;
  }
}
