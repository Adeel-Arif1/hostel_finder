import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:hostelfinder/Elevatedbutton.dart';
import 'package:hostelfinder/booking/bookingconformation.dart';
import 'package:hostelfinder/hosteldetailscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final String hostelName;
  final String hostelId;
  final List<String> roomNumbers;
  final String hostelIds;

  const BookingScreen({
    super.key,
    required this.hostelName,
    required this.hostelId,
    required this.roomNumbers,
    required this.hostelIds,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController =
      TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ownerNameController =
      TextEditingController(); // Controller for Owner's Name
  DateTime? _checkInDate;

  final databaseReference = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _selectedRoomNum;
  String? _selectedBookingType;
  String? _selectedMessOption;
  List<String> _availableRooms = [];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _initializeLocalNotifications();
    _loadAvailableRooms();
  }

  void _initializeFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? 'You have a new message',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification taps
    });
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _localNotifications.initialize(initializationSettings);
  }

  Future<void> _showOwnerNotification(String newUser) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'owner_channel_id',
      'Owner Notifications',
      channelDescription:
          'Notifications for hostel owner when a new booking occurs',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      'New Booking Notification',
      '$newUser has booked your hostel!',
      platformChannelSpecifics,
    );
  }

  Future<void> _showUserConfirmationNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'user_channel_id',
      'User Notifications',
      channelDescription: 'Notifications for user booking confirmation',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      1,
      'Booking Confirmation',
      'Your booking is confirmed!',
      platformChannelSpecifics,
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_channel_id',
      'Booking Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Future<void> _showbookingConfirmationotification() async {
  //   await _showNotification("Booking Confirmed",
  //       "Your booking at ${widget.hostelName} is confirmed.");
  // }

  Future<void> _loadAvailableRooms() async {
    try {
      final snapshot = await databaseReference
          .child('hostels')
          .child(widget.hostelId)
          .child('rooms')
          .get();
      if (snapshot.exists) {
        List<String> rooms = [];
        for (var room in snapshot.children) {
          final roomNum = room.key;
          if (roomNum != null && room.value == true) {
            // assuming value 'true' means the room is available
            rooms.add(roomNum);
          }
        }
        setState(() {
          _availableRooms = rooms;
        });
      }
    } catch (e) {
      print('Error loading rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load available rooms.')),
      );
    }
  }

  Future<void> _saveBookingInfo() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    try {
      final userUid = await _getUserUid();
      if (userUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User UID not found.')),
        );
        return;
      }

      // Fetch existing bookings
      final existingBookings = await databaseReference
          .child('bookings')
          .orderByChild("user_uid")
          .equalTo(userUid)
          .once();

      bool hasPendingBooking = false;
      int cancelledCount = 0; // Track the number of cancelled bookings
      DateTime now = DateTime.now();

      if (existingBookings.snapshot.exists) {
        for (var booking in existingBookings.snapshot.children) {
          DateTime bookingDate =
              DateTime.parse(booking.child('booking_date').value as String);
          String bookingStatus = booking.child('status').value as String;
          String paymentStatus =
              booking.child('payment_status').value as String;

          // Count cancellations
          if (bookingStatus == 'cancelled') {
            cancelledCount++;
          }

          // Check for pending bookings
          if (bookingStatus == 'pending' && paymentStatus == 'unpaid') {
            if (now.isBefore(bookingDate.add(Duration(days: 7)))) {
              hasPendingBooking = true;
            } else {
              // Cancel the booking if it's pending for too long
              await booking.ref.update(
                  {'status': 'cancelled', 'payment_status': 'cancelled'});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Your previous booking was canceled due to non-payment.')),
              );
            }
          }
        }
      }

      // Check cancellation count
      if (cancelledCount >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'You cannot make more bookings after two cancellations.')),
        );
        return; // Prevent further bookings after two cancellations
      }

      // Check for pending bookings
      if (hasPendingBooking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'You have a pending booking. Complete the booking or wait until it is canceled before making a new one.')),
        );
        return;
      }

      // Create a New Booking
      final newBookingRef = databaseReference.child('bookings').push();
      await newBookingRef.set({
        "hostel_name": widget.hostelName,
        "hostel_id": widget.hostelId,
        "room_number": _selectedRoomNum,
        "booking_type": _selectedBookingType,
        "mess_option": _selectedMessOption,
        "First name": _firstnameController.text,
        "Last name": _lastnameController.text,
        "address": _addressController.text,
        "mobile_number": _mobileNumberController.text,
        "guardian_name": _guardianNameController.text,
        "guardian_phone": _guardianPhoneController.text,
        "cnic_number": _cnicController.text,
        "profession": _professionController.text,
        "email": _emailController.text,
        "owner_name": _ownerNameController.text,
        "check_in_date": _checkInDate?.toIso8601String(),
        "user_uid": userUid,
        "booking_date": DateTime.now().toIso8601String(),
        "status": "pending",
        "payment_status": "unpaid",
      }).then((value) {
        databaseReference.child("room_bookings").push().set({
          'room_ID': _selectedRoomNum,
          'user_ID': userUid,
          'hotel_ID': widget.hostelId,
          "hostel_name": widget.hostelName,
          "cnic_number": _cnicController.text,
        }).then((_) {
          print("Booking stored successfully.");
        }).catchError((error) {
          print("Failed to store booking: $error");
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully!')),
      );
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      String newUserName =
          _firstnameController.text + " " + _lastnameController.text;
      if (currentUserId == userUid) {
        await _showUserConfirmationNotification();
      } else {
        await _showOwnerNotification(newUserName);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            hostelName: widget.hostelName,
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HostelDetailScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      print('Error saving booking info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save booking information.')),
      );
    }
  }

  Future<String?> _getUserUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  bool _validateForm() {
    String mobileNumber = _mobileNumberController.text;
    String email = _emailController.text;
    String cnic = _cnicController.text;

    return _firstnameController.text.isNotEmpty &&
        _lastnameController.text.isNotEmpty &&
        _guardianNameController.text.isNotEmpty &&
        _mobileNumberController.text.isNotEmpty &&
        _guardianPhoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _selectedRoomNum != null &&
        _selectedBookingType != null &&
        _selectedMessOption != null &&
        _checkInDate != null &&
        _professionController.text.isNotEmpty &&
        _ownerNameController.text.isNotEmpty; // Validate owner name
    // RegExp(r'^\d{11}$').hasMatch(mobileNumber) &&
    // RegExp(r'^\d{13}$').hasMatch(cnic) && // CNIC number must be 13 digits
    // RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z]+\.[a-zA-Z]+')
    //     .hasMatch(email); // Basic email validation
  }

  Future<void> _pickCheckInDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _checkInDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("roomNumbers ${widget.roomNumbers}");
    print("hostelIds ${widget.hostelIds}");
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Book Hostel',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.hostelName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Firstname',
                _firstnameController,
              ),
              _buildTextField('Lastname', _lastnameController),
              _buildTextField(
                'Mobile Number',
                _mobileNumberController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField('CNIC Number', _cnicController,
                  keyboardType: TextInputType.number),
              _buildTextField('Address', _addressController),
              _buildTextField('Email', _emailController,
                  keyboardType: TextInputType.emailAddress),
              _buildTextField('Profession', _professionController),
              _buildTextField('Guardian Name', _guardianNameController),
              _buildTextField('Guardian Phone Number', _guardianPhoneController,
                  keyboardType: TextInputType.phone),
              _buildRoomNumberTextField(widget.roomNumbers),
              TextField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name', // Label for Owner's Name
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildBookingTypeSelection(),
              _buildMessOptionSelection(),
              _buildCheckInDatePicker(),
              const SizedBox(height: 40),
              CustomLoadingButton(
                label: 'Save',
                onPressed: _saveBookingInfo,
                // This should be your async function for login
                buttonColor: Colors.teal, // Set the button color to teal
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomNumberTextField(List<String> roomNumbers) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: _selectedRoomNum),
        decoration: InputDecoration(
          labelText: 'Room Number',
          labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          border: const OutlineInputBorder(),
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Get the current room number index
                    int currentIndex =
                        roomNumbers.indexOf(_selectedRoomNum ?? roomNumbers[0]);

                    // Check if next room number exists
                    if (currentIndex < roomNumbers.length - 1) {
                      _selectedRoomNum = roomNumbers[currentIndex + 1];
                    }
                  });
                },
                child: const Icon(
                  Icons.arrow_drop_up,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Get the current room number index
                    int currentIndex =
                        roomNumbers.indexOf(_selectedRoomNum ?? roomNumbers[0]);

                    // Check if previous room number exists
                    if (currentIndex > 0) {
                      _selectedRoomNum = roomNumbers[currentIndex - 1];
                    }
                  });
                },
                child: const Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildBookingTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking For:',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
        _buildBookingTypeRadio('One Day'),
        _buildBookingTypeRadio('Weekly'),
        _buildBookingTypeRadio('Monthly'),
      ],
    );
  }

  Widget _buildMessOptionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mess Option:',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
        _buildMessOptionRadio('With Mess'),
        _buildMessOptionRadio('Without Mess'),
      ],
    );
  }

  Widget _buildMessOptionRadio(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(fontStyle: FontStyle.italic)),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedMessOption,
        onChanged: (String? newValue) {
          setState(() {
            _selectedMessOption = newValue;
          });
        },
      ),
    );
  }

  Widget _buildBookingTypeRadio(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(fontStyle: FontStyle.italic)),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedBookingType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedBookingType = newValue;
          });
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCheckInDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _checkInDate == null
                  ? 'Check-in Date'
                  : 'Check-in Date: ${_checkInDate?.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickCheckInDate,
          ),
        ],
      ),
    );
  }
}
