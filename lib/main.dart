import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hostelfinder/routescreen.dart';

import 'booking/bookingscreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDEEa1HXMh7j5WC45czZdcblofs5c_A6-4",
        appId: "1:646387180448:android:2f5d3bfa5ef23f26b0fac5",
        messagingSenderId: "646387180448",
        databaseURL: "https://hostelfinder-8c017-default-rtdb.firebaseio.com",
        projectId: "hostelfinder-8c017",
        storageBucket: "hostelfinder-8c017.appspot.com",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.teal, // Set the status bar color to teal
    statusBarIconBrightness: Brightness.light, // Set icon brightness to light
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
     initialRoute: Routescreen.splash,
      getPages: Routescreen.pages,
      //  home: BookingScreen(hostelId: '', hostelName: '', roomNumbers: [], hostelIds: '',),
    );
  }
}
//BookingScreen




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hostelfinder/form_screen.dart';
// import 'package:hostelfinder/routescreen.dart';
// import 'package:hostelfinder/splash_screen.dart';
// import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:hostelfinder/shareprefrence.dart';
// import 'package:flutter/services.dart';

// void main() async {
//   print('Initializing Firebase...');
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//     statusBarColor: Colors.teal, // Set the status bar color to teal
//     statusBarIconBrightness: Brightness.light, // Optional: Set icon brightness
//   ));


//   try {
//     await WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp(
//       options: FirebaseOptions(
//         apiKey: "AIzaSyDEEa1HXMh7j5WC45czZdcblofs5c_A6-4",
//         appId: "1:646387180448:android:2f5d3bfa5ef23f26b0fac5",
//         messagingSenderId: "646387180448",
//         databaseURL: "https://hostelfinder-8c017-default-rtdb.firebaseio.com",
//         projectId: "hostelfinder-8c017",
//         storageBucket: "hostelfinder-8c017.appspot.com",
//       ),
//     );
//     print('Firebase initialized successfully');
//   } catch (e) {
//     print('Failed to initialize Firebase: $e');
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(

//         debugShowCheckedModeBanner: false,
//         initialRoute: Routescreen.splash,
//          getPages: Routescreen.pages);
//   }
// }
