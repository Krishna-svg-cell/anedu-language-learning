import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'journey/journey_screen.dart';
import 'profile/profile_screen.dart';

import '../core/services/audio_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const JourneyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex != index) {
            AudioService.instance.playNavigation();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        indicatorColor: AppTheme.primaryBlue.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.primaryBlue),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
