import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/local_db.dart';
import '../../models/user_progress.dart';
import '../../models/lesson.dart';
import 'agent_state.dart';
import 'supervisor_agent.dart';
import 'speech_coach_agent.dart';
import 'mission_agent.dart';
import 'retention_agent.dart';
import 'growth_agent.dart';

class AgentOrchestrator {
  static final AgentOrchestrator instance = AgentOrchestrator._internal();
  AgentOrchestrator._internal();

  static const String cacheBoxName = 'agentic_cache_box';

  static Future<void> init() async {
    await Hive.openBox(cacheBoxName);
  }

  Box get _cacheBox => Hive.box(cacheBoxName);

  /// Formulates, evaluates, checks, and validates the complete personalized lesson object.
  /// First checks the local Hive cache using Day timeline slot.
  Future<Lesson> getLessonForDay(int day, UserProgress progress) async {
    final cacheKey = 'lesson_day_$day';
    final cachedData = _cacheBox.get(cacheKey);

    if (cachedData != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          cachedData is String ? jsonDecode(cachedData) : cachedData,
        );
        debugPrint("AgentOrchestrator: Cache hit for Day $day.");
        
        // cost tracking update
        try {
          final Box progressBox = Hive.box('progress_box');
          final Box usersBox = Hive.box('users_box');
          final String activeUserId = Hive.box('settings_box').get('active_user_id', defaultValue: 'guest_user');
          final updated = progress.copyWith(cacheHitsCount: progress.cacheHitsCount + 1);
          await usersBox.put(activeUserId, updated.toJson());
          await progressBox.put('user_progress', updated.toJson());
        } catch (_) {}

        return Lesson.fromJson(json);
      } catch (e) {
        debugPrint("AgentOrchestrator: Failed to parse cached lesson: $e. Regenerating...");
      }
    }

    final String serverKey = "${progress.cefrLevel.replaceAll(' ', '_')}_${progress.nativeLanguage}_day_$day";
    final String backendUrl = LocalDb.geminiBackendUrl;
    if (backendUrl.isNotEmpty) {
      try {
        final url = Uri.parse("$backendUrl/api/verified-lessons/$serverKey");
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final lesson = Lesson.fromJson(Map<String, dynamic>.from(data));
          debugPrint("AgentOrchestrator: Server Verified Cache HIT for key: $serverKey");
          
          // Save to local cache
          await _cacheBox.put(cacheKey, lesson.toJson());
          
          // Increment cache telemetry
          try {
            final Box progressBox = Hive.box('progress_box');
            final Box usersBox = Hive.box('users_box');
            final String activeUserId = Hive.box('settings_box').get('active_user_id', defaultValue: 'guest_user');
            final updated = progress.copyWith(cacheHitsCount: progress.cacheHitsCount + 1);
            await usersBox.put(activeUserId, updated.toJson());
            await progressBox.put('user_progress', updated.toJson());
          } catch (_) {}
          
          return lesson;
        }
      } catch (e) {
        debugPrint("AgentOrchestrator: Error querying server cache: $e");
      }
    }

    // Cache miss, coordinate real agent pipeline
    final lesson = await SupervisorAgent.instance.generateLessonForDay(day, progress);

    // cost tracking update
    try {
      final Box progressBox = Hive.box('progress_box');
      final Box usersBox = Hive.box('users_box');
      final String activeUserId = Hive.box('settings_box').get('active_user_id', defaultValue: 'guest_user');
      final updated = progress.copyWith(geminiCallsCount: progress.geminiCallsCount + 1);
      await usersBox.put(activeUserId, updated.toJson());
      await progressBox.put('user_progress', updated.toJson());
    } catch (_) {}

    // Save to local cache
    await _cacheBox.put(cacheKey, lesson.toJson());

    // Save to server cache globally
    if (backendUrl.isNotEmpty) {
      try {
        final url = Uri.parse("$backendUrl/api/verified-lessons");
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'key': serverKey,
            'lesson': lesson.toJson(),
          }),
        );
        debugPrint("AgentOrchestrator: Successfully saved lesson to global server cache: $serverKey");
      } catch (e) {
        debugPrint("AgentOrchestrator: Failed to push lesson to global server cache: $e");
      }
    }

    return lesson;
  }

  /// Clears the cached generated lessons (e.g. on profile/motivational updates).
  Future<void> clearLessonCache() async {
    await _cacheBox.clear();
  }

  /// Delegates spoken evaluation to SpeechCoachAgent.
  Future<SpeechEvaluationResult> evaluateSpeech({
    required String userSpeech,
    required String targetSentence,
  }) async {
    return SpeechCoachAgent.instance.evaluateSpeech(
      userSpeech: userSpeech,
      targetSentence: targetSentence,
    );
  }

  /// Delegates reflection validation check to MissionAgent.
  Future<MissionVerificationResult> verifyRealWorldMission({
    required String missionDescription,
    required String userReflection,
  }) async {
    return MissionAgent.instance.verifyMission(
      missionDescription: missionDescription,
      userReflection: userReflection,
    );
  }

  /// Delegates context-specific retention reminders to RetentionAgent.
  Future<String> generateMotivation(UserProgress progress) async {
    final state = AgentState(userProfile: progress);
    return RetentionAgent.instance.generateMotivation(state);
  }

  /// Delegates analytics compilation to GrowthAgent.
  Map<String, dynamic> getAnalytics(UserProgress progress) {
    final state = AgentState(userProfile: progress);
    return GrowthAgent.instance.compileAnalytics(state);
  }
}
