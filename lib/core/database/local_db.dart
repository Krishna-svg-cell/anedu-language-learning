import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_progress.dart';
import '../../models/lesson.dart';
import 'curriculum_generator.dart';
import '../agents/agent_orchestrator.dart';

class LocalDb {
  static List<Lesson> _cachedLessons = [];
  static const String settingsBoxName = 'settings_box';
  static const String progressBoxName = 'progress_box';
  static const String lessonsBoxName = 'lessons_box';
  static const String usersBoxName = 'users_box';

  static bool get isFirebaseInitialized {
    try {
      if (Firebase.apps.isEmpty) return false;
      final apiKey = Firebase.app().options.apiKey;
      if (apiKey.contains('Dummy') || apiKey.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static void configureFirebasePersistence() {
    if (!isFirebaseInitialized) return;
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint("Firestore hybrid offline persistence enabled.");
    } catch (e) {
      debugPrint("Warning setting Firestore settings: $e");
    }
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(progressBoxName);
    await Hive.openBox(lessonsBoxName);
    await Hive.openBox(usersBoxName);
    await Hive.openBox('ai_chat_box');
    await Hive.openBox('speech_history');
    await AgentOrchestrator.init();

    // Seed Gemini API Key & Backend Proxy URL securely
    final settingsBox = Hive.box(settingsBoxName);
    if (settingsBox.get('gemini_api_key') == null) {
      await settingsBox.put('gemini_api_key', ''); // Blank by default in production, API requests route via Proxy server
    }
    if (settingsBox.get('gemini_backend_url') == null) {
      await settingsBox.put('gemini_backend_url', 'http://localhost:3000');
    }

    // Load curriculum.json dynamically from assets
    try {
      final jsonStr = await rootBundle.loadString('assets/config/curriculum.json');
      final List<dynamic> list = jsonDecode(jsonStr);
      _cachedLessons = list.map((item) => Lesson.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      debugPrint("Error loading curriculum.json from assets: $e. Falling back to CurriculumGenerator.");
      _cachedLessons = List.generate(90, (i) => CurriculumGenerator.getRawLessonForDay(i + 1));
    }

    // Seed default lessons if they are empty
    final lessonsBox = Hive.box(lessonsBoxName);
    if (lessonsBox.isEmpty) {
      for (final lesson in _cachedLessons) {
        await lessonsBox.put(lesson.id, {
          'isUnlocked': lesson.isUnlocked,
          'isCompleted': lesson.isCompleted,
        });
      }
    } else {
      // Migration: ensure day_1 is incomplete by default if user has completed 0 lessons
      final progress = getUserProgress();
      if (progress.lessonsCompletedCount == 0) {
        final state = lessonsBox.get('day_1');
        if (state != null) {
          final stateMap = Map<String, dynamic>.from(state);
          if (stateMap['isCompleted'] == true) {
            stateMap['isCompleted'] = false;
            await lessonsBox.put('day_1', stateMap);
          }
        }
      }
    }
  }

  // Settings Box Methods
  static Box get _settingsBox => Hive.box(settingsBoxName);

  static bool get isOnboardingCompleted {
    return _settingsBox.get('onboarding_completed', defaultValue: false);
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _settingsBox.put('onboarding_completed', completed);
  }

  static bool get isDarkTheme {
    return _settingsBox.get('dark_theme', defaultValue: false);
  }

  static Future<void> setDarkTheme(bool isDark) async {
    await _settingsBox.put('dark_theme', isDark);
  }

  static String get geminiApiKey {
    return _settingsBox.get('gemini_api_key', defaultValue: '');
  }

  static Future<void> setGeminiApiKey(String apiKey) async {
    await _settingsBox.put('gemini_api_key', apiKey.trim());
  }

  static String get geminiBackendUrl {
    return _settingsBox.get('gemini_backend_url', defaultValue: 'http://localhost:3000');
  }

  static Future<void> setGeminiBackendUrl(String url) async {
    await _settingsBox.put('gemini_backend_url', url.trim());
  }

  static String? get lastAiChatDate {
    return _settingsBox.get('last_ai_chat_date');
  }

  static Future<void> setLastAiChatDate(DateTime date) async {
    await _settingsBox.put('last_ai_chat_date', date.toIso8601String());
  }

  static String? get lastPronunciationDate {
    return _settingsBox.get('last_pronunciation_date');
  }

  static Future<void> setLastPronunciationDate(DateTime date) async {
    await _settingsBox.put('last_pronunciation_date', date.toIso8601String());
  }

  static String? get claimedDailyBonusDate {
    return _settingsBox.get('claimed_daily_bonus_date');
  }

  static Future<void> setClaimedDailyBonusDate(DateTime date) async {
    await _settingsBox.put('claimed_daily_bonus_date', date.toIso8601String());
  }

  static bool isMilestoneClaimed(String milestoneId) {
    return _settingsBox.get(
      'claimed_milestone_$milestoneId',
      defaultValue: false,
    );
  }

  static Future<void> setMilestoneClaimed(
    String milestoneId,
    bool claimed,
  ) async {
    await _settingsBox.put('claimed_milestone_$milestoneId', claimed);
  }

  // Progress Box Methods
  static Box get _progressBox => Hive.box(progressBoxName);
  static Box get _usersBox => Hive.box(usersBoxName);

  static String get activeUserId =>
      _settingsBox.get('active_user_id', defaultValue: 'guest_user');

  static Future<void> setActiveUserId(String userId) async {
    await _settingsBox.put('active_user_id', userId);
  }

  static int calendarDaysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  static Future<bool> verifyPremiumSubscriptionStatus() async {
    final String backend = geminiBackendUrl;
    final String activeUser = activeUserId;
    const String mockToken = 'tok_sub_active_12345'; 

    if (backend.isEmpty) {
      return getUserProgress().isPremium;
    }

    try {
      final response = await http.post(
        Uri.parse('$backend/api/verify-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': activeUser,
          'subscriptionToken': mockToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isVerified = data['isPremium'] as bool? ?? false;
        
        final progress = getUserProgress();
        if (progress.isPremium != isVerified) {
          final updated = progress.copyWith(isPremium: isVerified);
          await saveUserProgress(updated);
        }
        return isVerified;
      }
    } catch (e) {
      debugPrint("Error verifying subscription: $e");
    }

    return getUserProgress().isPremium;
  }

  static UserProgress getUserProgress() {
    final userId = activeUserId;
    final rawProgress =
        _usersBox.get(userId) ?? _progressBox.get('user_progress');
    UserProgress progress;

    if (rawProgress != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          rawProgress is String ? jsonDecode(rawProgress) : rawProgress,
        );
        progress = UserProgress.fromJson(json);
      } catch (e) {
        if (kDebugMode) print('Error parsing progress: $e');
        progress = UserProgress(lastActive: DateTime.now());
      }
    } else {
      String display = userId;
      if (userId == 'guest_user') {
        display = 'Guest User';
      } else if (userId == 'google_user@anedu.com') {
        display = 'Google User';
      } else {
        final prefix = userId.split('@').first;
        display = prefix.split('_').map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
      }
      progress = UserProgress(
        name: display,
        lastActive: DateTime.now(),
      );
    }

    // Check if daily streak has broken (missed an entire day)
    final now = DateTime.now();
    if (calendarDaysBetween(progress.lastActive, now) > 1) {
      progress = progress.copyWith(streakDays: 0);
      _usersBox.put(userId, progress.toJson());
      _progressBox.put('user_progress', progress.toJson());
    }

    return progress;
  }

  static Future<void> saveUserProgress(UserProgress progress) async {
    final userId = activeUserId;
    await _usersBox.put(userId, progress.toJson());
    await _progressBox.put('user_progress', progress.toJson());

    // Synchronize to Firestore for all Firebase authenticated accounts (including anonymous Guests)
    if (!isFirebaseInitialized) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final List<String> journeyOrder = List<String>.from(_settingsBox.get('journey_order') ?? []);
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          ...progress.toJson(),
          'journey_order': journeyOrder,
        });
      } catch (e) {
        debugPrint("Firestore save progress error (handled offline): $e");
      }
    }
  }

  static Future<void> restoreProgressFromFirestore(String uid) async {
    if (!isFirebaseInitialized) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));
      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data()!;
        final progress = UserProgress.fromJson(data);
        await _usersBox.put(uid, progress.toJson());
        await _progressBox.put('user_progress', progress.toJson());

        if (data['journey_order'] != null) {
          final List<dynamic> jo = data['journey_order'];
          await _settingsBox.put('journey_order', jo.cast<String>());
        }

        // Restore lessons progress
        final lessonsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('lessons')
            .get();
        for (final lessonDoc in lessonsSnap.docs) {
          await _lessonsBox.put(lessonDoc.id, lessonDoc.data());
        }
        await setOnboardingCompleted(true);
      }
    } catch (e) {
      debugPrint("Firestore restore progress error: $e");
    }
  }

  // Lesson Box Methods
  static Box get _lessonsBox => Hive.box(lessonsBoxName);

  static Map<String, dynamic> getLessonState(String lessonId) {
    final state = _lessonsBox.get(lessonId);
    if (state != null) {
      return Map<String, dynamic>.from(state);
    }
    return {'isUnlocked': false, 'isCompleted': false};
  }



  static bool hasCompletedLessonToday() {
    return false;
  }

  static Future<void> recordLessonCompletedToday() async {
    await _settingsBox.put('last_completed_date', DateTime.now().toIso8601String());
  }

  static List<String> generateInitialJourneyOrder(UserProgress progress) {
    final List<Lesson> baseRawLessons = _cachedLessons.isNotEmpty
        ? List<Lesson>.from(_cachedLessons)
        : List.generate(90, (i) => CurriculumGenerator.getRawLessonForDay(i + 1));
    final List<Lesson> sortedRawLessons = CurriculumGenerator.sortLessonsForUser(baseRawLessons, progress);
    return sortedRawLessons.map((l) => l.id).toList();
  }

  static Future<void> saveJourneyOrder(List<String> order) async {
    await _settingsBox.put('journey_order', order);
  }

  static Future<void> updateJourneyOrderOnPreferenceChange(UserProgress progress) async {
    final List<String> currentOrder = List<String>.from(_settingsBox.get('journey_order') ?? []);
    if (currentOrder.isEmpty) {
      final newOrder = generateInitialJourneyOrder(progress);
      await saveJourneyOrder(newOrder);
      return;
    }

    final int completedCount = progress.lessonsCompletedCount;
    if (completedCount >= currentOrder.length) return; // everything is completed

    final List<String> completedPrefix = currentOrder.sublist(0, completedCount);
    final List<String> remainingIds = currentOrder.sublist(completedCount);

    final List<Lesson> remainingLessons = remainingIds.map((id) {
      final dayNum = int.tryParse(id.replaceAll('day_', '')) ?? 1;
      return _cachedLessons.isNotEmpty && dayNum <= _cachedLessons.length
          ? _cachedLessons[dayNum - 1]
          : CurriculumGenerator.getRawLessonForDay(dayNum);
    }).toList();

    final List<Lesson> sortedRemaining = CurriculumGenerator.sortLessonsForUser(remainingLessons, progress);
    final List<String> newOrder = [...completedPrefix, ...sortedRemaining.map((l) => l.id)];
    await saveJourneyOrder(newOrder);
  }

  static List<Lesson> getAllLessons() {
    final progress = getUserProgress();
    
    // Check if we have a journey order initialized. If not, generate it.
    List<String> journeyOrder = List<String>.from(_settingsBox.get('journey_order') ?? []);
    if (journeyOrder.isEmpty) {
      journeyOrder = generateInitialJourneyOrder(progress);
      _settingsBox.put('journey_order', journeyOrder);
    }

    // Adapt sorted raw lessons to align with the journey order array
    final List<Lesson> sortedRawLessons = [];
    for (int i = 0; i < journeyOrder.length; i++) {
      final id = journeyOrder[i];
      final dayNum = int.tryParse(id.replaceAll('day_', '')) ?? 1;

      // Load from agentic cache box first if available
      final cacheKey = 'lesson_day_$dayNum';
      final cacheBox = Hive.isBoxOpen(AgentOrchestrator.cacheBoxName) 
          ? Hive.box(AgentOrchestrator.cacheBoxName) 
          : null;
      final cachedData = cacheBox?.get(cacheKey);
      
      Lesson? cachedLesson;
      if (cachedData != null) {
        try {
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            cachedData is String ? jsonDecode(cachedData) : cachedData,
          );
          cachedLesson = Lesson.fromJson(json);
        } catch (_) {}
      }

      final rawLesson = cachedLesson ?? (_cachedLessons.isNotEmpty && dayNum <= _cachedLessons.length
          ? _cachedLessons[dayNum - 1]
          : CurriculumGenerator.getRawLessonForDay(dayNum));
      sortedRawLessons.add(rawLesson);
    }

    // Append extra Fluency Mode lessons if user completed more than 90
    final int currentTotal = (progress.lessonsCompletedCount + 1) > 90 
        ? (progress.lessonsCompletedCount + 1) 
        : 90;
    while (sortedRawLessons.length < currentTotal) {
      final int nextDay = sortedRawLessons.length + 1;
      final rawFluencyLesson = CurriculumGenerator.getRawLessonForDay(nextDay);
      sortedRawLessons.add(rawFluencyLesson);
      journeyOrder.add(rawFluencyLesson.id);
      _settingsBox.put('journey_order', journeyOrder);
    }

    final List<Lesson> mappedLessons = [];
    final todayCompleted = hasCompletedLessonToday();

    for (int i = 0; i < sortedRawLessons.length; i++) {
      final lesson = sortedRawLessons[i];
      final slotKey = 'slot_$i';
      final state = getLessonState(slotKey);
      final isCompleted = state['isCompleted'] ?? false;

      // Completed is always unlocked (review mode).
      // Next day slot is unlocked only if we did not complete a lesson today.
      // Future day slots are locked.
      bool isUnlocked = false;
      if (i < progress.lessonsCompletedCount) {
        isUnlocked = true;
      } else if (i == progress.lessonsCompletedCount) {
        isUnlocked = !todayCompleted;
      } else {
        isUnlocked = false;
      }

      final personalized = _personalizeLesson(lesson, progress, isUnlocked, isCompleted);
      mappedLessons.add(personalized);
    }

    return mappedLessons;
  }

  static String _getRecurringSpeaker(String speaker) {
    final lower = speaker.toLowerCase();
    if (lower.contains('waiter') || lower.contains('staff')) return 'Ramesh (Waiter)';
    if (lower.contains('classmate') || lower.contains('roommate')) return 'Rahul (Roommate)';
    if (lower.contains('friend') || lower.contains('passerby')) return 'Asha (Friend)';
    if (lower.contains('librarian') || lower.contains('moderator') || lower.contains('professor')) return 'Professor Mehta';
    if (lower.contains('electrician')) return 'Ravi (Electrician)';
    if (lower.contains('guard') || lower.contains('security')) return 'Mahesh (Guard)';
    if (lower.contains('shopkeeper') || lower.contains('vendor')) return 'Lakshmi (Shopkeeper)';
    if (lower.contains('driver') || lower.contains('conductor') || lower.contains('executive')) return 'Kumar (Driver)';
    if (lower.contains('doctor') || lower.contains('nurse')) return 'Doctor Priya';
    if (lower.contains('manager') || lower.contains('boss') || lower.contains('colleague') || lower.contains('coworker')) return 'Anil (Manager)';
    return speaker;
  }

  static Lesson _personalizeLesson(
    Lesson lesson,
    UserProgress progress,
    bool isUnlocked,
    bool isCompleted,
  ) {
    final String name = progress.name.isEmpty ? 'Krishna' : progress.name;

    String replaceName(String source) {
      return source.replaceAll('Krishna', name);
    }

    // 1. Personalize vocabulary
    final personalizedVocab = lesson.vocabulary.map((v) {
      return VocabularyWord(
        id: v.id,
        kannada: replaceName(v.kannada),
        english: replaceName(v.english),
        pronunciation: replaceName(v.pronunciation),
        exampleSentenceKannada: replaceName(v.exampleSentenceKannada),
        exampleSentenceEnglish: replaceName(v.exampleSentenceEnglish),
        category: v.category,
      );
    }).toList();

    // 2. Personalize dialogue & map recurring speakers
    final personalizedDialogue = lesson.dialogue.map((d) {
      final finalSpeaker = d.isUser ? 'User' : _getRecurringSpeaker(d.speaker);
      return DialogueTurn(
        speaker: finalSpeaker,
        textKannada: replaceName(d.textKannada),
        textEnglish: replaceName(d.textEnglish),
        pronunciation: replaceName(d.pronunciation),
        isUser: d.isUser,
      );
    }).toList();

    // 3. Personalize quizzes
    final personalizedQuiz = lesson.quiz.map((q) {
      return QuizQuestion(
        id: q.id,
        questionText: replaceName(q.questionText),
        options: q.options.map(replaceName).toList(),
        correctAnswer: replaceName(q.correctAnswer),
        type: q.type,
      );
    }).toList();

    // 4. Personalize sentence builder words
    final personalizedSentenceWords = lesson.sentenceBuilderWords.map(replaceName).toList();

    return Lesson(
      id: lesson.id,
      title: replaceName(lesson.title),
      subtitle: replaceName(lesson.subtitle),
      category: lesson.category,
      situationDescription: replaceName(lesson.situationDescription),
      vocabulary: personalizedVocab,
      dialogue: personalizedDialogue,
      quiz: personalizedQuiz,
      sentenceBuilderWords: personalizedSentenceWords,
      sentenceBuilderAnswer: replaceName(lesson.sentenceBuilderAnswer),
      sentenceBuilderTranslation: replaceName(lesson.sentenceBuilderTranslation),
      missionDescription: replaceName(lesson.missionDescription),
      xpReward: lesson.xpReward,
      coinReward: lesson.coinReward,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      customIllustrationPath: lesson.customIllustrationPath,
      mittuAnimationState: lesson.mittuAnimationState,
    );
  }

  static Future<void> updateLessonState(
    String lessonId, {
    required bool isCompleted,
    required bool isUnlocked,
    String? completedAt,
  }) async {
    final stateMap = {
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
    };
    await _lessonsBox.put(lessonId, stateMap);

    // Sync to Firestore
    if (!isFirebaseInitialized) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('lessons')
            .doc(lessonId)
            .set(stateMap);
      } catch (e) {
        debugPrint("Firestore lesson sync error (handled offline): $e");
      }
    }
  }

  static bool isSameWeek(DateTime a, DateTime b) {
    final startA = a.subtract(Duration(days: a.weekday - 1));
    final startB = b.subtract(Duration(days: b.weekday - 1));
    return startA.year == startB.year &&
        startA.month == startB.month &&
        startA.day == startB.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static Future<void> completeLesson(String lessonId, {bool isPerfect = false}) async {
    final List<String> journeyOrder = List<String>.from(_settingsBox.get('journey_order') ?? []);
    final int slotIndex = journeyOrder.indexOf(lessonId);
    final String slotKey = slotIndex != -1 ? 'slot_$slotIndex' : lessonId;

    final state = getLessonState(slotKey);
    final alreadyCompleted = state['isCompleted'] ?? false;

    // Review mode does not award additional XP or duplicate rewards
    if (alreadyCompleted) {
      return;
    }

    final now = DateTime.now();

    // 1. Mark lesson completed locally with timestamp (which also syncs to Firestore)
    await updateLessonState(
      slotKey,
      isCompleted: true,
      isUnlocked: true,
      completedAt: now.toIso8601String(),
    );

    // Record that we completed a lesson today for the daily time-lock
    await recordLessonCompletedToday();

    final dayNumStr = lessonId.replaceAll('day_', '');
    final dayNum = int.tryParse(dayNumStr) ?? 1;
    final currentLesson = _cachedLessons.isNotEmpty && dayNum <= _cachedLessons.length
        ? _cachedLessons[dayNum - 1]
        : CurriculumGenerator.getRawLessonForDay(dayNum);
    final user = getUserProgress();

    // Calculate new streak
    int newStreak = user.streakDays;
    final diff = calendarDaysBetween(user.lastActive, now);
    if (diff == 1) {
      newStreak = user.streakDays + 1;
    } else if (diff == 0) {
      if (newStreak == 0) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // Streak XP Multiplier
    double multiplier = 1.0;
    if (newStreak >= 7) {
      multiplier = 1.5;
    } else if (newStreak >= 3) {
      multiplier = 1.2;
    }

    int baseReward = (currentLesson.xpReward * multiplier).round();
    if (isPerfect) {
      baseReward += 50; // Perfect bonus XP
    }

    // Calculate weekly/monthly XP resets
    int newXpWeekly = isSameWeek(user.lastActive, now) ? user.xpWeekly : 0;
    int newXpMonthly = isSameMonth(user.lastActive, now) ? user.xpMonthly : 0;

    newXpWeekly += baseReward;
    newXpMonthly += baseReward;

    final int nextXp = user.xp + baseReward;
    final int nextLevel = (nextXp / 300).floor() + 1;

    final category = currentLesson.category;
    
    // Survival decay base: decrease all categories by 3 points (minimum 10) to reflect forgetfulness
    int nextGreetings = (user.survivalGreetings - 3).clamp(10, 100);
    int nextTravel = (user.survivalTravel - 3).clamp(10, 100);
    int nextRestaurant = (user.survivalRestaurant - 3).clamp(10, 100);
    int nextShopping = (user.survivalShopping - 3).clamp(10, 100);
    int nextCollege = (user.survivalCollege - 3).clamp(10, 100);
    int nextOffice = (user.survivalOffice - 3).clamp(10, 100);
    int nextEmergency = (user.survivalEmergency - 3).clamp(10, 100);
    int nextDailyLife = (user.survivalDailyLife - 3).clamp(10, 100);

    // Apply the active category boost
    switch (category) {
      case LessonCategory.basics:
        nextDailyLife = (user.survivalDailyLife + 15).clamp(10, 100);
        break;
      case LessonCategory.greetings:
      case LessonCategory.introductions:
        nextGreetings = (user.survivalGreetings + 15).clamp(10, 100);
        break;
      case LessonCategory.travel:
        nextTravel = (user.survivalTravel + 15).clamp(10, 100);
        break;
      case LessonCategory.restaurant:
        nextRestaurant = (user.survivalRestaurant + 15).clamp(10, 100);
        break;
      case LessonCategory.shopping:
        nextShopping = (user.survivalShopping + 15).clamp(10, 100);
        break;
      case LessonCategory.college:
        nextCollege = (user.survivalCollege + 15).clamp(10, 100);
        break;
      case LessonCategory.workplace:
        nextOffice = (user.survivalOffice + 15).clamp(10, 100);
        break;
      case LessonCategory.fluentConversation:
        nextGreetings = (user.survivalGreetings + 5).clamp(10, 100);
        nextTravel = (user.survivalTravel + 5).clamp(10, 100);
        nextRestaurant = (user.survivalRestaurant + 5).clamp(10, 100);
        nextShopping = (user.survivalShopping + 5).clamp(10, 100);
        nextCollege = (user.survivalCollege + 5).clamp(10, 100);
        nextOffice = (user.survivalOffice + 5).clamp(10, 100);
        nextEmergency = (user.survivalEmergency + 5).clamp(10, 100);
        nextDailyLife = (user.survivalDailyLife + 5).clamp(10, 100);
        break;
    }

    int earnedCoins = currentLesson.coinReward;
    if (isPerfect) {
      earnedCoins += 10; // Extra coins for perfection
    }

    // Check achievements
    final unlocked = List<String>.from(_settingsBox.get('unlocked_achievements') ?? []);
    int achievementBonusCoins = 0;

    void checkUnlock(String id, int coins) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        achievementBonusCoins += coins;
      }
    }

    // Streak consistency checks
    if (newStreak >= 3) checkUnlock('consistency_3', 20);
    if (newStreak >= 7) checkUnlock('consistency_7', 50);
    if (newStreak >= 30) checkUnlock('consistency_30', 200);

    // Category master checks
    final allLessons = getAllLessons();
    final catName = category.toString().split('.').last;
    if (catName == 'restaurant') {
      final restaurantLessons = allLessons.where((l) => l.category == LessonCategory.restaurant).toList();
      if (restaurantLessons.isNotEmpty && restaurantLessons.every((l) => l.isCompleted || l.id == lessonId)) {
        checkUnlock('cafe_master', 100);
      }
    }
    if (catName == 'college') {
      final collegeLessons = allLessons.where((l) => l.category == LessonCategory.college).toList();
      if (collegeLessons.isNotEmpty && collegeLessons.every((l) => l.isCompleted || l.id == lessonId)) {
        checkUnlock('campus_hero', 100);
      }
    }
    if (catName == 'travel') {
      final travelLessons = allLessons.where((l) => l.category == LessonCategory.travel).toList();
      if (travelLessons.isNotEmpty && travelLessons.every((l) => l.isCompleted || l.id == lessonId)) {
        checkUnlock('bengaluru_explorer', 100);
      }
    }

    if (user.lessonsCompletedCount + 1 >= 50) {
      checkUnlock('confident_speaker', 250);
    }

    if (achievementBonusCoins > 0) {
      await _settingsBox.put('unlocked_achievements', unlocked);
    }

    final updatedUser = user.copyWith(
      xp: nextXp,
      xpWeekly: newXpWeekly,
      xpMonthly: newXpMonthly,
      coins: user.coins + earnedCoins + achievementBonusCoins,
      streakDays: newStreak,
      lastActive: now,
      currentLevel: nextLevel,
      lessonsCompletedCount: user.lessonsCompletedCount + 1,
      wordsLearnedCount:
          user.wordsLearnedCount + currentLesson.vocabulary.length,
      phrasesLearnedCount:
          user.phrasesLearnedCount + currentLesson.dialogue.length + 1,
      survivalGreetings: nextGreetings,
      survivalTravel: nextTravel,
      survivalRestaurant: nextRestaurant,
      survivalShopping: nextShopping,
      survivalCollege: nextCollege,
      survivalOffice: nextOffice,
      survivalEmergency: nextEmergency,
      survivalDailyLife: nextDailyLife,
    );
    await saveUserProgress(updatedUser);
  }

  static List<UserProgress> getRealUsers() {
    final box = Hive.box(usersBoxName);
    final List<UserProgress> list = [];
    for (final key in box.keys) {
      final val = box.get(key);
      if (val != null) {
        try {
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            val is String ? jsonDecode(val) : val,
          );
          list.add(UserProgress.fromJson(json));
        } catch (e) {
          if (kDebugMode) print('Error parsing user list: $e');
        }
      }
    }
    // If list is empty (e.g. guest hasn't saved yet), add current user progress
    if (list.isEmpty) {
      list.add(getUserProgress());
    }
    return list;
  }

  static String get equippedAccessory => _settingsBox.get('equipped_accessory') ?? '';
  
  static Future<void> setEquippedAccessory(String val) async {
    await _settingsBox.put('equipped_accessory', val);
  }

  static List<String> get purchasedAccessories => List<String>.from(_settingsBox.get('purchased_accessories') ?? []);
  
  static Future<void> buyAccessory(String id, int cost) async {
    final list = purchasedAccessories;
    if (!list.contains(id)) {
      list.add(id);
      await _settingsBox.put('purchased_accessories', list);
      final user = getUserProgress();
      await saveUserProgress(user.copyWith(coins: (user.coins - cost).clamp(0, 999999)));
    }
  }

  static List<String> getUnlockedAchievements() {
    return List<String>.from(_settingsBox.get('unlocked_achievements') ?? []);
  }

  static List<Map<String, dynamic>> getWeakWords() {
    final list = _settingsBox.get('weak_words');
    if (list == null) return [];
    return List<Map<dynamic, dynamic>>.from(list).map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Future<void> addWeakWord(String lessonId, int quizIndex) async {
    final list = getWeakWords();
    // Prevent duplicate entries
    final exists = list.any((m) => m['lessonId'] == lessonId && m['quizIndex'] == quizIndex);
    if (!exists) {
      list.add({'lessonId': lessonId, 'quizIndex': quizIndex});
      await _settingsBox.put('weak_words', list);
    }
  }

  static Future<void> removeWeakWord(String lessonId, int quizIndex) async {
    final list = getWeakWords();
    list.removeWhere((m) => m['lessonId'] == lessonId && m['quizIndex'] == quizIndex);
    await _settingsBox.put('weak_words', list);
  }

  // Clear Database for resetting app
  static Future<void> clearAll() async {
    await _settingsBox.clear();
    await _progressBox.clear();
    await _lessonsBox.clear();
    await _usersBox.clear();

    // Reseed curriculum lessons
    final totalLessons = _cachedLessons.isNotEmpty
        ? _cachedLessons
        : List.generate(90, (i) => CurriculumGenerator.getRawLessonForDay(i + 1));
    for (final lesson in totalLessons) {
      await _lessonsBox.put(lesson.id, {
        'isUnlocked': lesson.isUnlocked,
        'isCompleted': lesson.isCompleted,
      });
    }
  }
}
