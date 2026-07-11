import 'dart:convert';
import 'package:hive/hive.dart';
import 'model_router.dart';

class SpeechEvaluationResult {
  final int overallScore;
  final int pronunciationScore;
  final int fluencyScore;
  final int speedScore;
  final int confidenceScore;
  final String corrections;
  final String nativeAlternative;

  // New fields requested by ANEDU FINAL MARKET READY ENGINEERING UPGRADE
  final String incorrectSounds;
  final String correction;
  final String practiceExercise;

  SpeechEvaluationResult({
    required this.overallScore,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.speedScore,
    required this.confidenceScore,
    required this.corrections,
    required this.nativeAlternative,
    this.incorrectSounds = 'None',
    this.correction = 'Good job!',
    this.practiceExercise = 'Try saying it again.',
  });

  factory SpeechEvaluationResult.fromFallback(String target) {
    return SpeechEvaluationResult(
      overallScore: 80,
      pronunciationScore: 8,
      fluencyScore: 8,
      speedScore: 8,
      confidenceScore: 8,
      corrections: 'Good attempt. Try matching pronunciation syllables.',
      nativeAlternative: target,
      incorrectSounds: 'None',
      correction: 'Good attempt. Try matching pronunciation syllables.',
      practiceExercise: 'Practice saying: $target',
    );
  }
}

class SpeechCoachAgent {
  static final SpeechCoachAgent instance = SpeechCoachAgent._internal();
  SpeechCoachAgent._internal();

  Map<String, dynamic> _simulateAudioFeatureExtraction(String target, String input) {
    // Basic similarity ratio check
    final String cleanTarget = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final String cleanInput = input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    
    int matchCount = 0;
    final List<String> targetWords = cleanTarget.split(' ');
    final List<String> inputWords = cleanInput.split(' ');
    
    for (final word in targetWords) {
      if (inputWords.contains(word)) {
        matchCount++;
      }
    }
    
    final double matchRatio = targetWords.isNotEmpty ? matchCount / targetWords.length : 0.0;
    final int score = (matchRatio * 100).round();
    
    return {
      'matchRatio': matchRatio,
      'score': score,
      'pauses': input.contains('...') || input.contains(',') ? 1 : 0,
    };
  }

  void _logSpeechResult(String target, String input, SpeechEvaluationResult result) async {
    try {
      final box = Hive.box('speech_history');
      final currentList = box.get('history') ?? [];
      final List<dynamic> list = List<dynamic>.from(currentList);
      list.add({
        'target': target,
        'userSpeech': input,
        'overallScore': result.overallScore,
        'pronunciationScore': result.pronunciationScore,
        'fluencyScore': result.fluencyScore,
        'speedScore': result.speedScore,
        'confidenceScore': result.confidenceScore,
        'corrections': result.corrections,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await box.put('history', list);
    } catch (_) {}
  }

  Future<SpeechEvaluationResult> evaluateSpeech({
    required String userSpeech,
    required String targetSentence,
  }) async {
    if (userSpeech.trim().isEmpty) {
      return SpeechEvaluationResult.fromFallback(targetSentence);
    }

    final features = _simulateAudioFeatureExtraction(targetSentence, userSpeech);
    final int baseScore = features['score'] as int? ?? 80;
    final int pronunciation = (baseScore / 10).round().clamp(1, 10);
    final int fluency = (features['pauses'] == 1) ? 7 : 9;

    final String systemInstruction = '''
You are the SpeechCoachAgent in an MVP Kannada language learning platform.
Compare the user's spoken Kannada transcript to the target text.
Assess meaning similarity, pronunciation target sounds, and corrections.

Respond strictly in this JSON format:
{
  "overallScore": 85, // Integer 0 to 100
  "pronunciationScore": 8, // Integer 1 to 10
  "fluencyScore": 7, // Integer 1 to 10
  "speedScore": 9, // Integer 1 to 10
  "confidenceScore": 8, // Integer 1 to 10
  "incorrectSounds": "None",
  "correction": "Good effort! Practice saying the words clearly.",
  "practiceExercise": "Repeat after me.",
  "nativeAlternative": "The natural native phrasing."
}
''';

    final String prompt = '''
Target text: "$targetSentence"
User spoken text: "$userSpeech"
Basic Match Score: $baseScore%
Evaluate this speaking attempt for the MVP.
''';

    try {
      final jsonResult = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );

      if (jsonResult != null) {
        final result = SpeechEvaluationResult(
          overallScore: jsonResult['overallScore'] as int? ?? baseScore,
          pronunciationScore: jsonResult['pronunciationScore'] as int? ?? pronunciation,
          fluencyScore: jsonResult['fluencyScore'] as int? ?? fluency,
          speedScore: jsonResult['speedScore'] as int? ?? 8,
          confidenceScore: jsonResult['confidenceScore'] as int? ?? 8,
          corrections: jsonResult['correction'] as String? ?? 'Good attempt!',
          nativeAlternative: jsonResult['nativeAlternative'] as String? ?? targetSentence,
          incorrectSounds: jsonResult['incorrectSounds'] as String? ?? 'None',
          correction: jsonResult['correction'] as String? ?? 'Good attempt!',
          practiceExercise: jsonResult['practiceExercise'] as String? ?? 'Practice the target sentence.',
        );

        _logSpeechResult(targetSentence, userSpeech, result);
        return result;
      }
    } catch (_) {}

    final fallback = SpeechEvaluationResult.fromFallback(targetSentence);
    _logSpeechResult(targetSentence, userSpeech, fallback);
    return fallback;
  }
}
