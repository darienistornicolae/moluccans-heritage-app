import 'package:flutter/material.dart';

class AndroidTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> children;

  const AndroidTabBar({
    super.key,
    required this.controller,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamp Wyldemerk'),
        centerTitle: true,
      ),
      body: TabBarView(
        controller: controller,
        children: children,
      ),
      bottomNavigationBar: Material(
        child: TabBar(
          controller: controller,
          indicator: const BoxDecoration(
            color: Colors.green,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              icon: Icon(
                Icons.location_on,
                color: controller.index == 0 ? Colors.white : Colors.grey,
              ),
              text: 'Places',
            ),
            Tab(
              icon: Icon(
                Icons.map,
                color: controller.index == 1 ? Colors.white : Colors.grey,
              ),
              text: 'Map',
            ),
            Tab(
              icon: Icon(
                Icons.sports_esports,
                color: controller.index == 2 ? Colors.white : Colors.grey,
              ),
              text: 'Gaming',
            ),
          ],
        ),
      ),
    );
  }
}

