import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';

class MenuDetailScreen extends StatelessWidget {
  final Map<String, String> breakfastMenu;
  final Map<String, String> lunchMenu;
  final Map<String, String> dinnerMenu;

  const MenuDetailScreen({
    super.key,
    required this.breakfastMenu,
    required this.lunchMenu,
    required this.dinnerMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Menu detail'),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Breakfast'),
                Tab(text: 'Lunch'),
                Tab(text: 'Dinner'),
              ],
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
              labelColor: Colors.black,
              indicatorColor: Colors.teal,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMenuTabContent(breakfastMenu),
                  _buildMenuTabContent(lunchMenu),
                  _buildMenuTabContent(dinnerMenu),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTabContent(Map<String, String> menuData) {
    final daysOfWeek = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 9.0,
          mainAxisSpacing: 9.0,
          childAspectRatio: 1.4, // Adjust as needed
        ),
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          final day = daysOfWeek[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.teal, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    menuData[day] ?? 'No menu available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
