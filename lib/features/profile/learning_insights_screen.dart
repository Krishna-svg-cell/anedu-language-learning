import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';

class LearningInsightsScreen extends ConsumerWidget {
  const LearningInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final lessons = ref.watch(lessonsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Dynamic Calculations
    final int completedLessons = progress.lessonsCompletedCount;
    final int completedQuizzes = progress.quizzesCompletedCount;
    
    // Level & Proficiency Mapping
    String proficiencyLevel = 'Beginner (Level A1.1)';
    if (completedLessons >= 21) {
      proficiencyLevel = 'Intermediate (Level A2.2)';
    } else if (completedLessons >= 11) {
      proficiencyLevel = 'Upper Elementary (Level A2.1)';
    } else if (completedLessons >= 4) {
      proficiencyLevel = 'Elementary (Level A1.2)';
    }

    // Dynamic Skill Metrics (0-100)
    final double baseSurvival = progress.overallSurvivalScore > 0 
        ? progress.overallSurvivalScore 
        : (completedLessons * 3.3).clamp(5.0, 100.0);
        
    final int listening = (baseSurvival * 0.9 + completedQuizzes * 2.5).clamp(15.0, 95.0).round();
    final int speaking = (baseSurvival * 0.8 + completedLessons * 3.0).clamp(10.0, 92.0).round();
    final int reading = (baseSurvival * 0.95 + progress.wordsLearnedCount * 0.5).clamp(20.0, 96.0).round();
    final int writing = (progress.phrasesLearnedCount * 0.6 + completedQuizzes * 2.0).clamp(12.0, 90.0).round();

    final int pronunciation = (speaking * 1.05).clamp(10.0, 98.0).round();
    final int vocabStrength = (progress.wordsLearnedCount * 1.2 + 10).clamp(15.0, 99.0).round();
    final int grammar = (completedQuizzes * 5 + completedLessons * 2 + 15).clamp(10.0, 94.0).round();
    final int conversation = (baseSurvival * 1.1).clamp(10.0, 95.0).round();

    final int survivalScore = baseSurvival.round();
    final int confidenceScore = ((listening + speaking + reading + writing) / 4).round();

    final int totalWords = progress.wordsLearnedCount > 0 ? progress.wordsLearnedCount : completedLessons * 5;
    final int totalSentences = progress.phrasesLearnedCount > 0 ? progress.phrasesLearnedCount : completedLessons * 3;
    final int totalConversations = completedLessons;
    final int totalMissions = completedLessons;
    final int streak = progress.streakDays;
    final int totalTimeMinutes = (completedLessons * 12 + completedQuizzes * 4 + 5);

    // Prioritized and Weak Situations based on Onboarding Persona
    String frequentSituation = 'Greeting people in Kannada';
    String needPracticeSituation = 'Conversations with Auto drivers';
    String recommendation = 'Practice vocabulary card matches daily to improve vocabulary.';
    
    final roleLower = progress.role.toLowerCase();
    if (roleLower.contains('student')) {
      frequentSituation = 'Classroom discussions & Cafeteria chats';
      needPracticeSituation = 'Talking to the College Professor';
      recommendation = 'Complete the Day 10 library vocabulary check to reinforce academic terms.';
    } else if (roleLower.contains('professional') || roleLower.contains('work')) {
      frequentSituation = 'Office greetings & Team meetings';
      needPracticeSituation = 'Business presentations & Manager syncs';
      recommendation = 'Spend more time in AI Roleplay to build professional sentence framing.';
    } else if (roleLower.contains('tourist') || roleLower.contains('travel')) {
      frequentSituation = 'Hotel check-in & Hailing Auto-rickshaws';
      needPracticeSituation = 'Bargaining at the local Sandalwood/Silk shops';
      recommendation = 'Review the Travel phrases section weekly to remember direction terms.';
    } else if (roleLower.contains('homemaker') || roleLower.contains('home')) {
      frequentSituation = 'Vegetable market & Neighbors interactions';
      needPracticeSituation = 'Talking to electricians/plumbers';
      recommendation = 'Review the daily household needs checklist for standard utility verbs.';
    } else if (roleLower.contains('business')) {
      frequentSituation = 'Greeting customers & Collecting cash payments';
      needPracticeSituation = 'Supplier negotiation & Banking transactions';
      recommendation = 'Focus on number practice to converse quickly about prices and billing.';
    }

    // Next Mission Suggestion
    String nextMissionTitle = 'Day 1: Meeting Someone';
    String nextMissionDesc = 'Introduce yourself, swap names, and basic greetings.';
    if (completedLessons < lessons.length) {
      final nextLesson = lessons[completedLessons];
      nextMissionTitle = nextLesson.title;
      nextMissionDesc = nextLesson.situationDescription;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Insights',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mittu Mascot & Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Row(
                  children: [
                    const MittuWidget(
                      mood: MittuMood.happy,
                      size: 90,
                      animate: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey ${progress.name}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Here is your personalized progress analysis based on your onboarding profile as a ${progress.role}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Overall Level & Scores Section
              const Text(
                'Overall Progress Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricCard('Survival Score', '$survivalScore%', Icons.health_and_safety_rounded, Colors.red, isDark),
                  const SizedBox(width: 12),
                  _buildMetricCard('Confidence', '$confidenceScore%', Icons.psychology_rounded, Colors.orange, isDark),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KANNADA PROFICIENCY LEVEL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      proficiencyLevel,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (completedLessons / 30.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed $completedLessons daily adventures to date.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Four Core Skills (Listening, Speaking, Reading, Writing)
              const Text(
                'Core Language Skills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Column(
                  children: [
                    _buildSkillRow('Listening Performance', listening, Colors.blue, isDark),
                    _buildSkillRow('Speaking Performance', speaking, Colors.green, isDark),
                    _buildSkillRow('Reading Performance', reading, Colors.purple, isDark),
                    _buildSkillRow('Writing Performance', writing, Colors.amber, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Additional Analysis (Pronunciation, Vocabulary, Grammar, Conversation)
              const Text(
                'Sub-Skill Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildSubSkillCard('Pronunciation', '$pronunciation%', Icons.settings_voice_rounded, Colors.teal, isDark),
                    _buildSubSkillCard('Vocabulary', '$vocabStrength%', Icons.menu_book_rounded, Colors.deepPurple, isDark),
                    _buildSubSkillCard('Grammar', '$grammar%', Icons.g_translate_rounded, Colors.indigo, isDark),
                    _buildSubSkillCard('Conversation', '$conversation%', Icons.forum_rounded, Colors.pink, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Learning Summary Metrics
              const Text(
                'Learning Summary Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Column(
                  children: [
                    _buildStatRow('Total Words Learned', '$totalWords words'),
                    _buildStatRow('Sentences Learned', '$totalSentences sentences'),
                    _buildStatRow('Conversations Completed', '$totalConversations dialogs'),
                    _buildStatRow('Adventures Completed', '$totalMissions adventures'),
                    _buildStatRow('Active Learning Streak', '$streak days'),
                    _buildStatRow('Total Practice Time', '$totalTimeMinutes mins'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Survival Domain Scores Breakdown
              const Text(
                'Survival Domain Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Column(
                  children: [
                    _buildSkillRow('Greetings & Introductions', progress.survivalGreetings, Colors.amber, isDark),
                    _buildSkillRow('Restaurant & Dining', progress.survivalRestaurant, Colors.orange, isDark),
                    _buildSkillRow('Transportation & Travel', progress.survivalTravel, Colors.blue, isDark),
                    _buildSkillRow('Shopping & Bargaining', progress.survivalShopping, Colors.teal, isDark),
                    _buildSkillRow('College & Academia', progress.survivalCollege, Colors.purple, isDark),
                    _buildSkillRow('Office & Workplace', progress.survivalOffice, Colors.indigo, isDark),
                    _buildSkillRow('Daily Life Needs', progress.survivalDailyLife, Colors.green, isDark),
                    _buildSkillRow('Emergency & Medical', progress.survivalEmergency, Colors.red, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Strengths & Improvement
              const Text(
                'Situational Relevance Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⭐️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Most Frequently Practiced Situation',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(frequentSituation, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Situation Requiring More Practice',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(needPracticeSituation, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                                'Mittu\'s Recommendation',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(recommendation, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Next Mission Card
              const Text(
                'Recommended Next Step',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(isDark ? 0.15 : 0.06),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'SUGGESTED ADVENTURE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nextMissionTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextMissionDesc,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close insights
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Go to Journey Feed', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRow(String label, int score, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                '$score%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 6,
              backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSkillCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppTheme.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        width: 1.5,
      ),
    );
  }
}
