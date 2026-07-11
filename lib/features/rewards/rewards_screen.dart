import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_db.dart';
import '../../core/services/audio_service.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_progress.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int currentProgress;
  final int targetProgress;

  BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.currentProgress,
    required this.targetProgress,
  });

  bool get isUnlocked => currentProgress >= targetProgress;
}

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _activeTab = 0; // 0 = Badges, 1 = Streaks, 2 = Achievements

  List<BadgeItem> _getBadges(
    int lessonsCompleted,
    int wordsLearned,
    int streakDays,
    int quizzesCompleted,
  ) {
    return [
      BadgeItem(
        id: 'b1',
        title: 'First Steps',
        description: 'Complete 1 lesson',
        icon: Icons.directions_walk_rounded,
        color: Colors.purple,
        currentProgress: lessonsCompleted,
        targetProgress: 1,
      ),
      BadgeItem(
        id: 'b2',
        title: 'Word Master',
        description: 'Learn 50 words',
        icon: Icons.font_download_rounded,
        color: Colors.teal,
        currentProgress: wordsLearned,
        targetProgress: 50,
      ),
      BadgeItem(
        id: 'b3',
        title: 'Streak 7',
        description: '7 days streak',
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.secondaryOrange,
        currentProgress: streakDays,
        targetProgress: 7,
      ),
      BadgeItem(
        id: 'b4',
        title: 'Quick Learner',
        description: 'Complete 10 lessons',
        icon: Icons.offline_bolt_rounded,
        color: Colors.blue,
        currentProgress: lessonsCompleted,
        targetProgress: 10,
      ),
      BadgeItem(
        id: 'b5',
        title: 'Listener',
        description: 'Listen to 20 lessons',
        icon: Icons.headset_rounded,
        color: Colors.indigo,
        currentProgress: lessonsCompleted, // simulated
        targetProgress: 20,
      ),
      BadgeItem(
        id: 'b6',
        title: 'Quiz Master',
        description: 'Complete 10 quizzes',
        icon: Icons.assignment_turned_in_rounded,
        color: Colors.pink,
        currentProgress: quizzesCompleted,
        targetProgress: 10,
      ),
      // Locked high tier badges
      BadgeItem(
        id: 'b7',
        title: 'Bilingual Pro',
        description: 'Complete 50 lessons',
        icon: Icons.menu_book_rounded,
        color: Colors.grey,
        currentProgress: lessonsCompleted,
        targetProgress: 50,
      ),
      BadgeItem(
        id: 'b8',
        title: 'Karnataka Native',
        description: 'Score 90% survival',
        icon: Icons.favorite_rounded,
        color: Colors.grey,
        currentProgress: 0,
        targetProgress: 90,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badges = _getBadges(
      progress.lessonsCompletedCount,
      progress.wordsLearnedCount,
      progress.streakDays,
      progress.quizzesCompletedCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rewards',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6D28D9),
                  ], // Gorgeous Purple
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Balance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${progress.coins}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.monetization_on,
                              color: AppTheme.accentYellow,
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab toggles
            Row(
              children: [
                _buildTabButton(0, 'Badges'),
                _buildTabButton(1, 'Streaks'),
                _buildTabButton(2, 'Milestones'),
              ],
            ),
            const SizedBox(height: 20),

            // Content based on Active Tab
            if (_activeTab == 0) ...[
              // Badges Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return _buildBadgeCard(badge, isDark);
                },
              ),
            ] else if (_activeTab == 1) ...[
              // Streaks View
              _buildStreaksView(progress, isDark),
            ] else ...[
              // Milestones View
              _buildMilestonesView(progress, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _activeTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeItem badge, bool isDark) {
    final bool isUnlocked = badge.isUnlocked;
    final double percent = (badge.currentProgress / badge.targetProgress).clamp(
      0.0,
      1.0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? AppTheme.darkCard : Colors.white)
            : (isDark ? AppTheme.darkCard.withOpacity(0.5) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              : (isDark ? Colors.transparent : Colors.grey[200]!),
          width: 1.5,
        ),
        boxShadow: isUnlocked ? AppTheme.premiumShadow(isDark: isDark) : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badge.color.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? badge.icon : Icons.lock_outline_rounded,
              color: isUnlocked ? badge.color : Colors.grey[500],
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked
                  ? (isDark ? Colors.white : AppTheme.lightTextPrimary)
                  : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked
                  ? (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary)
                  : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Checkmark or Progress Bar
          if (isUnlocked)
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successGreen,
              size: 20,
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: isDark
                        ? AppTheme.darkBorder
                        : Colors.grey[300],
                    color: AppTheme.primaryBlue,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge.currentProgress}/${badge.targetProgress}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStreaksView(UserProgress progress, bool isDark) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Big Glowing Flame Circle
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.secondaryOrange.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondaryOrange, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryOrange.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 48)),
                Text(
                  '${progress.streakDays}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: AppTheme.secondaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${progress.streakDays} DAY STREAK',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Keep learning every day to keep Mittu dancing!',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // 7-day Calendar Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: AppTheme.glassCardDecoration(
            context: context,
            radius: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'THIS WEEK\'S PROGRESS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppTheme.secondaryOrange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayIndex = index + 1; // 1 to 7
                  final name = weekdays[index];

                  // Simple check: active if dayIndex <= todayWeekday AND within streakDays
                  final diff = todayWeekday - dayIndex;
                  final isActive =
                      dayIndex <= todayWeekday &&
                      diff >= 0 &&
                      diff < progress.streakDays;
                  final isToday = dayIndex == todayWeekday;

                  return Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.secondaryOrange
                              : (isToday
                                    ? AppTheme.secondaryOrange.withOpacity(0.15)
                                    : (isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200])),
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: AppTheme.secondaryOrange,
                                  width: 2,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isActive
                            ? const Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                name[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? AppTheme.secondaryOrange
                                      : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? AppTheme.secondaryOrange
                              : (isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesView(UserProgress progress, bool isDark) {
    final milestones = [
      _MilestoneData(
        id: 'm1',
        title: 'Vocabulary Explorer',
        description: 'Learn your first 15 Kannada words',
        target: 15,
        current: progress.wordsLearnedCount,
        reward: 50,
      ),
      _MilestoneData(
        id: 'm2',
        title: 'Dedicated Learner',
        description: 'Complete 3 Kannada path lessons',
        target: 3,
        current: progress.lessonsCompletedCount,
        reward: 100,
      ),
      _MilestoneData(
        id: 'm3',
        title: 'Quiz Champion',
        description: 'Complete 5 language quizzes',
        target: 5,
        current: progress.quizzesCompletedCount,
        reward: 150,
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final ms = milestones[index];
        final bool achieved = ms.current >= ms.target;
        final bool claimed = LocalDb.isMilestoneClaimed(ms.id);
        final double percent = (ms.current / ms.target).clamp(0.0, 1.0);

        Color borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        Color bgCol = isDark ? AppTheme.darkCard : Colors.white;

        if (achieved && !claimed) {
          borderCol = AppTheme.successGreen;
          bgCol = AppTheme.successGreen.withOpacity(0.04);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderCol, width: 1.5),
            boxShadow: achieved && !claimed
                ? [
                    BoxShadow(
                      color: AppTheme.successGreen.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ms.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ms.description,
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
                  Row(
                    children: [
                      Text(
                        '+${ms.reward}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentYellow,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.monetization_on,
                        color: AppTheme.accentYellow,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (claimed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Claimed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (achieved) ...[
                ElevatedButton(
                  onPressed: () async {
                    ref
                        .read(userProgressProvider.notifier)
                        .addXpAndCoins(0, ms.reward);
                    await LocalDb.setMilestoneClaimed(ms.id, true);
                    setState(() {}); // refresh UI
                    AudioService.instance.playSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: AppTheme.accentYellow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Claimed +${ms.reward} coins for completing "${ms.title}"!',
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text(
                    'CLAIM REWARD',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ] else ...[
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: isDark
                            ? AppTheme.darkBorder
                            : Colors.grey[200],
                        color: AppTheme.primaryBlue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: ${ms.current} / ${ms.target}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'Locked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneData {
  final String id;
  final String title;
  final String description;
  final int target;
  final int current;
  final int reward;

  _MilestoneData({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.current,
    required this.reward,
  });
}
