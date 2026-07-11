import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/local_db.dart';
import '../../models/user_progress.dart';
import '../../models/lesson.dart';
import '../agents/agent_orchestrator.dart';

// 1. Theme Provider
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier()
    : super(LocalDb.isDarkTheme ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() async {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await LocalDb.setDarkTheme(false);
    } else {
      state = ThemeMode.dark;
      await LocalDb.setDarkTheme(true);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// 2. User Progress Provider
class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier() : super(LocalDb.getUserProgress());

  void reloadProgress() {
    state = LocalDb.getUserProgress();
  }

  void updateProgress(UserProgress updated) async {
    state = updated;
    await LocalDb.saveUserProgress(updated);
  }

  void addXpAndCoins(int xp, int coins) async {
    final updated = state.copyWith(
      xp: state.xp + xp,
      coins: state.coins + coins,
    );
    updateProgress(updated);
  }

  void recordQuizCompleted() async {
    final updated = state.copyWith(
      quizzesCompletedCount: state.quizzesCompletedCount + 1,
    );
    updateProgress(updated);
  }

  void saveOnboardingDetails({
    required String name,
    required int age,
    required String role,
    required String motivation,
    required List<String> commuteModes,
    required List<String> visitedPlaces,
    required String currentLevel,
    required String nativeLanguage,
    required String learningGoal,
    required int initialConfidence,
  }) async {
    final updated = state.copyWith(
      name: name,
      age: age,
      role: role,
      motivation: motivation,
      commuteModes: commuteModes,
      visitedPlaces: visitedPlaces,
      level: currentLevel,
      nativeLanguage: nativeLanguage,
      learningGoal: learningGoal,
      initialConfidence: initialConfidence,
      currentConfidence: initialConfidence,
    );
    await LocalDb.saveUserProgress(updated);
    await LocalDb.updateJourneyOrderOnPreferenceChange(updated);
    await LocalDb.setOnboardingCompleted(true);
    state = updated;
  }

  void resetProgress() async {
    await LocalDb.clearAll();
    state = UserProgress(lastActive: DateTime.now());
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
      return UserProgressNotifier();
    });

// 3. Lessons List Provider
class LessonsListNotifier extends StateNotifier<List<Lesson>> {
  final Ref _ref;
  LessonsListNotifier(this._ref) : super(LocalDb.getAllLessons());

  void reloadLessons() {
    state = LocalDb.getAllLessons();
  }

  Future<void> pregeneratePersonalizedLesson(int day) async {
    final progress = _ref.read(userProgressProvider);
    await AgentOrchestrator.instance.getLessonForDay(day, progress);
    reloadLessons();
  }

  void completeLesson(String lessonId, {bool isPerfect = false}) async {
    await LocalDb.completeLesson(lessonId, isPerfect: isPerfect);
    reloadLessons();
    _ref.read(userProgressProvider.notifier).reloadProgress();
  }
}

final lessonsListProvider =
    StateNotifierProvider<LessonsListNotifier, List<Lesson>>((ref) {
      return LessonsListNotifier(ref);
    });
