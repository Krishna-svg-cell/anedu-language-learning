import 'model_router.dart';

class MissionVerificationResult {
  final bool verified;
  final String responseMessage;
  final int bonusCoins;
  final int bonusXp;

  MissionVerificationResult({
    required this.verified,
    required this.responseMessage,
    required this.bonusCoins,
    required this.bonusXp,
  });
}

class MissionAgent {
  static final MissionAgent instance = MissionAgent._internal();
  MissionAgent._internal();

  /// Verifies a user's real-world mission completion reflection.
  /// Uses Gemini to analyze whether the user's report shows they actually tried the interaction.
  Future<MissionVerificationResult> verifyMission({
    required String missionDescription,
    required String userReflection,
  }) async {
    if (userReflection.trim().length < 5) {
      return MissionVerificationResult(
        verified: false,
        responseMessage: 'Your description is too short. Please tell me a bit more about what the other person said or did!',
        bonusCoins: 0,
        bonusXp: 0,
      );
    }

    final String systemInstruction = '''
You are the MissionAgent in a Kannada learning app.
Your task is to analyze the user's reflection/report on completing a real-world Kannada conversation mission.
Determine if the user genuinely attempted the task based on their description of what the local said or how the interaction went.
Be supportive and encouraging.

Respond strictly in this JSON format:
{
  "verified": true, // Boolean representing if the challenge attempt was valid
  "responseMessage": "A warm feedback reply congratulating them on the attempt and highlighting cultural learnings.",
  "bonusCoins": 15, // Suggested coin reward if verified (0 to 20)
  "bonusXp": 25 // Suggested XP reward if verified (0 to 30)
}
''';

    final String prompt = '''
Mission Description: "$missionDescription"
User's completed reflection report: "$userReflection"
Analyze if the attempt is successful.
''';

    try {
      final jsonResult = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );

      if (jsonResult != null) {
        return MissionVerificationResult(
          verified: jsonResult['verified'] as bool? ?? true,
          responseMessage: jsonResult['responseMessage'] as String? ?? 'Awesome work! You completed the mission successfully!',
          bonusCoins: jsonResult['bonusCoins'] as int? ?? 15,
          bonusXp: jsonResult['bonusXp'] as int? ?? 25,
        );
      }
    } catch (_) {}

    return MissionVerificationResult(
      verified: true,
      responseMessage: 'Good job completing your real-world challenge! Mittu is proud!',
      bonusCoins: 15,
      bonusXp: 20,
    );
  }
}
