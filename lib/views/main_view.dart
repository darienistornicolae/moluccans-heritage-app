import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'places_view.dart';
import 'map_view.dart';
import 'gaming_view.dart';
import '../widgets/web_navigation_sidebar.dart';
import '../widgets/android_tab_bar.dart';
import '../models/navigation_config.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !Platform.isIOS) {
      // Only needed for Android
      _tabController = TabController(length: 3, vsync: this);
      _tabController.addListener(() {
        if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && !Platform.isIOS) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Widget _buildMobileView() {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: Colors.green,
          inactiveColor: CupertinoColors.inactiveGray,
          backgroundColor: CupertinoColors.white,
          items: NavigationConfig.mobileItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => const PlacesView(),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => const MapView(),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const GamingView(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const PlacesView(),
              );
          }
        },
      );
    } else {
      // Android
      return AndroidTabBar(
        controller: _tabController,
        children: const [
          PlacesView(),
          MapView(),
          GamingView(),
        ],
      );
    }
  }

  Widget _buildWebView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamp Wyldemerk'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          WebNavigationSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _getSelectedView(),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        // Home - for now we are showing PlacesView, we'll create the HomeView when we'll have the design for it
        return const PlacesView();
      case 1:
        return const PlacesView();
      case 2:
        return const MapView();
      case 3:
        return const GamingView();
      case 4:
        // Settings - for now we are showing PlacesView, we'll create the SettingsView when we'll have the design for it
        return const PlacesView();
      default:
        return const PlacesView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebView();
    } else {
      return _buildMobileView();
    }
  }
}

