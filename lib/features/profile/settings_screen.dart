import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/local_db.dart';
import '../../core/services/audio_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _backendUrlController;
  bool _obscureApiKey = true;
  bool _isTestingConnection = false;
  ConnectionStatus? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: LocalDb.geminiApiKey);
    _backendUrlController = TextEditingController(text: LocalDb.geminiBackendUrl);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'App Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          // Gemini API Key Config Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.vpn_key_rounded,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gemini API Key',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Used for freeform natural conversations with AI characters. The key is stored locally on your device.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    style: const TextStyle(fontSize: 14, letterSpacing: 0.5),
                    decoration: InputDecoration(
                      hintText: 'Enter API Key (AIzaSy...)',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscureApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            onPressed: () async {
                              await LocalDb.setGeminiApiKey(_apiKeyController.text);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gemini API Key saved successfully!'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Gemini Backend Proxy Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.settings_input_component_rounded,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gemini API Backend Proxy',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Query Gemini securely via a local backend server proxy (recommended to protect API keys in production).',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _backendUrlController,
                    style: const TextStyle(fontSize: 14, letterSpacing: 0.5),
                    decoration: InputDecoration(
                      hintText: 'Enter Server URL (http://localhost:3000)',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: _isTestingConnection
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _connectionStatus == ConnectionStatus.connected
                                    ? Icons.cloud_done_rounded
                                    : (_connectionStatus == ConnectionStatus.noApiKey
                                        ? Icons.cloud_queue_rounded
                                        : (_connectionStatus == ConnectionStatus.failed ? Icons.cloud_off_rounded : Icons.cloud_sync_rounded)),
                                size: 16,
                                color: _connectionStatus == ConnectionStatus.connected
                                    ? AppTheme.successGreen
                                    : (_connectionStatus == ConnectionStatus.noApiKey
                                        ? Colors.orange
                                        : (_connectionStatus == ConnectionStatus.failed ? AppTheme.errorRed : AppTheme.primaryBlue)),
                              ),
                        label: Text(
                          _isTestingConnection
                              ? 'Testing...'
                              : (_connectionStatus == ConnectionStatus.connected
                                  ? 'Connected!'
                                  : (_connectionStatus == ConnectionStatus.noApiKey
                                      ? 'Server Ready (No API Key)'
                                      : (_connectionStatus == ConnectionStatus.failed ? 'Failed (Offline)' : 'Test Connection'))),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _connectionStatus == ConnectionStatus.connected
                                ? AppTheme.successGreen
                                : (_connectionStatus == ConnectionStatus.noApiKey
                                    ? Colors.orange
                                    : (_connectionStatus == ConnectionStatus.failed ? AppTheme.errorRed : AppTheme.primaryBlue)),
                          ),
                        ),
                        onPressed: _isTestingConnection
                            ? null
                            : () async {
                                setState(() {
                                  _isTestingConnection = true;
                                  _connectionStatus = null;
                                });
                                final status = await LocalDb.testBackendConnection(_backendUrlController.text);
                                setState(() {
                                  _isTestingConnection = false;
                                  _connectionStatus = status;
                                });
                                if (mounted) {
                                  if (status == ConnectionStatus.connected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Connected successfully! Gemini API key is loaded on proxy.'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  } else if (status == ConnectionStatus.noApiKey) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Server connected, but GEMINI_API_KEY is not defined in backend/.env!'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not reach the server proxy. Please check URL or start backend proxy.'),
                                        backgroundColor: AppTheme.errorRed,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await LocalDb.setGeminiBackendUrl(_backendUrlController.text);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Backend Proxy URL saved successfully!'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        },
                        child: const Text('Save URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dark Mode Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.primaryBlue,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Toggle light and dark color schemes'),
              value: isDark,
              activeThumbColor: AppTheme.primaryBlue,
              onChanged: (value) {
                AudioService.instance.playToggle();
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 12),

          // Learning Preferences
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.tune_rounded,
                color: AppTheme.primaryBlue,
              ),
              title: const Text(
                'Learning Preferences',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Adjust role, goals, commutes, and difficulty level',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                AudioService.instance.playClick();
                context.push('/edit-preferences');
              },
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'System Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          // Reset Cache Option
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_sweep_outlined,
                color: AppTheme.errorRed,
              ),
              title: const Text(
                'Reset Progress & Cache',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorRed,
                ),
              ),
              subtitle: const Text(
                'Deletes all local progress, streaks, coins, and resets onboarding.',
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Progress?'),
                    content: const Text(
                      'This action will delete all your local database cache, reset your Streak back to zero, and clear coin balances. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(userProgressProvider.notifier)
                              .resetProgress();
                          ref
                              .read(lessonsListProvider.notifier)
                              .reloadLessons();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('App cache reset successfully!'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        },
                        child: const Text(
                          'Reset All',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Log Out Option
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppTheme.primaryBlue,
              ),
              title: const Text(
                'Log Out / Switch Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Sign out of the current profile and switch to another.',
              ),
              onTap: () async {
                await LocalDb.setActiveUserId('guest_user');
                ref.read(userProgressProvider.notifier).reloadProgress();
                ref.read(lessonsListProvider.notifier).reloadLessons();
                if (context.mounted) {
                  context.go('/auth');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
