class UserProgress {
  final String name;
  final int age;
  final String role; // Student, Professional, Tourist, etc.
  final String motivation; // Job, Study, Daily, etc.
  final List<String> commuteModes;
  final List<String> visitedPlaces;
  final String level; // None, Few Words, Basic, Intermediate
  final String nativeLanguage;
  final String learningGoal;
  final int initialConfidence;
  final int currentConfidence;
  final int weakRespectfulWordsCount;
  final String cefrLevel;
  final bool isPremium;
  final int geminiCallsCount;
  final int cacheHitsCount;
  final String targetLanguageCode;
  final double realWorldConfidenceScore;
  final double survivalOutcomeIntroduce;
  final double survivalOutcomeOrder;
  final double survivalOutcomeTravel;
  final double survivalOutcomeNegotiate;
  final double survivalOutcomeProblem;
  final String weeklyCheckInIssue;

  // Gamification Metrics
  final int xp;
  final int xpWeekly;
  final int xpMonthly;
  final int coins;
  final int streakDays;
  final int currentLevel;
  final DateTime lastActive;

  // Learning Counts
  final int wordsLearnedCount;
  final int phrasesLearnedCount;
  final int lessonsCompletedCount;
  final int quizzesCompletedCount;

  // Survival Scores (0 to 100)
  final int survivalGreetings;
  final int survivalTravel;
  final int survivalRestaurant;
  final int survivalShopping;
  final int survivalCollege;
  final int survivalOffice;
  final int survivalEmergency;
  final int survivalDailyLife;

  UserProgress({
    this.name = 'Guest User',
    this.age = 18,
    this.role = 'New Learner',
    this.motivation = 'Daily Survival',
    this.commuteModes = const [],
    this.visitedPlaces = const [],
    this.level = 'None',
    this.nativeLanguage = 'English',
    this.learningGoal = 'General Fluency',
    this.initialConfidence = 10,
    this.currentConfidence = 10,
    this.weakRespectfulWordsCount = 0,
    this.cefrLevel = 'Level 0: Silent Beginner',
    this.isPremium = false,
    this.geminiCallsCount = 0,
    this.cacheHitsCount = 0,
    this.targetLanguageCode = 'kan',
    this.realWorldConfidenceScore = 10.0,
    this.survivalOutcomeIntroduce = 10.0,
    this.survivalOutcomeOrder = 10.0,
    this.survivalOutcomeTravel = 10.0,
    this.survivalOutcomeNegotiate = 10.0,
    this.survivalOutcomeProblem = 10.0,
    this.weeklyCheckInIssue = 'None',
    this.xp = 0,
    this.xpWeekly = 0,
    this.xpMonthly = 0,
    this.coins = 0,
    this.streakDays = 0,
    this.currentLevel = 1,
    required this.lastActive,
    this.wordsLearnedCount = 0,
    this.phrasesLearnedCount = 0,
    this.lessonsCompletedCount = 0,
    this.quizzesCompletedCount = 0,
    this.survivalGreetings = 0,
    this.survivalTravel = 0,
    this.survivalRestaurant = 0,
    this.survivalShopping = 0,
    this.survivalCollege = 0,
    this.survivalOffice = 0,
    this.survivalEmergency = 0,
    this.survivalDailyLife = 0,
  });

  // Calculate overall survival score
  double get overallSurvivalScore {
    return (survivalGreetings +
            survivalTravel +
            survivalRestaurant +
            survivalShopping +
            survivalCollege +
            survivalOffice +
            survivalEmergency +
            survivalDailyLife) /
        8.0;
  }

  // Calculate user level dynamically based on XP (300 XP per level)
  int get calculatedLevel => (xp / 300).floor() + 1;
  double get percentToNextLevel => (xp % 300) / 300.0;

  // CopyWith helper
  UserProgress copyWith({
    String? name,
    int? age,
    String? role,
    String? motivation,
    List<String>? commuteModes,
    List<String>? visitedPlaces,
    String? level,
    String? nativeLanguage,
    String? learningGoal,
    int? initialConfidence,
    int? currentConfidence,
    int? weakRespectfulWordsCount,
    String? cefrLevel,
    bool? isPremium,
    int? geminiCallsCount,
    int? cacheHitsCount,
    String? targetLanguageCode,
    double? realWorldConfidenceScore,
    double? survivalOutcomeIntroduce,
    double? survivalOutcomeOrder,
    double? survivalOutcomeTravel,
    double? survivalOutcomeNegotiate,
    double? survivalOutcomeProblem,
    String? weeklyCheckInIssue,
    int? xp,
    int? xpWeekly,
    int? xpMonthly,
    int? coins,
    int? streakDays,
    int? currentLevel,
    DateTime? lastActive,
    int? wordsLearnedCount,
    int? phrasesLearnedCount,
    int? lessonsCompletedCount,
    int? quizzesCompletedCount,
    int? survivalGreetings,
    int? survivalTravel,
    int? survivalRestaurant,
    int? survivalShopping,
    int? survivalCollege,
    int? survivalOffice,
    int? survivalEmergency,
    int? survivalDailyLife,
  }) {
    return UserProgress(
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      motivation: motivation ?? this.motivation,
      commuteModes: commuteModes ?? this.commuteModes,
      visitedPlaces: visitedPlaces ?? this.visitedPlaces,
      level: level ?? this.level,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningGoal: learningGoal ?? this.learningGoal,
      initialConfidence: initialConfidence ?? this.initialConfidence,
      currentConfidence: currentConfidence ?? this.currentConfidence,
      weakRespectfulWordsCount: weakRespectfulWordsCount ?? this.weakRespectfulWordsCount,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      isPremium: isPremium ?? this.isPremium,
      geminiCallsCount: geminiCallsCount ?? this.geminiCallsCount,
      cacheHitsCount: cacheHitsCount ?? this.cacheHitsCount,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      realWorldConfidenceScore: realWorldConfidenceScore ?? this.realWorldConfidenceScore,
      survivalOutcomeIntroduce: survivalOutcomeIntroduce ?? this.survivalOutcomeIntroduce,
      survivalOutcomeOrder: survivalOutcomeOrder ?? this.survivalOutcomeOrder,
      survivalOutcomeTravel: survivalOutcomeTravel ?? this.survivalOutcomeTravel,
      survivalOutcomeNegotiate: survivalOutcomeNegotiate ?? this.survivalOutcomeNegotiate,
      survivalOutcomeProblem: survivalOutcomeProblem ?? this.survivalOutcomeProblem,
      weeklyCheckInIssue: weeklyCheckInIssue ?? this.weeklyCheckInIssue,
      xp: xp ?? this.xp,
      xpWeekly: xpWeekly ?? this.xpWeekly,
      xpMonthly: xpMonthly ?? this.xpMonthly,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      currentLevel: currentLevel ?? this.currentLevel,
      lastActive: lastActive ?? this.lastActive,
      wordsLearnedCount: wordsLearnedCount ?? this.wordsLearnedCount,
      phrasesLearnedCount: phrasesLearnedCount ?? this.phrasesLearnedCount,
      lessonsCompletedCount:
          lessonsCompletedCount ?? this.lessonsCompletedCount,
      quizzesCompletedCount:
          quizzesCompletedCount ?? this.quizzesCompletedCount,
      survivalGreetings: survivalGreetings ?? this.survivalGreetings,
      survivalTravel: survivalTravel ?? this.survivalTravel,
      survivalRestaurant: survivalRestaurant ?? this.survivalRestaurant,
      survivalShopping: survivalShopping ?? this.survivalShopping,
      survivalCollege: survivalCollege ?? this.survivalCollege,
      survivalOffice: survivalOffice ?? this.survivalOffice,
      survivalEmergency: survivalEmergency ?? this.survivalEmergency,
      survivalDailyLife: survivalDailyLife ?? this.survivalDailyLife,
    );
  }

  // JSON helper for Hive/local DB
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'role': role,
      'motivation': motivation,
      'commuteModes': commuteModes,
      'visitedPlaces': visitedPlaces,
      'level': level,
      'nativeLanguage': nativeLanguage,
      'learningGoal': learningGoal,
      'initialConfidence': initialConfidence,
      'currentConfidence': currentConfidence,
      'weakRespectfulWordsCount': weakRespectfulWordsCount,
      'cefrLevel': cefrLevel,
      'isPremium': isPremium,
      'geminiCallsCount': geminiCallsCount,
      'cacheHitsCount': cacheHitsCount,
      'targetLanguageCode': targetLanguageCode,
      'realWorldConfidenceScore': realWorldConfidenceScore,
      'survivalOutcomeIntroduce': survivalOutcomeIntroduce,
      'survivalOutcomeOrder': survivalOutcomeOrder,
      'survivalOutcomeTravel': survivalOutcomeTravel,
      'survivalOutcomeNegotiate': survivalOutcomeNegotiate,
      'survivalOutcomeProblem': survivalOutcomeProblem,
      'weeklyCheckInIssue': weeklyCheckInIssue,
      'xp': xp,
      'xpWeekly': xpWeekly,
      'xpMonthly': xpMonthly,
      'coins': coins,
      'streakDays': streakDays,
      'currentLevel': currentLevel,
      'lastActive': lastActive.toIso8601String(),
      'wordsLearnedCount': wordsLearnedCount,
      'phrasesLearnedCount': phrasesLearnedCount,
      'lessonsCompletedCount': lessonsCompletedCount,
      'quizzesCompletedCount': quizzesCompletedCount,
      'survivalGreetings': survivalGreetings,
      'survivalTravel': survivalTravel,
      'survivalRestaurant': survivalRestaurant,
      'survivalShopping': survivalShopping,
      'survivalCollege': survivalCollege,
      'survivalOffice': survivalOffice,
      'survivalEmergency': survivalEmergency,
      'survivalDailyLife': survivalDailyLife,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      name: json['name'] ?? 'Guest User',
      age: json['age'] ?? 18,
      role: json['role'] ?? 'New Learner',
      motivation: json['motivation'] ?? 'Daily Survival',
      commuteModes: List<String>.from(json['commuteModes'] ?? []),
      visitedPlaces: List<String>.from(json['visitedPlaces'] ?? []),
      level: json['level'] ?? 'None',
      nativeLanguage: json['nativeLanguage'] ?? 'English',
      learningGoal: json['learningGoal'] ?? 'General Fluency',
      initialConfidence: json['initialConfidence'] ?? 10,
      currentConfidence: json['currentConfidence'] ?? 10,
      weakRespectfulWordsCount: json['weakRespectfulWordsCount'] ?? 0,
      cefrLevel: json['cefrLevel'] ?? 'Level 0: Silent Beginner',
      isPremium: json['isPremium'] ?? false,
      geminiCallsCount: json['geminiCallsCount'] ?? 0,
      cacheHitsCount: json['cacheHitsCount'] ?? 0,
      targetLanguageCode: json['targetLanguageCode'] ?? 'kan',
      realWorldConfidenceScore: (json['realWorldConfidenceScore'] as num?)?.toDouble() ?? 10.0,
      survivalOutcomeIntroduce: (json['survivalOutcomeIntroduce'] as num?)?.toDouble() ?? 10.0,
      survivalOutcomeOrder: (json['survivalOutcomeOrder'] as num?)?.toDouble() ?? 10.0,
      survivalOutcomeTravel: (json['survivalOutcomeTravel'] as num?)?.toDouble() ?? 10.0,
      survivalOutcomeNegotiate: (json['survivalOutcomeNegotiate'] as num?)?.toDouble() ?? 10.0,
      survivalOutcomeProblem: (json['survivalOutcomeProblem'] as num?)?.toDouble() ?? 10.0,
      weeklyCheckInIssue: json['weeklyCheckInIssue'] ?? 'None',
      xp: json['xp'] ?? 0,
      xpWeekly: json['xpWeekly'] ?? 0,
      xpMonthly: json['xpMonthly'] ?? 0,
      coins: json['coins'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
      wordsLearnedCount: json['wordsLearnedCount'] ?? 0,
      phrasesLearnedCount: json['phrasesLearnedCount'] ?? 0,
      lessonsCompletedCount: json['lessonsCompletedCount'] ?? 0,
      quizzesCompletedCount: json['quizzesCompletedCount'] ?? 0,
      survivalGreetings: json['survivalGreetings'] ?? 0,
      survivalTravel: json['survivalTravel'] ?? 0,
      survivalRestaurant: json['survivalRestaurant'] ?? 0,
      survivalShopping: json['survivalShopping'] ?? 0,
      survivalCollege: json['survivalCollege'] ?? 0,
      survivalOffice: json['survivalOffice'] ?? 0,
      survivalEmergency: json['survivalEmergency'] ?? 0,
      survivalDailyLife: json['survivalDailyLife'] ?? 0,
    );
  }
}
