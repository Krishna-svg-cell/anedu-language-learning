import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  final _pageController = PageController();

  // Onboarding answers state
  String _name = '';
  String _ageGroup = '18-22';
  String _persona = 'Working Professional';
  String _reason = 'Daily Life';
  String _commute = 'Metro';
  final List<String> _selectedPlaces = [];
  String _level = 'None';
  String _nativeLanguage = 'English';
  double _initialConfidence = 10.0;

  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name so Mittu can address you!'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      return;
    }

    if (_currentStep == 0) {
      setState(() {
        _name = _nameController.text.trim();
      });
    }

    if (_currentStep < 7) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Completed! Save to local database via Provider and redirect to Home
      ref
          .read(userProgressProvider.notifier)
          .saveOnboardingDetails(
            name: _name,
            age: _getAgeInt(_ageGroup),
            role: _persona,
            motivation: _reason,
            commuteModes: [_commute],
            visitedPlaces: _selectedPlaces.isEmpty
                ? ['Metro', 'Cafe']
                : _selectedPlaces,
            currentLevel: _level,
            nativeLanguage: _nativeLanguage,
            learningGoal: _reason,
            initialConfidence: _initialConfidence.round(),
          );
      context.go('/home');
    }
  }

  int _getAgeInt(String group) {
    if (group == 'Below 18') return 16;
    if (group == '18-22') return 20;
    if (group == '23-30') return 26;
    if (group == '31-45') return 38;
    return 50;
  }

  void _prevPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMittuSpeech(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MittuWidget(mood: MittuMood.neutral, size: 70, animate: true),
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
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const totalSteps = 8;

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: _prevPage,
              )
            : null,
        title: LinearProgressIndicator(
          value: (_currentStep + 1) / totalSteps,
          backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Direct skip using default parameters
              ref
                  .read(userProgressProvider.notifier)
                  .saveOnboardingDetails(
                    name: 'Learner',
                    age: 25,
                    role: 'Working Professional',
                    motivation: 'Daily Life',
                    commuteModes: ['Metro'],
                    visitedPlaces: ['Office', 'Supermarket'],
                    currentLevel: 'None',
                    nativeLanguage: 'English',
                    learningGoal: 'Daily Life',
                    initialConfidence: 10,
                  );
              context.go('/home');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Hi! I'm Mittu 🐘. Let's start by getting to know you. What should I call you?",
                  ),
                  const SizedBox(height: 24),
                  // Onboarding visual illustration
                  Container(
                    height: 140,
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
                        'assets/images/situations/onboarding_intro.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter your name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Karthik R',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              // Step 2: Age
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Nice to meet you, $_name! How old are you? This helps me adjust my study pace.",
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Select your age range',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: ['Below 18', '18-22', '23-30', '31-45', '45+']
                          .map((age) {
                            final isSelected = _ageGroup == age;
                            return _buildSelectionTile(age, isSelected, () {
                              setState(() => _ageGroup = age);
                            });
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
              // Step 3: Who are you?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Perfect. Who are you? I will tailor situation-based modules for your context!",
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Select your profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children:
                          [
                            'School Student',
                            'College Student',
                            'Working Professional',
                            'Tourist',
                            'Business Owner',
                            'Homemaker',
                            'Other',
                          ].map((role) {
                            final isSelected = _persona == role;
                            return _buildSelectionTile(role, isSelected, () {
                              setState(() => _persona = role);
                            });
                          }).toList(),
                    ),
                  ),
                ],
              ),
              // Step 4: Why are you learning?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Got it. What's your main reason to learn Kannada?",
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Select learning motivation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children:
                          [
                            'Study',
                            'Job / Career growth',
                            'Travel in Karnataka',
                            'Business deals',
                            'Daily Life survival',
                            'Talking to Friends',
                            'Become Fluent',
                          ].map((reason) {
                            final isSelected = _reason == reason;
                            return _buildSelectionTile(reason, isSelected, () {
                              setState(() => _reason = reason);
                            });
                          }).toList(),
                    ),
                  ),
                ],
              ),
              // Step 5: How do you travel?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Navigating Karnataka is an adventure! How do you commute?",
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Select primary mode of travel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: ['Metro', 'Bus', 'Auto', 'Bike', 'Car', 'Walk']
                          .map((mode) {
                            final isSelected = _commute == mode;
                            return _buildSelectionTile(mode, isSelected, () {
                              setState(() => _commute = mode);
                            });
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
              // Step 6: Frequently visited places
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Where do you visit frequently? Select all that apply. I'll make sure you learn these first!",
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select frequent spots',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children:
                          [
                            'Office',
                            'College',
                            'PG / Hostel',
                            'Restaurant',
                            'Shopping Mall',
                            'Supermarket',
                            'Metro Stop',
                            'Bus Stop',
                            'Gym',
                            'Temple',
                            'Hospital',
                            'Airport',
                            'Cafe',
                            'Apartment',
                          ].map((place) {
                            final isSelected = _selectedPlaces.contains(place);
                            return _buildSelectionCard(place, isSelected, () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPlaces.remove(place);
                                } else {
                                  _selectedPlaces.add(place);
                                }
                              });
                            });
                          }).toList(),
                    ),
                  ),
                ],
              ),
              // Step 7: Current Kannada Level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "What is your current level of Kannada language?",
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Choose current level',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children:
                          [
                            'None - absolute beginner 🐣',
                            'Few Words - can understand basic words 💬',
                            'Basic - can make simple sentences 🗣',
                            'Intermediate - can carry conversations ⚡',
                          ].map((lvl) {
                            final rawLvl = lvl.split(' - ')[0];
                            final isSelected = _level == rawLvl;
                            return _buildSelectionTile(lvl, isSelected, () {
                              setState(() => _level = rawLvl);
                            });
                          }).toList(),
                    ),
                  ),
                ],
              ),
              // New Step 8: Native Language
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Select your native language or the language you speak best. I will highlight direct comparative word bridges!",
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select native language',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: ['English', 'Telugu', 'Tamil', 'Hindi', 'Malayalam']
                          .map((lang) {
                            final isSelected = _nativeLanguage == lang;
                            return _buildSelectionTile(lang, isSelected, () {
                              setState(() => _nativeLanguage = lang);
                            });
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
              // New Step 9: Initial Confidence Level Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMittuSpeech(
                    "Be honest! What is your current Kannada speaking confidence level?",
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Speaking Confidence: ${_initialConfidence.round()}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: _initialConfidence,
                    min: 10.0,
                    max: 100.0,
                    divisions: 9,
                    label: '${_initialConfidence.round()}%',
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setState(() {
                        _initialConfidence = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _initialConfidence <= 20
                          ? "🐣 Complete Beginner - Cannot speak single words confidently."
                          : _initialConfidence <= 50
                              ? "💬 Word Builder - Can speak some words but struggle to make sentences."
                              : "🗣 Survival Speaker - Can speak basic daily expressions.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // New Step 10: Final Journey Synthesis Animation
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: MittuWidget(
                      mood: MittuMood.happy,
                      size: 140,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    "Your Kannada journey is created for your life! 🌟",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Mittu has successfully generated a customized curriculum matching your native language ($_nativeLanguage) and specific goals ($_reason) for Bengaluru campus life. Let's go!",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 56),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currentStep == 7 ? 'Start Journey' : 'Next'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return _BouncySelectionTile(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildSelectionCard(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return _BouncySelectionCard(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _BouncySelectionTile extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BouncySelectionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BouncySelectionTile> createState() => _BouncySelectionTileState();
}

class _BouncySelectionTileState extends State<_BouncySelectionTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withOpacity(0.08)
                : (isDark ? AppTheme.darkCard : Colors.white),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryBlue
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: widget.isSelected ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ListTile(
            title: Text(
              widget.label,
              style: TextStyle(
                fontWeight: widget.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : (isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.lightTextPrimary),
              ),
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: widget.isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryBlue,
                      key: ValueKey('selected'),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: Colors.grey,
                      key: ValueKey('unselected'),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BouncySelectionCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BouncySelectionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BouncySelectionCard> createState() => _BouncySelectionCardState();
}

class _BouncySelectionCardState extends State<_BouncySelectionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withOpacity(0.08)
                : (isDark ? AppTheme.darkCard : Colors.white),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryBlue
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: widget.isSelected ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.isSelected
                      ? Icons.check_box_outlined
                      : Icons.add_box_outlined,
                  key: ValueKey(widget.isSelected),
                  size: 16,
                  color: widget.isSelected ? AppTheme.primaryBlue : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: widget.isSelected
                        ? AppTheme.primaryBlue
                        : (isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
