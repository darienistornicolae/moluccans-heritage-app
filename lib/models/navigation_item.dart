import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
  });

  NavigationItem copyWith({
    IconData? icon,
    IconData? selectedIcon,
    String? label,
    int? index,
  }) {
    return NavigationItem(
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      label: label ?? this.label,
      index: index ?? this.index,
    );
  }
}

