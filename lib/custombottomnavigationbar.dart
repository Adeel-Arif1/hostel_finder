import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,  // This places the FAB in the center
      backgroundColor: Colors.teal,  // Background color of the bottom bar
      activeColor: Colors.white,     // Color of the active icon and label
      items: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.favorite, title: 'Favorites'),
        TabItem(icon: Icons.add, title: 'Add'),  // This is for the FAB
        TabItem(icon: Icons.data_usage, title: 'Data'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
      initialActiveIndex: currentIndex,  // Current index of the selected tab
      onTap: onTap,  // This handles tab change
    );
  }
}


