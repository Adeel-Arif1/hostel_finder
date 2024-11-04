import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hostelfinder/Custom/Appbar.dart';

class HostelBookingsScreen extends StatefulWidget {
  final String hostelId;

  HostelBookingsScreen({super.key, required this.hostelId});

  @override
  _HostelBookingsScreenState createState() => _HostelBookingsScreenState();
}

class _HostelBookingsScreenState extends State<HostelBookingsScreen> {
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref("bookings");
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void _initializeNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String hostelName, String cnicNumber) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_deletion_channel',
      'Booking Deletion Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Booking Deleted',
      'Your booking at $hostelName has been deleted due to full occupancy.',
      platformChannelSpecifics,
    );
  }

  // Function to delete a specific bookingreha
  void _deleteBooking(
      String bookingId, String hostelName, String cnicNumber) async {
    try {
      await databaseRef.child(bookingId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
      await _showNotification(hostelName, cnicNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete booking: $e')),
      );
    }
  }

  void deleteBookingByDetails(String userUid, String hostelName,
      String roomNumber, String cnicNumber) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    // Query to find the booking based on userUid
    databaseReference
        .child("room_bookings")
        .orderByChild("user_ID")
        .equalTo(userUid)
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> bookings =
            snapshot.value as Map<dynamic, dynamic>;

        bookings.forEach((key, value) {
          // Check if hostel_name, room_ID, and cnic_number match
          if (value['hostel_name'] == hostelName &&
              value['room_ID'] == roomNumber &&
              value['cnic_number'] == cnicNumber) {
            // Match found, delete the booking
            databaseReference
                .child("room_bookings")
                .child(key)
                .remove()
                .then((_) {
              print("Booking deleted successfully.");
            }).catchError((error) {
              print("Failed to delete booking: $error");
            });
          }
        });
      } else {
        print("No booking found for the given details.");
      }
    }).catchError((error) {
      print("Error retrieving bookings: $error");
    });
  }

  // Function to update booking status to 'Paid'
  Future<void> _markAsPaid(String bookingId) async {
    try {
      await databaseRef.child(bookingId).update({
        'status': 'Confirmed', // Update the status to 'Paid'
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking marked as Paid')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark booking as Paid: $e')),
      );
    }
  }

  // Function to show confirmation dialog before marking as paid
  Future<void> _showConfirmDialog(String bookingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: const Text('Are you sure this person has paid the amount?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _markAsPaid(bookingId); // Mark the booking as Paid
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Booking Details"),
      body: StreamBuilder(
        stream: databaseRef
            .orderByChild('hostel_name')
            .equalTo(widget.hostelId)
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('No bookings found'));
            }

            Map<dynamic, dynamic> bookingsMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            List<MapEntry<dynamic, dynamic>> bookingsList =
                bookingsMap.entries.toList();

            return ListView.builder(
              itemCount: bookingsList.length,
              itemBuilder: (context, index) {
                var bookingEntry = bookingsList[index];
                var booking = bookingEntry.value;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: booking['status'] == 'Confirmed'
                        ? Colors.green
                        : Colors.red, // Change color based on status
                    child: ListTile(
                      title: Text(
                        "Hostel Name: ${booking['hostel_name']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Name: ${booking['First name']} ${booking['Last name']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Booking Type: ${booking['booking_type']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "CNIC: ${booking['cnic_number']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Room Number: ${booking['room_number']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Status: ${booking['status']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Conditionally show the "Paid" button only if the status is not "Confirmed"
                              if (booking['status'] != 'Confirmed')
                                ElevatedButton(
                                  onPressed: () {
                                    _showConfirmDialog(bookingEntry
                                        .key); // Show confirmation dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("Paid"),
                                ),
                              const SizedBox(width: 100),
                              Container(
                                height: 40,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteBooking(
                                        bookingEntry.key,
                                        booking['hostel_name'],
                                        booking['cnic_number']);
                                    deleteBookingByDetails(
                                      booking['user_uid'],
                                      booking['hostel_name'],
                                      booking['room_number'],
                                      booking['cnic_number'],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
