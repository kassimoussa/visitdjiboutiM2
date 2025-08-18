import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/enums/bottom_nav_tab.dart';
import 'package:visitdjibouti/presentation/pages/home_page.dart';
import 'package:visitdjibouti/presentation/pages/discover_page.dart';
import 'package:visitdjibouti/presentation/pages/events_page.dart';
import 'package:visitdjibouti/presentation/pages/map_page.dart';
import 'package:visitdjibouti/presentation/pages/favorites_page.dart';
import 'package:visitdjibouti/presentation/widgets/app_drawer.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const DiscoverPage(),
    const EventsPage(),
    const MapPage(),
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF3860F8),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        items: BottomNavTab.values.map((tab) {
          return BottomNavigationBarItem(
            icon: _buildTabIcon(tab, false),
            activeIcon: _buildTabIcon(tab, true),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle() {
    switch (BottomNavTab.values[_currentIndex]) {
      case BottomNavTab.home:
        return 'Visit Djibouti';
      case BottomNavTab.discover:
        return 'Découvrir';
      case BottomNavTab.events:
        return 'Événements';
      case BottomNavTab.map:
        return 'Carte';
      case BottomNavTab.favorites:
        return 'Favoris';
    }
  }

  Widget _buildTabIcon(BottomNavTab tab, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF3860F8).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _getIconWidget(tab, isActive),
          ),
        ],
      ),
    );
  }

  Widget _getIconWidget(BottomNavTab tab, bool isActive) {
    final color = isActive 
        ? const Color(0xFF3860F8)
        : const Color(0xFF64748B);
    
    switch (tab) {
      case BottomNavTab.home:
        return Icon(
          isActive ? Icons.home : Icons.home_outlined,
          color: color,
          size: 24,
        );
      case BottomNavTab.discover:
        return Icon(
          isActive ? Icons.explore : Icons.explore_outlined,
          color: color,
          size: 24,
        );
      case BottomNavTab.events:
        return Icon(
          isActive ? Icons.event : Icons.event_outlined,
          color: color,
          size: 24,
        );
      case BottomNavTab.map:
        return Icon(
          isActive ? Icons.map : Icons.map_outlined,
          color: color,
          size: 24,
        );
      case BottomNavTab.favorites:
        return Icon(
          isActive ? Icons.favorite : Icons.favorite_outline,
          color: color,
          size: 24,
        );
    }
  }
}