import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Check if the keyboard is open by comparing the viewInsets.bottom to zero
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;

    // If the keyboard is open, return an empty container, otherwise show the FloatingActionButton
    return isKeyboardOpen
        ? const SizedBox.shrink() // Hide the button when the keyboard is open
        : FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.teal, // Set the background color to teal
            child: const Icon(
              Icons.add,
              size: 18.0, // Adjust the size of the icon
            ),
            // You can also adjust the size of the FAB itself using the mini parameter
            // mini: true, // Uncomment this line to make the FAB smaller
          );
  }
}


