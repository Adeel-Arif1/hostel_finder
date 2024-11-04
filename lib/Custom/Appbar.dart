// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;

//   const CustomAppBar({Key? key, required this.title}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: TextStyle(
//           fontStyle: FontStyle.italic,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Colors.teal,
//        leading: BackButton(),
//       actions: actions, // Use the actions
//     );
//   }

//   // Override preferredSize to specify the height of the AppBar
//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // Accept actions as a parameter

  const CustomAppBar({super.key, required this.title, this.actions}); // Constructor

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const BackButton(),
      backgroundColor: Colors.teal,
      actions: actions, // Use the actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // AppBar height
}
