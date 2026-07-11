import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import '../../core/database/local_db.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../models/user_progress.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  Future<void> _performPostLoginTasks(String uid) async {
    // Set active user id in LocalDb
    await LocalDb.setActiveUserId(uid);

    // Attempt to restore progress from Firestore (hybrid offline backup)
    await LocalDb.restoreProgressFromFirestore(uid);

    // Reload state
    ref.read(userProgressProvider.notifier).reloadProgress();
    ref.read(lessonsListProvider.notifier).reloadLessons();

    if (mounted) {
      final progress = LocalDb.getUserProgress();
      
      // Determine navigation based on whether onboarding is complete
      if (!LocalDb.isOnboardingCompleted) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  void _handleSocialLogin(String provider) async {
    if (provider == 'Google' && !LocalDb.isFirebaseInitialized) {
      _showSimulatedGoogleLogin();
      return;
    }
    if (!LocalDb.isFirebaseInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication service is unavailable. Try Guest access.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }
    if (provider == 'Google') {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // User cancelled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          await _performPostLoginTasks(user.uid);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In failed: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _handleEmailLogin() async {
    if (!LocalDb.isFirebaseInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication service is unavailable. Try Guest access.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid email and password.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential;
      if (_isSignUp) {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = userCredential.user;
      if (user != null) {
        await _performPostLoginTasks(user.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _handleGuestLogin() async {
    try {
      if (LocalDb.isFirebaseInitialized) {
        final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        final user = userCredential.user;
        if (user != null) {
          await _performPostLoginTasks(user.uid);
          return;
        }
      }
    } catch (e) {
      debugPrint('Firebase Anonymous Sign-In failed: $e. Falling back to offline guest account.');
    }
    // Offline guest fallback
    await _performPostLoginTasks('guest_user');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSimulatedGoogleLogin() {
    List<Map<String, String>> accounts = [
      {'name': 'Krishna Teja', 'email': 'krishnatejakanasi026@gmail.com'},
      {'name': 'Anedu Tester', 'email': 'test.anedu@gmail.com'},
    ];
    String selectedEmail = 'krishnatejakanasi026@gmail.com';
    String selectedRole = 'Working Professional';
    
    bool isAddingCustom = false;
    String newName = '';
    String newEmail = '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            // Generate userId based on selected email
            final String userId = "google_user_${selectedEmail.replaceAll('@', '_').replaceAll('.', '_')}";
            final bool userExists = Hive.box(LocalDb.usersBoxName).containsKey(userId);

            // Find selected account details
            final selectedAccount = accounts.firstWhere(
              (acc) => acc['email'] == selectedEmail,
              orElse: () => accounts.first,
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: isDark ? const Color(0xFF1E1E38) : Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isAddingCustom) ...[
                        Text(
                          'Choose an account to continue to ANEDU:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display list of accounts as selectable cards
                        ...accounts.map((acc) {
                          final isSelected = acc['email'] == selectedEmail;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                width: isSelected ? 2.0 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? (isDark ? const Color(0xFF1B2A4A) : const Color(0xFFEBF4FF))
                                  : (isDark ? const Color(0xFF151528) : Colors.white),
                            ),
                            child: ListTile(
                              onTap: () {
                                setDialogState(() {
                                  selectedEmail = acc['email']!;
                                });
                              },
                              leading: CircleAvatar(
                                backgroundColor: isSelected ? AppTheme.primaryBlue : Colors.grey,
                                child: Text(
                                  acc['name']!.isNotEmpty ? acc['name']![0].toUpperCase() : 'G',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                acc['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(acc['email']!),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                                  : null,
                            ),
                          );
                        }),
                        // Add custom account button
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              isAddingCustom = true;
                              newName = '';
                              newEmail = '';
                            });
                          },
                          icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
                          label: const Text(
                            'Add custom Google account...',
                            style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: userExists
                                ? (isDark ? const Color(0xFF143A2A) : const Color(0xFFE6F4EA))
                                : (isDark ? const Color(0xFF3C2F15) : const Color(0xFFFEF7E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                userExists ? Icons.cloud_done_outlined : Icons.person_add_alt_1_outlined,
                                color: userExists ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  userExists
                                      ? 'Returning account detected. Stored preferences and progress will be loaded.'
                                      : 'New account detected. Please select your preferences below.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: userExists
                                        ? (isDark ? Colors.green[200] : Colors.green[800])
                                        : (isDark ? Colors.orange[200] : Colors.orange[800]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Preference dropdown (Only shown if account is new)
                        if (!userExists) ...[
                          Text(
                            'Select Your Learning Profile & Preference:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            dropdownColor: isDark ? const Color(0xFF1E1E38) : Colors.white,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: [
                              'Working Professional',
                              'Student',
                              'Tourist',
                              'Homemaker',
                            ].map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedRole = val;
                                });
                              }
                            },
                          ),
                        ],
                      ] else ...[
                        Text(
                          'Add Mock Google Account',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onChanged: (val) => newName = val.trim(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) => newEmail = val.trim(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  isAddingCustom = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (newName.isEmpty || newEmail.isEmpty || !newEmail.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a valid name and email address.'),
                                      backgroundColor: AppTheme.errorRed,
                                    ),
                                  );
                                  return;
                                }
                                setDialogState(() {
                                  accounts.add({'name': newName, 'email': newEmail});
                                  selectedEmail = newEmail;
                                  isAddingCustom = false;
                                });
                              },
                              child: const Text('Add & Select'),
                            ),
                          ],
                        ),
                      ],
                      if (!isAddingCustom) ...[
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context); // close dialog
                            
                            // Show a loading indicator since we are pregenerating the AI lesson
                            showDialog(
                              context: this.context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text(
                                          'AI Agent is generating your personalized situation path...',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            if (!userExists) {
                              // 1. Map role to motivation and places
                              String motivation = 'Daily Survival';
                              List<String> visitedPlaces = ['Metro', 'Cafe'];
                              if (selectedRole == 'Working Professional') {
                                motivation = 'Job / Office';
                                visitedPlaces = ['Office', 'Meeting Room', 'Cafeteria', 'Metro'];
                              } else if (selectedRole == 'Student') {
                                motivation = 'College / Study';
                                visitedPlaces = ['Classroom', 'Hostel', 'Canteen', 'Library', 'Metro'];
                              } else if (selectedRole == 'Tourist') {
                                motivation = 'Travel / Tourism';
                                visitedPlaces = ['Hotel', 'Heritage Site', 'Auto Stand', 'Bus Station'];
                              } else if (selectedRole == 'Homemaker') {
                                motivation = 'Daily Life';
                                visitedPlaces = ['Apartment', 'Grocery Market', 'Tailor Shop', 'Supermarket'];
                              }

                              // 2. Construct UserProgress
                              final progress = UserProgress(
                                name: selectedAccount['name']!,
                                role: selectedRole,
                                motivation: motivation,
                                visitedPlaces: visitedPlaces,
                                commuteModes: ['Cab', 'Metro'],
                                level: 'None',
                                nativeLanguage: 'English',
                                learningGoal: motivation,
                                initialConfidence: 15,
                                currentConfidence: 15,
                                lastActive: DateTime.now(),
                              );

                              // 3. Save details
                              await LocalDb.saveUserProgress(progress);
                              await LocalDb.updateJourneyOrderOnPreferenceChange(progress);
                              await LocalDb.setOnboardingCompleted(true);
                              
                              // 4. Trigger AI agent pregeneration of Day 1
                              try {
                                await ref.read(lessonsListProvider.notifier).pregeneratePersonalizedLesson(1);
                              } catch (e) {
                                debugPrint('Error pregenerating personalized lesson: $e');
                              }
                            } else {
                              // Reload the existing journey order & state for returning user
                              await LocalDb.setActiveUserId(userId);
                            }

                            if (this.mounted) {
                              Navigator.pop(this.context); // close progress dialog
                              await _performPostLoginTasks(userId);
                            }
                          },
                          child: Text(userExists ? 'Sign In' : 'Create Profile & Personalize Path'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppTheme.darkBg, const Color(0xFF131326)]
                  : [const Color(0xFFEBF4FF), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom Welcome Illustration
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.5,
                      ),
                      boxShadow: AppTheme.premiumShadow(isDark: isDark),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/situations/auth_intro.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to Mittu widget
                          return const Center(
                            child: MittuWidget(
                              mood: MittuMood.happy,
                              size: 110,
                              animate: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome to ANEDU',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your daily guide to survive and speak Kannada',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCardDecoration(
                      context: context,
                      radius: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _handleEmailLogin,
                          child: Text(_isSignUp ? 'Sign Up' : 'Log In'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-In Card Button
                  InkWell(
                    onTap: () => _handleSocialLogin('Google'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.premiumShadow(isDark: isDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Guest Login / Anonymous Sign In
                  TextButton(
                    onPressed: _handleGuestLogin,
                    child: Text(
                      'Try as Guest / Anonymous',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Toggle Signup/Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account? '
                            : 'New to ANEDU? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'Log In' : 'Sign Up',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
