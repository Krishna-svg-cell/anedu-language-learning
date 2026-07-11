import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/database/local_db.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../core/providers/app_providers.dart';

class CharacterRole {
  final String id;
  final String title;
  final String description;
  final String avatarEmoji;
  final String firstMessageKannada;
  final String firstMessageEnglish;
  final String firstMessagePronunciation;
  final int patienceLevel;
  final String vocabularyScope;

  CharacterRole({
    required this.id,
    required this.title,
    required this.description,
    required this.avatarEmoji,
    required this.firstMessageKannada,
    required this.firstMessageEnglish,
    required this.firstMessagePronunciation,
    this.patienceLevel = 8,
    this.vocabularyScope = 'colloquial',
  });
}

class AiEvaluation {
  final int confidence;
  final int pronunciation;
  final int vocabulary;
  final int grammar;
  final int politeness;
  final int taskCompletion;
  final int survivalSuccess;
  final String feedbackTip;

  AiEvaluation({
    required this.confidence,
    required this.pronunciation,
    required this.vocabulary,
    required this.grammar,
    required this.politeness,
    required this.taskCompletion,
    required this.survivalSuccess,
    required this.feedbackTip,
  });
}

class ChatMessage {
  final String textKannada;
  final String textEnglish;
  final String pronunciation;
  final bool isUser;
  final DateTime time;
  final AiEvaluation? evaluation;

  ChatMessage({
    required this.textKannada,
    required this.textEnglish,
    required this.pronunciation,
    required this.isUser,
    required this.time,
    this.evaluation,
  });
}

class AiTutorScreen extends ConsumerStatefulWidget {
  const AiTutorScreen({super.key});

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen> {
  CharacterRole? _selectedCharacter;
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isVoiceRecording = false;

  final List<CharacterRole> _roles = [
    CharacterRole(
      id: 'r1',
      title: 'Kumar (Auto Driver)',
      description: 'Negotiate fares and give directions around Bengaluru.',
      avatarEmoji: '🛺',
      firstMessageKannada:
          'Namaskara! Indiranagar ge barthira? Meter plus swalpa extra aaguthe.',
      firstMessageEnglish:
          'Hello! Will you come to Indiranagar? It will be meter plus a little extra.',
      firstMessagePronunciation:
          'Namaskara! Indiranagar gay bar-thee-rah? Meter plus swal-pah extra ah-goo-theh.',
      patienceLevel: 4,
      vocabularyScope: 'colloquial',
    ),
    CharacterRole(
      id: 'r2',
      title: 'Ramesh (Darshini Waiter)',
      description: 'Order breakfast or ask for the bill at a local cafe.',
      avatarEmoji: '☕',
      firstMessageKannada:
          'Banni! Ivattu Masala Dosa mathu Filter Coffee thumba fresh ide. Enu beku?',
      firstMessageEnglish:
          'Come! Today Masala Dosa and Filter Coffee are very fresh. What do you want?',
      firstMessagePronunciation:
          'Ban-nee! Ee-vah-thoo Masala Dosa mah-thoo Filter Coffee thoomba fresh ee-deh. Ay-noo bay-koo?',
      patienceLevel: 5,
      vocabularyScope: 'simple',
    ),
    CharacterRole(
      id: 'r3',
      title: 'Mahesh (Apartment Security)',
      description: 'Ask for delivery packages or enquire about visitor parking.',
      avatarEmoji: '👮🏽',
      firstMessageKannada:
          'Namaskara, yaava flat sir? Delivery box table mele ide, thogoli.',
      firstMessageEnglish:
          'Hello, which flat sir? Delivery box is on the table, take it.',
      firstMessagePronunciation:
          'Namaskara, yaah-vah flat sir? Delivery box table may-lay ee-deh, thoh-goh-lee.',
      patienceLevel: 6,
      vocabularyScope: 'simple',
    ),
    CharacterRole(
      id: 'r4',
      title: 'Lakshmi (Kirana Store Owner)',
      description: 'Buy groceries, ask for change, or scan UPI QR code.',
      avatarEmoji: '🛍️',
      firstMessageKannada:
          'Banni, enu beku? ₹500 change illa, scan madi pay madi.',
      firstMessageEnglish:
          'Come, what do you want? I do not have change for ₹500, scan and pay.',
      firstMessagePronunciation:
          'Ban-nee, ay-noo bay-koo? ₹500 change eel-lah, scan mah-dee pay mah-dee.',
      patienceLevel: 5,
      vocabularyScope: 'colloquial',
    ),
    CharacterRole(
      id: 'r5',
      title: 'Rahul (College Roommate)',
      description: 'Plan study sessions and coordinate apartment chores.',
      avatarEmoji: '🎒',
      firstMessageKannada:
          'Hlo! Nale exams ge study maadbeku, library eega open idya?',
      firstMessageEnglish:
          'Hello! We need to study for tomorrow\'s exams, is the library open now?',
      firstMessagePronunciation:
          'Hlo! Nah-lay exams gay study maad-bay-koo, library ee-gah open eed-yah?',
      patienceLevel: 9,
      vocabularyScope: 'simple',
    ),
    CharacterRole(
      id: 'r6',
      title: 'Asha (Best Friend)',
      description: 'Plan weekend hangouts and catch up on personal stories.',
      avatarEmoji: '👋',
      firstMessageKannada:
          'Namaste! Silk Board hatthira meeting madona? Nale free idira?',
      firstMessageEnglish:
          'Hello! Shall we meet near Silk Board? Are you free tomorrow?',
      firstMessagePronunciation:
          'Namaste! Silk Board hat-thee-rah meeting mah-doh-nah? Nah-lay free eed-ee-rah?',
      patienceLevel: 10,
      vocabularyScope: 'colloquial',
    ),
    CharacterRole(
      id: 'r7',
      title: 'Doctor Priya (Physician)',
      description: 'Explain symptoms and understand medical prescriptions.',
      avatarEmoji: '👩‍⚕️',
      firstMessageKannada:
          'Namaskara, enagide? Thumba jvara idya?',
      firstMessageEnglish:
          'Hello, what happened? Do you have a high fever?',
      firstMessagePronunciation:
          'Namaskara, ay-nah-gee-deh? Thoomba jva-rah eed-yah?',
      patienceLevel: 8,
      vocabularyScope: 'polite',
    ),
    CharacterRole(
      id: 'r8',
      title: 'Anil (Corporate Manager)',
      description: 'Submit presentations and coordinate work schedules.',
      avatarEmoji: '💼',
      firstMessageKannada:
          'Namaskara, presentation details eega ready idya? Clients waiting.',
      firstMessageEnglish:
          'Hello, are the presentation details ready now? Clients are waiting.',
      firstMessagePronunciation:
          'Namaskara, presentation details ee-gah ready eed-yah? Clients waiting.',
      patienceLevel: 7,
      vocabularyScope: 'formal',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _chatMessageToJson(ChatMessage msg) {
    return {
      'textKannada': msg.textKannada,
      'textEnglish': msg.textEnglish,
      'pronunciation': msg.pronunciation,
      'isUser': msg.isUser,
      'time': msg.time.toIso8601String(),
      'evaluation': msg.evaluation != null ? {
        'confidence': msg.evaluation!.confidence,
        'pronunciation': msg.evaluation!.pronunciation,
        'vocabulary': msg.evaluation!.vocabulary,
        'grammar': msg.evaluation!.grammar,
        'politeness': msg.evaluation!.politeness,
        'taskCompletion': msg.evaluation!.taskCompletion,
        'survivalSuccess': msg.evaluation!.survivalSuccess,
        'feedbackTip': msg.evaluation!.feedbackTip,
      } : null,
    };
  }

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    final evalJson = json['evaluation'] as Map<String, dynamic>?;
    return ChatMessage(
      textKannada: json['textKannada'] as String? ?? '',
      textEnglish: json['textEnglish'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      time: DateTime.parse(json['time'] as String? ?? DateTime.now().toIso8601String()),
      evaluation: evalJson != null ? AiEvaluation(
        confidence: evalJson['confidence'] as int? ?? 8,
        pronunciation: evalJson['pronunciation'] as int? ?? 8,
        vocabulary: evalJson['vocabulary'] as int? ?? 8,
        grammar: evalJson['grammar'] as int? ?? 8,
        politeness: evalJson['politeness'] as int? ?? 8,
        taskCompletion: evalJson['taskCompletion'] as int? ?? 8,
        survivalSuccess: evalJson['survivalSuccess'] as int? ?? 8,
        feedbackTip: evalJson['feedbackTip'] as String? ?? '',
      ) : null,
    );
  }

  void _persistChatHistory(String characterId) async {
    try {
      final box = Hive.box('ai_chat_box');
      final list = _messages.map((m) => _chatMessageToJson(m)).toList();
      await box.put(characterId, jsonEncode(list));
    } catch (e) {
      debugPrint("Error persisting chat history: $e");
    }
  }

  void _loadChatHistory(CharacterRole role) {
    try {
      final box = Hive.box('ai_chat_box');
      final cached = box.get(role.id);
      if (cached != null) {
        final List<dynamic> list = jsonDecode(cached as String);
        setState(() {
          _messages.clear();
          _messages.addAll(list.map((item) => _chatMessageFromJson(Map<String, dynamic>.from(item))));
        });
      } else {
        setState(() {
          _messages.clear();
          _messages.add(
            ChatMessage(
              textKannada: role.firstMessageKannada,
              textEnglish: role.firstMessageEnglish,
              pronunciation: role.firstMessagePronunciation,
              isUser: false,
              time: DateTime.now(),
            ),
          );
        });
        _persistChatHistory(role.id);
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
  }

  void _clearChatHistory(CharacterRole role) async {
    try {
      final box = Hive.box('ai_chat_box');
      await box.delete(role.id);
      setState(() {
        _messages.clear();
        _messages.add(
          ChatMessage(
            textKannada: role.firstMessageKannada,
            textEnglish: role.firstMessageEnglish,
            pronunciation: role.firstMessagePronunciation,
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
      _persistChatHistory(role.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat history cleared!')),
      );
    } catch (e) {
      debugPrint("Error clearing chat: $e");
    }
  }

  void _selectCharacter(CharacterRole role) {
    setState(() {
      _selectedCharacter = role;
    });
    _loadChatHistory(role);
  }

  void _toggleSpeechInput() async {
    if (_isVoiceRecording) {
      await AudioService.instance.stopListening();
      setState(() {
        _isVoiceRecording = false;
      });
    } else {
      final available = await AudioService.instance.initSpeech();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available on this device.')),
        );
        return;
      }
      setState(() {
        _isVoiceRecording = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening... Speak Kannada now. Tap mic again to stop.'),
          duration: Duration(seconds: 4),
        ),
      );
      await AudioService.instance.startListening(
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _messageController.text = text;
          });
        },
      );
    }
  }

  AiEvaluation? _parseEvaluation(String line) {
    try {
      if (!line.toLowerCase().startsWith('evaluation:')) return null;
      final content = line.substring('evaluation:'.length).trim();
      final parts = content.split('|');
      final scoresPart = parts[0].trim();
      final tipPart = parts.length > 1 ? parts[1].trim() : '';

      int confidence = 8;
      int pronunciation = 7;
      int vocabulary = 8;
      int grammar = 8;
      int politeness = 9;
      int taskCompletion = 8;
      int survivalSuccess = 8;

      final scoreRegex = RegExp(r'([a-zA-Z]+)\s*:\s*(\d+)');
      final matches = scoreRegex.allMatches(scoresPart);
      for (final match in matches) {
        final key = match.group(1)!.toLowerCase();
        final val = int.tryParse(match.group(2)!) ?? 8;
        if (key == 'confidence') confidence = val;
        else if (key == 'pronunciation') pronunciation = val;
        else if (key == 'vocabulary') vocabulary = val;
        else if (key == 'grammar') grammar = val;
        else if (key == 'politeness') politeness = val;
        else if (key == 'taskcompletion') taskCompletion = val;
        else if (key == 'survivalsuccess') survivalSuccess = val;
      }

      return AiEvaluation(
        confidence: confidence,
        pronunciation: pronunciation,
        vocabulary: vocabulary,
        grammar: grammar,
        politeness: politeness,
        taskCompletion: taskCompletion,
        survivalSuccess: survivalSuccess,
        feedbackTip: tipPart.replaceFirst('Tip:', '').trim(),
      );
    } catch (e) {
      debugPrint('Error parsing evaluation: $e');
      return null;
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userText = _messageController.text.trim();
    _messageController.clear();

    LocalDb.setLastAiChatDate(DateTime.now());

    setState(() {
      _messages.add(
        ChatMessage(
          textKannada: userText,
          textEnglish: 'Translating...',
          pronunciation: 'Pronouncing...',
          isUser: true,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _persistChatHistory(_selectedCharacter!.id);

    final apiKey = LocalDb.geminiApiKey;
    final backendUrl = LocalDb.geminiBackendUrl;
    if (apiKey.isEmpty && backendUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            textKannada: '⚠️ Gemini API Key not configured!',
            textEnglish:
                'Please go to the settings page (top-left menu button on home) and configure your Gemini API Key.',
            pronunciation: 'System Warning',
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
      return;
    }

    final role = _selectedCharacter!;
    final userMsgIndex = _messages.length - 1;

    // Step 1: Translate the user's input to Kannada and Pronunciation so they learn it!
    String userKan = userText;
    String userEng = userText;
    String userPron = '';

    final userTranslationInstruction = '''
You are a translation assistant in a Kannada language learning app.
The user wants to speak to ${role.title} (${role.description}).
Translate the user's input: "$userText" into conversational Kannada script and add phonetic pronunciation guide.
Adhere strictly to this 3-line format:
Kannada: <conversational Kannada translation>
English: $userText
Pronunciation: <phonetic pronunciation guide with hyphens for syllables>

Do NOT output anything else.
''';

    final userTranslationRaw = await GeminiService.instance.generateContent(
      conversationHistory: [
        {'isUser': true, 'text': userText}
      ],
      systemInstruction: userTranslationInstruction,
    );

    if (userTranslationRaw != null && userTranslationRaw.trim().isNotEmpty) {
      final lines = userTranslationRaw.split('\n');
      for (final line in lines) {
        final cleanLine = line.replaceAll('*', '').trim();
        final lower = cleanLine.toLowerCase();
        if (lower.startsWith('kannada:')) {
          userKan = cleanLine.substring('kannada:'.length).trim();
        } else if (lower.startsWith('pronunciation:')) {
          userPron = cleanLine.substring('pronunciation:'.length).trim();
        }
      }
    }

    if (userPron.isEmpty) {
      userPron = userKan; // Fallback
    }

    // Update user's message in the chat
    if (mounted) {
      setState(() {
        _messages[userMsgIndex] = ChatMessage(
          textKannada: userKan,
          textEnglish: userEng,
          pronunciation: userPron,
          isUser: true,
          time: DateTime.now(),
        );
      });
      _persistChatHistory(role.id);
    }

    final List<Map<String, dynamic>> conversationHistory = [];
    
    // Gemini API requires history to start with a 'user' turn.
    // If the first message in our list is the tutor's greeting, prepend a user initiation message.
    if (_messages.isNotEmpty && !_messages.first.isUser) {
      conversationHistory.add({
        'isUser': true,
        'text': "Hello, let's start the conversation."
      });
    }
    
    for (final m in _messages) {
      final text = m.isUser
          ? "Kannada: ${m.textKannada}"
          : "Kannada: ${m.textKannada}\nEnglish: ${m.textEnglish}\nPronunciation: ${m.pronunciation}";
      conversationHistory.add({
        'isUser': m.isUser,
        'text': text,
      });
    }

    final systemInstruction =
        '''
You are playing the role of ${role.title} (${role.description}) in a Kannada language learning app.
The user is speaking to you. You MUST respond in character as ${role.title}.
To make the conversation realistic and teach real negotiation skills, do NOT make it easy or predictable.
Introduce unexpected daily hurdles:
- Kumar (Auto Driver): might complain about rain, heavy traffic, demand "₹50 extra" or "double meter".
- Ramesh (Darshini Waiter): might say the requested dish is sold out or will take 20 minutes.
- Lakshmi (Kirana Store Owner): might complain about not having change for a large note and insist on UPI scanning.
- Mahesh (Security): might ask for proof of identity or assert visitor parking is full.

Your responses and emotional warmth (politeness rating) should shift dynamically depending on how polite, respectful (e.g. using honorific '-ri' verb suffix), or confident the user's Kannada phrasing is!

Your response MUST strictly adhere to the following format:
Kannada: <your response in Kannada script/language. Keep it simple, natural, and under 2 sentences.>
English: <the English translation of your Kannada response.>
Pronunciation: <the phonetic pronunciation guide of the Kannada response, written using English letters so it is easy for an English speaker to pronounce. Use hyphens for syllables.>
Evaluation: Confidence: <score 1-10>, Pronunciation: <score 1-10>, Vocabulary: <score 1-10>, Grammar: <score 1-10>, Politeness: <score 1-10>, TaskCompletion: <score 1-10>, SurvivalSuccess: <score 1-10> | Tip: <a friendly, helpful feedback tip or suggestion to help the user improve their conversational Kannada>

Example output:
Kannada: ನಮಸ್ಕಾರ, ಬನ್ನಿ ಕೂತ್ಕೊಳ್ಳಿ.
English: Hello, please come sit.
Pronunciation: Na-mas-ka-ra, ban-nee kooth-kol-lee.
Evaluation: Confidence: 9, Pronunciation: 8, Vocabulary: 9, Grammar: 8, Politeness: 10, TaskCompletion: 9, SurvivalSuccess: 9 | Tip: Brilliant pronunciation! To sound even more natural, you can use 'bisi neeru' when asking for hot water!

Do NOT output anything else except these four lines. Do not wrap in markdown code blocks.
''';

    final responseText = await GeminiService.instance.generateContent(
      conversationHistory: conversationHistory,
      systemInstruction: systemInstruction,
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      if (responseText != null && responseText.trim().isNotEmpty) {
        String kan = '';
        String eng = '';
        String pron = '';
        AiEvaluation? eval;

        final lines = responseText.split('\n');
        for (final line in lines) {
          final cleanLine = line.replaceAll('*', '').trim();
          final lower = cleanLine.toLowerCase();
          if (lower.startsWith('kannada:')) {
            kan = cleanLine.substring('kannada:'.length).trim();
          } else if (lower.startsWith('english:')) {
            eng = cleanLine.substring('english:'.length).trim();
          } else if (lower.startsWith('pronunciation:')) {
            pron = cleanLine.substring('pronunciation:'.length).trim();
          } else if (lower.startsWith('evaluation:')) {
            eval = _parseEvaluation(cleanLine);
          }
        }

        // Bulletproof fallback: search by characteristics if fields are empty
        if (kan.isEmpty || eng.isEmpty || pron.isEmpty) {
          for (final line in lines) {
            final cleanLine = line.replaceAll('*', '').trim();
            if (cleanLine.isEmpty) continue;
            
            if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(cleanLine) && !cleanLine.toLowerCase().startsWith('kannada:')) {
              kan = cleanLine;
            } else if (cleanLine.toLowerCase().contains('pronunciation') || 
                       (cleanLine.contains('-') && cleanLine.split(' ').length > 2 && pron.isEmpty)) {
              if (!cleanLine.toLowerCase().startsWith('pronunciation:')) {
                pron = cleanLine;
              }
            } else if (eng.isEmpty && !cleanLine.toLowerCase().startsWith('english:') && 
                       !cleanLine.toLowerCase().startsWith('kannada:')) {
              eng = cleanLine;
            }
          }
        }

        // Final safety net:
        if (kan.isEmpty) kan = responseText.split('\n').first;
        if (eng.isEmpty) eng = 'Click to see translation';
        if (pron.isEmpty) pron = 'Pronunciation guide unavailable';

        _messages.add(
          ChatMessage(
            textKannada: kan,
            textEnglish: eng,
            pronunciation: pron,
            isUser: false,
            time: DateTime.now(),
            evaluation: eval,
          ),
        );
        _persistChatHistory(role.id);

        // Boost the user's survival score in real-time on successful message evaluations
        if (eval != null) {
          final progress = ref.read(userProgressProvider);
          final int scoreBoost = (eval.survivalSuccess * 2).clamp(0, 20);
          
          int newGreetings = progress.survivalGreetings;
          int newTravel = progress.survivalTravel;
          int newRestaurant = progress.survivalRestaurant;
          int newShopping = progress.survivalShopping;
          int newCollege = progress.survivalCollege;
          int newOffice = progress.survivalOffice;
          int newEmergency = progress.survivalEmergency;
          int newDailyLife = progress.survivalDailyLife;

          switch (role.id) {
            case 'r1': // Auto Driver
              newTravel = (newTravel + scoreBoost).clamp(0, 100);
              break;
            case 'r2': // Waiter
              newRestaurant = (newRestaurant + scoreBoost).clamp(0, 100);
              break;
            case 'r3': // Security
              newDailyLife = (newDailyLife + scoreBoost).clamp(0, 100);
              break;
            case 'r4': // Kirana
              newShopping = (newShopping + scoreBoost).clamp(0, 100);
              break;
            case 'r5': // Roommate
              newCollege = (newCollege + scoreBoost).clamp(0, 100);
              break;
            case 'r6': // Best Friend
              newGreetings = (newGreetings + scoreBoost).clamp(0, 100);
              break;
            case 'r7': // Doctor
              newEmergency = (newEmergency + scoreBoost).clamp(0, 100);
              break;
            case 'r8': // Manager
              newOffice = (newOffice + scoreBoost).clamp(0, 100);
              break;
          }

          double newOutcomeTravel = progress.survivalOutcomeTravel;
          double newOutcomeOrder = progress.survivalOutcomeOrder;
          double newOutcomeNegotiate = progress.survivalOutcomeNegotiate;
          double newOutcomeIntroduce = progress.survivalOutcomeIntroduce;
          double newOutcomeProblem = progress.survivalOutcomeProblem;

          switch (role.id) {
            case 'r1':
              newOutcomeTravel = (newOutcomeTravel + scoreBoost).clamp(0.0, 100.0);
              newOutcomeNegotiate = (newOutcomeNegotiate + scoreBoost / 2).clamp(0.0, 100.0);
              break;
            case 'r2':
              newOutcomeOrder = (newOutcomeOrder + scoreBoost).clamp(0.0, 100.0);
              break;
            case 'r4':
              newOutcomeNegotiate = (newOutcomeNegotiate + scoreBoost).clamp(0.0, 100.0);
              break;
            case 'r5':
            case 'r6':
              newOutcomeIntroduce = (newOutcomeIntroduce + scoreBoost).clamp(0.0, 100.0);
              break;
            case 'r3':
            case 'r7':
            case 'r8':
              newOutcomeProblem = (newOutcomeProblem + scoreBoost).clamp(0.0, 100.0);
              break;
          }

          final double newAvgConfidence = (newOutcomeIntroduce + newOutcomeOrder + newOutcomeTravel + newOutcomeNegotiate + newOutcomeProblem) / 5.0;

          final updated = progress.copyWith(
            survivalGreetings: newGreetings,
            survivalTravel: newTravel,
            survivalRestaurant: newRestaurant,
            survivalShopping: newShopping,
            survivalCollege: newCollege,
            survivalOffice: newOffice,
            survivalEmergency: newEmergency,
            survivalDailyLife: newDailyLife,
            survivalOutcomeIntroduce: newOutcomeIntroduce,
            survivalOutcomeOrder: newOutcomeOrder,
            survivalOutcomeTravel: newOutcomeTravel,
            survivalOutcomeNegotiate: newOutcomeNegotiate,
            survivalOutcomeProblem: newOutcomeProblem,
            realWorldConfidenceScore: newAvgConfidence,
          );
          ref.read(userProgressProvider.notifier).updateProgress(updated);
        }

      } else {
        _messages.add(
          ChatMessage(
            textKannada:
                'I apologize, I could not reach my AI thoughts. Please check your internet connection or Gemini API Key.',
            textEnglish: 'Error communicating with Gemini model.',
            pronunciation: 'Error',
            isUser: false,
            time: DateTime.now(),
          ),
        );
      }
    });
  }

  void _showEvaluationSheet(BuildContext context, AiEvaluation eval, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    'AI Tutor Scorecard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildEvalBar('Confidence', eval.confidence, Colors.orange, isDark),
              _buildEvalBar('Pronunciation', eval.pronunciation, Colors.teal, isDark),
              _buildEvalBar('Vocabulary', eval.vocabulary, Colors.deepPurple, isDark),
              _buildEvalBar('Grammar', eval.grammar, Colors.blue, isDark),
              _buildEvalBar('Politeness & Respect', eval.politeness, Colors.amber, isDark),
              _buildEvalBar('Task Completion', eval.taskCompletion, Colors.green, isDark),
              _buildEvalBar('Survival Success', eval.survivalSuccess, Colors.red, isDark),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tutor Advice',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eval.feedbackTip.isNotEmpty ? eval.feedbackTip : 'Excellent practice! Keep speaking Kannada with local characters.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Got It, Thanks!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvalBar(String label, int score, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '$score/10',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 10.0,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCharacter == null
              ? 'AI Conversations'
              : _selectedCharacter!.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: _selectedCharacter != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedCharacter = null),
              )
            : null,
        actions: _selectedCharacter != null
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Clear Chat History',
                  onPressed: () => _clearChatHistory(_selectedCharacter!),
                ),
              ]
            : null,
      ),
      body: _selectedCharacter == null
          ? _buildCharacterSelector(isDark)
          : _buildChatInterface(isDark),
    );
  }

  // CHARACTER SELECTOR SCREEN
  Widget _buildCharacterSelector(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.5,
              ),
              boxShadow: AppTheme.premiumShadow(isDark: isDark),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/situations/ai_tutor_intro.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.forum_rounded, size: 48, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MittuWidget(mood: MittuMood.happy, size: 76, animate: true),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 1.5,
                    ),
                    boxShadow: AppTheme.premiumShadow(isDark: isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaskara! I am Mittu 🐘✨',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s practice real-life conversations! Speak with local experts of Bengaluru. Choose one to start chatting in Kannada!',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Practice Real Situations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.premiumShadow(isDark: isDark),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _selectCharacter(role),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            role.avatarEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.primaryBlue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // CHAT ROOM INTERFACE
  Widget _buildChatInterface(bool isDark) {
    return Column(
      children: [
        // Message thread list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppTheme.primaryBlue
                        : (isDark ? AppTheme.darkCard : Colors.white),
                    border: Border.all(
                      color: msg.isUser
                          ? AppTheme.primaryBlue
                          : (isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: msg.isUser
                          ? const Radius.circular(20)
                          : Radius.zero,
                      bottomRight: msg.isUser
                          ? Radius.zero
                          : const Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              msg.textKannada,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: msg.isUser
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white
                                          : AppTheme.lightTextPrimary),
                              ),
                            ),
                          ),
                          if (!msg.isUser)
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryBlue, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                AudioService.instance.speakKannada(msg.textKannada);
                              },
                            ),
                        ],
                      ),
                      if (msg.pronunciation.isNotEmpty && 
                          msg.pronunciation.toLowerCase() != msg.textKannada.toLowerCase()) ...[
                        const SizedBox(height: 2),
                        Text(
                          msg.pronunciation,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: msg.isUser ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                      if (msg.textEnglish.isNotEmpty && 
                          msg.textEnglish.toLowerCase() != msg.textKannada.toLowerCase() &&
                          msg.textEnglish.toLowerCase() != msg.pronunciation.toLowerCase()) ...[
                        Divider(
                          height: 12, 
                          color: msg.isUser ? Colors.white24 : (isDark ? Colors.white24 : Colors.black12)
                        ),
                        Text(
                          msg.textEnglish,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: msg.isUser
                                ? Colors.white.withOpacity(0.95)
                                : (isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF334155)),
                          ),
                        ),
                      ],
                      if (msg.evaluation != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showEvaluationSheet(context, msg.evaluation!, isDark),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: AppTheme.accentYellow, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'View AI Scorecard',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              children: [
                Text('${_selectedCharacter!.avatarEmoji}  '),
                const Text(
                  'Typing response...',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
              ],
            ),
          ),

        // Text input bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isVoiceRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isVoiceRecording ? AppTheme.errorRed : AppTheme.primaryBlue,
                    size: 28,
                  ),
                  onPressed: _toggleSpeechInput,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type Kannada message...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkBg : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
