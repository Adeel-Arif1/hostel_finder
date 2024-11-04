import 'package:flutter/material.dart';
class AmenityIcon extends StatelessWidget {
  final String amenity;

  const AmenityIcon({super.key, required this.amenity});

  @override
  Widget build(BuildContext context) {
    // Define the map of amenities and their icons here
 final Map<String, IconData> amenitiesIcons = {
  'WiFi': Icons.wifi,
  'Filter Water': Icons.filter,
  'Security': Icons.security,
  'Laundry': Icons.local_laundry_service,
  'kitchen': Icons.kitchen_rounded,  // Represents self-cooking
  'Air Conditioning': Icons.ac_unit,
  'TV': Icons.tv,  // Represents an LCD screen
  // Add more as necessary
};


    // Return the icon and amenity name
    return Row(
      children: [
        Icon(
          amenitiesIcons[amenity] ?? Icons.info, // Default icon if not found
          color: Colors.teal,
        ),
        const SizedBox(width: 8),
        Text(
          amenity,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
