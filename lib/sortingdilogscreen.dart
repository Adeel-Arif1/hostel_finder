import 'package:flutter/material.dart';

class SortingOptionsDialog extends StatefulWidget {
  final Function(String) onApply;

  const SortingOptionsDialog({super.key, required this.onApply});

  @override
  _SortingOptionsDialogState createState() => _SortingOptionsDialogState();
}

class _SortingOptionsDialogState extends State<SortingOptionsDialog> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          RadioListTile<String>(
            title: const Text(
              'Price Low to High',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            value: 'Price Low to High',
            groupValue: _selectedOption,
            onChanged: (String? value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text(
              'Price High to Low',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            value: 'Price High to Low',
            groupValue: _selectedOption,
            onChanged: (String? value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_selectedOption != null) {
                widget.onApply(_selectedOption!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a sorting option.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // Set the background color to white
                foregroundColor: Colors.teal // Set the background color to teal
                ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
