enum LessonCategory {
  basics,
  greetings,
  introductions,
  travel,
  restaurant,
  shopping,
  college,
  workplace,
  fluentConversation,
}

class VocabularyWord {
  final String id;
  final String kannada;
  final String english;
  final String pronunciation;
  final String exampleSentenceKannada;
  final String exampleSentenceEnglish;
  final String category; // e.g. "greeting", "food", "directions"

  VocabularyWord({
    required this.id,
    required this.kannada,
    required this.english,
    required this.pronunciation,
    this.exampleSentenceKannada = '',
    this.exampleSentenceEnglish = '',
    this.category = 'general',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kannada': kannada,
        'english': english,
        'pronunciation': pronunciation,
        'exampleSentenceKannada': exampleSentenceKannada,
        'exampleSentenceEnglish': exampleSentenceEnglish,
        'category': category,
      };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
        id: json['id'] as String,
        kannada: json['kannada'] as String,
        english: json['english'] as String,
        pronunciation: json['pronunciation'] as String,
        exampleSentenceKannada: json['exampleSentenceKannada'] as String? ?? '',
        exampleSentenceEnglish: json['exampleSentenceEnglish'] as String? ?? '',
        category: json['category'] as String? ?? 'general',
      );
}

class DialogueTurn {
  final String speaker; // "Mittu", "Waiter", "Auto Driver", "User"
  final String textKannada;
  final String textEnglish;
  final String pronunciation;
  final bool isUser;

  DialogueTurn({
    required this.speaker,
    required this.textKannada,
    required this.textEnglish,
    required this.pronunciation,
    this.isUser = false,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'textKannada': textKannada,
        'textEnglish': textEnglish,
        'pronunciation': pronunciation,
        'isUser': isUser,
      };

  factory DialogueTurn.fromJson(Map<String, dynamic> json) => DialogueTurn(
        speaker: json['speaker'] as String,
        textKannada: json['textKannada'] as String,
        textEnglish: json['textEnglish'] as String,
        pronunciation: json['pronunciation'] as String,
        isUser: json['isUser'] as bool? ?? false,
      );
}

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String type; // "mcq", "fill_blank", "listening"

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.type = 'mcq',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        'type': type,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        questionText: json['questionText'] as String,
        options: List<String>.from(json['options'] as List),
        correctAnswer: json['correctAnswer'] as String,
        type: json['type'] as String? ?? 'mcq',
      );
}

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final LessonCategory category;
  final String situationDescription;
  final List<VocabularyWord> vocabulary;
  final List<DialogueTurn> dialogue;
  final List<QuizQuestion> quiz;
  final List<String> sentenceBuilderWords; // Chips for drag-and-drop
  final String sentenceBuilderAnswer; // Correct ordered sentence
  final String sentenceBuilderTranslation; // English translation of the sentence
  final String missionDescription;
  final int xpReward;
  final int coinReward;
  final bool isUnlocked;
  final bool isCompleted;
  final String? customIllustrationPath;
  final String? mittuAnimationState;
  final List<String> grammarBites;

  String get illustrationPath {
    if (customIllustrationPath != null && customIllustrationPath!.contains('day_')) {
      return customIllustrationPath!;
    }
    if (id.startsWith('day_')) {
      final numStr = id.replaceAll('day_', '');
      final parsed = int.tryParse(numStr);
      if (parsed != null) {
        return 'assets/images/situations/day_$parsed.webp';
      }
    }
    switch (id) {
      case 'basics_1': return 'assets/images/situations/day_1.webp';
      case 'greetings_1': return 'assets/images/situations/day_2.webp';
      case 'travel_1': return 'assets/images/situations/day_3.webp';
      case 'restaurant_1': return 'assets/images/situations/day_4.webp';
      case 'workplace_1': return 'assets/images/situations/day_5.webp';
    }
    return customIllustrationPath ?? 'assets/images/situations/day_1.webp';
  }

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.situationDescription,
    required this.vocabulary,
    required this.dialogue,
    required this.quiz,
    required this.sentenceBuilderWords,
    required this.sentenceBuilderAnswer,
    required this.sentenceBuilderTranslation,
    required this.missionDescription,
    this.xpReward = 15,
    this.coinReward = 10,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.customIllustrationPath,
    this.mittuAnimationState,
    this.grammarBites = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category.name,
        'situationDescription': situationDescription,
        'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
        'dialogue': dialogue.map((d) => d.toJson()).toList(),
        'quiz': quiz.map((q) => q.toJson()).toList(),
        'sentenceBuilderWords': sentenceBuilderWords,
        'sentenceBuilderAnswer': sentenceBuilderAnswer,
        'sentenceBuilderTranslation': sentenceBuilderTranslation,
        'missionDescription': missionDescription,
        'xpReward': xpReward,
        'coinReward': coinReward,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'customIllustrationPath': customIllustrationPath,
        'mittuAnimationState': mittuAnimationState,
        'grammarBites': grammarBites,
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        category: LessonCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => LessonCategory.basics,
        ),
        situationDescription: json['situationDescription'] as String,
        vocabulary: (json['vocabulary'] as List)
            .map((v) => VocabularyWord.fromJson(Map<String, dynamic>.from(v)))
            .toList(),
        dialogue: (json['dialogue'] as List)
            .map((d) => DialogueTurn.fromJson(Map<String, dynamic>.from(d)))
            .toList(),
        quiz: (json['quiz'] as List)
            .map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q)))
            .toList(),
        sentenceBuilderWords: List<String>.from(json['sentenceBuilderWords'] as List),
        sentenceBuilderAnswer: json['sentenceBuilderAnswer'] as String,
        sentenceBuilderTranslation: json['sentenceBuilderTranslation'] as String,
        missionDescription: json['missionDescription'] as String,
        xpReward: json['xpReward'] as int? ?? 15,
        coinReward: json['coinReward'] as int? ?? 10,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
        customIllustrationPath: json['customIllustrationPath'] as String?,
        mittuAnimationState: json['mittuAnimationState'] as String?,
        grammarBites: json['grammarBites'] != null
            ? List<String>.from(json['grammarBites'] as List)
            : const [],
      );

  Lesson copyWith({
    String? id,
    String? title,
    String? subtitle,
    LessonCategory? category,
    String? situationDescription,
    List<VocabularyWord>? vocabulary,
    List<DialogueTurn>? dialogue,
    List<QuizQuestion>? quiz,
    List<String>? sentenceBuilderWords,
    String? sentenceBuilderAnswer,
    String? sentenceBuilderTranslation,
    String? missionDescription,
    int? xpReward,
    int? coinReward,
    bool? isUnlocked,
    bool? isCompleted,
    String? customIllustrationPath,
    String? mittuAnimationState,
    List<String>? grammarBites,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      situationDescription: situationDescription ?? this.situationDescription,
      vocabulary: vocabulary ?? this.vocabulary,
      dialogue: dialogue ?? this.dialogue,
      quiz: quiz ?? this.quiz,
      sentenceBuilderWords: sentenceBuilderWords ?? this.sentenceBuilderWords,
      sentenceBuilderAnswer: sentenceBuilderAnswer ?? this.sentenceBuilderAnswer,
      sentenceBuilderTranslation: sentenceBuilderTranslation ?? this.sentenceBuilderTranslation,
      missionDescription: missionDescription ?? this.missionDescription,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      customIllustrationPath: customIllustrationPath ?? this.customIllustrationPath,
      mittuAnimationState: mittuAnimationState ?? this.mittuAnimationState,
      grammarBites: grammarBites ?? this.grammarBites,
    );
  }

  // Create sample database lessons
  static List<Lesson> getSampleLessons() {
    final List<Lesson> list = [];

    // Day 1 to 5: Hand-written detailed lessons covering complete conversations
    list.add(
      Lesson(
        id: 'basics_1',
        title: 'Meeting Someone',
        subtitle: 'Learn greetings, introductions, and origins.',
        category: LessonCategory.basics,
        situationDescription:
            'Introduce yourself to a local resident. Exchange names, ask how they are doing, share your background, check if they are working or studying, and end the conversation politely.',
        isUnlocked: true,
        isCompleted: false,
        customIllustrationPath: 'assets/images/situations/basics_1.webp',
        mittuAnimationState: 'mittu_wave',
        vocabulary: [
          VocabularyWord(
            id: 'v1',
            kannada: 'Namaskara',
            english: 'Hello',
            pronunciation: 'Nah-mah-skah-rah',
          ),
          VocabularyWord(
            id: 'v2',
            kannada: 'Hegiddira?',
            english: 'How are you?',
            pronunciation: 'Hay-geed-dee-rah?',
          ),
          VocabularyWord(
            id: 'v3',
            kannada: 'Naanu chennagiddene',
            english: 'I am doing well',
            pronunciation: 'Naanu chen-nah-geed-deh-neh',
          ),
          VocabularyWord(
            id: 'v4',
            kannada: 'Ninna hesaru enu?',
            english: 'What is your name?',
            pronunciation: 'Neen-nah heh-sah-roo ay-noo?',
          ),
          VocabularyWord(
            id: 'v5',
            kannada: 'Nanna hesaru...',
            english: 'My name is...',
            pronunciation: 'Nan-nah heh-sah-roo...',
          ),
          VocabularyWord(
            id: 'v6',
            kannada: 'Neevu yaava ooru?',
            english: 'Where are you from?',
            pronunciation: 'Nee-voo yaah-vah oo-roo?',
          ),
          VocabularyWord(
            id: 'v7',
            kannada: 'Naanu student',
            english: 'I am a student',
            pronunciation: 'Naanu student',
          ),
          VocabularyWord(
            id: 'v8',
            kannada: 'Nale sigona',
            english: 'See you tomorrow',
            pronunciation: 'Nah-lay see-goh-nah',
          ),
        ],
        dialogue: [
          DialogueTurn(
            speaker: 'Mittu',
            textKannada: 'Namaskara! Ninna hesaru enu?',
            textEnglish: 'Hello! What is your name?',
            pronunciation: 'Namaskara! Neen-nah heh-sah-roo ay-noo?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Namaskara, nanna hesaru Krishna. Hegiddira?',
            textEnglish: 'Hello, my name is Krishna. How are you?',
            pronunciation:
                'Namaskara, nan-nah heh-sah-roo Krishna. Hay-geed-dee-rah?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Mittu',
            textKannada:
                'Naanu chennagiddene, dhanyavada! Neevu student or working?',
            textEnglish:
                'I am doing well, thank you! Are you a student or working?',
            pronunciation:
                'Naanu chen-nah-geed-deh-neh, dhan-yah-vah-dah! Nee-voo student or working?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Naanu college student. Neevu yaava ooru?',
            textEnglish: 'I am a college student. Where are you from?',
            pronunciation: 'Naanu college student. Nee-voo yaah-vah oo-roo?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Mittu',
            textKannada: 'Naanu Bengaluru ooru. Nimma ooru yavudu?',
            textEnglish: 'I am from Bengaluru. Which is your hometown?',
            pronunciation:
                'Naanu Bengaluru oo-roo. Neem-mah oo-roo yaah-voo-doo?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Nanna ooru Mysuru. Nale sigona, bye!',
            textEnglish: 'My hometown is Mysuru. See you tomorrow, bye!',
            pronunciation: 'Nan-nah oo-roo Mysuru. Nah-lay see-goh-nah, bye!',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Mittu',
            textKannada: 'Sari, thumba santosha. Nale sigona. Bye!',
            textEnglish: 'Okay, very happy. See you tomorrow. Bye!',
            pronunciation:
                'Sari, thoomba san-toh-shah. Nah-lay see-goh-nah. Bye!',
          ),
        ],
        sentenceBuilderWords: [
          'Nanna',
          'hesaru',
          'Krishna',
          'student',
          'haudu',
        ],
        sentenceBuilderAnswer: 'Nanna hesaru Krishna',
        sentenceBuilderTranslation: 'My name is Krishna',
        missionDescription:
            'Introduce yourself in Kannada by stating "Nanna hesaru [Your Name]".',
        quiz: [
          QuizQuestion(
            id: 'q1',
            questionText: 'How do you ask "Where are you from?" in Kannada?',
            options: [
              'Ninna hesaru enu?',
              'Neevu yaava ooru?',
              'Hegiddira?',
              'Nale sigona',
            ],
            correctAnswer: 'Neevu yaava ooru?',
          ),
          QuizQuestion(
            id: 'q2',
            questionText: 'Complete the greeting: "Hegiddira ______?"',
            options: ['neevu', 'nanna', 'illa', 'banni'],
            correctAnswer: 'neevu',
            type: 'fill_blank',
          ),
          QuizQuestion(
            id: 'q3',
            questionText: 'Namaskara',
            options: ['Hello', 'Thank you', 'Yes', 'Goodbye'],
            correctAnswer: 'Hello',
            type: 'listening',
          ),
        ],
      ),
    );

    list.add(
      Lesson(
        id: 'greetings_1',
        title: 'Coffee Shop Intro',
        subtitle: 'Meet classmates and discuss courses.',
        category: LessonCategory.greetings,
        situationDescription:
            'Sit next to a classmate at a cafe. Order beverages, introduce yourself, talk about your course subjects, check their college name, and exchange contact coordinates.',
        isUnlocked: true,
        isCompleted: false,
        customIllustrationPath: 'assets/images/situations/greetings_1.webp',
        mittuAnimationState: 'mittu_wave',
        vocabulary: [
          VocabularyWord(
            id: 'vg1',
            kannada: 'Coffee kodi',
            english: 'Give coffee',
            pronunciation: 'Coffee koh-dee',
          ),
          VocabularyWord(
            id: 'vg2',
            kannada: 'Yaava college?',
            english: 'Which college?',
            pronunciation: 'Yaah-vah college?',
          ),
          VocabularyWord(
            id: 'vg3',
            kannada: 'Enu course?',
            english: 'What course?',
            pronunciation: 'Ay-noo course?',
          ),
          VocabularyWord(
            id: 'vg4',
            kannada: 'Ninna nodi kushi aaythu',
            english: 'Nice to meet you',
            pronunciation: 'Neen-nah noh-dee koo-shee eye-thoo',
          ),
          VocabularyWord(
            id: 'vg5',
            kannada: 'Oota aaytha?',
            english: 'Did you have food?',
            pronunciation: 'Oo-tah eye-thah?',
          ),
          VocabularyWord(
            id: 'vg6',
            kannada: 'Swalpa space kodi',
            english: 'Give some space',
            pronunciation: 'Swal-pah space koh-dee',
          ),
          VocabularyWord(
            id: 'vg7',
            kannada: 'Engineering kalithiddene',
            english: 'I study engineering',
            pronunciation: 'Engineering kaleetheedeene',
          ),
        ],
        dialogue: [
          DialogueTurn(
            speaker: 'Classmate',
            textKannada: 'Namaskara! Space ideya? Kuthkoli.',
            textEnglish: 'Hello! Is there space? Take a seat.',
            pronunciation: 'Namaskara! Space ee-deh-yah? Kooth-koh-lee.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Namaskara, haudu space ide. Ninna hesaru enu?',
            textEnglish: 'Hello, yes there is space. What is your name?',
            pronunciation:
                'Namaskara, how-du space ee-deh. Neen-nah heh-sah-roo ay-noo?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Classmate',
            textKannada: 'Naanu Rakesh. Ninna nodi kushi aaythu!',
            textEnglish: 'I am Rakesh. Nice to meet you!',
            pronunciation: 'Naanu Rakesh. Neen-nah noh-dee koo-shee eye-thoo!',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Nanna hesaru Krishna. Neevu yaava college?',
            textEnglish: 'My name is Krishna. Which college do you go to?',
            pronunciation:
                'Nan-nah heh-sah-roo Krishna. Nee-voo yaah-vah college?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Classmate',
            textKannada: 'Naanu RV College. Enu course kalithiddira?',
            textEnglish: 'I am in RV College. What course are you pursuing?',
            pronunciation: 'Naanu RV College. Ay-noo course kaleetheedeera?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada:
                'Naanu Engineering kalithiddene. Ondu filter coffee kodi.',
            textEnglish:
                'I am studying Engineering. Please give one filter coffee.',
            pronunciation:
                'Naanu Engineering kaleetheedeene. Ondoo filter coffee koh-dee.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Classmate',
            textKannada:
                'Tumba santosha! Filter coffee match aaythu. Nale sigona.',
            textEnglish: 'Very happy! Filter coffee matched. See you tomorrow.',
            pronunciation:
                'Thoomba san-toh-shah! Filter coffee match eye-thoo. Nah-lay see-goh-nah.',
          ),
        ],
        sentenceBuilderWords: ['Ninna', 'nodi', 'kushi', 'aaythu', 'banni'],
        sentenceBuilderAnswer: 'Ninna nodi kushi aaythu',
        sentenceBuilderTranslation: 'Nice to meet you',
        missionDescription:
            'Use the phrase "Ninna nodi kushi aaythu" when meeting someone new.',
        quiz: [
          QuizQuestion(
            id: 'qg1',
            questionText: 'How do you say "Nice to meet you" in Kannada?',
            options: [
              'Ninna nodi kushi aaythu',
              'Hegiddira?',
              'Dhanyavada',
              'Banni',
            ],
            correctAnswer: 'Ninna nodi kushi aaythu',
          ),
          QuizQuestion(
            id: 'qg2',
            questionText: 'Complete the sentence: "Neevu yaava ______?"',
            options: ['college', 'oota', 'kelsa', 'neeru'],
            correctAnswer: 'college',
            type: 'fill_blank',
          ),
          QuizQuestion(
            id: 'qg3',
            questionText: 'Ondu filter coffee kodi',
            options: [
              'Give one filter coffee',
              'I want water',
              'How much is it?',
              'Go to Indiranagar',
            ],
            correctAnswer: 'Give one filter coffee',
            type: 'listening',
          ),
        ],
      ),
    );

    list.add(
      Lesson(
        id: 'travel_1',
        title: 'Booking a Ticket',
        subtitle: 'Buy a Metro ticket and ask for routes.',
        category: LessonCategory.travel,
        situationDescription:
            'Enter Majestic Metro Station. Stop the guard to locate the ticket counter, ask the ticket executive for a ticket to Indiranagar, negotiate the ticket counter pricing, ask about the platforms, and reach the destination.',
        isUnlocked: true,
        isCompleted: false,
        customIllustrationPath: 'assets/images/situations/travel_1.webp',
        mittuAnimationState: 'mittu_talking',
        vocabulary: [
          VocabularyWord(
            id: 'vt1',
            kannada: 'Majestic ge ticket kodi',
            english: 'Give ticket to Majestic',
            pronunciation: 'Majestic gay ticket koh-dee',
          ),
          VocabularyWord(
            id: 'vt2',
            kannada: 'Counter elli ide?',
            english: 'Where is the counter?',
            pronunciation: 'Counter el-lee ee-deh?',
          ),
          VocabularyWord(
            id: 'vt3',
            kannada: 'Estu aaguthe?',
            english: 'How much is it?',
            pronunciation: 'Es-too ah-goo-theh?',
          ),
          VocabularyWord(
            id: 'vt4',
            kannada: 'Yaava platform?',
            english: 'Which platform?',
            pronunciation: 'Yaah-vah platform?',
          ),
          VocabularyWord(
            id: 'vt5',
            kannada: 'Eradu ticket kodi',
            english: 'Give two tickets',
            pronunciation: 'Er-ah-doo ticket koh-dee',
          ),
          VocabularyWord(
            id: 'vt6',
            kannada: 'Sahaya maadi',
            english: 'Please help',
            pronunciation: 'Sah-ha-yah mah-dee',
          ),
          VocabularyWord(
            id: 'vt7',
            kannada: 'Indiranagar ge hogi',
            english: 'Go to Indiranagar',
            pronunciation: 'Indiranagar gay hoh-gee',
          ),
        ],
        dialogue: [
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Namaskara sir, ticket counter elli ide?',
            textEnglish: 'Hello sir, where is the ticket counter?',
            pronunciation: 'Namaskara sir, ticket counter el-lee ee-deh?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Guard',
            textKannada: 'Namaskara, left side Counter ide, banni.',
            textEnglish: 'Hello, the counter is on the left side, come.',
            pronunciation: 'Namaskara, left side counter ee-deh, ban-nee.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Indiranagar ge ticket kodi. Estu aaguthe?',
            textEnglish: 'Give ticket to Indiranagar. How much does it cost?',
            pronunciation:
                'Indiranagar gay ticket koh-dee. Es-too ah-goo-theh?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Executive',
            textKannada: 'Ondu ticket ge muvattu (30) rupayi aaguthe, sir.',
            textEnglish: 'For one ticket it will be thirty (30) rupees, sir.',
            pronunciation:
                'Ondoo ticket gay moo-vah-thoo roo-pah-yee ah-goo-theh, sir.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Sari, Indiranagar ge yaava platform ge hogabeku?',
            textEnglish: 'Okay, which platform should I go to for Indiranagar?',
            pronunciation:
                'Sari, Indiranagar gay yaah-vah platform gay hoh-gah-bay-koo?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Executive',
            textKannada: 'Platform eradu (2) ge hogi, train baruthe.',
            textEnglish: 'Go to platform two (2), the train will arrive.',
            pronunciation:
                'Platform er-ah-doo gay hoh-gee, train bah-roo-theh.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Tumba dhanyavada, help maadiddu.',
            textEnglish: 'Thank you very much for helping.',
            pronunciation: 'Thoomba dhan-yah-vah-dah, help mah-dee-doo.',
            isUser: true,
          ),
        ],
        sentenceBuilderWords: ['Indiranagar', 'ge', 'ticket', 'kodi', 'hogi'],
        sentenceBuilderAnswer: 'Indiranagar ge ticket kodi',
        sentenceBuilderTranslation: 'Give ticket to Indiranagar',
        missionDescription:
            'State "Indiranagar ge ticket kodi" or select your destination ticket using "kodi" today!',
        quiz: [
          QuizQuestion(
            id: 'qt1',
            questionText: 'How do you ask "Which platform?" in Kannada?',
            options: [
              'Counter elli?',
              'Yaava platform?',
              'Estu aaguthe?',
              'Ticket kodi',
            ],
            correctAnswer: 'Yaava platform?',
          ),
          QuizQuestion(
            id: 'qt2',
            questionText: 'How much is it? -> "______ aaguthe?"',
            options: ['Estu', 'Elli', 'Yaava', 'Enu'],
            correctAnswer: 'Estu',
            type: 'fill_blank',
          ),
          QuizQuestion(
            id: 'qt3',
            questionText: 'Majestic ge ticket kodi',
            options: [
              'Give ticket to Majestic',
              'Go to Majestic by auto',
              'Where is Majestic?',
              'Put the meter on',
            ],
            correctAnswer: 'Give ticket to Majestic',
            type: 'listening',
          ),
        ],
      ),
    );

    list.add(
      Lesson(
        id: 'restaurant_1',
        title: 'Darshini Restaurant',
        subtitle: 'Order breakfast and handle bills.',
        category: LessonCategory.restaurant,
        situationDescription:
            'Step into a traditional Darshini hotel. Greet the waiter, ask for a table, request the menu, order Masala Dosa and Filter Coffee, check if the dish is spicy, ask for water, pay via UPI scanner, and leave.',
        isUnlocked: false,
        isCompleted: false,
        customIllustrationPath: 'assets/images/situations/restaurant_1.webp',
        mittuAnimationState: 'mittu_talking',
        vocabulary: [
          VocabularyWord(
            id: 'vr1',
            kannada: 'Menu kodi',
            english: 'Give the menu',
            pronunciation: 'Menu koh-dee',
          ),
          VocabularyWord(
            id: 'vr2',
            kannada: 'Masala Dosa kodi',
            english: 'Give Masala Dosa',
            pronunciation: 'Masala Dosa koh-dee',
          ),
          VocabularyWord(
            id: 'vr3',
            kannada: 'Khara ideya?',
            english: 'Is it spicy?',
            pronunciation: 'Kah-rah ee-deh-yah?',
          ),
          VocabularyWord(
            id: 'vr4',
            kannada: 'Swalpa neeru kodi',
            english: 'Give some water',
            pronunciation: 'Swal-pah nee-roo koh-dee',
          ),
          VocabularyWord(
            id: 'vr5',
            kannada: 'Bill kodi',
            english: 'Give the bill',
            pronunciation: 'Bill koh-dee',
          ),
          VocabularyWord(
            id: 'vr6',
            kannada: 'UPI idiya?',
            english: 'Do you have UPI?',
            pronunciation: 'UPI ee-dee-yah?',
          ),
          VocabularyWord(
            id: 'vr7',
            kannada: 'Oota beku',
            english: 'I want food',
            pronunciation: 'Oo-tah bay-koo',
          ),
        ],
        dialogue: [
          DialogueTurn(
            speaker: 'Waiter',
            textKannada: 'Namaskara sir, enu beku? Table ready ide.',
            textEnglish: 'Hello sir, what do you want? The table is ready.',
            pronunciation: 'Namaskara sir, ay-noo bay-koo? Table ready ee-deh.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Namaskara. Swalpa menu kodi.',
            textEnglish: 'Hello. Please give me the menu.',
            pronunciation: 'Namaskara. Swal-pah menu koh-dee.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Waiter',
            textKannada:
                'Sir, ivattu Masala Dosa mathu Filter Coffee super ide.',
            textEnglish: 'Sir, today Masala Dosa and Filter Coffee are great.',
            pronunciation:
                'Sir, ee-vah-thoo Masala Dosa mah-thoo Filter Coffee super ee-deh.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Masala Dosa thumba khara ideya?',
            textEnglish: 'Is the Masala Dosa very spicy?',
            pronunciation: 'Masala Dosa thoomba kah-rah ee-deh-yah?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Waiter',
            textKannada: 'Illa sir, sweet & spicy medium ide. Enu order?',
            textEnglish: 'No sir, it is medium. What is the order?',
            pronunciation:
                'Illa sir, sweet & spicy medium ee-deh. Ay-noo order?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada:
                'Ondu Masala Dosa mathu filter coffee kodi. Swalpa neeru kodi.',
            textEnglish:
                'Give one Masala Dosa and filter coffee. Give some water.',
            pronunciation:
                'Ondoo Masala Dosa mah-thoo filter coffee koh-dee. Swal-pah nee-roo koh-dee.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Waiter',
            textKannada: 'Sari sir, neeru banthu. Masala Dosa two minutes.',
            textEnglish: 'Okay sir, water is here. Masala Dosa in two minutes.',
            pronunciation:
                'Sari sir, nee-roo ban-thoo. Masala Dosa er-ah-doo nee-mee-shah.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Tumba testy. Waiter, bill kodi. UPI idiya?',
            textEnglish: 'Very tasty. Waiter, give the bill. Do you have UPI?',
            pronunciation:
                'Thoomba tasty. Waiter, bill koh-dee. UPI ee-dee-yah?',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Waiter',
            textKannada: 'Haudu sir, counter QR code scan maadi. Dhanyavada!',
            textEnglish: 'Yes sir, scan the counter QR code. Thank you!',
            pronunciation:
                'How-du sir, counter QR code scan mah-dee. Dhan-yah-vah-dah!',
          ),
        ],
        sentenceBuilderWords: ['Swalpa', 'neeru', 'kodi', 'restaurant', 'ota'],
        sentenceBuilderAnswer: 'Swalpa neeru kodi',
        sentenceBuilderTranslation: 'Give some water',
        missionDescription:
            'Request water at a Darshini using the phrase "Swalpa neeru kodi".',
        quiz: [
          QuizQuestion(
            id: 'qr1',
            questionText: 'How do you ask "Is it spicy?" in Kannada?',
            options: ['Khara ideya?', 'Bill kodi', 'Menu kodi', 'UPI idiya?'],
            correctAnswer: 'Khara ideya?',
          ),
          QuizQuestion(
            id: 'qr2',
            questionText: 'Complete the billing request: "______ kodi."',
            options: ['Bill', 'Neeru', 'Oota', 'Kelsa'],
            correctAnswer: 'Bill',
            type: 'fill_blank',
          ),
          QuizQuestion(
            id: 'qr3',
            questionText: 'UPI idiya?',
            options: [
              'Do you have UPI?',
              'Give menu',
              'Show QR code',
              'How much is it?',
            ],
            correctAnswer: 'Do you have UPI?',
            type: 'listening',
          ),
        ],
      ),
    );

    list.add(
      Lesson(
        id: 'workplace_1',
        title: 'Cafeteria Work Chat',
        subtitle: 'Connect with coworkers over coffee.',
        category: LessonCategory.workplace,
        situationDescription:
            'Meet a colleague in the office cafeteria. Suggest drinking filter coffee, ask about their workload burden, update status of your manager project files, and agree to meet tomorrow.',
        isUnlocked: false,
        isCompleted: false,
        customIllustrationPath: 'assets/images/situations/workplace_1.webp',
        mittuAnimationState: 'mittu_talking',
        vocabulary: [
          VocabularyWord(
            id: 'vw1',
            kannada: 'Coffee kudiyona?',
            english: 'Shall we drink coffee?',
            pronunciation: 'Coffee koo-dee-yoh-nah?',
          ),
          VocabularyWord(
            id: 'vw2',
            kannada: 'Tumba kelsa ide',
            english: 'There is a lot of work',
            pronunciation: 'Thoomba kel-sah ee-deh',
          ),
          VocabularyWord(
            id: 'vw3',
            kannada: 'Kelsa aagide',
            english: 'Work is completed',
            pronunciation: 'Kel-sah ah-gee-deh',
          ),
          VocabularyWord(
            id: 'vw4',
            kannada: 'Nale sigona',
            english: 'See you tomorrow',
            pronunciation: 'Nah-lay see-goh-nah',
          ),
          VocabularyWord(
            id: 'vw5',
            kannada: 'Manager bandiddara?',
            english: 'Has manager come?',
            pronunciation: 'Manager ban-deed-dah-rah?',
          ),
          VocabularyWord(
            id: 'vw6',
            kannada: 'Break thogo',
            english: 'Take a break',
            pronunciation: 'Break thoh-go',
          ),
        ],
        dialogue: [
          DialogueTurn(
            speaker: 'Coworker',
            textKannada: 'Hi Krishna! Coffee kudiyona? Break beka?',
            textEnglish: 'Hi Krishna! Shall we drink coffee? Need a break?',
            pronunciation: 'Hi Krishna! Coffee koo-dee-yoh-nah? Break bay-kah?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada: 'Hi, haudu coffee kudiyona. Ivattu tumba kelsa ide.',
            textEnglish:
                'Hi, yes let\'s drink coffee. Today there is a lot of work.',
            pronunciation:
                'Hi, how-du coffee koo-dee-yoh-nah. Ee-vah-thoo thoomba kel-sah ee-deh.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Coworker',
            textKannada:
                'Aiyyo, project work check completed? Manager bandiddara?',
            textEnglish:
                'Aiyyo, is project work check completed? Has the manager come?',
            pronunciation:
                'Aiyyo, project work check completed? Manager ban-deed-dah-rah?',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada:
                'Haudu sir, manager bandiddare. Kelsa aagide, report ready ide.',
            textEnglish:
                'Yes sir, manager has come. Work is completed, the report is ready.',
            pronunciation:
                'How-du sir, manager ban-deed-dah-ray. Kel-sah ah-gee-deh, report ready ee-deh.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Coworker',
            textKannada: 'Great! Swalpa break thogo. Stress thgobeda.',
            textEnglish: 'Great! Take a short break. Don\'t stress.',
            pronunciation:
                'Great! Swal-pah break thoh-go. Stress thoh-go-bay-dah.',
          ),
          DialogueTurn(
            speaker: 'User',
            textKannada:
                'Cafeteria coffee super. Nale project review nalli sigona.',
            textEnglish:
                'Cafeteria coffee is super. See you tomorrow in the project review.',
            pronunciation:
                'Cafeteria coffee super. Nah-lay project review nal-lee see-goh-nah.',
            isUser: true,
          ),
          DialogueTurn(
            speaker: 'Coworker',
            textKannada: 'Haudu, sure. Nale sigona! Bye.',
            textEnglish: 'Yes, sure. See you tomorrow! Bye.',
            pronunciation: 'Haudu, sure. Nah-lay see-goh-nah! Bye.',
          ),
        ],
        sentenceBuilderWords: [
          'Nale',
          'sigona',
          'colleague',
          'manager',
          'kelsa',
        ],
        sentenceBuilderAnswer: 'Nale sigona',
        sentenceBuilderTranslation: 'See you tomorrow',
        missionDescription:
            'Tell a coworker "Nale sigona" (See you tomorrow) at the end of the workday.',
        quiz: [
          QuizQuestion(
            id: 'qw1',
            questionText: 'What does "Tumba kelsa ide" mean?',
            options: [
              'There is a lot of work',
              'Work is completed',
              'Give me coffee',
              'Take a break',
            ],
            correctAnswer: 'There is a lot of work',
          ),
          QuizQuestion(
            id: 'qw2',
            questionText: 'Complete the status: "Project ______."',
            options: ['kelsa aagide', 'oota aaytha', 'neeru kodi', 'hegiddira'],
            correctAnswer: 'kelsa aagide',
            type: 'fill_blank',
          ),
          QuizQuestion(
            id: 'qw3',
            questionText: 'Coffee kudiyona?',
            options: [
              'Shall we drink coffee?',
              'Give me coffee',
              'Where is coffee?',
              'Who wants coffee?',
            ],
            correctAnswer: 'Shall we drink coffee?',
            type: 'listening',
          ),
        ],
      ),
    );

    // Dynamic generations for Days 6 to 30 with highly expanded situations, multiple question formats and dialogue turns
    final List<Map<String, dynamic>> data = [
      {
        'id': 'shopping_1',
        'title': 'Supermarket QR Pay',
        'sub': 'Scan codes and scan bills at grocery.',
        'cat': LessonCategory.shopping,
        'sit':
            'Go to a local grocery store, ask for the price of milk packets, scan the UPI QR code for payment, confirm status, and thank the shopkeeper.',
        'vocab': [
          {
            'k': 'QR code torisi',
            'e': 'Show QR code',
            'p': 'QR code toh-ree-see',
          },
          {
            'k': 'Rate estu?',
            'e': 'How much is the rate?',
            'p': 'Rate es-too?',
          },
          {'k': 'UPI idiya?', 'e': 'Do you have UPI?', 'p': 'UPI ee-dee-yah?'},
          {'k': 'Dhanyavada', 'e': 'Thank you', 'p': 'Dhan-yah-vah-dah'},
        ],
        'turns': [
          {
            'sp': 'Shopkeeper',
            'k': 'Namaskara sir, enu beku?',
            'e': 'Hello sir, what do you need?',
            'p': 'Namaskara sir, ay-noo bay-koo?',
          },
          {
            'sp': 'User',
            'k': 'Namaskara. Milk packet rate estu?',
            'e': 'Hello. What is the rate of the milk packet?',
            'p': 'Namaskara. Milk packet rate es-too?',
            'user': true,
          },
          {
            'sp': 'Shopkeeper',
            'k': 'Ondu packet ge eravattu (20) rupayi, sir.',
            'e': 'For one packet it is twenty (20) rupees, sir.',
            'p': 'Ondoo packet gay er-ah-vah-thoo roo-pah-yee, sir.',
          },
          {
            'sp': 'User',
            'k': 'Sari, eradu packet kodi. UPI idiya?',
            'e': 'Okay, give two packets. Do you have UPI?',
            'p': 'Sari, er-ah-doo packet koh-dee. UPI ee-dee-yah?',
            'user': true,
          },
          {
            'sp': 'Shopkeeper',
            'k': 'Haudu sir, counter QR code torisi scan maadi.',
            'e': 'Yes sir, show QR code at the counter and scan.',
            'p': 'How-du sir, counter QR code toh-ree-see scan mah-dee.',
          },
          {
            'sp': 'User',
            'k': 'Payment completed. Dhanyavada!',
            'e': 'Payment completed. Thank you!',
            'p': 'Payment completed. Dhan-yah-vah-dah!',
            'user': true,
          },
        ],
        'sb': ['QR', 'code', 'torisi', 'upi', 'estu'],
        'sba': 'QR code torisi',
        'm': 'Ask a shopkeeper "UPI idiya?" before making a transaction today.',
        'quizzes': [
          {
            'q': 'How do you ask to show the QR code?',
            'opts': ['QR code torisi', 'Rate estu?', 'Bill kodi', 'Dhanyavada'],
            'ans': 'QR code torisi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Milk packet ______?"',
            'opts': [
              'rate estu',
              'neeru kodi',
              'hathira ATM',
              'current bandilla',
            ],
            'ans': 'rate estu',
            'type': 'fill_blank',
          },
          {
            'q': 'QR code torisi',
            'opts': [
              'Show QR code',
              'Give ticket',
              'Give water',
              'Reduce price',
            ],
            'ans': 'Show QR code',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'college_1',
        'title': 'Campus Classmate Meet',
        'sub': 'Introduce details on the first day.',
        'cat': LessonCategory.college,
        'sit':
            'Meet a fellow student on campus. Ask their name, introduce yours, discuss classes on the schedule, and walk to the classroom together.',
        'vocab': [
          {
            'k': 'Nanna hesaru Krishna',
            'e': 'My name is Krishna',
            'p': 'Nan-nah heh-sah-roo Krishna',
          },
          {
            'k': 'Neevu student?',
            'e': 'Are you a student?',
            'p': 'Nee-voo student?',
          },
          {
            'k': 'Classroom elli?',
            'e': 'Where is the classroom?',
            'p': 'Classroom el-lee?',
          },
          {
            'k': 'Banni hogona',
            'e': 'Come let\'s go',
            'p': 'Ban-nee hoh-goh-nah',
          },
        ],
        'turns': [
          {
            'sp': 'Classmate',
            'k': 'Namaskara! Ninna hesaru enu? Naanu Karthik.',
            'e': 'Hello! What is your name? I am Karthik.',
            'p': 'Namaskara! Neen-nah heh-sah-roo ay-noo? Naanu Karthik.',
          },
          {
            'sp': 'User',
            'k': 'Namaskara Karthik, nanna hesaru Krishna. Neevu student?',
            'e': 'Hello Karthik, my name is Krishna. Are you a student?',
            'p':
                'Namaskara Karthik, nan-nah heh-sah-roo Krishna. Nee-voo student?',
            'user': true,
          },
          {
            'sp': 'Classmate',
            'k': 'Haudu, naanu Engineering student. Ninna class yavudu?',
            'e': 'Yes, I am an Engineering student. Which is your class?',
            'p':
                'How-du, naanu Engineering student. Neen-nah class yaah-voo-doo?',
          },
          {
            'sp': 'User',
            'k':
                'Nanna class block B nalli ide. Classroom elli ide, gothideya?',
            'e': 'My class is in Block B. Do you know where the classroom is?',
            'p':
                'Nan-nah class block B nal-lee ee-deh. Classroom el-lee ee-deh, go-thee-deh-yah?',
            'user': true,
          },
          {
            'sp': 'Classmate',
            'k': 'Haudu, second floor nalli ide. Banni hogona.',
            'e': 'Yes, it is on the second floor. Come, let\'s go.',
            'p': 'How-du, second floor nal-lee ee-deh. Ban-nee hoh-goh-nah.',
          },
        ],
        'sb': ['Nanna', 'hesaru', 'Krishna', 'student', 'RV'],
        'sba': 'Nanna hesaru Krishna',
        'm':
            'Introduce your name to a classmate stating "Nanna hesaru [Name]".',
        'quizzes': [
          {
            'q': 'How do you say "My name is Krishna"?',
            'opts': [
              'Nanna hesaru Krishna',
              'Neevu student?',
              'Classroom elli?',
              'Banni hogona',
            ],
            'ans': 'Nanna hesaru Krishna',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Second floor nalli ______?"',
            'opts': [
              'classroom elli',
              'neeru kodi',
              'bill estu',
              'kelsa aagide',
            ],
            'ans': 'classroom elli',
            'type': 'fill_blank',
          },
          {
            'q': 'Classroom elli?',
            'opts': [
              'Where is the classroom?',
              'Where is the washroom?',
              'Where is the library?',
              'Where is the canteen?',
            ],
            'ans': 'Where is the classroom?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'travel_2',
        'title': 'Negotiating Auto Rates',
        'sub': 'Discuss pricing meters with drivers.',
        'cat': LessonCategory.travel,
        'sit':
            'Hail an auto. Address the driver, ask to go to Majestic, negotiate traffic surcharge rates, demand meter usage, and reach agreement.',
        'vocab': [
          {
            'k': 'Majestic ge hogi',
            'e': 'Go to Majestic',
            'p': 'Majestic gay hoh-gee',
          },
          {
            'k': 'Meter haaki banni',
            'e': 'Put meter and come',
            'p': 'Meter hah-kee ban-nee',
          },
          {
            'k': 'Swalpa kadime maadi',
            'e': 'Reduce a bit',
            'p': 'Swal-pah ka-dee-may mah-dee',
          },
          {
            'k': 'Estu aaguthe?',
            'e': 'How much will it be?',
            'p': 'Es-too ah-goo-theh?',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Driver sir, Majestic ge barthira?',
            'e': 'Driver sir, will you come to Majestic?',
            'p': 'Driver sir, Majestic gay bar-thee-rah?',
            'user': true,
          },
          {
            'sp': 'Driver',
            'k':
                'Majestic ge traffic heavy ide sir. Double meter rate aaguthe.',
            'e':
                'Traffic is heavy for Majestic sir. It will be double meter rate.',
            'p':
                'Majestic gay traffic heavy ee-deh sir. Double meter rate ah-goo-theh.',
          },
          {
            'sp': 'User',
            'k': 'Illa sir, meter haaki banni. Extra 20 kodi check?',
            'e': 'No sir, put the meter and come. Check giving extra 20?',
            'p':
                'Ill-ah sir, meter hah-kee ban-nee. Extra er-ah-vah-thoo koh-dee check?',
            'user': true,
          },
          {
            'sp': 'Driver',
            'k': 'Sari sir, swalpa adjustment extra kodi, banni banni.',
            'e': 'Okay sir, give some adjustment extra, come come.',
            'p':
                'Sari sir, swal-pah adjustment extra koh-dee, ban-nee ban-nee.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. Majestic ge hogi.',
            'e': 'Thank you. Go to Majestic.',
            'p': 'Dhan-yah-vah-dah. Majestic gay hoh-gee.',
            'user': true,
          },
        ],
        'sb': ['Meter', 'haaki', 'banni', 'driver', 'Majestic'],
        'sba': 'Meter haaki banni',
        'm':
            'Demand meter usage by stating "Meter haaki banni" on your next auto ride.',
        'quizzes': [
          {
            'q': 'What does "Swalpa kadime maadi" mean?',
            'opts': [
              'Reduce the rate a bit',
              'Go fast',
              'Turn left',
              'Stop here',
            ],
            'ans': 'Reduce the rate a bit',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Meter ______ banni."',
            'opts': ['haaki', 'hogi', 'kodi', 'baruthe'],
            'ans': 'haaki',
            'type': 'fill_blank',
          },
          {
            'q': 'Majestic ge hogi',
            'opts': [
              'Go to Majestic',
              'Go to counter',
              'Give the ticket',
              'Put the meter',
            ],
            'ans': 'Go to Majestic',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'emergency_1',
        'title': 'Asking for Medical Help',
        'sub': 'Signal assistance and locate clinics.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Encounter a road accident. Ask passersby for help, request calling an ambulance, check directions for the nearest clinic, and express urgency.',
        'vocab': [
          {'k': 'Sahaya maadi', 'e': 'Please help', 'p': 'Sah-ha-yah mah-dee'},
          {
            'k': 'Ambulance karesi',
            'e': 'Call ambulance',
            'p': 'Ambulance ka-ree-see',
          },
          {
            'k': 'Hospital elli ide?',
            'e': 'Where is the hospital?',
            'p': 'Hospital el-lee ee-deh?',
          },
          {
            'k': 'Doctor yavaga barthare?',
            'e': 'When will doctor come?',
            'p': 'Doctor yaah-vah-gah bar-tha-ray?',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Excuse me, swalpa sahaya maadi! Accident aagide.',
            'e': 'Excuse me, please help a bit! An accident happened.',
            'p': 'Excuse me, swal-pah sah-ha-yah mah-dee! Accident ah-gee-deh.',
            'user': true,
          },
          {
            'sp': 'Passerby',
            'k': 'Aiyyo! Hospital elli ide hathira? Ambulance karesona?',
            'e':
                'Aiyyo! Where is the nearby hospital? Shall we call an ambulance?',
            'p':
                'Aiyyo! Hospital el-lee ee-deh ha-thee-rah? Ambulance ka-ree-soh-nah?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, ambulance karesi, help maadi. Doctor beku.',
            'e': 'Yes, call an ambulance, please help. A doctor is needed.',
            'p': 'How-du, ambulance ka-ree-see, help mah-dee. Doctor bay-koo.',
            'user': true,
          },
          {
            'sp': 'Passerby',
            'k': 'Sari, emergency clinic number check maadi call madthini.',
            'e': 'Okay, I will check the emergency clinic number and call.',
            'p':
                'Sari, emergency clinic number check mah-dee call mad-thee-nee.',
          },
          {
            'sp': 'User',
            'k': 'Tumba dhanyavada, sahaya maadiddu.',
            'e': 'Thank you very much for helping.',
            'p': 'Thoomba dhan-yah-vah-dah, sah-ha-yah mah-dee-doo.',
            'user': true,
          },
        ],
        'sb': ['Sahaya', 'maadi', 'banni', 'ambulance', 'hospital'],
        'sba': 'Sahaya maadi',
        'm':
            'Learn the life-saving emergency phrase "Sahaya maadi" for assistance.',
        'quizzes': [
          {
            'q': 'How do you say "Please help" in Kannada?',
            'opts': [
              'Sahaya maadi',
              'Nale sigona',
              'Oota aaytha?',
              'Banni banni',
            ],
            'ans': 'Sahaya maadi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Ambulance ______!"',
            'opts': ['karesi', 'kodi', 'hogi', 'banni'],
            'ans': 'karesi',
            'type': 'fill_blank',
          },
          {
            'q': 'Hospital elli ide?',
            'opts': [
              'Where is the hospital?',
              'Where is the office?',
              'Where is the school?',
              'Where is the library?',
            ],
            'ans': 'Where is the hospital?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'daily_1',
        'title': 'Apartment Security Entry',
        'sub': 'Enquire security register rules.',
        'cat': LessonCategory.basics,
        'sit':
            'Visit a residential complex. Address the security guard, state the flat destination, register entry details, and request gate access clearance.',
        'vocab': [
          {
            'k': 'Flat number kodi',
            'e': 'Give flat number',
            'p': 'Flat number koh-dee',
          },
          {
            'k': 'Register baredi',
            'e': 'Write in register',
            'p': 'Register bah-ray-dee',
          },
          {
            'k': 'Gate open maadi',
            'e': 'Open the gate',
            'p': 'Gate open mah-dee',
          },
          {
            'k': 'Yavaga barthira?',
            'e': 'When will you come?',
            'p': 'Yaah-vah-gah bar-thee-rah?',
          },
        ],
        'turns': [
          {
            'sp': 'Guard',
            'k': 'Namaskara, flat number kodi. Enu delivery?',
            'e': 'Hello, give the flat number. Is it a delivery?',
            'p': 'Namaskara, flat number koh-dee. Ay-noo delivery?',
          },
          {
            'sp': 'User',
            'k': 'Namaskara, flat number 402 ge hogabeku. Courier package ide.',
            'e': 'Hello, I need to go to flat 402. There is a courier package.',
            'p':
                'Namaskara, flat number 402 gay hoh-gah-bay-koo. Courier package ee-deh.',
            'user': true,
          },
          {
            'sp': 'Guard',
            'k': 'Sari, entry register baredi, signature maadi sir.',
            'e': 'Okay, write in the entry register and sign, sir.',
            'p': 'Sari, entry register bah-ray-dee, signature mah-dee sir.',
          },
          {
            'sp': 'User',
            'k': 'Register entry completed. Gate open maadi.',
            'e': 'Register entry completed. Open the gate.',
            'p': 'Register entry completed. Gate open mah-dee.',
            'user': true,
          },
          {
            'sp': 'Guard',
            'k': 'Sari banni, second floor flat side lift lift door check.',
            'e': 'Okay come, check lift door on the second floor flat side.',
            'p': 'Sari ban-nee, second floor flat side lift lift door check.',
          },
        ],
        'sb': ['Flat', 'number', 'kodi', 'gate', 'open'],
        'sba': 'Flat number kodi',
        'm':
            'Interact with security guards stating destination flat details today.',
        'quizzes': [
          {
            'q': 'What does "Flat number kodi" mean?',
            'opts': [
              'Give flat number',
              'Open the gate',
              'Sign the register',
              'Where is lift?',
            ],
            'ans': 'Give flat number',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Register entry ______."',
            'opts': ['baredi', 'kodi', 'hogi', 'banni'],
            'ans': 'baredi',
            'type': 'fill_blank',
          },
          {
            'q': 'Gate open maadi',
            'opts': [
              'Open the gate',
              'Close the door',
              'Go to second floor',
              'Call the manager',
            ],
            'ans': 'Open the gate',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'restaurant_2',
        'title': 'Bakery Masala Tea Order',
        'sub': 'Order beverages and request snacks.',
        'cat': LessonCategory.restaurant,
        'sit':
            'Visit a local tea shop/bakery. Order Masala Tea with low sugar, request standard biscuits, count pricing details, and pay the shop counter cashier.',
        'vocab': [
          {
            'k': 'Masala Tea kodi',
            'e': 'Give Masala Tea',
            'p': 'Masala Tea koh-dee',
          },
          {
            'k': 'Biscuits beku',
            'e': 'I want biscuits',
            'p': 'Biscuits bay-koo',
          },
          {
            'k': 'Sweet swalpa kadime',
            'e': 'Reduce sweet a bit',
            'p': 'Sweet swal-pah ka-dee-may',
          },
          {
            'k': 'Estu aaguthe?',
            'e': 'How much is it?',
            'p': 'Es-too ah-goo-theh?',
          },
        ],
        'turns': [
          {
            'sp': 'Staff',
            'k': 'Namaskara sir, enu beku? Tea or coffee?',
            'e': 'Hello sir, what do you want? Tea or coffee?',
            'p': 'Namaskara sir, ay-noo bay-koo? Tea or coffee?',
          },
          {
            'sp': 'User',
            'k': 'Ondu Masala Tea kodi. Sweet swalpa kadime maadi.',
            'e': 'Give one Masala Tea. Make the sweet a bit less.',
            'p': 'Ondoo Masala Tea koh-dee. Sweet swal-pah ka-dee-may mah-dee.',
            'user': true,
          },
          {
            'sp': 'Staff',
            'k': 'Sari sir, low sugar tea ready. Biscuits beka?',
            'e': 'Okay sir, low sugar tea is ready. Do you want biscuits?',
            'p': 'Sari sir, low sugar tea ready. Biscuits bay-kah?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, eradu salt biscuits kodi. Estu aaguthe?',
            'e': 'Yes, give two salt biscuits. How much does it cost?',
            'p': 'How-du, er-ah-doo salt biscuits koh-dee. Es-too ah-goo-theh?',
            'user': true,
          },
          {
            'sp': 'Staff',
            'k': 'Total twenty-five (25) rupees, sir.',
            'e': 'Total twenty-five (25) rupees, sir.',
            'p': 'Total twenty-five (25) rupees, sir.',
          },
          {
            'sp': 'User',
            'k': 'Sari, scan QR completed. Dhanyavada!',
            'e': 'Okay, QR scan completed. Thank you!',
            'p': 'Sari, scan QR completed. Dhan-yah-vah-dah!',
            'user': true,
          },
        ],
        'sb': ['Masala', 'Tea', 'kodi', 'sweet', 'kadime'],
        'sba': 'Masala Tea kodi',
        'm': 'Order tea specifying sugar customization using "swalpa kadime".',
        'quizzes': [
          {
            'q': 'How do you ask for Masala Tea?',
            'opts': [
              'Masala Tea kodi',
              'Water kodi',
              'Bill kodi',
              'Coffee kodi',
            ],
            'ans': 'Masala Tea kodi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Biscuits ______."',
            'opts': ['beku', 'illa', 'kodi', 'banni'],
            'ans': 'beku',
            'type': 'fill_blank',
          },
          {
            'q': 'Sweet swalpa kadime',
            'opts': [
              'Reduce sweet a bit',
              'Add more sweet',
              'Spicy tea please',
              'No milk',
            ],
            'ans': 'Reduce sweet a bit',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'workplace_2',
        'title': 'Project Update Dialogue',
        'sub': 'Update managers on final deadlines.',
        'cat': LessonCategory.workplace,
        'sit':
            'Report status of a critical software task to the manager. Confirm completion, discuss final deadlines, and schedule the delivery panel review.',
        'vocab': [
          {
            'k': 'Kelsa aagide sir',
            'e': 'Work is completed sir',
            'p': 'Kel-sah ah-gee-deh sir',
          },
          {
            'k': 'Deadline yavaga?',
            'e': 'When is the deadline?',
            'p': 'Deadline yaah-vah-gah?',
          },
          {
            'k': 'Today evening 6 PM',
            'e': 'Today evening 6 PM',
            'p': 'Today evening 6 PM',
          },
          {'k': 'Review meeting', 'e': 'Review meeting', 'p': 'Review meeting'},
        ],
        'turns': [
          {
            'sp': 'Manager',
            'k': 'Krishna, project kelsa checking done? Update kodi.',
            'e': 'Krishna, is project work verification done? Give update.',
            'p': 'Krishna, project kel-sah checking done? Update koh-dee.',
          },
          {
            'sp': 'User',
            'k':
                'Haudu sir, kelsa aagide. Verification complete checking done.',
            'e':
                'Yes sir, work is completed. Verification check is completely done.',
            'p':
                'How-du sir, kel-sah ah-gee-deh. Verification complete checking done.',
            'user': true,
          },
          {
            'sp': 'Manager',
            'k': 'Excellent task! Final report deadline yavaga?',
            'e': 'Excellent task! When is the final report deadline?',
            'p': 'Excellent task! Final report deadline yaah-vah-gah?',
          },
          {
            'sp': 'User',
            'k': 'Deadline today evening 6 PM. Files send madthene.',
            'e': 'The deadline is today evening 6 PM. I will send the files.',
            'p': 'Deadline today evening 6 PM. Files send mad-thee-nay.',
            'user': true,
          },
          {
            'sp': 'Manager',
            'k': 'Sari, tomorrow review meeting schedule check.',
            'e': 'Okay, check tomorrow review meeting schedule.',
            'p': 'Sari, tomorrow review meeting schedule check.',
          },
        ],
        'sb': ['Kelsa', 'aagide', 'sir', 'deadline', 'meeting'],
        'sba': 'Kelsa aagide sir',
        'm':
            'State task progress by stating "Kelsa aagide sir" in your next sync.',
        'quizzes': [
          {
            'q': 'What does "Kelsa aagide sir" mean?',
            'opts': [
              'Work is completed sir',
              'Work is pending sir',
              'Meeting has started',
              'Where is report?',
            ],
            'ans': 'Work is completed sir',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Deadline ______?"',
            'opts': ['yavaga', 'elli', 'estu', 'haudu'],
            'ans': 'yavaga',
            'type': 'fill_blank',
          },
          {
            'q': 'Kelsa aagide sir',
            'opts': [
              'Work is completed sir',
              'Work is starting sir',
              'Where is office?',
              'Call electrician',
            ],
            'ans': 'Work is completed sir',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'shopping_2',
        'title': 'Bargaining at Mango Market',
        'sub': 'Negotiate fruit prices with vendors.',
        'cat': LessonCategory.shopping,
        'sit':
            'Purchase fresh mangoes from an open market vendor. Enquire about the price per kilogram, negotiate a volume discount, weigh purchases, and check out.',
        'vocab': [
          {
            'k': 'Mangoes rate estu?',
            'e': 'What is mango rate?',
            'p': 'Mangoes rate es-too?',
          },
          {
            'k': 'Rate swalpa kadime maadi',
            'e': 'Reduce price a bit',
            'p': 'Rate swal-pah ka-dee-may mah-dee',
          },
          {
            'k': 'Eradu kilo kodi',
            'e': 'Give two kilos',
            'p': 'Er-ah-doo kilo koh-dee',
          },
          {'k': 'Fresh ideya?', 'e': 'Is it fresh?', 'p': 'Fresh ee-deh-yah?'},
        ],
        'turns': [
          {
            'sp': 'Vendor',
            'k': 'Namaskara sir, fresh mangoes scale ready. Kilo kodi?',
            'e': 'Hello sir, fresh mangoes scale is ready. Give a kilo?',
            'p': 'Namaskara sir, fresh mangoes scale ready. Kilo koh-dee?',
          },
          {
            'sp': 'User',
            'k': 'Namaskara. Mangoes rate estu? Fresh ideya?',
            'e': 'Hello. What is the rate of the mangoes? Is it fresh?',
            'p': 'Namaskara. Mangoes rate es-too? Fresh ee-deh-yah?',
            'user': true,
          },
          {
            'sp': 'Vendor',
            'k': 'Haudu sir, very sweet. Kilo scale rate 120 rupees.',
            'e': 'Yes sir, very sweet. One kilo rate is 120 rupees.',
            'p': 'How-du sir, very sweet. Kilo scale rate 120 rupees.',
          },
          {
            'sp': 'User',
            'k': 'Heavy price! Rate swalpa kadime maadi, 100 kodi.',
            'e': 'Heavy price! Reduce the rate a bit, make it 100.',
            'p':
                'Heavy price! Rate swal-pah ka-dee-may mah-dee, noor-oo koh-dee.',
            'user': true,
          },
          {
            'sp': 'Vendor',
            'k': 'Sari sir, eradu kilo threshold 200 kodi, pack done.',
            'e': 'Okay sir, give 200 for two kilos, packing is done.',
            'p':
                'Sari sir, er-ah-doo kilo threshold er-ah-doo noor-oo koh-dee, pack done.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. UPI payment done.',
            'e': 'Thank you. UPI payment is done.',
            'p': 'Dhan-yah-vah-dah. UPI payment done.',
            'user': true,
          },
        ],
        'sb': ['Rate', 'swalpa', 'kadime', 'maadi', 'kilo'],
        'sba': 'Rate swalpa kadime maadi',
        'm':
            'Practice bargain adjustments saying "Swalpa kadime maadi" at a local stall today.',
        'quizzes': [
          {
            'q': 'How do you request a lower rate?',
            'opts': [
              'Rate swalpa kadime maadi',
              'Rate estu?',
              'Fresh ideya?',
              'UPI idiya?',
            ],
            'ans': 'Rate swalpa kadime maadi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Mangoes ______?"',
            'opts': [
              'fresh ideya',
              'bill kodi',
              'hathira ATM',
              'current bandilla',
            ],
            'ans': 'fresh ideya',
            'type': 'fill_blank',
          },
          {
            'q': 'Eradu kilo kodi',
            'opts': [
              'Give two kilos',
              'Give three kilos',
              'What is price?',
              'Show QR code',
            ],
            'ans': 'Give two kilos',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'college_2',
        'title': 'Meet Hostel Roommates',
        'sub': 'Introduce roommate and share hometowns.',
        'cat': LessonCategory.college,
        'sit':
            'Meet your assigned hostel roommate. Exchange names, ask where they are from, discuss baggage arrangements, and express delight.',
        'vocab': [
          {
            'k': 'Neevu yaava ooru?',
            'e': 'Where are you from?',
            'p': 'Nee-voo yaah-vah oo-roo?',
          },
          {'k': 'Nanna roommate', 'e': 'My roommate', 'p': 'Nan-nah roommate'},
          {
            'k': 'Mootegalu elli?',
            'e': 'Where are the bags?',
            'p': 'Moo-tay-gah-loo el-lee?',
          },
          {
            'k': 'Nodi kushi aaythu',
            'e': 'Nice meeting you',
            'p': 'Noh-dee koo-shee eye-thoo',
          },
        ],
        'turns': [
          {
            'sp': 'Roommate',
            'k': 'Hi! Ninna hesaru enu? Naanu Karthik, engineering room.',
            'e': 'Hi! What is your name? I am Karthik, engineering room.',
            'p':
                'Hi! Neen-nah heh-sah-roo ay-noo? Naanu Karthik, engineering room.',
          },
          {
            'sp': 'User',
            'k': 'Hi Karthik, naanu Krishna. Neevu yaava ooru?',
            'e': 'Hi Karthik, I am Krishna. Where are you from?',
            'p': 'Hi Karthik, naanu Krishna. Nee-voo yaah-vah oo-roo?',
            'user': true,
          },
          {
            'sp': 'Roommate',
            'k': 'Naanu Shivamogga ooru, nimdu yaava ooru?',
            'e': 'I am from Shivamogga, which is your hometown?',
            'p': 'Naanu Shivamogga oo-roo, neem-doo yaah-vah oo-roo?',
          },
          {
            'sp': 'User',
            'k': 'Nanna ooru Mysuru. Nodi kushi aaythu, roommate!',
            'e': 'My hometown is Mysuru. Nice meeting you, roommate!',
            'p': 'Nan-nah oo-roo Mysuru. Noh-dee koo-shee eye-thoo, roommate!',
            'user': true,
          },
          {
            'sp': 'Roommate',
            'k': 'Same here. Mootegalu shelf corner check pack done.',
            'e': 'Same here. Checked the shelves for bags, packing is done.',
            'p': 'Same here. Moo-tay-gah-loo shelf corner check pack done.',
          },
        ],
        'sb': ['Neevu', 'yaava', 'ooru', 'student', 'hesaru'],
        'sba': 'Neevu yaava ooru',
        'm':
            'Ask a hostel colleague "Neevu yaava ooru?" to check their origins.',
        'quizzes': [
          {
            'q': 'What does "Neevu yaava ooru?" mean?',
            'opts': [
              'Where are you from?',
              'What is your name?',
              'Are you studying?',
              'Where are bags?',
            ],
            'ans': 'Where are you from?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Ninna nodi ______ aaythu."',
            'opts': ['kushi', 'oota', 'kelsa', 'neeru'],
            'ans': 'kushi',
            'type': 'fill_blank',
          },
          {
            'q': 'Neevu yaava ooru?',
            'opts': [
              'Where are you from?',
              'What is your name?',
              'How are you?',
              'Goodbye',
            ],
            'ans': 'Where are you from?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'daily_2',
        'title': 'Call Home Electrician',
        'sub': 'Report flat power switch failures.',
        'cat': LessonCategory.basics,
        'sit':
            'Face a power outage in your apartment flat. Search for an electrician contact number, explain current switch failures, check repair timelines, and request review.',
        'vocab': [
          {
            'k': 'Current bandilla',
            'e': 'Power has not come',
            'p': 'Current ban-deel-lah',
          },
          {
            'k': 'Switch check maadi',
            'e': 'Check the switch',
            'p': 'Switch check mah-dee',
          },
          {
            'k': 'Electrician counter',
            'e': 'Electrician counter',
            'p': 'Electrician counter',
          },
          {
            'k': 'Estu time aaguthe?',
            'e': 'How much time will it take?',
            'p': 'Es-too time ah-goo-theh?',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Hello electrician, nanna flat power check. Current bandilla.',
            'e':
                'Hello electrician, check my flat power. Current has not come.',
            'p':
                'Hello electrician, nan-nah flat power check. Current ban-deel-lah.',
            'user': true,
          },
          {
            'sp': 'Electrician',
            'k':
                'Sari sir, whole building current bandilla, or flat switch problem?',
            'e':
                'Okay sir, has power not come to the whole building, or is it a flat switch problem?',
            'p':
                'Sari sir, whole building current ban-deel-lah, or flat switch problem?',
          },
          {
            'sp': 'User',
            'k': 'Nanna flat nalli switch check box board failure ide.',
            'e': 'Inside my flat, there is a switch check box board failure.',
            'p': 'Nan-nah flat nal-lee switch check box board failure ee-deh.',
            'user': true,
          },
          {
            'sp': 'Electrician',
            'k': 'Sari, naanu 10 minutes nalli barthini, switch check board.',
            'e': 'Okay, I will come in 10 minutes and check the switch board.',
            'p':
                'Sari, naanu hathoo minutes nal-lee bar-thee-nee, switch check board.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. Quick banni.',
            'e': 'Thank you. Come quickly.',
            'p': 'Dhan-yah-vah-dah. Quick ban-nee.',
            'user': true,
          },
        ],
        'sb': ['Current', 'bandilla', 'flat', 'board', 'electrician'],
        'sba': 'Current bandilla',
        'm':
            'Learn power failure statements stating "Current bandilla" in case of blackout.',
        'quizzes': [
          {
            'q': 'How do you say "Power has not come"?',
            'opts': [
              'Current bandilla',
              'Sahaya maadi',
              'Bill kodi',
              'Meter haaki',
            ],
            'ans': 'Current bandilla',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Switch ______ maadi."',
            'opts': ['check', 'kodi', 'hogi', 'banni'],
            'ans': 'check',
            'type': 'fill_blank',
          },
          {
            'q': 'Current bandilla',
            'opts': [
              'Power has not come',
              'Check the switch',
              'Open the gate',
              'Where is hospital?',
            ],
            'ans': 'Power has not come',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'emergency_2',
        'title': 'GYM Lost Mobile Check',
        'sub': 'Search lost mobile devices.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Lose your smartphone at the gym. Enquire with the reception manager, describe cover colors, verify log books, and claim your device.',
        'vocab': [
          {
            'k': 'Nanna mobile elli?',
            'e': 'Where is my mobile?',
            'p': 'Nan-nah mobile el-lee?',
          },
          {'k': 'Gym manager', 'e': 'Gym manager', 'p': 'Gym manager'},
          {
            'k': 'Table check box',
            'e': 'Table check box',
            'p': 'Table check box',
          },
          {
            'k': 'Red color cover',
            'e': 'Red color cover',
            'p': 'Red color cover',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Gym manager sir, nanna mobile elli? Table check box look.',
            'e':
                'Gym manager sir, where is my mobile? Look at the table check box.',
            'p':
                'Gym manager sir, nan-nah mobile el-lee? Table check box look.',
            'user': true,
          },
          {
            'sp': 'Manager',
            'k':
                'Namaskara sir. Nimma mobile cover color enu? Red color cover?',
            'e':
                'Hello sir. What is the color of your mobile cover? Is it red?',
            'p':
                'Namaskara sir. Neem-mah mobile cover color ay-noo? Red color cover?',
          },
          {
            'sp': 'User',
            'k': 'Haudu sir, red color cover. Ring signal check done?',
            'e': 'Yes sir, red color cover. Is the ring signal checked?',
            'p': 'How-du sir, red color cover. Ring signal check done?',
            'user': true,
          },
          {
            'sp': 'Manager',
            'k': 'Haudu sir, counter safe box registration counter nalli ide.',
            'e':
                'Yes sir, it is inside the counter safe box registration counter.',
            'p':
                'How-du sir, counter safe box registration counter nal-lee ee-deh.',
          },
          {
            'sp': 'User',
            'k': 'Mobile found! Dhanyavada, big help.',
            'e': 'Mobile found! Thank you, big help.',
            'p': 'Mobile found! Dhan-yah-vah-dah, big help.',
            'user': true,
          },
        ],
        'sb': ['Nanna', 'mobile', 'elli', 'gym', 'manager'],
        'sba': 'Nanna mobile elli',
        'm': 'Ask for lost items saying "Nanna [item] elli?" during search.',
        'quizzes': [
          {
            'q': 'How do you ask "Where is my mobile?"',
            'opts': [
              'Nanna mobile elli?',
              'Current bandilla',
              'Flat number kodi',
              'Dhanyavada',
            ],
            'ans': 'Nanna mobile elli?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Red color ______ cover."',
            'opts': ['mobile', 'oota', 'kelsa', 'neeru'],
            'ans': 'mobile',
            'type': 'fill_blank',
          },
          {
            'q': 'Nanna mobile elli?',
            'opts': [
              'Where is my mobile?',
              'Where is the counter?',
              'Where is the washroom?',
              'Open the gate',
            ],
            'ans': 'Where is my mobile?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'travel_3',
        'title': 'Riding the BMTC Bus',
        'sub': 'Ask conductor for ticket & routes.',
        'cat': LessonCategory.travel,
        'sit':
            'Board a BMTC bus. Ask the conductor if the bus routes go to Majestic terminal, buy the ticket, and ask about ticket fares.',
        'vocab': [
          {
            'k': 'Bus Majestic ge hogutha?',
            'e': 'Does bus go to Majestic?',
            'p': 'Bus Majestic gay hoh-goo-thah?',
          },
          {'k': 'Ticket kodi', 'e': 'Give ticket', 'p': 'Ticket koh-dee'},
          {
            'k': 'Estu ticket price?',
            'e': 'What is ticket price?',
            'p': 'Es-too ticket price?',
          },
          {
            'k': 'Majestic terminal',
            'e': 'Majestic terminal',
            'p': 'Majestic terminal',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Conductor sir, ee bus Majestic ge hogutha?',
            'e': 'Conductor sir, does this bus go to Majestic?',
            'p': 'Conductor sir, ee bus Majestic gay hoh-goo-thah?',
            'user': true,
          },
          {
            'sp': 'Conductor',
            'k': 'Haudu sir, Majestic direct route board. Banni board.',
            'e': 'Yes sir, it is a Majestic direct route board. Come board.',
            'p': 'How-du sir, Majestic direct route board. Ban-nee board.',
          },
          {
            'sp': 'User',
            'k': 'Majestic ge ticket kodi. Estu ticket price?',
            'e': 'Give ticket to Majestic. How much is the ticket price?',
            'p': 'Majestic gay ticket koh-dee. Es-too ticket price?',
            'user': true,
          },
          {
            'sp': 'Conductor',
            'k': 'Majestic ticket price twenty (20) rupees, sir.',
            'e': 'Majestic ticket price is twenty (20) rupees, sir.',
            'p': 'Majestic ticket price twenty (20) rupees, sir.',
          },
          {
            'sp': 'User',
            'k': 'Sari, 20 rupees cash kodi details scan. Dhanyavada!',
            'e': 'Okay, giving 20 rupees cash. Thank you!',
            'p':
                'Sari, er-ah-vah-thoo rupees cash koh-dee details scan. Dhan-yah-vah-dah!',
            'user': true,
          },
        ],
        'sb': ['Ee', 'bus', 'Majestic', 'ge', 'hogutha'],
        'sba': 'Ee bus Majestic ge hogutha',
        'm':
            'Check travel routes asking "Ee bus [destination] ge hogutha?" today.',
        'quizzes': [
          {
            'q': 'How do you check bus destinations?',
            'opts': [
              'Bus Majestic ge hogutha?',
              'Ticket kodi',
              'Counter elli?',
              'Meter haaki',
            ],
            'ans': 'Bus Majestic ge hogutha?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Majestic ge ______ kodi."',
            'opts': ['ticket', 'oota', 'kelsa', 'current'],
            'ans': 'ticket',
            'type': 'fill_blank',
          },
          {
            'q': 'Bus Majestic ge hogutha?',
            'opts': [
              'Does this bus go to Majestic?',
              'Give ticket to Majestic',
              'Where is Majestic?',
              'Go to Majestic by auto',
            ],
            'ans': 'Does this bus go to Majestic?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'restaurant_3',
        'title': 'Restaurant Bill Check Out',
        'sub': 'Pay bills and get dinner receipt.',
        'cat': LessonCategory.restaurant,
        'sit':
            'Finish dinner at a restaurant. Summon the waiter, request the final bill, check total items count, scan QR codes, and pay.',
        'vocab': [
          {
            'k': 'Dinner bill kodi',
            'e': 'Give dinner bill',
            'p': 'Dinner bill koh-dee',
          },
          {
            'k': 'UPI option scanning',
            'e': 'UPI option scanning',
            'p': 'UPI option scanning',
          },
          {
            'k': 'Total price count',
            'e': 'Total price count',
            'p': 'Total price count',
          },
          {
            'k': 'Dhanyavada waiter',
            'e': 'Thank you waiter',
            'p': 'Dhan-yah-vah-dah waiter',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Waiter sir, dinner oota complete. Bill kodi.',
            'e': 'Waiter sir, dinner food is complete. Give the bill.',
            'p': 'Waiter sir, dinner oo-tah complete. Bill koh-dee.',
            'user': true,
          },
          {
            'sp': 'Waiter',
            'k': 'Sari sir, total item count check details receipt.',
            'e': 'Okay sir, check total item count details on the receipt.',
            'p': 'Sari sir, total item count check details receipt.',
          },
          {
            'sp': 'User',
            'k': 'UPI scanning machine idiya?',
            'e': 'Do you have the UPI scanning machine?',
            'p': 'UPI scanning machine ee-dee-yah?',
            'user': true,
          },
          {
            'sp': 'Waiter',
            'k': 'Haudu sir, counter QR code scan scan details.',
            'e': 'Yes sir, scan the counter QR code for scanning details.',
            'p': 'How-du sir, counter QR code scan scan details.',
          },
          {
            'sp': 'User',
            'k': 'Payment completed. Dhanyavada waiter.',
            'e': 'Payment completed. Thank you waiter.',
            'p': 'Payment completed. Dhan-yah-vah-dah waiter.',
            'user': true,
          },
        ],
        'sb': ['Bill', 'kodi', 'swalpa', 'waiter', 'dinner'],
        'sba': 'Bill kodi',
        'm': 'Request checkout bills stating "Bill kodi" when dining out.',
        'quizzes': [
          {
            'q': 'How do you ask for the restaurant bill?',
            'opts': [
              'Dinner bill kodi',
              'Menu kodi',
              'Water kodi',
              'Banni banni',
            ],
            'ans': 'Dinner bill kodi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "UPI scanning ______ idiya?"',
            'opts': ['machine', 'oota', 'kelsa', 'neeru'],
            'ans': 'machine',
            'type': 'fill_blank',
          },
          {
            'q': 'Dinner bill kodi',
            'opts': [
              'Give the dinner bill',
              'Give the menu card',
              'Give some water',
              'How much is it?',
            ],
            'ans': 'Give the dinner bill',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'workplace_3',
        'title': 'Cafeteria Lunch Box',
        'sub': 'Share lunch boxes with office friends.',
        'cat': LessonCategory.workplace,
        'sit':
            'Join colleagues at lunch hours. Exchange boxes, ask about meal menus, share items, and enjoy break hours.',
        'vocab': [
          {
            'k': 'Oota aaytha?',
            'e': 'Did you have food?',
            'p': 'Oo-tah eye-thah?',
          },
          {
            'k': 'Curry share matching',
            'e': 'Curry share matching',
            'p': 'Curry share matching',
          },
          {'k': 'Roti box curry', 'e': 'Roti box curry', 'p': 'Roti box curry'},
          {
            'k': 'Dhanyavada guru',
            'e': 'Thank you mate',
            'p': 'Dhan-yah-vah-dah guru',
          },
        ],
        'turns': [
          {
            'sp': 'Colleague',
            'k': 'Krishna, break ready. Oota aaytha? Lunch box ready?',
            'e':
                'Krishna, break is ready. Did you have food? Is your lunch box ready?',
            'p': 'Krishna, break ready. Oo-tah eye-thah? Lunch box ready?',
          },
          {
            'sp': 'User',
            'k': 'Hi! Haudu, nanna box nalli roti curry check ready.',
            'e': 'Hi! Yes, inside my box roti curry check is ready.',
            'p': 'Hi! How-du, nan-nah box nal-lee roti curry check ready.',
            'user': true,
          },
          {
            'sp': 'Colleague',
            'k': 'Super, share curries! Nanna box nalli rice bath ide.',
            'e': 'Super, share curries! Inside my box, there is rice bath.',
            'p': 'Super, share curries! Nan-nah box nal-lee rice bath ee-deh.',
          },
          {
            'sp': 'User',
            'k': 'Wow, rice bath testy. Dhanyavada guru!',
            'e': 'Wow, rice bath is tasty. Thank you mate!',
            'p': 'Wow, rice bath tasty. Dhan-yah-vah-dah guru!',
            'user': true,
          },
          {
            'sp': 'Colleague',
            'k': 'Welcome! Canteen lunch share matched, back to kelsa.',
            'e': 'Welcome! Canteen lunch sharing is matched, back to work.',
            'p': 'Welcome! Canteen lunch share matched, back to kel-sah.',
          },
        ],
        'sb': ['Oota', 'aaytha', 'nimdu', 'guru', 'lunch'],
        'sba': 'Oota aaytha',
        'm': 'Ask a coworker "Oota aaytha?" during lunch breaks today.',
        'quizzes': [
          {
            'q': 'What does "Oota aaytha?" mean?',
            'opts': [
              'Did you have food?',
              'What is your name?',
              'How are you?',
              'Where is canteen?',
            ],
            'ans': 'Did you have food?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Dhanyavada ______."',
            'opts': ['guru', 'kelsa', 'oota', 'neeru'],
            'ans': 'guru',
            'type': 'fill_blank',
          },
          {
            'q': 'Oota aaytha?',
            'opts': [
              'Did you have food?',
              'Did you complete work?',
              'Shall we drink coffee?',
              'See you tomorrow',
            ],
            'ans': 'Did you have food?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'shopping_3',
        'title': 'Locating Grocery Aisle',
        'sub': 'Search oils and grocery shelves.',
        'cat': LessonCategory.shopping,
        'sit':
            'Search for items in a large retail supermarket. Ask the floor staff for the cooking oil rack, verify discounts, and check price lists.',
        'vocab': [
          {
            'k': 'Enne packet elli ide?',
            'e': 'Where is oil packet?',
            'p': 'En-nay packet el-lee ee-deh?',
          },
          {
            'k': 'Oil section rack',
            'e': 'Oil section rack',
            'p': 'Oil section rack',
          },
          {
            'k': 'First aisle corner',
            'e': 'First aisle corner',
            'p': 'First aisle corner',
          },
          {
            'k': 'Discount tags check',
            'e': 'Discount tags check',
            'p': 'Discount tags check',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Staff sir, swalpa help. Enne packet elli ide?',
            'e': 'Staff sir, some help. Where is the oil packet?',
            'p': 'Staff sir, swal-pah help. En-nay packet el-lee ee-deh?',
            'user': true,
          },
          {
            'sp': 'Staff',
            'k': 'Namaskara sir, oil section first aisle corner check.',
            'e': 'Hello sir, check the oil section first aisle corner.',
            'p': 'Namaskara sir, oil section first aisle corner check.',
          },
          {
            'sp': 'User',
            'k': 'Third rack checking done? Discount tag counter?',
            'e':
                'Is the third rack checked? Where is the discount tag counter?',
            'p': 'Third rack checking done? Discount tag counter?',
            'user': true,
          },
          {
            'sp': 'Staff',
            'k': 'Haudu sir, discount tags scan board counter nalli apply.',
            'e':
                'Yes sir, discount tags are applied at the scan board counter.',
            'p': 'How-du sir, discount tags scan board counter nal-lee apply.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. Packing counter ge barthini.',
            'e': 'Thank you. I will come to the packing counter.',
            'p': 'Dhan-yah-vah-dah. Packing counter gay bar-thee-nee.',
            'user': true,
          },
        ],
        'sb': ['Enne', 'packet', 'elli', 'ide', 'oil'],
        'sba': 'Enne packet elli ide',
        'm': 'Locate grocery items using "elli ide?" at a store today.',
        'quizzes': [
          {
            'q': 'How do you ask "Where is the oil packet?"',
            'opts': [
              'Enne packet elli ide?',
              'Rate estu?',
              'QR code torisi',
              'Dhanyavada',
            ],
            'ans': 'Enne packet elli ide?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Oil section ______ aisle."',
            'opts': ['first', 'canteen', 'lift', 'flat'],
            'ans': 'first',
            'type': 'fill_blank',
          },
          {
            'q': 'Enne packet elli ide?',
            'opts': [
              'Where is the oil packet?',
              'Where is the milk packet?',
              'Show me the QR code',
              'Give the bill',
            ],
            'ans': 'Where is the oil packet?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'college_3',
        'title': 'Library Enquiries',
        'sub': 'Borrow books using library cards.',
        'cat': LessonCategory.college,
        'sit':
            'Visit college library shelves. Ask the librarian for a Kannada history book, check returning deadlines, and present your library card.',
        'vocab': [
          {
            'k': 'Kannada pustaka beku',
            'e': 'I want a Kannada book',
            'p': 'Kannada poos-tah-kah bay-koo',
          },
          {
            'k': 'Library card registration',
            'e': 'Library card registration',
            'p': 'Library card registration',
          },
          {
            'k': 'Return date limit',
            'e': 'Return date limit',
            'p': 'Return date limit',
          },
          {
            'k': 'Late fine threshold',
            'e': 'Late fine threshold',
            'p': 'Late fine threshold',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Librarian sir, research Kannada pustaka beku.',
            'e': 'Librarian sir, I want a research Kannada book.',
            'p': 'Librarian sir, research Kannada poos-tah-kah bay-koo.',
            'user': true,
          },
          {
            'sp': 'Librarian',
            'k': 'Namaskara. Kannada catalog row check shelf catalog.',
            'e': 'Hello. Check the Kannada catalog row shelf catalog.',
            'p': 'Namaskara. Kannada catalog row check shelf catalog.',
          },
          {
            'sp': 'User',
            'k': 'Book number found. Library card check valid?',
            'e': 'Book number found. Is the library card checked as valid?',
            'p': 'Book number found. Library card check valid?',
            'user': true,
          },
          {
            'sp': 'Librarian',
            'k': 'Haudu sir, card check scanned. Return date 15 days.',
            'e': 'Yes sir, card check is scanned. Return date is 15 days.',
            'p': 'How-du sir, card check scanned. Return date fifteen days.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. Pustaka issue check done.',
            'e': 'Thank you. Book issue check is done.',
            'p': 'Dhan-yah-vah-dah. Poos-tah-kah issue check done.',
            'user': true,
          },
        ],
        'sb': ['Kannada', 'pustaka', 'beku', 'library', 'card'],
        'sba': 'Kannada pustaka beku',
        'm':
            'Ask for reading materials by stating "[Topic] pustaka beku" today.',
        'quizzes': [
          {
            'q': 'How do you say "I want a Kannada book"?',
            'opts': [
              'Kannada pustaka beku',
              'Classroom elli?',
              'Neevu student?',
              'Nale sigona',
            ],
            'ans': 'Kannada pustaka beku',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Library card ______ check."',
            'opts': ['ID', 'oota', 'kelsa', 'neeru'],
            'ans': 'ID',
            'type': 'fill_blank',
          },
          {
            'q': 'Kannada pustaka beku',
            'opts': [
              'I want a Kannada book',
              'Where is the library?',
              'Write in register',
              'Go to counter',
            ],
            'ans': 'I want a Kannada book',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'daily_3',
        'title': 'Locating Nearby ATM',
        'sub': 'Request directions for cash machines.',
        'cat': LessonCategory.basics,
        'sit':
            'Run out of pocket cash. Ask a local passerby for ATM bank branches directions, check if it is within walking distance, and thank them.',
        'vocab': [
          {
            'k': 'Hathira ATM elli ide?',
            'e': 'Where is nearby ATM?',
            'p': 'Ha-thee-rah ATM el-lee ee-deh?',
          },
          {
            'k': 'SBI bank signal',
            'e': 'SBI bank signal',
            'p': 'SBI bank signal',
          },
          {
            'k': 'Signal left block',
            'e': 'Signal left block',
            'p': 'Signal left block',
          },
          {
            'k': 'Walk distance close',
            'e': 'Walk distance close',
            'p': 'Walk distance close',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Namaskara, hathira ATM elli ide, gothideya?',
            'e': 'Hello, do you know where the nearby ATM is?',
            'p': 'Namaskara, ha-thee-rah ATM el-lee ee-deh, go-thee-deh-yah?',
            'user': true,
          },
          {
            'sp': 'Passerby',
            'k': 'Haudu, next signal left side SBI bank ATM ide.',
            'e':
                'Yes, on the left side of the next signal, there is an SBI bank ATM.',
            'p': 'How-du, next signal left side SBI bank ATM ee-deh.',
          },
          {
            'sp': 'User',
            'k': 'Walk distance or travel auto ride required?',
            'e': 'Is it walking distance or is an auto ride required?',
            'p': 'Walk distance or travel auto ride required?',
            'user': true,
          },
          {
            'sp': 'Passerby',
            'k': 'Very close, walk for 2 minutes signal left block.',
            'e': 'Very close, walk for 2 minutes to the signal left block.',
            'p': 'Very close, walk for er-ah-doo minutes signal left block.',
          },
          {
            'sp': 'User',
            'k': 'Tumba dhanyavada! Clean logic route.',
            'e': 'Thank you very much! Clear route logic.',
            'p': 'Thoomba dhan-yah-vah-dah! Clean logic route.',
            'user': true,
          },
        ],
        'sb': ['Hathira', 'ATM', 'elli', 'ide', 'SBI'],
        'sba': 'Hathira ATM elli ide',
        'm': 'Locate local ATMs asking "Hathira ATM elli ide?" today.',
        'quizzes': [
          {
            'q': 'How do you ask "Where is the nearby ATM?"',
            'opts': [
              'Hathira ATM elli ide?',
              'Current bandilla',
              'Flat number kodi',
              'Sahaya maadi',
            ],
            'ans': 'Hathira ATM elli ide?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Next signal ______ side ATM."',
            'opts': ['left', 'oota', 'kelsa', 'neeru'],
            'ans': 'left',
            'type': 'fill_blank',
          },
          {
            'q': 'Hathira ATM elli ide?',
            'opts': [
              'Where is the nearby ATM?',
              'Where is the hospital?',
              'Where is the shop?',
              'Put the meter on',
            ],
            'ans': 'Where is the nearby ATM?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'emergency_3',
        'title': 'Doctor consultation timings',
        'sub': 'Consult clinic tokens and timings.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Visit a health clinic. Request tokens at the counter from receptionists, explain timing details, ask when the doctor comes, and request emergency tokens.',
        'vocab': [
          {
            'k': 'Doctor yavaga barthare?',
            'e': 'When will doctor come?',
            'p': 'Doctor yaah-vah-gah bar-tha-ray?',
          },
          {
            'k': 'Clinic token register',
            'e': 'Clinic token register',
            'p': 'Clinic token register',
          },
          {
            'k': 'Consultation timings 10 AM',
            'e': 'Consultation timings 10 AM',
            'p': 'Consultation timings 10 AM',
          },
          {
            'k': 'Emergency special token',
            'e': 'Emergency special token',
            'p': 'Emergency special token',
          },
        ],
        'turns': [
          {
            'sp': 'User',
            'k': 'Namaskara receptionist, doctor yavaga barthare?',
            'e': 'Hello receptionist, when will the doctor come?',
            'p': 'Namaskara receptionist, doctor yaah-vah-gah bar-tha-ray?',
            'user': true,
          },
          {
            'sp': 'Receptionist',
            'k': 'Doctor consultation timings 10 AM. Token list check?',
            'e':
                'Doctor consultation timings are 10 AM. Did you check the token list?',
            'p': 'Doctor consultation timings ten AM. Token list check?',
          },
          {
            'sp': 'User',
            'k': 'Yes. Please emergency special token kodi, health warning.',
            'e': 'Yes. Please give an emergency special token, health warning.',
            'p': 'Yes. Please emergency special token koh-dee, health warning.',
            'user': true,
          },
          {
            'sp': 'Receptionist',
            'k':
                'Sari sir, special token number 5, check registration counter.',
            'e':
                'Okay sir, special token number 5, check at the registration counter.',
            'p':
                'Sari sir, special token number five, check registration counter.',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada. Box room nalli koththini.',
            'e': 'Thank you. I will sit in the waiting room.',
            'p': 'Dhan-yah-vah-dah. Box room nal-lee koth-thee-nee.',
            'user': true,
          },
        ],
        'sb': ['Doctor', 'yavaga', 'barthare', 'clinic', 'token'],
        'sba': 'Doctor yavaga barthare',
        'm':
            'Ask clinical desk counters "Doctor yavaga barthare?" when waiting today.',
        'quizzes': [
          {
            'q': 'What does "Doctor yavaga barthare?" mean?',
            'opts': [
              'When will the doctor come?',
              'Give me medicine',
              'Where is the hospital?',
              'Please help',
            ],
            'ans': 'When will the doctor come?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Emergency special ______ number 5."',
            'opts': ['token', 'oota', 'kelsa', 'neeru'],
            'ans': 'token',
            'type': 'fill_blank',
          },
          {
            'q': 'Doctor yavaga barthare?',
            'opts': [
              'When will the doctor come?',
              'When will power come?',
              'When will bus come?',
              'When will train come?',
            ],
            'ans': 'When will the doctor come?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'social_1',
        'title': 'Workshop Culture Chat',
        'sub': 'Exchange greetings at weekend events.',
        'cat': LessonCategory.greetings,
        'sit':
            'Attend a weekend Kannada cultural workshop. Initiate conversation, express pleasure at meeting a new participant, and schedule next day meetups.',
        'vocab': [
          {
            'k': 'Nodiddu thumba kushi',
            'e': 'Very happy to see you',
            'p': 'Noh-deed-doo thoomba koo-shee',
          },
          {
            'k': 'Karnataka culture event',
            'e': 'Karnataka culture event',
            'p': 'Karnataka culture event',
          },
          {
            'k': 'Weekend workshop meetup',
            'e': 'Weekend workshop meetup',
            'p': 'Weekend workshop meetup',
          },
          {
            'k': 'Nale sigona contacts',
            'e': 'See you tomorrow contacts',
            'p': 'Nah-lay see-goh-nah contacts',
          },
        ],
        'turns': [
          {
            'sp': 'Friend',
            'k': 'Namaskara! Event workshop thumba exciting, correct?',
            'e': 'Hello! The event workshop is very exciting, correct?',
            'p': 'Namaskara! Event workshop thoomba exciting, correct?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, Karnataka culture event super. Nodiddu thumba kushi.',
            'e':
                'Yes, the Karnataka culture event is super. Very happy to see you.',
            'p':
                'How-du, Karnataka culture event super. Noh-deed-doo thoomba koo-shee.',
            'user': true,
          },
          {
            'sp': 'Friend',
            'k': 'Me too! Ninna hesaru enu? Naanu Rakesh, contacts exchange?',
            'e': 'Me too! What is your name? I am Rakesh, exchange contacts?',
            'p':
                'Me too! Neen-nah heh-sah-roo ay-noo? Naanu Rakesh, contacts exchange?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, number exchange done. Nale meetup nalli sigona!',
            'e':
                'Yes, number exchange is done. See you tomorrow in the meetup!',
            'p':
                'How-du, number exchange done. Nah-lay meetup nal-lee see-goh-nah!',
            'user': true,
          },
          {
            'sp': 'Friend',
            'k': 'Sari, double kushi, nale sigona. Bye!',
            'e': 'Okay, double happy, see you tomorrow. Bye!',
            'p': 'Sari, double koo-shee, nah-lay see-goh-nah. Bye!',
          },
        ],
        'sb': ['Nodi', 'kushi', 'aaythu', 'work', 'friend'],
        'sba': 'Nodi kushi aaythu',
        'm':
            'Express delight saying "Nodiddu thumba kushi" to a new colleague.',
        'quizzes': [
          {
            'q': 'How do you state "Happy to see you"?',
            'opts': [
              'Nodiddu thumba kushi',
              'Nale sigona',
              'Oota aaytha?',
              'Hegiddira?',
            ],
            'ans': 'Nodiddu thumba kushi',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Ninna nodi ______ aaythu."',
            'opts': ['kushi', 'oota', 'kelsa', 'neeru'],
            'ans': 'kushi',
            'type': 'fill_blank',
          },
          {
            'q': 'Nodiddu thumba kushi',
            'opts': [
              'Very happy to see you',
              'See you tomorrow',
              'Give me coffee',
              'Are you a student?',
            ],
            'ans': 'Very happy to see you',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'social_2',
        'title': 'Birthday Party Invite',
        'sub': 'Invite colleagues to celebrations.',
        'cat': LessonCategory.greetings,
        'sit':
            'Invite a close colleague to your birthday dinner celebration. Specify evening timings, hotel location details, and welcome them.',
        'vocab': [
          {
            'k': 'Nanna birthday party ge banni',
            'e': 'Come to my birthday party',
            'p': 'Nanna birthday party gay banni',
          },
          {
            'k': 'Sanje entu gantege',
            'e': 'At 8 PM in the evening',
            'p': 'Sanje entoo gante-gay',
          },
          {
            'k': 'Hotel address kalisuttene',
            'e': 'I will send the hotel address',
            'p': 'Hotel address kalee-soo-theh-neh',
          },
          {
            'k': 'Nale sigona',
            'e': 'See you tomorrow',
            'p': 'Nah-lay see-goh-nah',
          },
        ],
        'turns': [
          {
            'sp': 'Colleague',
            'k': 'Hi Krishna! Project check list mugiyitha?',
            'e': 'Hi Krishna! Is the project checklist finished?',
            'p': 'Hi Krishna! Project check list moo-gee-yee-thah?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, kelsa aagide. Nanna birthday party ge banni, dinner ide.',
            'e': 'Yes, work is completed. Come to my birthday party, there is dinner.',
            'p': 'How-du, kel-sah ah-gee-deh. Nanna birthday party gay ban-nee, dinner ee-deh.',
            'user': true,
          },
          {
            'sp': 'Colleague',
            'k': 'Wow! Happy Birthday Krishna. Sanje timings estu gantege?',
            'e': 'Wow! Happy Birthday Krishna. What time in the evening?',
            'p': 'Wow! Happy Birthday Krishna. Sanje timings es-too gante-gay?',
          },
          {
            'sp': 'User',
            'k': 'Sanje entu gantege dinner start. Hotel address WhatsApp kalisuttene.',
            'e': 'Dinner starts at 8 PM in the evening. I will WhatsApp the hotel address.',
            'p': 'Sanje entoo gante-gay dinner start. Hotel address WhatsApp kalee-soo-theh-neh.',
            'user': true,
          },
          {
            'sp': 'Colleague',
            'k': 'Sari Krishna, special dinner, naanu kooda barthini. Tumba santosha!',
            'e': 'Okay Krishna, special dinner, I will also come. Very happy!',
            'p': 'Sari Krishna, special dinner, naanu koo-dah bar-thee-nee. Thoomba san-toh-shah!',
          },
          {
            'sp': 'User',
            'k': 'Great! Nale party nalli sigona. Bye!',
            'e': 'Great! See you tomorrow at the party. Bye!',
            'p': 'Great! Nah-lay party nal-lee see-goh-nah. Bye!',
            'user': true,
          },
          {
            'sp': 'Colleague',
            'k': 'Sari, nale sigona! Bye.',
            'e': 'Okay, see you tomorrow! Bye.',
            'p': 'Sari, nah-lay see-goh-nah! Bye.',
          },
        ],
        'sb': ['Nanna', 'birthday', 'party', 'ge', 'banni'],
        'sba': 'Nanna birthday party ge banni',
        'sbt': 'Come to my birthday party',
        'm': 'Extend celebration invitations stating "Nanna birthday party ge banni" today.',
        'quizzes': [
          {
            'q': 'How do you invite a friend to your birthday party?',
            'opts': [
              'Nanna birthday party ge banni',
              'Nale sigona',
              'Hegiddira?',
              'Dhanyavada',
            ],
            'ans': 'Nanna birthday party ge banni',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Sanje entu ______ dinner start."',
            'opts': ['gantege', 'oota', 'kelsa', 'neeru'],
            'ans': 'gantege',
            'type': 'fill_blank',
          },
          {
            'q': 'Nanna birthday party ge banni',
            'opts': [
              'Come to my birthday party',
              'See you tomorrow',
              'Give the bill',
              'How much is it?',
            ],
            'ans': 'Come to my birthday party',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'social_3',
        'title': 'Kannada Movie Review',
        'sub': 'Discuss film reviews with roommates.',
        'cat': LessonCategory.greetings,
        'sit':
            'Discuss a blockbuster Kannada movie with flatmates. Praise visual graphics, acting performance, and book theater tickets.',
        'vocab': [
          {
            'k': 'Cinema thumba chennagide',
            'e': 'The movie is very good',
            'p': 'Cinema thoomba chen-nah-gee-deh',
          },
          {
            'k': 'Nanna roommate',
            'e': 'My roommate',
            'p': 'Nanna roommate',
          },
          {
            'k': 'Tickets book maadona',
            'e': 'Let\'s book tickets',
            'p': 'Tickets book mah-doh-nah',
          },
          {
            'k': 'Hero acting super',
            'e': 'Hero\'s acting is super',
            'p': 'Hero acting super',
          },
        ],
        'turns': [
          {
            'sp': 'Roommate',
            'k': 'Krishna, yesterday released Kannada hit movie check done?',
            'e': 'Krishna, did you watch the new Kannada hit movie?',
            'p': 'Krishna, yesterday released Kannada hit movie check done?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, cinema thumba chennagide. Hero acting super!',
            'e': 'Yes, the movie is very good. The hero\'s acting is super!',
            'p': 'How-du, cinema thoomba chen-nah-gee-deh. Hero acting super!',
            'user': true,
          },
          {
            'sp': 'Roommate',
            'k': 'Graphic visual setups excellent? Screen booking active?',
            'e': 'Are the visual graphics excellent? Is booking open?',
            'p': 'Graphic visual setups excellent? Screen booking active?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, graphics class. BookMyShow nalli tickets book maadona.',
            'e': 'Yes, graphics are class. Let\'s book tickets on BookMyShow.',
            'p': 'How-du, graphics class. BookMyShow nal-lee tickets book mah-doh-nah.',
            'user': true,
          },
          {
            'sp': 'Roommate',
            'k': 'Sari, next weekend tickets book map complete!',
            'e': 'Okay, let\'s book the tickets for next weekend!',
            'p': 'Sari, next weekend tickets book map complete!',
          },
        ],
        'sb': ['Cinema', 'thumba', 'chennagide', 'pustaka', 'kathe'],
        'sba': 'Cinema thumba chennagide',
        'sbt': 'The movie is very good',
        'm': 'Provide movie recommendations stating "Cinema thumba chennagide".',
        'quizzes': [
          {
            'q': 'What does "Cinema thumba chennagide" translate to?',
            'opts': [
              'The movie is very good',
              'The food is very good',
              'Where is the cinema?',
              'I hate movies',
            ],
            'ans': 'The movie is very good',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Hero acting ______."',
            'opts': ['super', 'oota', 'kelsa', 'neeru'],
            'ans': 'super',
            'type': 'fill_blank',
          },
          {
            'q': 'Cinema thumba chennagide',
            'opts': [
              'The movie is very good',
              'The book is very good',
              'Open the gate',
              'Where is the ATM?',
            ],
            'ans': 'The movie is very good',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'advanced_1',
        'title': 'Casual Slang & Guru',
        'sub': 'Learn daily street slang guru.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Join casual street-side conversations. Enquire whats up mate, check traffic status, and chat like a local resident.',
        'vocab': [
          {
            'k': 'En samachara guru?',
            'e': 'What\'s up mate?',
            'p': 'En sah-mah-chah-rah goo-roo?',
          },
          {
            'k': 'Ella ok boss',
            'e': 'All is ok boss',
            'p': 'El-lah ok boss',
          },
          {
            'k': 'Heavy traffic guru',
            'e': 'Heavy traffic mate',
            'p': 'Heavy traffic goo-roo',
          },
          {
            'k': 'Hathira tea stall',
            'e': 'Nearby tea stall',
            'p': 'Ha-thee-rah tea stall',
          },
        ],
        'turns': [
          {
            'sp': 'Friend',
            'k': 'Hey Krishna! En samachara guru? Class checking done?',
            'e': 'Hey Krishna! What\'s up mate? Are classes done?',
            'p': 'Hey Krishna! En sah-mah-chah-rah goo-roo? Class checking done?',
          },
          {
            'sp': 'User',
            'k': 'Ella ok boss! Gym class done, heavy traffic ride completed.',
            'e': 'All is ok boss! Gym class is done, heavy traffic ride is completed.',
            'p': 'El-lah ok boss! Gym class done, heavy traffic ride completed.',
            'user': true,
          },
          {
            'sp': 'Friend',
            'k': 'Super guru. Hathira tea stall ge hogi tea kudiyona?',
            'e': 'Super mate. Shall we go to the nearby tea stall and drink tea?',
            'p': 'Super guru. Ha-thee-rah tea stall gay hoh-gee tea koo-dee-yoh-nah?',
          },
          {
            'sp': 'User',
            'k': 'Haudu guru, kudiyona. Canteen counter banni guru.',
            'e': 'Yes mate, let\'s drink. Come to the canteen counter mate.',
            'p': 'How-du guru, koo-dee-yoh-nah. Canteen counter ban-nee goo-roo.',
            'user': true,
          },
          {
            'sp': 'Friend',
            'k': 'Sari, banni banni guru.',
            'e': 'Okay, come come mate.',
            'p': 'Sari, ban-nee ban-nee goo-roo.',
          },
        ],
        'sb': ['En', 'samachara', 'guru', 'boss', 'namaskara'],
        'sba': 'En samachara guru',
        'sbt': 'What\'s up mate?',
        'm': 'Greet close local friends saying "En samachara guru?".',
        'quizzes': [
          {
            'q': 'What does the slang "En samachara guru?" mean?',
            'opts': [
              'What\'s up mate?',
              'How is work?',
              'Where are you going?',
              'Give me water',
            ],
            'ans': 'What\'s up mate?',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Ella ok ______."',
            'opts': ['boss', 'guru', 'student', 'waiter'],
            'ans': 'boss',
            'type': 'fill_blank',
          },
          {
            'q': 'En samachara guru?',
            'opts': [
              'What\'s up mate?',
              'Nice to meet you',
              'How are you?',
              'Thank you very much',
            ],
            'ans': 'What\'s up mate?',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'advanced_2',
        'title': 'Workspace Panel Presentation',
        'sub': 'Deliver formal conference updates.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Present an update at a regional office conference panel. Address greetings to everyone, state project scopes, and thank your team.',
        'vocab': [
          {
            'k': 'Ellarigu namaskara',
            'e': 'Greetings to everyone',
            'p': 'El-lah-ree-goo nah-mah-skah-rah',
          },
          {
            'k': 'Project update review',
            'e': 'Project update review',
            'p': 'Project update review',
          },
          {
            'k': 'Kelsa mugiyithu',
            'e': 'Work is completed',
            'p': 'Kel-sah moo-gee-yee-thoo',
          },
          {
            'k': 'Dhanyavada team',
            'e': 'Thank you team',
            'p': 'Dhan-yah-vah-dah team',
          },
        ],
        'turns': [
          {
            'sp': 'Host',
            'k': 'Welcome speakers. Speaker Krishna, start panel slides.',
            'e': 'Welcome speakers. Speaker Krishna, start your slides.',
            'p': 'Welcome speakers. Speaker Krishna, start panel slides.',
          },
          {
            'sp': 'User',
            'k': 'Ellarigu namaskara. Indu nanna project update torisuttene.',
            'e': 'Greetings to everyone. Today I will show my project update.',
            'p': 'El-lah-ree-goo nah-mah-skah-rah. Een-doo nanna project update toh-ree-soo-theh-neh.',
            'user': true,
          },
          {
            'sp': 'Boss',
            'k': 'Very precise. Technical details look great!',
            'e': 'Very precise. Technical details look great!',
            'p': 'Very precise. Technical details look great!',
          },
          {
            'sp': 'User',
            'k': 'Dhanyavada team. Kelsa mugiyithu, report complete checking done.',
            'e': 'Thank you team. Work is completed, report check is done.',
            'p': 'Dhan-yah-vah-dah team. Kel-sah moo-gee-yee-thoo, report complete checking done.',
            'user': true,
          },
        ],
        'sb': ['Ellarigu', 'namaskara', 'sir', 'team', 'meeting'],
        'sba': 'Ellarigu namaskara',
        'sbt': 'Greetings to everyone',
        'm': 'Begin formal group meetings saying "Ellarigu namaskara" today.',
        'quizzes': [
          {
            'q': 'How do you formally say "Greetings to everyone"?',
            'opts': [
              'Ellarigu namaskara',
              'Hegiddira?',
              'Dhanyavada',
              'Nale sigona',
            ],
            'ans': 'Ellarigu namaskara',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Project ______ review."',
            'opts': ['update', 'oota', 'kelsa', 'neeru'],
            'ans': 'update',
            'type': 'fill_blank',
          },
          {
            'q': 'Ellarigu namaskara',
            'opts': [
              'Greetings to everyone',
              'Greetings to manager',
              'See you tomorrow',
              'Please help me',
            ],
            'ans': 'Greetings to everyone',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'advanced_3',
        'title': 'Narrate Folklore Story',
        'sub': 'Recite classic village folklore stories.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Recite a small traditional folklore story in a language club. Introduce character roles and share hometown settings.',
        'vocab': [
          {
            'k': 'Kathe thumba chennagide',
            'e': 'Story is very good',
            'p': 'Kah-thay thoomba chen-nah-gee-deh',
          },
          {
            'k': 'Ondu ooralli...',
            'e': 'In a certain town...',
            'p': 'Ondoo oo-ral-lee...',
          },
          {
            'k': 'Obba raja idda',
            'e': 'There was a king',
            'p': 'Obbah rah-jah eed-dah',
          },
          {
            'k': 'Santosha aaythu',
            'e': 'It was joyful',
            'p': 'San-toh-shah eye-thoo',
          },
        ],
        'turns': [
          {
            'sp': 'Moderator',
            'k': 'Krishna sir, please narrate village folklore story.',
            'e': 'Krishna sir, please narrate the village folklore story.',
            'p': 'Krishna sir, please narrate village folklore story.',
          },
          {
            'sp': 'User',
            'k': 'Sari. Ondu ooralli obba raja idda. Avanu thumba olleyavanu.',
            'e': 'Okay. In a certain town, there was a king. He was a very good man.',
            'p': 'Sari. Ondoo oo-ral-lee obbah rah-jah eed-dah. Ah-vah-noo thoomba ol-lay-yah-vah-noo.',
            'user': true,
          },
          {
            'sp': 'Kids',
            'k': 'Wow! Kathe thumba chennagide. We love village stories.',
            'e': 'Wow! The story is very good. We love village stories.',
            'p': 'Wow! Kah-thay thoomba chen-nah-gee-deh. We love village stories.',
          },
          {
            'sp': 'User',
            'k': 'Santosha aaythu, thank you. Kathe mugiyithu.',
            'e': 'I felt happy, thank you. The story has ended.',
            'p': 'San-toh-shah eye-thoo, thank you. Kah-thay moo-gee-yee-thoo.',
            'user': true,
          },
        ],
        'sb': ['Kathe', 'thumba', 'chennagide', 'cinema', 'book'],
        'sba': 'Kathe thumba chennagide',
        'sbt': 'Story is very good',
        'm': 'Recite short stories praising authors with "Kathe thumba chennagide".',
        'quizzes': [
          {
            'q': 'What is the meaning of "Kathe thumba chennagide"?',
            'opts': [
              'The story is very good',
              'The movie is very good',
              'The book is old',
              'I want food',
            ],
            'ans': 'The story is very good',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Obba ______ idda."',
            'opts': ['raja', 'oota', 'kelsa', 'neeru'],
            'ans': 'raja',
            'type': 'fill_blank',
          },
          {
            'q': 'Kathe thumba chennagide',
            'opts': [
              'The story is very good',
              'The tea is very hot',
              'Open the gate',
              'Where is the hospital?',
            ],
            'ans': 'The story is very good',
            'type': 'listening',
          },
        ],
      },
      {
        'id': 'advanced_4',
        'title': 'Final Fluency Dialog',
        'sub': 'Complete fluid Kannada discussion checklist.',
        'cat': LessonCategory.fluentConversation,
        'sit':
            'Engage in a complete fluent Kannada conversation check with Mittu. Review your 30-day learning milestone achievements, declare local communication confidence, and celebrate.',
        'vocab': [
          {
            'k': 'Naanu Kannada mathaduthene',
            'e': 'I speak Kannada',
            'p': 'Naanu Kannada mah-thah-doo-thay-nay',
          },
          {
            'k': 'Fluency milestone achieved',
            'e': 'Fluency milestone achieved',
            'p': 'Fluency milestone achieved',
          },
          {
            'k': 'Confidence level high',
            'e': 'Confidence level high',
            'p': 'Confidence level high',
          },
          {
            'k': 'Santosh Bengaluru life',
            'e': 'Happy Bengaluru life',
            'p': 'San-toh-shah Bengaluru life',
          },
        ],
        'turns': [
          {
            'sp': 'Mittu',
            'k':
                'Krishna, 30 days complete learning path done! How do you feel?',
            'e': 'Krishna, 30 days complete learning path is done! How do you feel?',
            'p': 'Krishna, thirty days complete learning path done! How do you feel?',
          },
          {
            'sp': 'User',
            'k': 'Naanu Kannada mathaduthene. Confidence level high now.',
            'e': 'I speak Kannada. My confidence level is high now.',
            'p': 'Naanu Kannada mah-thah-doo-thay-nay. Confidence level high now.',
            'user': true,
          },
          {
            'sp': 'Mittu',
            'k': 'Amazing! Auto ride, hotel order, campus talks simple?',
            'e': 'Amazing! Are auto rides, hotel ordering, and campus talks simple now?',
            'p': 'Amazing! Auto ride, hotel order, campus talks simple?',
          },
          {
            'sp': 'User',
            'k': 'Haudu, simple. Santosh Bengaluru life matched.',
            'e': 'Yes, simple. Happy Bengaluru life is matched.',
            'p': 'How-du, simple. San-toh-shah Bengaluru life matched.',
            'user': true,
          },
          {
            'sp': 'Mittu',
            'k': 'Thumba santosha! Karnataka welcomes you. Bye!',
            'e': 'Very happy! Karnataka welcomes you. Bye!',
            'p': 'Thoomba san-toh-shah! Karnataka welcomes you. Bye!',
          },
        ],
        'sb': ['Naanu', 'Kannada', 'mathaduthene', 'student', 'hometown'],
        'sba': 'Naanu Kannada mathaduthene',
        'sbt': 'I speak Kannada',
        'm':
            'Declare your language milestone saying "Naanu Kannada mathaduthene" to friends today.',
        'quizzes': [
          {
            'q': 'How do you say "I speak Kannada" in conversation?',
            'opts': [
              'Naanu Kannada mathaduthene',
              'Kannada baralla',
              'Namaskara neevu?',
              'Dhanyavada',
            ],
            'ans': 'Naanu Kannada mathaduthene',
            'type': 'mcq',
          },
          {
            'q': 'Complete: "Confidence ______ high."',
            'opts': ['level', 'oota', 'kelsa', 'neeru'],
            'ans': 'level',
            'type': 'fill_blank',
          },
          {
            'q': 'Naanu Kannada mathaduthene',
            'opts': [
              'I speak Kannada',
              'I study Kannada',
              'I read Kannada',
              'I teach Kannada',
            ],
            'ans': 'I speak Kannada',
            'type': 'listening',
          },
        ],
      },
    ];

    for (final map in data) {
      final List<VocabularyWord> vocabList = [];
      for (final v in map['vocab']) {
        vocabList.add(
          VocabularyWord(
            id: 'v_${map['id']}_${vocabList.length}',
            kannada: v['k'],
            english: v['e'],
            pronunciation: v['p'],
          ),
        );
      }

      final List<DialogueTurn> dialogueList = [];
      for (final turn in map['turns']) {
        dialogueList.add(
          DialogueTurn(
            speaker: turn['sp'],
            textKannada: turn['k'],
            textEnglish: turn['e'],
            pronunciation: turn['p'],
            isUser: turn['user'] ?? false,
          ),
        );
      }

      final List<QuizQuestion> quizList = [];
      for (final q in map['quizzes']) {
        quizList.add(
          QuizQuestion(
            id: 'q_${map['id']}_${quizList.length}',
            questionText: q['q'],
            options: List<String>.from(q['opts']),
            correctAnswer: q['ans'],
            type: q['type'] ?? 'mcq',
          ),
        );
      }

      list.add(
        Lesson(
          id: map['id'],
          title: map['title'],
          subtitle: map['sub'],
          category: map['cat'],
          situationDescription: map['sit'],
          isUnlocked: false,
          isCompleted: false,
          customIllustrationPath: 'assets/images/situations/${map['id']}.webp',
          mittuAnimationState: 'mittu_talking',
          vocabulary: vocabList,
          dialogue: dialogueList,
          sentenceBuilderWords: List<String>.from(map['sb']),
          sentenceBuilderAnswer: map['sba'],
          sentenceBuilderTranslation: map['sbt'] ?? map['e'] ?? '',
          missionDescription: map['m'],
          quiz: quizList,
          grammarBites: map['gb'] != null ? List<String>.from(map['gb'] as List) : const [],
        ),
      );
    }

    return list;
  }
}
