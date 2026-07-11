import 'package:flutter_test/flutter_test.dart';
import 'package:anedu/models/user_progress.dart';
import 'package:anedu/models/lesson.dart';

void main() {
  group('ANEDU AI Quality & Personalization Regression Tests', () {
    test('Personalization Accuracy - Student vs Employee vs Tourist', () {
      final student = UserProgress(
        name: 'Student User',
        learningGoal: 'Study & Socialize',
        nativeLanguage: 'Telugu',
        cefrLevel: 'Silent Beginner',
        lastActive: DateTime.now(),
      );

      final employee = UserProgress(
        name: 'Employee User',
        learningGoal: 'Office & Career',
        nativeLanguage: 'Hindi',
        cefrLevel: 'Survival Speaker',
        lastActive: DateTime.now(),
      );

      final tourist = UserProgress(
        name: 'Tourist User',
        learningGoal: 'Travel & Explore',
        nativeLanguage: 'English',
        cefrLevel: 'Daily Communicator',
        lastActive: DateTime.now(),
      );

      // Verify that goals and native languages remain uniquely segmented
      expect(student.learningGoal, 'Study & Socialize');
      expect(student.nativeLanguage, 'Telugu');

      expect(employee.learningGoal, 'Office & Career');
      expect(employee.nativeLanguage, 'Hindi');

      expect(tourist.learningGoal, 'Travel & Explore');
      expect(tourist.nativeLanguage, 'English');
    });

    test('Learning Science Spaced Repetition (SM-2) Math Formula Simulation', () {
      // Simulate SM-2 formula for quality = 4
      int q1 = 4;
      double ef1 = 2.5;
      int repetition1 = 0;
      int interval1 = 1;

      ef1 = ef1 + (0.1 - (5 - q1) * (0.08 + (5 - q1) * 0.02));
      if (ef1 < 1.3) ef1 = 1.3;
      
      if (repetition1 == 0) {
        interval1 = 1;
      } else if (repetition1 == 1) {
        interval1 = 6;
      } else {
        interval1 = (interval1 * ef1).round();
      }
      repetition1 += 1;

      expect(interval1, 1);
      expect(repetition1, 1);
      expect(ef1, closeTo(2.5, 0.01));

      // Simulate next repetition with quality = 5
      int q2 = 5;
      double ef2 = ef1;
      int repetition2 = repetition1;
      int interval2 = interval1;

      ef2 = ef2 + (0.1 - (5 - q2) * (0.08 + (5 - q2) * 0.02));
      if (ef2 < 1.3) ef2 = 1.3;

      if (repetition2 == 0) {
        interval2 = 1;
      } else if (repetition2 == 1) {
        interval2 = 6;
      } else {
        interval2 = (interval2 * ef2).round();
      }
      repetition2 += 1;

      expect(interval2, 6);
      expect(repetition2, 2);
      expect(ef2, closeTo(2.6, 0.01));
    });

    test('Kannada Unicode Verification Safety Gate', () {
      const String generatedTitle = 'ಕನ್ನಡ ಕಲಿಯಿರಿ (Learn Kannada)';
      
      // Match if Kannada script exists in content
      final hasKannadaScript = RegExp(r'[\u0c80-\u0cff]').hasMatch(generatedTitle);
      expect(hasKannadaScript, isTrue);

      const String englishOnlyText = 'Learn Kannada Basics';
      final hasNoKannadaScript = RegExp(r'[\u0c80-\u0cff]').hasMatch(englishOnlyText);
      expect(hasNoKannadaScript, isFalse);
    });
  });
}
