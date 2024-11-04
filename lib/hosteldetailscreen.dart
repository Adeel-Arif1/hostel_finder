import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hostelfinder/Custom/aminities_icons.dart';
import 'package:hostelfinder/menuscreen.dart'; // Import the new screen
import 'package:hostelfinder/paymentmethodscreen.dart'; // Import the booking screen file
// Add this import for shared preferences
import 'package:hostelfinder/roomdetail.dart';
import 'package:hostelfinder/rulesdilog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HostelDetailScreen extends StatefulWidget {
  const HostelDetailScreen({super.key});

  @override
  _HostelDetailScreenState createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  final Map<String, dynamic> hostel = Get.arguments;
  bool _isFavorite = false;
  List<Map<String, dynamic>> _rooms = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId =
      'exampleUserId'; // Fetch current user ID if you have authentication

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final hostelDoc = await _firestore
          .collection('favorites')
          .doc(hostel['id']) // Using hostel ID to identify the favorite
          .get();

      setState(() {
        _isFavorite = hostelDoc.exists; // If document exists, it's a favorite
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final hostelData = {
      'hostel_name': hostel['hostel_name'],
      'image_url': hostel['image_url'],
      'hostel_owner': hostel['hostel_owner'],
      'hostel_location': hostel['hostel_location'],
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        // Add favorite to Firestore
        await _firestore
            .collection('favorites')
            .doc(hostel['id']) // Using hostel ID as the document ID
            .set(hostelData);
      } else {
        // Remove favorite from Firestore
        await _firestore
            .collection('favorites')
            .doc(hostel['id']) // Using hostel ID as the document ID
            .delete();
      }
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
  }

  void _navigateToRoomListScreen() async {
    final roomData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(hostelName: hostel['hostel_name'], hostelId: hostel['id'],),
      ),
    );

    if (roomData != null) {
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(roomData);
      });
    }
  }

  Future<List<String>> fetchRoomNumbers(String hostelId) async {
    const String url =
        "https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels.json";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> roomNumbers = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey(hostelId) && data[hostelId]['rooms'] is List) {
            for (var room in data[hostelId]['rooms']) {
              // Convert room number to String
              roomNumbers
                  .add(room['room_number'].toString() ?? 'No room number');
            }
          }
        }
        return roomNumbers;
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            hostel['hostel_name'] ?? 'Hostel Details',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: [
            // Hostel Image Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  if (hostel['image_url'] != null)
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        hostel['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.photo,
                                  size: 100, color: Colors.grey[700]),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.photo,
                            size: 100, color: Colors.grey[700]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
// Hostel Details Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner and Gender Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner: ${hostel['hostel_owner'] ?? 'No owner'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                                fontStyle: FontStyle.italic, // Italic text
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Gender: ${hostel['gender'] ?? 'No gender'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                                fontStyle: FontStyle.italic, // Italic text
                              ),
                            ),
                            Text(
                              '${hostel['owner_email'] ?? 'No email'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                                fontStyle: FontStyle.italic, // Italic text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Address, Contact, and Price Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Address: ${hostel['hostel_location'] ?? 'No address'}',
                                    //  hostel['hostel_location'] ?? 'No address',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold, // Bold text
                                      fontStyle:
                                          FontStyle.italic, // Italic text
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.map, color: Colors.blue),
                                  onPressed: () {
                                    final address = hostel['hostel_location'];
                                    if (address != null && address.isNotEmpty) {
                                      _launchMap(context, address);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Address is not available'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Contact: ${hostel['hostel_contact'] ?? 'No contact'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold, // Bold text
                                      fontStyle:
                                          FontStyle.italic, // Italic text
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.call,
                                      color: Colors.green),
                                  onPressed: () {
                                    final contact = hostel['hostel_contact'];
                                    if (contact != null && contact is String) {
                                      _launchCaller(context, contact);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Invalid contact number'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Mess Price: ${hostel['price'] ?? 'No price'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Bold text
                                fontStyle: FontStyle.italic, // Italic text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amenities Card
                    Card(
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
                                fontWeight: FontWeight.bold, // Bold text
                                fontStyle: FontStyle.italic, // Italic text
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildAmenitiesList(hostel['amenities']),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Room Details Card
                    GestureDetector(
                      onTap: _navigateToRoomListScreen,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'View Room & Images',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold, // For bold text
                              fontStyle: FontStyle.italic, // For italic text
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuDetailScreen(
                              breakfastMenu:
                                  _parseMenu(hostel['breakfast_menu']),
                              lunchMenu: _parseMenu(hostel['lunch_menu']),
                              dinnerMenu: _parseMenu(hostel['dinner_menu']),
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.menu_book, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'View Menu',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold, // For bold text
                              fontStyle: FontStyle.italic, // For italic text
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Show Rules Dialog Button
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => RulesDialog(
                              //rules: hostel['rules'] ?? 'No rules available',
                              ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'View Rules',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold, // For bold text
                              fontStyle: FontStyle.italic, // For italic text
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Book Now Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold, // For bold text
                              fontStyle: FontStyle.italic, // For italic text
                            ),
                          ),
                          onPressed: () async {
                            List<String> roomNumbers =
                                await fetchRoomNumbers(hostel['id']);

                            final paymentMethods = <String, String>{
                              'Cash':
                                  hostel['cash']?.toString() ?? 'Check-in time',
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentDetailsScreen(
                                  hostelName:
                                      hostel['hostel_name']?.toString() ??
                                          'Unknown Hostel',
                                  paymentMethods: paymentMethods,
                                  roomNumbers: roomNumbers,
                                  hostelId: hostel['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  Map<String, String> _parseMenu(dynamic menuData) {
    if (menuData == null) {
      return {};
    } else if (menuData is Map<String, dynamic>) {
      return Map<String, String>.from(menuData);
    } else if (menuData is String) {
      final map = <String, String>{};
      menuData.split(', ').forEach((item) {
        final keyValue = item.split(': ');
        if (keyValue.length == 2) {
          map[keyValue[0]] = keyValue[1];
        }
      });
      return map;
    } else {
      return {};
    }
  }

  Widget _buildAmenitiesList(dynamic amenities) {
    List<String> amenitiesList;

    if (amenities is List) {
      amenitiesList = List<String>.from(amenities);
    } else if (amenities is String) {
      amenitiesList = amenities.split(', ');
    } else {
      amenitiesList = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: amenitiesList.map((amenity) {
        // Use the AmenityIcon widget here
        return AmenityIcon(amenity: amenity);
      }).toList(),
    );
  }

  void _launchMap(BuildContext context, String address) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _launchCaller(BuildContext context, String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not place call')),
      );
    }
  }
}
