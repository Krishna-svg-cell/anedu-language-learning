import 'dart:convert';
import 'dart:io';
import '../lib/core/database/curriculum_generator.dart';
import '../lib/models/lesson.dart';

void main() {
  final List<Map<String, dynamic>> serialized = [];
  
  for (int i = 1; i <= 90; i++) {
    try {
      final lesson = CurriculumGenerator.getRawLessonForDay(i);
      serialized.add(lesson.toJson());
    } catch (e) {
      print('Error on Day $i: $e');
    }
  }
  
  final jsonString = const JsonEncoder.withIndent('  ').convert(serialized);
  
  final directory = Directory('assets/config');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final file = File('assets/config/curriculum.json');
  file.writeAsStringSync(jsonString);
  
  print('Successfully exported ${serialized.length} lessons to assets/config/curriculum.json!');
}
