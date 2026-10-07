import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../garments/garments_screen.dart';
import '../tryon/tryon_screen.dart';
import '../tryon/tryon_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GarmentsScreen(),
    const TryonScreen(),
    const TryonHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.checkroom_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.checkroom_rounded, color: AppColors.primaryLight),
              label: 'Wardrobe',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight),
              label: 'Try-On',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.history_rounded, color: AppColors.primaryLight),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryLight),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
