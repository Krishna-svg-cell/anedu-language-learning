import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lesson.dart';
import '../../../core/widgets/mittu_widget.dart';
import '../../../core/services/audio_service.dart';

class SituationTwistStep extends StatefulWidget {
  final Lesson lesson;
  final ValueChanged<bool> onCompleted;

  const SituationTwistStep({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  @override
  State<SituationTwistStep> createState() => _SituationTwistStepState();
}

class _SituationTwistStepState extends State<SituationTwistStep> {
  int _selectedIndex = -1;

  String _getTwistDescription() {
    switch (widget.lesson.category) {
      case LessonCategory.restaurant:
        return "Oh no! Ramesh (Waiter) comes back to tell you they just ran out of Masala Dosa! 🥞 How do you ask for Idli Vada instead?";
      case LessonCategory.travel:
        return "Oh no! Kumar (Driver) tells you there is a huge traffic block at Silk Board and suggests taking an alternate route. How do you agree?";
      case LessonCategory.shopping:
        return "Oh no! Lakshmi (Shopkeeper) says she doesn't have changes for ₹500 and asks if you can scan UPI QR pay. How do you say yes?";
      case LessonCategory.workplace:
        return "Oh no! Anil (Manager) says the client presentation has been preponed by two hours! How do you tell him you'll submit it soon?";
      case LessonCategory.college:
        return "Oh no! Rahul (Roommate) tells you the library is closed today due to local exams. How do you suggest studying in the hostel room instead?";
      case LessonCategory.basics:
      case LessonCategory.greetings:
      case LessonCategory.introductions:
      case LessonCategory.fluentConversation:
      default:
        return "A sudden twist! Asha (Friend) says she is running late for class but wants to catch up later. How do you say 'No problem, see you later'?";
    }
  }

  List<Map<String, String>> _getTwistOptions() {
    switch (widget.lesson.category) {
      case LessonCategory.restaurant:
        return [
          {
            'k': 'Sari, idli vada kodi.',
            'e': 'Okay, give me idli vada.',
            'p': 'Sari, idli vada koh-di.'
          },
          {
            'k': 'Dosa beku.',
            'e': 'I want dosa.',
            'p': 'Dosa beh-koo.'
          }
        ];
      case LessonCategory.travel:
        return [
          {
            'k': 'Sari, bere rastheli hogi.',
            'e': 'Okay, go via another road.',
            'p': 'Sari, beh-ray ras-theh-li hoh-gi.'
          },
          {
            'k': 'Auto nillisi.',
            'e': 'Stop the auto.',
            'p': 'Auto neel-lee-see.'
          }
        ];
      case LessonCategory.shopping:
        return [
          {
            'k': 'Haudu, QR scan madthini.',
            'e': 'Yes, I will scan the QR code.',
            'p': 'Hau-doo, QR scan mad-thee-nee.'
          },
          {
            'k': 'Nanna hathira chillare illa.',
            'e': 'I don\'t have change.',
            'p': 'Nan-nah ha-thee-rah cheel-lah-ray eel-lah.'
          }
        ];
      case LessonCategory.workplace:
        return [
          {
            'k': 'Sari, bega ready madthini.',
            'e': 'Okay, I will prepare it quickly.',
            'p': 'Sari, beh-gah ready mad-thee-nee.'
          },
          {
            'k': 'Nale kodthini.',
            'e': 'I will give it tomorrow.',
            'p': 'Nah-lay kod-thee-nee.'
          }
        ];
      case LessonCategory.college:
        return [
          {
            'k': 'Sari, hostel nalli odona.',
            'e': 'Okay, let\'s study in the hostel.',
            'p': 'Sari, hostel nal-lee oh-doh-nah.'
          },
          {
            'k': 'Nale sigona.',
            'e': 'See you tomorrow.',
            'p': 'Nah-lay see-goh-nah.'
          }
        ];
      default:
        return [
          {
            'k': 'Parvagilla, aamele sigona.',
            'e': 'No problem, we will meet later.',
            'p': 'Par-vah-geel-lah, ah-meh-lay see-goh-nah.'
          },
          {
            'k': 'Yake late?',
            'e': 'Why late?',
            'p': 'Yaah-kay late?'
          }
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final twistText = _getTwistDescription();
    final options = _getTwistOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Twist Alert Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.secondaryOrange.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'SITUATION TWIST ALERT!',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.secondaryOrange,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mittu warning bubble
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MittuWidget(mood: MittuMood.sad, size: 70, animate: true),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Text(
                  twistText,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        const Text(
          'HOW DO YOU RESPOND?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),

        // 2 twist reply options (Option 0 is always the ideal polite reply)
        ...List.generate(options.length, (index) {
          final opt = options[index];
          final isSelected = _selectedIndex == index;
          final isCorrect = index == 0;

          Color borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
          Color bgCol = isDark ? AppTheme.darkCard : Colors.white;

          if (_selectedIndex != -1) {
            if (isCorrect) {
              borderCol = AppTheme.successGreen;
              bgCol = AppTheme.successGreen.withOpacity(0.08);
            } else if (isSelected) {
              borderCol = AppTheme.errorRed;
              bgCol = AppTheme.errorRed.withOpacity(0.08);
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol, width: 2.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: _selectedIndex != -1
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (isCorrect) {
                        AudioService.instance.playCorrect();
                      } else {
                        AudioService.instance.playIncorrect();
                      }
                      widget.onCompleted(true);
                    },
              title: Text(
                opt['k']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Pronunciation: "${opt['p']!}"',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Meaning: "${opt['e']!}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              trailing: _selectedIndex == -1
                  ? const Icon(Icons.arrow_forward_ios_rounded, size: 16)
                  : (isCorrect
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 28)
                      : const Icon(Icons.cancel_rounded, color: AppTheme.errorRed, size: 28)),
            ),
          );
        }),
      ],
    );
  }
}
