import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/navigation/app_bottom_nav.dart';
import 'discover_screen.dart';
import '../garments/garments_screen.dart';
import '../tryon/tryon_screen.dart';
import '../outfits/outfits_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DiscoverScreen(),
    GarmentsScreen(),
    TryonScreen(),
    OutfitsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onIndexChanged: (idx) {
          setState(() => _currentIndex = idx);
        },
      ),
    );
  }
}
