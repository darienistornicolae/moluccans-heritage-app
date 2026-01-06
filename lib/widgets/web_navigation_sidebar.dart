import 'package:flutter/material.dart';
import '../models/navigation_config.dart';

class WebNavigationSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const WebNavigationSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[300],
      child: Column(
        children: NavigationConfig.webItems.map((item) {
          return WebNavItem(
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            label: item.label,
            index: item.index,
            isSelected: selectedIndex == item.index,
            onTap: () => onItemSelected(item.index),
          );
        }).toList(),
      ),
    );
  }
}

class WebNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const WebNavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.black : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

