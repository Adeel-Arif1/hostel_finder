import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RoomListScreen extends StatefulWidget {
  final String hostelId;
  final String hostelName;

  const RoomListScreen({super.key, required this.hostelId,required this.hostelName});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final String url =
      "https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels.json";
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _filteredRooms = [];
  final TextEditingController _searchController = TextEditingController();

  // Variables for filters
  String? selectedRoomType;
  String? selectedWashroomType;
  List<String> roomIDs = []; // Store room IDs from bookings
  List<String> matchedRoomIDs = []; // New list to store matched room IDs
  @override
  void initState() {
    print("widget.hostelId ${widget.hostelId}");
    print("widget.hostelName ${widget.hostelName}");
    super.initState();
    fetchHostelData();
     fetchRoomBookings(); // Fetch room bookings to get booked room IDs

    _searchController
        .addListener(_filterRooms); // Add the listener for search functionality
  }

  // Fetch room bookings method
  Future<void> fetchRoomBookings() async {
    final String bookingsUrl =
        "https://hostelfinder-8c017-default-rtdb.firebaseio.com/room_bookings.json"; // URL for the room bookings collection
    try {
      final response = await http.get(Uri.parse(bookingsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          // Check if data is a map
          // Iterate through the data and fetch room IDs only if hostelId matches
          data.forEach((key, value) {
            if (value['hostel_name'] != null && value['hostel_name'].toString() == widget.hostelName) {
              roomIDs.add(
                  value['room_ID'].toString()); // Ensure room_ID is a string
              print('Matching Room ID: ${value['hostel_name'].toString()}');
            }
          });

          // Print the filtered room IDs
          print('Filtered Room IDs: $roomIDs');
          print('Filtered Room IDs length: ${roomIDs.length}');

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
  void dispose() {
    _searchController
        .removeListener(_filterRooms); // Remove listener on dispose
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchHostelData() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          List<Map<String, dynamic>> loadedRooms = [];

          data.forEach((key, value) {
            if (key == widget.hostelId) {
              if (value['rooms'] is List) {
                value['rooms'].forEach((roomValue) {
                  final roomData = {
                    'id': key,
                    'room_number': roomValue['room_number'] ?? 'No room number',
                    'available_seats':
                        roomValue['available_seats']?.toString() ??
                            'No available seats',
                    'occupied_seats': roomValue['occupied_seats']?.toString() ??
                        'No occupied seats',
                    'price_per_seat': roomValue['price_per_seat']?.toString() ??
                        'No price per seat',
                    'room_type': roomValue['room_type'] ?? 'No room type',
                    'Washroom_type':
                        roomValue['Washroom_type'] ?? 'No washroom type',
                    'images': roomValue['images'] is List
                        ? (roomValue['images'] as List)
                            .map((item) => item.toString())
                            .toList()
                        : ['No images'],
                  };

                  loadedRooms.add(roomData);
                });
              }
            }
          });

          setState(() {
            _rooms = loadedRooms;
            _filteredRooms = _rooms; // Initially, show all rooms
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Define the _filterRooms method for search functionality
  void _filterRooms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRooms = _rooms.where((room) {
        final roomNumber = room['room_number']?.toLowerCase() ?? '';
        return roomNumber.contains(query);
      }).toList();
    });
  }

  // Filter rooms based on room type and washroom type
  void applyFilters() {
    setState(() {
      _filteredRooms = _rooms.where((room) {
        bool matchesRoomType =
            selectedRoomType == null || room['room_type'] == selectedRoomType;
        bool matchesWashroomType = selectedWashroomType == null ||
            room['Washroom_type'] == selectedWashroomType;
        return matchesRoomType && matchesWashroomType;
      }).toList();
    });
  }

  // Open filter dialog
  Future<void> _openFilterDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Room Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                            _buildRoomTypeRadioButton('1-Seater', setState),
                            _buildRoomTypeRadioButton('2-Seater', setState),
                            _buildRoomTypeRadioButton('3-Seater', setState),
                            _buildRoomTypeRadioButton('4-Seater', setState),
                            _buildRoomTypeRadioButton('5-Seater', setState),
                            _buildRoomTypeRadioButton('6-Seater', setState),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Washroom Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                            _buildWashroomTypeRadioButton('Common', setState),
                            _buildWashroomTypeRadioButton('Attached', setState),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                applyFilters(); // Apply the filter and update the list
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Build radio button for room type
  Widget _buildRoomTypeRadioButton(String value, StateSetter setState) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedRoomType,
      onChanged: (newValue) {
        setState(() {
          selectedRoomType = newValue;
        });
      },
    );
  }

  // Build radio button for washroom type
  Widget _buildWashroomTypeRadioButton(String value, StateSetter setState) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedWashroomType,
      onChanged: (newValue) {
        setState(() {
          selectedWashroomType = newValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog, // Open filter dialog
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredRooms.isEmpty
                ? const Center(
                    child: Text('No rooms available',
                        style: TextStyle(fontStyle: FontStyle.italic)))
                : ListView.builder(
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      int roomCount = roomIDs
                          .where((id) => id == room['room_number'].toString())
                          .length;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Determine if the room number is in roomIDs
                            Container(
                              color: Colors.teal,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Room Number: ${room['room_number'].toString()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Room Type: ${room['room_type']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Count how many times the room_number appears in roomIDs

                                  // Conditional check for available seats based on roomIDs
                                  _buildRoomDetailRow(
                                    icon: Icons.bed,
                                    label: 'Available Seats',
                                    value: roomCount > 0
                                        ? (int.parse(room['available_seats']
                                                        .toString()) -
                                                    roomCount) <=
                                                0
                                            ? 'No booking available' // If available seats become 0 or less
                                            : (int.parse(room['available_seats']
                                                        .toString()) -
                                                    roomCount)
                                                .toString()
                                        : room['available_seats']
                                            .toString(), // No change if roomCount is 0
                                  ),
                                  // Conditional check for occupied seats based on roomCount
                                  _buildRoomDetailRow(
                                    icon: Icons.people,
                                    label: 'Occupied Seats',
                                    value: roomCount > 0
                                        ? (int.parse(room['occupied_seats']
                                                    .toString()) +
                                                roomCount)
                                            .toString()
                                        : room['occupied_seats']
                                            .toString(), // No change if roomCount is 0
                                  ),
                                  _buildRoomDetailRow(
                                    icon: Icons.bathroom,
                                    label: 'Washroom Type',
                                    value: room['Washroom_type'],
                                  ),
                                  _buildRoomDetailRow(
                                    icon: Icons.money,
                                    label: 'Price per Seat',
                                    value: room['price_per_seat'],
                                  ),
                                  const SizedBox(height: 10),
                                  room['images'].isNotEmpty
                                      ? SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: room['images'].length,
                                            itemBuilder: (context, imageIndex) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        room['images']
                                                            [imageIndex]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const Text('No images available'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Method to build room detail rows
  Widget _buildRoomDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
