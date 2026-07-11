import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../core/widgets/animated_pressable.dart';
import '../../core/services/audio_service.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  bool _isMapExpanded = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final lessons = ref.watch(lessonsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int activeIdx = lessons.indexWhere((l) => !l.isCompleted);
    final int activeIndex = activeIdx == -1 ? (lessons.length - 1) : activeIdx.clamp(0, lessons.length - 1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF), // Light blue matching background
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMMERSIVE HERO HEADER (No App Bar style, matches the first screenshot)
            Stack(
              children: [
                 // Header image
                AspectRatio(
                  aspectRatio: 1.25, // Taller ratio for immersive top feel
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                      child: Image.asset(
                        'assets/images/situations/journey_header_new.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Gradient tint to read coins badge clearly
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Overlay content: Back button (if can pop) + Coin Badge
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context))
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )
                      else
                        const SizedBox(),
                      // Top Right Coins Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${progress.coins}',
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. TIMELINE VERTICAL TASK LIST (Day Card Buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Builder(
                builder: (context) {
                  final List<int> visibleIndices = [];

                  if (_isMapExpanded) {
                    for (int i = 0; i < lessons.length; i++) {
                      visibleIndices.add(i);
                    }
                  } else {
                    int start = activeIndex - 1;
                    if (start < 0) start = 0;
                    int end = start + 5; // Shows ~5 items visible
                    if (end > lessons.length) {
                      end = lessons.length;
                      start = end - 5;
                      if (start < 0) start = 0;
                    }
                    for (int i = start; i < end; i++) {
                      visibleIndices.add(i);
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...visibleIndices.map((idx) {
                        return _buildTimelineItem(
                          lessons[idx],
                          idx,
                          activeIndex,
                          visibleIndices.last == idx,
                          isDark,
                        );
                      }),
                      const SizedBox(height: 12),
                      if (!_isMapExpanded)
                        AnimatedPressable(
                          onTap: () {
                            setState(() {
                              _isMapExpanded = true;
                            });
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A60EB),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1A60EB).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('📅  ', style: TextStyle(fontSize: 16)),
                                Text(
                                  'Show All 90 Days',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isMapExpanded = false;
                              });
                              AudioService.instance.playClick();
                            },
                            icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF1A60EB)),
                            label: const Text(
                              'Collapse List',
                              style: TextStyle(
                                color: Color(0xFF1A60EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // 3. EXPLORE KARNATAKA SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Karnataka 🗺️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const Text(
                    'Swipe 👉',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Learn about the rich culture, history, and heritage of Karnataka.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 205,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
                children: [
                  _buildKarnatakaCard(
                    title: 'Hampi Ruins 🛕',
                    location: 'Vijayanagara District',
                    description: 'A UNESCO World Heritage Site featuring the spectacular ruins of the Vijayanagara Empire. Famous for stone chariots, musical pillars, and ancient temples.',
                    imagePath: 'assets/images/situations/hampi_ruins.webp',
                    isDark: isDark,
                  ),
                  _buildKarnatakaCard(
                    title: 'Mysore Palace 👑',
                    location: 'Mysuru',
                    description: 'One of the most grand and visited royal palaces in India. The former seat of the Wodeyar dynasty, it illuminates with over 97,000 light bulbs during Dussehra!',
                    imagePath: 'assets/images/situations/mysore_palace.webp',
                    isDark: isDark,
                  ),
                  _buildKarnatakaCard(
                    title: 'Vidhana Soudha 🏛️',
                    location: 'Bengaluru',
                    description: 'The monumental seat of Karnataka\'s state legislature. Built in a unique Neo-Dravidian architecture style, it is the largest legislative building in India.',
                    imagePath: 'assets/images/situations/vidhana_soudha.webp',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Lesson lesson, int index, int activeIdx, bool isLast, bool isDark) {
    final bool isCompleted = lesson.isCompleted;
    final bool isActive = !isCompleted && index == activeIdx;
    final bool isLocked = !isCompleted && index > activeIdx;

    return Stack(
      children: [
        // Dotted/Solid Connecting vertical line running behind the circle
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2.5,
            color: isLast
                ? Colors.transparent
                : (isCompleted
                    ? const Color(0xFF22C55E) // Green connecting line
                    : (isDark ? Colors.grey[800] : const Color(0xFFCBD5E1))),
          ),
        ),
        // Content Row
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Timeline Node (Green check, Orange circle, Grey Lock)
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF22C55E) // Green background
                      : (isActive ? Colors.white : (isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0))),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : (isActive ? const Color(0xFFF97316) : (isDark ? AppTheme.darkBorder : const Color(0xFFCBD5E1))),
                    width: isActive ? 4 : 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 24, color: Colors.white)
                    : (isActive
                        ? const Center(
                            child: Icon(Icons.play_arrow_rounded, color: Color(0xFFF97316), size: 24),
                          )
                        : Icon(Icons.lock_rounded, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[500])),
              ),
              const SizedBox(width: 16),
              // Card Details
              Expanded(
                child: AnimatedPressable(
                  playSound: false,
                  onTap: () {
                    if (isLocked) {
                      AudioService.instance.playLocked();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔒 This daily adventure is locked! Clear the previous days to unlock.'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    } else {
                      AudioService.instance.playUnlocked();
                      _showLessonDetailsSheet(context, lesson, index + 1, isCompleted, isLocked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFF97316) // Orange border for active
                            : (isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
                        width: isActive ? 2.0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? const Color(0xFFF97316).withOpacity(0.06)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Thumbnail Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(
                              lesson.illustrationPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[100], child: const Icon(Icons.image, size: 24)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Right Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lesson.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted
                                    ? 'Completed'
                                    : (isActive ? 'In Progress' : 'Unlocks at 12:00 AM'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? const Color(0xFF22C55E)
                                      : (isActive ? const Color(0xFFF97316) : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLessonDetailsSheet(BuildContext context, Lesson lesson, int dayNum, bool isCompleted, bool isLocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MittuWidget(mood: MittuMood.happy, size: 70, animate: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAY $dayNum MISSION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isCompleted ? const Color(0xFF22C55E) : const Color(0xFF1A60EB),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildObjectiveItem(Icons.menu_book_rounded, '${lesson.vocabulary.length} Words', isDark),
                  _buildObjectiveItem(Icons.chat_bubble_outline_rounded, '${lesson.dialogue.length} Sentences', isDark),
                  _buildObjectiveItem(Icons.bolt, '+${lesson.xpReward} XP', isDark),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedPressable(
                playSound: false,
                onTap: isLocked
                    ? null
                    : () {
                        AudioService.instance.playMissionStart();
                        Navigator.pop(context);
                        context.push('/lesson/${lesson.id}');
                      },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.grey
                        : (isCompleted ? const Color(0xFF22C55E) : const Color(0xFF1A60EB)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLocked
                        ? '🔒 Locked'
                        : (isCompleted ? 'Replay Mission 🚀' : 'Start Mission 🚀'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildObjectiveItem(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : const Color(0xFF1A60EB).withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1A60EB), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildKarnatakaCard({
    required String title,
    required String location,
    required String description,
    required String imagePath,
    required bool isDark,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: AppTheme.premiumShadow(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            _showKarnatakaDetailDialog(title, location, description, imagePath, isDark);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 105,
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.secondaryOrange,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          location.split(' ').first,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKarnatakaDetailDialog(
    String title,
    String location,
    String description,
    String imagePath,
    bool isDark,
  ) {
    AudioService.instance.playClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePath,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppTheme.secondaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: AppTheme.secondaryOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedPressable(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A60EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
