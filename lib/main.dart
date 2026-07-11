import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/database/local_db.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize local Hive DB (seeds defaults if first run)
  await LocalDb.init();

  // 3. Optional Firebase initialization block
  // Wrapped in try-catch so the app runs smoothly even if Firebase CLI / google-services.json is not configured locally yet.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LocalDb.configureFirebasePersistence();
    debugPrint("Firebase setup detected: Offline synchronization ready.");
  } catch (e) {
    debugPrint(
      "Firebase initialization warning (Normal if google-services.json is missing): $e",
    );
  }

  // 4. Run application wrapped in ProviderScope for Riverpod
  runApp(const ProviderScope(child: AneduApp()));
}

class AneduApp extends ConsumerWidget {
  const AneduApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ANEDU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
