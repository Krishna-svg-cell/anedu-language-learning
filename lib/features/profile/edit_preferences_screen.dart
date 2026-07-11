import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';

class EditPreferencesScreen extends ConsumerStatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  ConsumerState<EditPreferencesScreen> createState() =>
      _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends ConsumerState<EditPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  String _selectedRole = '';
  String _selectedMotivation = '';
  String _selectedCommute = '';
  List<String> _selectedPlaces = [];
  String _selectedLevel = '';

  @override
  void initState() {
    super.initState();
    final progress = ref.read(userProgressProvider);
    _nameController = TextEditingController(text: progress.name);
    _selectedRole = progress.role;
    _selectedMotivation = progress.motivation;
    _selectedCommute = progress.commuteModes.isNotEmpty
        ? progress.commuteModes.first
        : 'Metro';
    _selectedPlaces = List<String>.from(progress.visitedPlaces);
    _selectedLevel = progress.level;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    ref
        .read(userProgressProvider.notifier)
        .saveOnboardingDetails(
          name: _nameController.text.trim(),
          age: ref.read(userProgressProvider).age, // retain current age
          role: _selectedRole,
          motivation: _selectedMotivation,
          commuteModes: [_selectedCommute],
          visitedPlaces: _selectedPlaces.isEmpty ? ['Metro'] : _selectedPlaces,
          currentLevel: _selectedLevel,
          nativeLanguage: ref.read(userProgressProvider).nativeLanguage,
          learningGoal: _selectedMotivation,
          initialConfidence: ref.read(userProgressProvider).initialConfidence,
        );

    // Refresh lessons
    ref.read(lessonsListProvider.notifier).reloadLessons();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Learning preferences updated! Your path has adjusted.'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome header with Mittu
              Row(
                children: [
                  const MittuWidget(
                    mood: MittuMood.happy,
                    size: 70,
                    animate: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Customize your path below. Mittu will dynamically re-route your lessons!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              Text(
                'Your Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryBlue,
                  ),
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 24),

              // Level Selector
              Text(
                'Kannada Level',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['None', 'Few Words', 'Basic', 'Intermediate'].map((
                  lvl,
                ) {
                  final isSelected = _selectedLevel == lvl;
                  return ChoiceChip(
                    label: Text(lvl),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedLevel = lvl);
                    },
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Profile Selector
              Text(
                'Who are you?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
                      final isSelected = _selectedRole == role;
                      return ChoiceChip(
                        label: Text(role),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = role);
                        },
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Learning Goals / Motivation
              Text(
                'Main Motivation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue:
                    [
                      'Study',
                      'Job / Career growth',
                      'Travel in Karnataka',
                      'Business deals',
                      'Daily Life survival',
                      'Talking to Friends',
                      'Become Fluent',
                    ].contains(_selectedMotivation)
                    ? _selectedMotivation
                    : 'Daily Life survival',
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.psychology_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                items:
                    [
                      'Study',
                      'Job / Career growth',
                      'Travel in Karnataka',
                      'Business deals',
                      'Daily Life survival',
                      'Talking to Friends',
                      'Become Fluent',
                    ].map((mot) {
                      return DropdownMenuItem<String>(
                        value: mot,
                        child: Text(mot),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMotivation = val);
                },
              ),
              const SizedBox(height: 24),

              // Commute Modes
              Text(
                'Primary Commute Mode',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Metro', 'Bus', 'Auto', 'Bike', 'Car', 'Walk'].map((
                  mode,
                ) {
                  final isSelected = _selectedCommute == mode;
                  return ChoiceChip(
                    label: Text(mode),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCommute = mode);
                    },
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Visited Places
              Text(
                'Frequently Visited Places',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
                      return FilterChip(
                        label: Text(place),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPlaces.add(place);
                            } else {
                              _selectedPlaces.remove(place);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 40),

              // Save button
              ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Save Learning Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
