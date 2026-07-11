import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/database/local_db.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_progress.dart';
import 'learning_insights_screen.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/mittu_widget.dart';

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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  int _activeLeaderboardTab = 0; // 0 = Weekly, 1 = Monthly, 2 = All Time

  List<LeaderboardUser> _getLeaderboardUsers(UserProgress currentUser, List<UserProgress> dbUsers) {
    final List<UserProgress> competitors = List<UserProgress>.from(dbUsers);

    // Ensure current user is in the list
    final hasCurrent = competitors.any((u) => u.name == currentUser.name);
    if (!hasCurrent) {
      competitors.add(currentUser);
    }

    // Convert to LeaderboardUser based on active tab
    final List<LeaderboardUser> list = competitors.map((user) {
      int rangeXp = user.xp;
      if (_activeLeaderboardTab == 0) {
        rangeXp = user.xpWeekly > 0 ? user.xpWeekly : (user.xp * 0.25).round();
      } else if (_activeLeaderboardTab == 1) {
        rangeXp = user.xpMonthly > 0 ? user.xpMonthly : (user.xp * 0.70).round();
      }

      final isCurrentUser = user.name == currentUser.name;
      return LeaderboardUser(
        rank: 1,
        name: user.name,
        xp: isCurrentUser ? currentUser.xp : rangeXp,
        avatarEmoji: isCurrentUser ? '🐘' : _getAvatarEmoji(user.name),
        isCurrentUser: isCurrentUser,
      );
    }).toList();

    // Sort by XP descending
    list.sort((a, b) => b.xp.compareTo(a.xp));

    // Recalculate ranks
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

  String _getAvatarEmoji(String name) {
    if (name.contains('Rahul')) return '👦';
    if (name.contains('Asha')) return '👧';
    if (name.contains('Ramesh')) return '👨';
    if (name.contains('Lakshmi')) return '👩';
    if (name.contains('Kumar')) return '🛺';
    return '👤';
  }

  void _showAccessoryShopSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final progress = LocalDb.getUserProgress();
            final purchased = LocalDb.purchasedAccessories;
            final equipped = LocalDb.equippedAccessory;

            final shopItems = [
              {'id': 'hat', 'name': 'Graduation Hat 🎓', 'cost': 100, 'desc': 'Show off your academic achievements'},
              {'id': 'sunglasses', 'name': 'Cool Sunglasses 🕶️', 'cost': 150, 'desc': 'Keep it cool in Bengaluru sun'},
              {'id': 'scarf', 'name': 'Cozy Red Scarf 🧣', 'desc': 'Wrap up warm for morning strolls', 'cost': 80},
              {'id': 'crown', 'name': 'Royal Crown 👑', 'desc': 'Feel like a Kannada king or queen', 'cost': 300},
            ];

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mittu\'s Boutique 🐘🛍️',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFEF3C7), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.coins}',
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Interactive Mascot Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        MittuWidget(
                          size: 110,
                          mood: MittuMood.happy,
                          equippedAccessoryOverride: LocalDb.equippedAccessory,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Style Your Companion!',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Buy hats, sunglasses, and crowns using coins earned from learning Kannada!',
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Shop List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: shopItems.length,
                      itemBuilder: (context, idx) {
                        final item = shopItems[idx];
                        final id = item['id'] as String;
                        final name = item['name'] as String;
                        final desc = item['desc'] as String;
                        final cost = item['cost'] as int;

                        final bool isBought = purchased.contains(id);
                        final bool isEquipped = equipped == id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isEquipped
                                  ? AppTheme.primaryBlue
                                  : (isDark ? Colors.white10 : Colors.black12),
                              width: isEquipped ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (isEquipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primaryBlue, width: 1),
                                  ),
                                  child: const Text(
                                    'Equipped',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else if (isBought)
                                ElevatedButton(
                                  onPressed: () async {
                                    AudioService.instance.playClick();
                                    await LocalDb.setEquippedAccessory(id);
                                    setSheetState(() {});
                                    setState(() {}); // refresh Profile page Mittu as well
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Equip', style: TextStyle(fontWeight: FontWeight.w900)),
                                )
                              else
                                ElevatedButton(
                                  onPressed: progress.coins < cost
                                      ? null
                                      : () async {
                                          AudioService.instance.playCoins();
                                          await LocalDb.buyAccessory(id, cost);
                                          await LocalDb.setEquippedAccessory(id);
                                          setSheetState(() {});
                                          setState(() {}); // refresh parent
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD97706),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('🪙 $cost', style: const TextStyle(fontWeight: FontWeight.w900)),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Unequip all button
                  if (equipped.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        AudioService.instance.playClick();
                        await LocalDb.setEquippedAccessory('');
                        setSheetState(() {});
                        setState(() {});
                      },
                      child: const Text('Unequip Accessory', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsSection(bool isDark) {
    final unlocked = LocalDb.getUnlockedAchievements();
    
    final badges = [
      {'id': 'consistency_3', 'title': 'Consistency 🔥', 'desc': '3-Day Streak'},
      {'id': 'consistency_7', 'title': 'Super Streak 🏆', 'desc': '7-Day Streak'},
      {'id': 'consistency_30', 'title': 'Streak Emperor 👑', 'desc': '30-Day Streak'},
      {'id': 'cafe_master', 'title': 'Cafe Master ☕', 'desc': 'Cafe Module Completed'},
      {'id': 'campus_hero', 'title': 'Campus Hero 🎓', 'desc': 'College Kannada Done'},
      {'id': 'bengaluru_explorer', 'title': 'BLR Explorer 🚇', 'desc': 'Travel Scenarios Done'},
      {'id': 'confident_speaker', 'title': 'Confident Speaker 🗣️', 'desc': '50 Conversations Completed'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Text('🎖️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Achievements & Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: badges.length,
          itemBuilder: (context, idx) {
            final badge = badges[idx];
            final id = badge['id'] as String;
            final title = badge['title'] as String;
            final desc = badge['desc'] as String;
            final isUnlocked = unlocked.contains(id);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF))
                    : (isDark ? Colors.black26 : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnlocked
                      ? AppTheme.primaryBlue.withOpacity(0.4)
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: 1.5,
                ),
              ),
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                        if (!isUnlocked)
                          const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
              debugPrint("Error decoding profile user: $e");
            }
          }
        }

        // Fallback to local users
        if (dbUsers.isEmpty) {
          dbUsers.addAll(LocalDb.getRealUsers());
        }

        final sortedUsers = _getLeaderboardUsers(progress, dbUsers);

    return Scaffold(
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0.0, (1.0 - value) * 24.0),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : AppTheme.lightBg,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. STACK COVER BANNER & OVERLAPPING AVATAR (FULL-BLEED)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/situations/profile_header_new.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Soft gradient overlay to ensure text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Header Overlay elements: Profile title and Circular Glassmorphic badges
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.0,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No new notifications')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.0,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                                  onPressed: () {
                                    AudioService.instance.playClick();
                                    context.push('/settings');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Overlapping Avatar
                    Positioned(
                      left: 24,
                      bottom: -40,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F172A) : AppTheme.lightBg,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/situations/basics_1.webp',
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.0, -0.45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 52), // Spacing for avatar overlap
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. NAME & INFO DETAIL ROW
                      Text(
                        progress.name.isEmpty ? 'Priya Sharma' : progress.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Learning Kannada',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.location_on_rounded, size: 14, color: AppTheme.secondaryOrange),
                          SizedBox(width: 4),
                          Text(
                            'Bengaluru, Karnataka',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. HORIZONTAL STATS CARD
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.premiumShadow(isDark: isDark),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildHorizontalStatItem('XP', '${progress.xp}', 'Total Earned', isDark),
                            _buildVerticalDivider(isDark),
                            _buildHorizontalStatItem('Streak', '${progress.streakDays} Days', 'Active Days', isDark),
                            _buildVerticalDivider(isDark),
                            _buildHorizontalStatItem('Level', '${(progress.xp / 1000).floor() + 1}', 'Explorer Title', isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. VERTICAL MENU TILES (GRID ABSTRACTION)
                      Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.analytics_outlined,
                            title: 'Learning Insights',
                            subtitle: 'Track your survival progress',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LearningInsightsScreen()),
                            ),
                            isDark: isDark,
                          ),
                          _buildMenuTile(
                            icon: Icons.leaderboard_outlined,
                            title: 'Leaderboard',
                            subtitle: 'See your rank',
                            onTap: () {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            isDark: isDark,
                          ),
                          _buildMenuTile(
                            icon: Icons.forum_outlined,
                            title: 'AI Tutor History',
                            subtitle: 'Your conversations',
                            onTap: () => context.push('/ai-tutor'),
                            isDark: isDark,
                          ),
                          _buildMenuTile(
                            icon: Icons.storefront_outlined,
                            title: 'Mascot Boutique 🐘🛍',
                            subtitle: 'Dress up Mittu with cool items',
                            onTap: () {
                              _showAccessoryShopSheet(context);
                            },
                            isDark: isDark,
                          ),
                          _buildMenuTile(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'Manage your preferences',
                            onTap: () => context.push('/settings'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 5. EXPLORER MILESTONE ILLUSTRATION CARD
                      _buildExplorerMilestoneIllustrationCard(isDark),
                      const SizedBox(height: 28),

                      // Achievements Grid
                      _buildAchievementsSection(isDark),
                      const SizedBox(height: 28),

                      // 6. LEADERBOARD SECTION TITLE
                      Row(
                        children: const [
                          Text('🏆', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 8),
                          Text(
                            'Competitive League',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, 'Weekly', isDark),
                            _buildTabItem(1, 'Monthly', isDark),
                            _buildTabItem(2, 'All Time', isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rank Tiles List
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<int>(_activeLeaderboardTab),
                          children: [
                            // Podium stairs chart
                            if (sortedUsers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: SizedBox(
                                  height: 260,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutBack,
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (sortedUsers.length > 1)
                                            _buildPodiumColumn(sortedUsers[1], 80.0 * value, 2, isDark),
                                          _buildPodiumColumn(sortedUsers[0], 110.0 * value, 1, isDark),
                                          if (sortedUsers.length > 2)
                                            _buildPodiumColumn(sortedUsers[2], 55.0 * value, 3, isDark),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            // Remaining competitors
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: max(0, sortedUsers.length - 3),
                              itemBuilder: (context, index) {
                                final user = sortedUsers[index + 3];
                                return _buildRankTile(user, isDark, index + 3);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
        ),
        ),
      ),
    );
      }
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark) {
    final bool isActive = _activeLeaderboardTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeLeaderboardTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildRankTile(LeaderboardUser user, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? AppTheme.primaryBlue.withOpacity(isDark ? 0.12 : 0.06)
            : (isDark ? AppTheme.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: user.isCurrentUser
              ? AppTheme.primaryBlue
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: user.isCurrentUser ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Number/Medal
          Container(
            width: 36,
            alignment: Alignment.centerLeft,
            child: _buildRankBadge(user.rank, isDark),
          ),
          // Profile avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: user.rank == 1
                    ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]
                    : user.rank == 2
                        ? [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)]
                        : user.rank == 3
                            ? [const Color(0xFFFDBA74), const Color(0xFFB45309)]
                            : [AppTheme.primaryBlue.withOpacity(0.2), AppTheme.primaryBlue.withOpacity(0.4)],
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user.avatarEmoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: user.isCurrentUser
                    ? AppTheme.primaryBlue
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          // XP
          Text(
            '${user.xp} XP',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryBlue,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, bool isDark) {
    if (rank == 1) {
      return const Text('👑', style: TextStyle(fontSize: 20));
    } else if (rank == 2) {
      return const Text('🥈', style: TextStyle(fontSize: 20));
    } else if (rank == 3) {
      return const Text('🥉', style: TextStyle(fontSize: 20));
    }
    return Text(
      '#$rank',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
    );
  }

  Widget _buildPodiumColumn(LeaderboardUser? user, double targetHeight, int rank, bool isDark) {
    if (user == null) return const SizedBox();

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: rank == 1 ? 64 : 52,
                height: rank == 1 ? 64 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: rank == 1
                        ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]
                        : rank == 2
                            ? [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)]
                            : [const Color(0xFFFDBA74), const Color(0xFFB45309)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.avatarEmoji,
                    style: TextStyle(fontSize: rank == 1 ? 26 : 22),
                  ),
                ),
              ),
              Positioned(
                top: rank == 1 ? -24 : -18,
                child: Text(
                  rank == 1 ? '👑' : (rank == 2 ? '🥈' : '🥉'),
                  style: TextStyle(fontSize: rank == 1 ? 22 : 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: targetHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: rank == 1
                    ? [const Color(0xFFFBBF24), const Color(0xFFD97706)]
                    : rank == 2
                        ? [const Color(0xFF94A3B8), const Color(0xFF475569)]
                        : [const Color(0xFFF97316), const Color(0xFFC2410C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: user.isCurrentUser ? AppTheme.primaryBlue : (isDark ? Colors.white70 : Colors.black87),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${user.xp} XP',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerMilestoneIllustrationCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1.5,
        ),
        boxShadow: AppTheme.premiumShadow(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Image.asset(
                  'assets/images/situations/journey_header_new.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Karnataka\'s Heritage 🗺️',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your adventure covers Hampi temples, Mysuru palaces, and Bengaluru tech parks. Keep playing to unlock classical and modern Kannada dialogues!',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatItem(String label, String value, String subtext, bool isDark) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: label == 'Level' ? AppTheme.secondaryOrange : AppTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1.5,
      height: 36,
      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
    );
  }
}

class _AnimatedHoverTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedHoverTile({required this.child, this.onTap});

  @override
  State<_AnimatedHoverTile> createState() => _AnimatedHoverTileState();
}

class _AnimatedHoverTileState extends State<_AnimatedHoverTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
