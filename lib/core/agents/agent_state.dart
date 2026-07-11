import '../../models/user_progress.dart';
import '../../models/lesson.dart';

class AgentState {
  final UserProgress userProfile;
  final String currentGoal;
  final Lesson? currentLesson;
  final Map<String, dynamic> currentMission;
  final List<Map<String, dynamic>> conversationContext;
  final Map<String, dynamic> weaknessData;
  final Map<String, dynamic> learningMetrics;
  final Map<String, dynamic> customData;

  AgentState({
    required this.userProfile,
    this.currentGoal = '',
    this.currentLesson,
    this.currentMission = const {},
    this.conversationContext = const [],
    this.weaknessData = const {},
    this.learningMetrics = const {},
    this.customData = const {},
  });

  AgentState copyWith({
    UserProgress? userProfile,
    String? currentGoal,
    Lesson? currentLesson,
    Map<String, dynamic>? currentMission,
    List<Map<String, dynamic>>? conversationContext,
    Map<String, dynamic>? weaknessData,
    Map<String, dynamic>? learningMetrics,
    Map<String, dynamic>? customData,
  }) {
    return AgentState(
      userProfile: userProfile ?? this.userProfile,
      currentGoal: currentGoal ?? this.currentGoal,
      currentLesson: currentLesson ?? this.currentLesson,
      currentMission: currentMission ?? this.currentMission,
      conversationContext: conversationContext ?? this.conversationContext,
      weaknessData: weaknessData ?? this.weaknessData,
      learningMetrics: learningMetrics ?? this.learningMetrics,
      customData: customData ?? this.customData,
    );
  }
}
