import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final lessons = ref.watch(lessonsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int completedCount = progress.lessonsCompletedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '30-Day Map Trail',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                _buildHeaderBadge('🔥 ${progress.streakDays} Days'),
                const SizedBox(width: 8),
                _buildHeaderBadge('💎 ${progress.xp} XP'),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0F9FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final Lesson lesson = lessons[index];
            final bool isCompleted = index < completedCount;
            final bool isActive = index == completedCount;
            final bool isLocked = index > completedCount;

            return _buildTimelineCard(
              context: context,
              index: index + 1,
              lesson: lesson,
              isCompleted: isCompleted,
              isActive: isActive,
              isLocked: isLocked,
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.15),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTimelineCard({
    required BuildContext context,
    required int index,
    required Lesson lesson,
    required bool isCompleted,
    required bool isActive,
    required bool isLocked,
    required bool isDark,
  }) {
    Color cardBorderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    Color cardBgColor = isDark ? AppTheme.darkCard : Colors.white;

    if (isActive) {
      cardBorderColor = AppTheme.primaryBlue;
      cardBgColor = AppTheme.primaryBlue.withOpacity(isDark ? 0.08 : 0.04);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 2.0),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔒 Complete previous days to unlock this mission!'),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (isCompleted) {
            _showReplayModal(context, lesson, index);
          } else {
            context.push('/lesson/${lesson.id}');
          }
        },
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successGreen
                    : (isActive
                        ? AppTheme.primaryBlue
                        : (isDark ? Colors.grey[800] : Colors.grey[200])),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : (isActive ? Icons.play_arrow_rounded : Icons.lock_rounded),
                color: isLocked ? Colors.grey : Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
        title: Text(
          'Day $index',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isLocked
                ? Colors.grey
                : (isActive ? AppTheme.primaryBlue : AppTheme.successGreen),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              lesson.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? Colors.grey
                    : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: isLocked ? Colors.grey : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${lesson.vocabulary.length} Words',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: isLocked ? Colors.grey : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${lesson.dialogue.length} Sentences',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLocked
                ? Colors.transparent
                : (isActive
                    ? AppTheme.primaryBlue.withOpacity(0.12)
                    : AppTheme.successGreen.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isLocked ? 'Locked' : '+50 XP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLocked
                  ? Colors.grey
                  : (isActive ? AppTheme.primaryBlue : AppTheme.successGreen),
            ),
          ),
        ),
      ),
    );
  }

  void _showReplayModal(BuildContext context, Lesson lesson, int dayNum) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Day $dayNum Completed! 🎉',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You already mastered "${lesson.title}". What would you like to do?',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/lesson/${lesson.id}');
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Replay Full Lesson (+0 XP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚡ Vocab practice mode is coming soon!')),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Practice Vocabulary'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
