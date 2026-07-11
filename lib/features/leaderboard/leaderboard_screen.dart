import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/database/local_db.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../models/user_progress.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final int xp;
  final String avatarEmoji;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatarEmoji,
    this.isCurrentUser = false,
  });
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _activeTab = 0; // 0 = This Week, 1 = This Month, 2 = All Time

  List<LeaderboardUser> _getLeaderboardUsers(UserProgress currentUser, List<UserProgress> dbUsers) {
    final List<UserProgress> realUsers = List<UserProgress>.from(dbUsers);

    // Ensure current user is in the list
    final hasCurrent = realUsers.any((u) => u.name == currentUser.name);
    if (!hasCurrent) {
      realUsers.add(currentUser);
    }

    // Convert UserProgress to LeaderboardUser based on activeTab range
    final List<LeaderboardUser> list = realUsers.map((user) {
      int rangeXp = user.xp;
      if (_activeTab == 0) {
        rangeXp = user.xpWeekly;
      } else if (_activeTab == 1) {
        rangeXp = user.xpMonthly;
      }

      final isCurrentUser = user.name == currentUser.name;
      return LeaderboardUser(
        rank: 1,
        name: user.name,
        xp: rangeXp,
        avatarEmoji: isCurrentUser ? '🐘' : '👤',
        isCurrentUser: isCurrentUser,
      );
    }).toList();

    // Sort by range XP descending
    list.sort((a, b) => b.xp.compareTo(a.xp));

    // Calculate unique ranks
    for (int i = 0; i < list.length; i++) {
      list[i] = LeaderboardUser(
        rank: i + 1,
        name: list[i].name,
        xp: list[i].xp,
        avatarEmoji: list[i].avatarEmoji,
        isCurrentUser: list[i].isCurrentUser,
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: LocalDb.isFirebaseInitialized
          ? FirebaseFirestore.instance.collection('users').snapshots()
          : null,
      builder: (context, snapshot) {
        final List<UserProgress> dbUsers = [];
        if (snapshot.hasData && snapshot.data != null) {
          for (final doc in snapshot.data!.docs) {
            try {
              dbUsers.add(UserProgress.fromJson(doc.data()));
            } catch (e) {
              debugPrint("Error decoding leaderboard user: $e");
            }
          }
        }

        // Fallback to local users if Firestore has no data or is not configured
        if (dbUsers.isEmpty) {
          dbUsers.addAll(LocalDb.getRealUsers());
        }

        final sortedUsers = _getLeaderboardUsers(progress, dbUsers);

        final firstPlace = sortedUsers.isNotEmpty ? sortedUsers[0] : null;
        final secondPlace = sortedUsers.length > 1 ? sortedUsers[1] : null;
        final thirdPlace = sortedUsers.length > 2 ? sortedUsers[2] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppTheme.primaryBlue,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('League Rules'),
                  content: const Text(
                    'Earn XP by completing lessons, daily missions, and answering quizzes. Connect accounts to compete globally!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Toggle Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'This Week'),
                  _buildTabButton(1, 'This Month'),
                  _buildTabButton(2, 'All Time'),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Podium Display
                  const SizedBox(height: 10),
                  _buildPodium(isDark, firstPlace, secondPlace, thirdPlace),
                  const SizedBox(height: 24),

                  // Rank List or Empty State
                  if (sortedUsers.length <= 1)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: AppTheme.glassCardDecoration(
                        context: context,
                        radius: 24,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.group_add_outlined,
                            size: 44,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Competitors Yet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Complete lessons to secure your Rank 1 spot, or register accounts to compete in local leagues.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedUsers.length,
                      itemBuilder: (context, index) {
                        final user = sortedUsers[index];
                        return _buildRankTile(user, isDark);
                      },
                    ),
                  const SizedBox(height: 16),

                  // Footer Card with Mittu Mascot
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
                            : [const Color(0xFFEFF6FF), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.primaryLight,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const MittuWidget(
                          mood: MittuMood.happy,
                          size: 68,
                          animate: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keep learning, earn XP!',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.lightTextPrimary,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Complete daily lessons to earn coins, upgrade Mittu, and boost survival score.',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(
    bool isDark,
    LeaderboardUser? first,
    LeaderboardUser? second,
    LeaderboardUser? third,
  ) {
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place: Rohan (2100 XP)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('👦🏻', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                const Text(
                  'Rohan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '2100 XP',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 1st Place: Ananya (2500 XP)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.accentYellow,
                  size: 28,
                ), // Crown
                const Text('👧🏽', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                const Text(
                  'Ananya',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text(
                  '2500 XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 3rd Place: Meghana (1950 XP)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('👩🏽', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                const Text(
                  'Meghana',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '1950 XP',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      }
    );
  }

  Widget _buildRankTile(LeaderboardUser user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? AppTheme.primaryBlue.withOpacity(0.08)
            : (isDark ? AppTheme.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isCurrentUser
              ? AppTheme.primaryBlue
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: user.isCurrentUser ? 2.0 : 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${user.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: user.isCurrentUser
                    ? AppTheme.primaryBlue
                    : (isDark ? Colors.grey : Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(user.avatarEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: user.isCurrentUser
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.lightTextPrimary,
              ),
            ),
          ),
          Text(
            '${user.xp} XP',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: user.isCurrentUser
                  ? AppTheme.primaryBlue
                  : (isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
