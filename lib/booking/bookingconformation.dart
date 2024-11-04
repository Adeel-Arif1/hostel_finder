import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_sms/flutter_sms.dart';

class ConfirmationScreen extends StatelessWidget {
  final String hostelName;
  final VoidCallback onBack;

  const ConfirmationScreen({
    super.key,
    required this.hostelName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Call the function to send notifications and SMS
    _sendConfirmationNotifications();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Confirmation'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your booking at $hostelName has been successfully processed.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendConfirmationNotifications() async {
    // Retrieve FCM token for the current user
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      // Send FCM notification to the user
      _sendNotificationToUser(fcmToken);
    }

    // Send SMS message to the hostel owner
    _sendSmsToOwner();
  }

  void _sendNotificationToUser(String fcmToken) async {
    try {
      // Send a push notification via Firebase API (Firebase functions/server or other server side code)
      // Example payload for FCM notification (this code assumes a server is set up to handle FCM notifications)
      final notificationPayload = {
        "to": fcmToken,
        "notification": {
          "title": "Room Confirmation",
          "body": "Your room at $hostelName has been confirmed for rent."
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "hostelName": hostelName
        }
      };

      // Here, you would make an HTTP POST request to the FCM server.
      // For demo purposes, this code does not include actual HTTP code.
    } catch (error) {
      print("Failed to send notification: $error");
    }
  }

  void _sendSmsToOwner() async {
    try {
      String ownerPhoneNumber = "OwnerPhoneNumber"; // Replace with actual owner's phone number
      String message = "The room at $hostelName has been confirmed for rent.";

      await sendSMS(message: message, recipients: [ownerPhoneNumber]);
      print("SMS sent to owner");
    } catch (error) {
      print("Failed to send SMS to owner: $error");
    }
  }
}
