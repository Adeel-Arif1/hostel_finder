import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingUserDetails extends StatefulWidget {
  const BookingUserDetails({super.key});

  @override
  State<BookingUserDetails> createState() => _BookingUserDetailsState();
}

class _BookingUserDetailsState extends State<BookingUserDetails> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _bookingDataList = [];
  bool _isOwner = false;
  String? _identifier;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Inside the _loadBookings function:
  Future<void> _loadBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isOwner = prefs.getBool('is_owner') ?? false;
    _userRole = prefs.getString('user_role') ?? 'user';
    _identifier =
        _isOwner ? prefs.getString('owner_name') : prefs.getString('user_uid');

    if (_identifier != null) {
      await _fetchBookings(_isOwner, _identifier!);

      // Schedule auto-delete for each pending booking upon loading
      for (var booking in _bookingDataList) {
        if (booking['status'] == 'pending') {
          _scheduleAutoDelete(booking['booking_id']);
        }
      }
    } else {
      print("No identifier found");
    }
  }

  Future<void> _fetchBookings(bool isOwner, String identifier) async {
    try {
      DataSnapshot snapshot;

      if (isOwner) {
        snapshot = await _databaseReference
            .child('bookings')
            .orderByChild('owner_name')
            .equalTo(identifier)
            .once()
            .then((event) => event.snapshot);
      } else {
        snapshot = await _databaseReference
            .child('bookings')
            .orderByChild('user_uid')
            .equalTo(identifier)
            .once()
            .then((event) => event.snapshot);
      }

      if (snapshot.exists) {
        Map<dynamic, dynamic> bookingData =
            snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> bookings = [];

        bookingData.forEach((key, value) {
          final booking = Map<String, dynamic>.from(value);
          booking['booking_id'] = key; // Use Firebase key as booking_id
          bookings.add(booking);
        });

        setState(() {
          _bookingDataList = bookings;
        });
      } else {
        setState(() {
          _bookingDataList = [];
        });
      }
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  void _scheduleAutoDelete(String bookingId) {
    Timer(Duration(days: 7), () async {
      try {
        // Check if booking is still pending
        DataSnapshot snapshot = await _databaseReference
            .child('bookings')
            .child(bookingId)
            .child('status')
            .get();
        if (snapshot.value == 'pending') {
          await deleteBookingById(bookingId);
        }
      } catch (e) {
        print('Error during auto-delete: $e');
      }
    });
  }

  Future<void> deleteBookingById(String bookingId) async {
    try {
      await _databaseReference.child('bookings').child(bookingId).remove();
      await _loadBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pending booking automatically deleted')),
      );
    } catch (e) {
      print('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete booking')),
      );
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      await _databaseReference.child('bookings').child(bookingId).update({
        'status': 'confirmed',
      });
      await _loadBookings();
    } catch (e) {
      print('Error confirming booking: $e');
    }
  }

  Future<void> deleteBookingByCnic(String cnic) async {
    try {
      final bookingSnapshot = await _databaseReference
          .child('bookings')
          .orderByChild('cnic_number')
          .equalTo(cnic)
          .once();

      if (bookingSnapshot.snapshot.exists) {
        final bookingData = bookingSnapshot.snapshot.children.first.value
            as Map<dynamic, dynamic>;
        final bookingKey = bookingSnapshot.snapshot.children.first.key;

        await _databaseReference.child('bookings').child(bookingKey!).remove();
        await _loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No booking found for this CNIC')),
        );
      }
    } catch (e) {
      print('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete booking')),
      );
    }
  }

  Future<void> _updateBookingDetails(
      String bookingId, Map<String, dynamic> updatedData) async {
    try {
      await _databaseReference
          .child('bookings')
          .child(bookingId)
          .update(updatedData);
      await _loadBookings();
    } catch (e) {
      print('Error updating booking details: $e');
    }
  }

  void _showDeleteConfirmation(String cnic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await deleteBookingByCnic(cnic);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: "Booking Details"),
        body: _bookingDataList.isEmpty
            ? const Center(child: Text('No Booking Data Available'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _bookingDataList.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(_bookingDataList[index]);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildBookingCard(Map<dynamic, dynamic> bookingData) {
    bool isConfirmed = bookingData['status'] == 'confirmed';
    Color cardColor;

    // Change card color based on status
    if (bookingData['status'] == 'pending') {
      cardColor = Colors.red; // Set color to red for pending status
    } else if (isConfirmed) {
      cardColor = Colors.blue; // Set color to blue for confirmed status
    } else {
      cardColor = Colors.teal; // Default color for other statuses
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        height: 350,
        child: Card(
          color: cardColor,
          child: Column(
            children: [
              _buildHostelNameCard(bookingData),
              _buildBookingDetailsCard(bookingData),
              _buildActionRow(bookingData, isConfirmed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostelNameCard(Map<dynamic, dynamic> bookingData) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Card(
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              bookingData['hostel_name'] ?? 'Hostel Name',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(Map<dynamic, dynamic> bookingData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 400,
        child: Card(
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Name: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${bookingData['First name'] ?? 'N/A'} ${bookingData['Last name'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'CNIC: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '${bookingData['cnic_number'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Booking Type: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: bookingData['booking_type'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Room Number: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: bookingData['room_number'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Status: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: bookingData['status'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(Map<dynamic, dynamic> bookingData, bool isConfirmed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_isOwner && !isConfirmed) // Owner can confirm
          ElevatedButton(
            onPressed: () => confirmBooking(bookingData['booking_id']),
            child: const Text('Confirm Booking'),
          ),
        ElevatedButton(
          onPressed: () {
            _showDeleteConfirmation(bookingData['cnic_number']);
          },
          child: const Text('Delete Booking'),
        ),
      ],
    );
  }
}
