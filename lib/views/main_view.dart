import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'news_view.dart';
import 'map_view.dart';
import 'gaming_view.dart';
import '../widgets/ios_tab_bar.dart';
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
    if (!kIsWeb) {
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
    if (!kIsWeb) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Widget _buildMobileView() {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  NewsView(),
                  MapView(),
                  GamingView(),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: NavigationConfig.mobileItems.map((item) {
                    return IosTabBarButton(
                      icon: item.icon,
                      label: item.label,
                      isSelected: _selectedIndex == item.index,
                      onTap: () => setState(() => _selectedIndex = item.index),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Android
      return AndroidTabBar(
        controller: _tabController,
        children: const [
          NewsView(),
          MapView(),
          GamingView(),
        ],
      );
    }
  }

  Widget _buildWebView() {
    return Scaffold(
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
        // Home - for now we are showing NewsView, we'll create the HomeView when we'll have the design for it
        return const NewsView();
      case 1:
        return const NewsView();
      case 2:
        return const MapView();
      case 3:
        return const GamingView();
      case 4:
        // Settings - for now we are showing NewsView, we'll create the SettingsView when we'll have the design for it
        return const NewsView();
      default:
        return const NewsView();
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

