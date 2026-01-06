import 'package:flutter/material.dart';
import 'navigation_item.dart';

class NavigationConfig {
  static const List<NavigationItem> mobileItems = [
    NavigationItem(
      icon: Icons.newspaper,
      selectedIcon: Icons.newspaper,
      label: 'News',
      index: 0,
    ),
    NavigationItem(
      icon: Icons.map,
      selectedIcon: Icons.map,
      label: 'Map',
      index: 1,
    ),
    NavigationItem(
      icon: Icons.sports_esports,
      selectedIcon: Icons.sports_esports,
      label: 'Gaming',
      index: 2,
    ),
  ];

  static const List<NavigationItem> webItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      index: 0,
    ),
    NavigationItem(
      icon: Icons.newspaper_outlined,
      selectedIcon: Icons.newspaper,
      label: 'News',
      index: 1,
    ),
    NavigationItem(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Map',
      index: 2,
    ),
    NavigationItem(
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
      label: 'Gaming',
      index: 3,
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      index: 4,
    ),
  ];
}

