import 'package:flutter/material.dart';

class FilterOptionsDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const FilterOptionsDialog({super.key, required this.onApply});

  @override
  _FilterOptionsDialogState createState() => _FilterOptionsDialogState();
}

class _FilterOptionsDialogState extends State<FilterOptionsDialog> {
  String? _selectedGender;
  String? _selectedBookingType;
  final List<String> _amenities = [
    'WiFi',
    'Kitchen',
    'TV',
    'Laundry',
    'Security',
    'Filtered Water',
    'Air Conditioning'
  ];
  final List<String> _selectedAmenities = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gender Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildGenderCheckbox('Male'),
                    _buildGenderCheckbox('Female'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Booking Type Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildBookingTypeRadio('One Day'),
                    _buildBookingTypeRadio('Weekly'),
                    _buildBookingTypeRadio('Monthly'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Amenities Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _amenities.map((amenity) {
                        return FilterChip(
                          label: Text(amenity),
                          selected: _selectedAmenities.contains(amenity),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Apply Filters Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> filters = {
                    'gender': _selectedGender,
                    'bookingType': _selectedBookingType,
                    'amenities': _selectedAmenities,
                  };

                  // Print the selected filters for debugging
                  print('Selected Filters: $filters');

                  widget.onApply(filters);
                  Navigator.pop(context); // Close the filters dialog
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  
                     backgroundColor: Colors.white, // Set the background color to white
                      foregroundColor: Colors.teal
                ),
                child: const Text('Apply Filters'),
              
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCheckbox(String gender) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(gender),
      leading: Transform.scale(
        scale: 1,
        child: Checkbox(
          checkColor: Colors.white,
          activeColor: Colors.purple,
          shape: const CircleBorder(),
          value: _selectedGender == gender,
          onChanged: (bool? selected) {
            setState(() {
              if (selected == true) {
                _selectedGender = gender;
              } else {
                _selectedGender = null;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildBookingTypeRadio(String type) {
    return RadioListTile<String>(
      title: Text(type),
      value: type,
      groupValue: _selectedBookingType,
      onChanged: (value) {
        setState(() {
          _selectedBookingType = value!;
        });
      },
    );
  }
}




