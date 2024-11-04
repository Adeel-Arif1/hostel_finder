

import 'package:flutter/material.dart';
class RulesDialog extends StatelessWidget {
  // Define the rules list
  final List<String> rules = [
    'Save the water',
    'Outsiders are not allowed',
    'Fees are paid on time',
    'Self-cooking is not allowed',
    'Late night entry is not allowed',
  ];

  RulesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Hostel Rules',
        style: TextStyle(
          color: Colors.teal,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: rules.map((rule) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic, // Italic style added here
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.teal),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
