import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anedu/main.dart';
import 'package:anedu/core/database/local_db.dart';

void main() {
  setUpAll(() async {
    // Disable Google Fonts HTTP runtime fetching during widget tests
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mock the path_provider MethodChannel
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });

    // Initialize Hive for widget test environment
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await LocalDb.init();
  });

  testWidgets('App splash screen loading smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AneduApp()));

    // Verify that the splash screen shows loading elements or name
    expect(find.text('ANEDU'), findsOneWidget);

    // Pump frames with duration to let the splash timer finish and prevent pending timers assertion error
    await tester.pump(const Duration(seconds: 3));
  });
}
