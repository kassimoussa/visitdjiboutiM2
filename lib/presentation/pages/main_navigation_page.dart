import 'package:flutter/material.dart';
import 'package:vd_gem/core/enums/bottom_nav_tab.dart';
import 'package:vd_gem/presentation/pages/home_page.dart';
import 'package:vd_gem/presentation/pages/discover_page.dart';
import 'package:vd_gem/presentation/pages/events_page.dart';
import 'package:vd_gem/presentation/pages/map_page.dart';
import 'package:vd_gem/presentation/pages/favorites_page.dart';
import 'package:vd_gem/presentation/widgets/app_drawer.dart';
import 'package:vd_gem/presentation/widgets/offline_indicator.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onTabChange: _changeTab),
      const DiscoverPage(),
      const EventsPage(),
      const MapPage(),
      const FavoritesPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return OfflineIndicator(
      child: Scaffold(
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
          actions: const [ConnectivityIcon()],
        ),
        drawer: const AppDrawer(),
        body: IndexedStack(index: _currentIndex, children: _pages),
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
              label: tab.getLabel(context),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPageTitle() {
    return BottomNavTab.values[_currentIndex].getTitle(context);
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
    final color = isActive ? const Color(0xFF3860F8) : const Color(0xFF64748B);

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
