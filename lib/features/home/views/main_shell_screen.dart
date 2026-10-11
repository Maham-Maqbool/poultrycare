import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../scanner/views/scanner_screen.dart';
import '../../flocks/views/flocks_list_screen.dart';
import '../../encyclopedia/views/disease_library_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../profile/controllers/settings_controller.dart';
import 'home_dashboard_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTab;

  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    ScannerScreen(),
    FlocksListScreen(),
    DiseaseLibraryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: isUrdu ? 'ہوم' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt_outlined),
            activeIcon: const Icon(Icons.camera_alt_rounded),
            label: isUrdu ? 'اسکین' : 'Scan',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_work_outlined),
            activeIcon: const Icon(Icons.home_work_rounded),
            label: isUrdu ? 'فلاکس' : 'Flocks',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book_rounded),
            label: isUrdu ? 'بیماریاں' : 'Library',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: isUrdu ? 'اکاؤنٹ' : 'Account',
          ),
        ],
      ),
    );
  }
}
