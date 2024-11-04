import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:hostelfinder/Custom/aminities_icons.dart';
import 'package:hostelfinder/booking/bookingdetailsuser.dart';
import 'package:hostelfinder/editdilogscreen.dart';
import 'package:hostelfinder/hostel_bookings.dart';
import 'package:hostelfinder/menuscreen.dart'; // Import the room images screen
import 'package:hostelfinder/roomdetail.dart';
import 'package:hostelfinder/shareprefrence.dart';
import 'package:http/http.dart' as http;

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  List<Map<String, dynamic>> _hostels = [];
  String? _useruid;

  @override
  void initState() {
    super.initState();
    _loadUseruid();
  }

  Future<void> _loadUseruid() async {
    _useruid = await SharedPreferencesHelper.getUserUid();
    fetchHostelData();
  }

  Future<void> fetchHostelData() async {
    if (_useruid == null) {
      print('User UID is null');
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels.json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data != null) {
          List<Map<String, dynamic>> loadedHostels = [];
          data.forEach((key, value) {
            if (value['useruid'] == _useruid) {
              // Handling rooms as a list
              List<Map<String, dynamic>> roomsList = [];
              if (value['rooms'] is List) {
                roomsList = List<Map<String, dynamic>>.from(
                    value['rooms'].map((room) => {
                          'room_number':
                              room['room_number'] ?? 'No room number',
                          'available_seats':
                              room['available_seats'] ?? 'No available seats',
                          'occupied_seats':
                              room['occupied_seats'] ?? 'No occupied seats',
                          'images': List<String>.from(room['images'] ?? []),
                          'price_per_seat':
                              room['price_per_seat'] ?? 'No price per seat',
                          'room_type': room['room_type'] ?? 'No room type',
                          'Washroom_type':
                              room['Washroom_type'] ?? 'No Washroom type',
                        }));
              }

              loadedHostels.add({
                'id': key,
                'hostel_name': value['hostel_name'] ?? 'No name',
                'hostel_address': value['hostel_address'] ?? 'No address',
                'hostel_contact': value['hostel_contact'] ?? 'No contact',
                'hostel_owner': value['hostel_owner'] ?? 'No owner',
                'owner_email': value['owner_email'] ?? 'No owner email',
                'gender': value['gender'] ?? 'No gender',
                'Mess_Price': value['Mess_Price'] ?? 'No Mess_Price',
                'booking_type': value['booking_type'] ?? 'No booking type',
                'amenities': value['amenities'] ?? [],
                'image_url': value['image_url'] ?? '',
                'price': value['price'] ?? 'No price',
                'room_images': value['room_images'] ?? [],
                'breakfast_menu': value['breakfast_menu'] ?? {},
                'lunch_menu': value['lunch_menu'] ?? {},
                'dinner_menu': value['dinner_menu'] ?? {},
                'rooms': roomsList,
              });
            }
          });

          setState(() {
            _hostels = loadedHostels;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: const Text(
            'Are you sure you want to delete this hostel?',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteHostel(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHostel(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels/$id.json'),
      );
      if (response.statusCode == 200) {
        fetchHostelData(); // Refresh the data after deletion
      } else {
        throw Exception('Failed to delete hostel');
      }
    } catch (e) {
      print('Error deleting hostel: $e');
    }
  }

  void _showEditDialog(Map<String, dynamic> hostel) {
    showDialog(
      context: context,
      builder: (context) =>
          EditHostelDialog(hostel: hostel, onUpdate: fetchHostelData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'User Data',
      ),
      endDrawer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            height: 60,
            child: Drawer(
              width: 210,
              child: Container(
                color: Colors.teal, // Set background color to white
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Limit height to content size
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.supervised_user_circle_rounded,
                        color: Colors.white,
                      ),
                      title: const Text("Booking Details"),
                      onTap: () {
                        Navigator.of(context).pop();
                        // Navigate to settings or any other screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const BookingUserDetails()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _hostels.isEmpty
          ? const Center(child: Text('No data available'))
          : ListView.builder(
              itemCount: _hostels.length,
              itemBuilder: (context, index) {
                var hostel = _hostels[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hostel['image_url'] !=
                            '') // Check if image URL is available
                          ClipOval(
                            child: Image.network(
                              hostel['image_url'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          hostel['hostel_name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildRoomImagesAndMenus(hostel),
                        const SizedBox(height: 10),
                        _buildAmenitiesCard(hostel['amenities']),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:5.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => HostelBookingsScreen(
                                        hostelId: hostel['hostel_name'],
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal, // Background color
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero, // Border radius set to 0
                                  ),
                                ),
                                child: const Text("All Bookings",style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(hostel),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _confirmDelete(
                                        context,
                                        hostel[
                                            'id']); // Show the confirmation dialog before deleting
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCustomDrawer() {
    return Container(
      height: 100, // Limit the height to 100sp
      margin: const EdgeInsets.only(
          left: 50), // Position it closer to the right like a drawer
      decoration: const BoxDecoration(
        color: Colors.white, // Background color of the drawer
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              // Navigate to settings or any other screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BookingUserDetails()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard(dynamic amenities) {
    List<String> amenitiesList;

    if (amenities is List) {
      amenitiesList = List<String>.from(amenities);
    } else if (amenities is String) {
      amenitiesList = amenities.split(', ');
    } else {
      amenitiesList = [];
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amenities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50, // Adjust the height as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: amenitiesList.map((amenity) {
                    return Container(
                      margin: const EdgeInsets.only(
                          right: 16), // Spacing between items
                      child: AmenityIcon(amenity: amenity),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomImagesAndMenus(Map<String, dynamic> hostel) {
    return Row(
      children: [
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoomListScreen(hostelId: hostel['id'], hostelName: hostel['hostel_name'],),
                  ),
                );
              },
              child: Container(
                color: Colors.teal,
                child: const ListTile(
                  title: Text(
                    'View Rooms & Images',
                    style: TextStyle(
                      color: Colors.white, // Text color when tapped
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuDetailScreen(
                      breakfastMenu:
                          Map<String, String>.from(hostel['breakfast_menu']),
                      lunchMenu: Map<String, String>.from(hostel['lunch_menu']),
                      dinnerMenu:
                          Map<String, String>.from(hostel['dinner_menu']),
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.teal,
                child: const ListTile(
                  title: Text(
                    'View Menus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
