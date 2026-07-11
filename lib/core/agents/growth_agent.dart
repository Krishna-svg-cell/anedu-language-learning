import 'agent_state.dart';

class GrowthAgent {
  static final GrowthAgent instance = GrowthAgent._internal();
  GrowthAgent._internal();

  Map<String, dynamic> compileAnalytics(AgentState state) {
    final progress = state.userProfile;
    final int completedCount = progress.lessonsCompletedCount;
    final int quizzesCount = progress.quizzesCompletedCount;
    final double overallScore = progress.overallSurvivalScore;

    final double cost = progress.geminiCallsCount * 0.00015;
    final double cacheRatio = progress.geminiCallsCount > 0 
        ? (progress.cacheHitsCount / (progress.geminiCallsCount + progress.cacheHitsCount)) 
        : 1.0;
    final String abCohort = progress.xp % 2 == 0 ? 'Cohort A: Story Lessons' : 'Cohort B: Direct Lessons';

    // Compile analytics metrics
    final Map<String, dynamic> analytics = {
      'dau_active_today': true,
      'retention_streak_days': progress.streakDays,
      'lesson_completion_rate': completedCount > 0 ? (completedCount / 90.0) * 100.0 : 0.0,
      'quizzes_completed': quizzesCount,
      'avg_survival_confidence': overallScore,
      'drop_off_risk': _calculateDropOffRisk(progress),
      'speaking_improvement_rate': _calculateSpeakingImprovement(progress),
      'gemini_api_cost_usd': cost,
      'cache_hit_ratio': cacheRatio,
      'ab_cohort': abCohort,
    };

    return analytics;
  }

  String _calculateDropOffRisk(dynamic progress) {
    final diff = DateTime.now().difference(progress.lastActive).inDays;
    if (diff > 5) return 'HIGH';
    if (diff > 2) return 'MEDIUM';
    return 'LOW';
  }

  double _calculateSpeakingImprovement(dynamic progress) {
    // Dynamic mock improvement slope based on phrases and quizzes count
    final count = progress.phrasesLearnedCount;
    if (count == 0) return 0.0;
    return (count * 1.5).clamp(10.0, 98.0);
  }
}
