import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomBookingWidget extends StatefulWidget {
  @override
  _RoomBookingWidgetState createState() => _RoomBookingWidgetState();
}

class _RoomBookingWidgetState extends State<RoomBookingWidget> {
  List<String> roomIDs = [];
  int a = 1;
  int b = 2;

  @override
  void initState() {
    super.initState();
    fetchRoomBookings();
  }

  Future<void> fetchRoomBookings() async {
    final String bookingsUrl = "https://hostelfinder-8c017-default-rtdb.firebaseio.com/room_bookings.json"; // URL for the room bookings collection
    try {
      final response = await http.get(Uri.parse(bookingsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) { // Check if data is a map
          // Iterate through the data and fetch room IDs
          data.forEach((key, value) {
            if (value['room_ID'] != null) {
              roomIDs.add(value['room_ID'].toString()); // Ensure room_ID is a string
            }
          });

          // Print the room IDs
          print('Room IDs: $roomIDs');

          // Update the UI
          setState(() {});
        } else {
          print('No bookings found or data is not a map');
        }
      } else {
        print('Error fetching room bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching room bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Room IDs:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        for (var id in roomIDs)
          Text(
            id,
            style: TextStyle(
              color: (id == a.toString() || id == b.toString()) ? Colors.red : Colors.black, // Change color based on match
            ),
          ),
        // Display variables a and b at the bottom
        Text(
          'Variable a: $a',
          style: TextStyle(
            color: roomIDs.contains(a.toString()) ? Colors.red : Colors.black,
          ),
        ),
        Text(
          'Variable b: $b',
          style: TextStyle(
            color: roomIDs.contains(b.toString()) ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
