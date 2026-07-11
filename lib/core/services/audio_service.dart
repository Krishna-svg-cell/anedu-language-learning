import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'audio_synthesizer.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal() {
    _initTts();
  }

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isTtsInitialized = false;
  bool _speechAvailable = false;

  Future<void> _initTts() async {
    try {
      // Set language to Kannada (India)
      await _tts.setLanguage("kn-IN");
      await _tts.setSpeechRate(0.4); // Slower pacing for learners
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isTtsInitialized = true;
    } catch (e) {
      print("TTS Initialization error: $e");
    }
  }

  /// Synthesizes Kannada speech dynamically via native Google speech services
  Future<void> speakKannada(String text) async {
    if (!_isTtsInitialized) {
      await _initTts();
    }
    try {
      await _player.stop(); // Stop sound effects
      await _tts.speak(text);
    } catch (e) {
      print("TTS Speak error: $e");
    }
  }

  /// Plays synthesized sound bytes directly using BytesSource
  Future<void> playBytes(Uint8List bytes) async {
    try {
      await _player.stop();
      await _player.play(BytesSource(bytes));
    } catch (e) {
      print("Error playing synthesized sound bytes: $e");
    }
  }

  // Pre-synthesized or dynamically generated game sound triggers
  void playCorrect() {
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [523.25, 659.25], // C5, E5
      durations: [0.08, 0.16],
      volumes: [0.55, 0.65],
    );
    playBytes(bytes);
  }

  void playIncorrect() {
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 220.0,
      endFreq: 110.0,
      duration: 0.35,
      volume: 0.7,
    );
    playBytes(bytes);
  }

  void playSuccess() {
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [261.63, 329.63, 392.00, 523.25], // C4, E4, G4, C5
      durations: [0.08, 0.08, 0.08, 0.3],
      volumes: [0.5, 0.5, 0.5, 0.7],
    );
    playBytes(bytes);
  }

  void playClick() {
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 800.0,
      endFreq: 300.0,
      duration: 0.03,
      volume: 0.4,
    );
    playBytes(bytes);
  }

  void playPop() {
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 400.0,
      endFreq: 150.0,
      duration: 0.05,
      volume: 0.55,
    );
    playBytes(bytes);
  }

  void playLocked() {
    // Low, short double-buzz indicating error/locked state
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [140.0, 0.0, 140.0],
      durations: [0.08, 0.04, 0.08],
      volumes: [0.6, 0.0, 0.6],
    );
    playBytes(bytes);
  }

  void playUnlocked() {
    // Sparkly rising chimes indicating unlock/completion action
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [523.25, 659.25, 783.99, 1046.50], // C5, E5, G5, C6
      durations: [0.06, 0.06, 0.06, 0.22],
      volumes: [0.4, 0.45, 0.5, 0.65],
    );
    playBytes(bytes);
  }

  void playToggle() {
    // Clean woodblock toggle/switch sound
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 600.0,
      endFreq: 900.0,
      duration: 0.04,
      volume: 0.5,
    );
    playBytes(bytes);
  }

  void playCardSelect() {
    // Cute high bubble pop for selecting words/cards
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 450.0,
      endFreq: 750.0,
      duration: 0.06,
      volume: 0.45,
    );
    playBytes(bytes);
  }

  void playNavigation() {
    // Smooth navigation swoosh
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 350.0,
      endFreq: 600.0,
      duration: 0.12,
      volume: 0.4,
    );
    playBytes(bytes);
  }

  void playMissionStart() {
    // Exciting up-tempo chime melody
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [392.00, 523.25, 659.25], // G4, C5, E5
      durations: [0.08, 0.08, 0.22],
      volumes: [0.45, 0.5, 0.65],
    );
    playBytes(bytes);
  }

  void playMissionComplete() {
    // Triumphant Candy Crush style arpeggio
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [261.63, 329.63, 392.00, 523.25, 659.25, 783.99, 1046.50], // C4, E4, G4, C5, E5, G5, C6
      durations: [0.07, 0.07, 0.07, 0.07, 0.07, 0.07, 0.35],
      volumes: [0.45, 0.45, 0.45, 0.5, 0.5, 0.55, 0.75],
    );
    playBytes(bytes);
  }

  void playAchievementUnlocked() {
    // Fanfare chords/sparkles for badge rewards
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [523.25, 659.25, 783.99, 1046.50, 1318.51], // C5, E5, G5, C6, E6
      durations: [0.08, 0.08, 0.08, 0.08, 0.42],
      volumes: [0.45, 0.45, 0.5, 0.55, 0.8],
    );
    playBytes(bytes);
  }

  void playLevelUp() {
    // Grand ascending brass-like chimes
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [440.0, 554.37, 659.25, 880.0, 1108.73], // A4, C#5, E5, A5, C#6
      durations: [0.1, 0.1, 0.1, 0.1, 0.55],
      volumes: [0.5, 0.5, 0.55, 0.6, 0.85],
    );
    playBytes(bytes);
  }

  void playXPCount() {
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [987.77], // B5 (sparkly coin sound)
      durations: [0.04],
      volumes: [0.5],
    );
    playBytes(bytes);
  }

  void playStreak() {
    final bytes = AudioSynthesizer.generateSlideWav(
      startFreq: 300.0,
      endFreq: 750.0,
      duration: 0.35,
      volume: 0.55,
    );
    playBytes(bytes);
  }

  void playCoins() {
    final bytes = AudioSynthesizer.generateWav(
      frequencies: [987.77, 1318.51], // B5, E6
      durations: [0.06, 0.2],
      volumes: [0.5, 0.65],
    );
    playBytes(bytes);
  }

  // Speech Recognition methods
  Future<bool> initSpeech() async {
    if (_speechAvailable) return true;
    try {
      _speechAvailable = await _speech.initialize(
        onError: (val) => print('Speech initialization error: $val'),
        onStatus: (val) => print('Speech status: $val'),
      );
    } catch (e) {
      print("Speech initialize exception: $e");
    }
    return _speechAvailable;
  }

  Future<void> startListening({required Function(String text, bool isFinal) onResult}) async {
    final available = await initSpeech();
    if (!available) {
      print("Speech recognition not available on this device");
      return;
    }
    try {
      await _tts.stop();
    } catch (_) {}
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: "kn-IN",
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;

  /// Levenshtein similarity distance checker
  double calculateSimilarity(String expected, String actual) {
    String norm(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r'[\s\p{P}]', unicode: true), '')
          .replaceAll('ā', 'a')
          .replaceAll('ē', 'e')
          .replaceAll('ī', 'i')
          .replaceAll('ō', 'o')
          .replaceAll('ū', 'u')
          .replaceAll('ḷ', 'l')
          .replaceAll('ṇ', 'n')
          .replaceAll('ś', 's')
          .replaceAll('ṣ', 's');
    }

    final s1 = norm(expected);
    final s2 = norm(actual);
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final m = s1.length;
    final n = s2.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1.codeUnitAt(i - 1) == s2.codeUnitAt(j - 1)) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] =
              1 +
              [
                dp[i - 1][j],
                dp[i][j - 1],
                dp[i - 1][j - 1],
              ].reduce((curr, next) => curr < next ? curr : next);
        }
      }
    }

    final distance = dp[m][n];
    final maxLength = m > n ? m : n;
    return 1.0 - (distance / maxLength);
  }
}
