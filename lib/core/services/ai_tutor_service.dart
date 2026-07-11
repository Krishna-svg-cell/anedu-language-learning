import 'dart:math';
import 'gemini_service.dart';

class AiTutorService {
  static final AiTutorService instance = AiTutorService._internal();
  AiTutorService._internal();

  // Maps scenarios to system prompts, hints, and expected responses
  final Map<String, Map<String, dynamic>> scenarios = {
    'cafe': {
      'systemPrompt': 'You are Ramesh, a friendly waiter at a traditional Darshini cafe in Bengaluru. Speak a mix of simple Kannada and English. Respond warmly, ask what the customer wants, offer hot filter coffee or idli-vada, handle orders, provide pricing, and guide payment.',
      'initialMessage': 'Namaskara sir! Welcome to Darshini. Enu beku? (What would you like?)',
      'targets': [
        'Filter kapi kodi',
        'Sakkare beda',
        'Bill kodi',
        'Idli-vada kodi',
      ],
      'hints': [
        'Ask for filter coffee: "Ondu filter kapi kodi"',
        'Say no sugar: "Sakkare beda"',
        'Ask for the bill: "Bill kodi"',
      ]
    },
    'auto': {
      'systemPrompt': 'You are Kumar, an auto driver in Majestic, Bengaluru. Be slightly gruff but helpful. Negotiate fares, ask where the customer wants to go, and guide them politely.',
      'initialMessage': 'Namaskara! Majestic-ge barutha? Yelli hogabeku? (Where do you want to go?)',
      'targets': [
        'Majestic-ge eshtu?',
        'Auto nilli',
        'Sari banni',
      ],
      'hints': [
        'Ask how much to Majestic: "Majestic-ge eshtu?"',
        'Tell him to stop here: "Nilli"',
      ]
    },
    'metro': {
      'systemPrompt': 'You are a helpful Metro passenger in Indiranagar. Give directions to tourists, help them buy tickets, and find platforms.',
      'initialMessage': 'Excuse me! Metro station yelli ide? Can I help you find it?',
      'targets': [
        'Yelli ide?',
        'Nera hogi',
        'Edake thirugi',
      ],
      'hints': [
        'Ask where it is: "Yelli ide?"',
        'Say go straight: "Nera hogi"',
      ]
    }
  };

  /// Start a chat session: returns the initial dialogue prompt
  String startChat(String scenario) {
    final s = scenarios[scenario.toLowerCase()] ?? scenarios['cafe']!;
    return s['initialMessage'];
  }

  /// Calculates string similarity between two phrases (Levenshtein Distance normalized)
  double checkInputSimilarity(String input, String target) {
    final cleanInput = input.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final cleanTarget = target.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (cleanInput == cleanTarget) return 1.0;
    if (cleanInput.isEmpty || cleanTarget.isEmpty) return 0.0;

    // Levenshtein distance calculation
    final List<int> costs = List<int>.filled(cleanTarget.length + 1, 0);
    for (int j = 0; j < costs.length; j++) {
      costs[j] = j;
    }
    for (int i = 1; i <= cleanInput.length; i++) {
      costs[0] = i;
      int nw = i - 1;
      for (int j = 1; j <= cleanTarget.length; j++) {
        int cj = min(1 + min(costs[j], costs[j - 1]), cleanInput.codeUnitAt(i - 1) == cleanTarget.codeUnitAt(j - 1) ? nw : nw + 1);
        nw = costs[j];
        costs[j] = cj;
      }
    }

    final int maxLen = max(cleanInput.length, cleanTarget.length);
    return 1.0 - (costs[cleanTarget.length] / maxLen);
  }

  /// Generates a response prompt from Mittu or Tutor using the GeminiService proxy/API
  Future<String> getResponse({
    required String scenario,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    final s = scenarios[scenario.toLowerCase()] ?? scenarios['cafe']!;
    final systemPrompt = s['systemPrompt'] as String;

    final response = await GeminiService.instance.generateContent(
      conversationHistory: conversationHistory,
      systemInstruction: systemPrompt,
    );

    return response ?? "Sari sir, got it! Let's practice more Kannada.";
  }

  /// Returns random hint from target list
  String getHint(String scenario) {
    final s = scenarios[scenario.toLowerCase()] ?? scenarios['cafe']!;
    final List<String> hints = List<String>.from(s['hints'] ?? []);
    if (hints.isEmpty) return "Try saying simple words like Namaskara.";
    return hints[Random().nextInt(hints.length)];
  }
}
