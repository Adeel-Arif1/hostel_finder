import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hostelfinder/custombottomnavigationbar.dart';
import 'package:hostelfinder/favoritescreen.dart';
import 'package:hostelfinder/home_screen.dart';
import 'package:hostelfinder/profilescreen.dart';
import 'package:hostelfinder/routescreen.dart';
import 'package:hostelfinder/userdatascreen.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}

class DashboardScreen extends StatelessWidget {
  final BottomNavController bottomNavController =
      Get.put(BottomNavController());

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.teal, // Set the status bar color to teal
      statusBarIconBrightness:
          Brightness.light, // Optional: Set icon brightness
    ));

    return WillPopScope(
      onWillPop: () async {
        if (bottomNavController.currentIndex.value != 0) {
          bottomNavController.changeTabIndex(0);
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Obx(() {
            switch (bottomNavController.currentIndex.value) {
              case 0:
                return const Homescreen(); // Show Home Screen when index is 0
              case 1:
                return FavoriteScreen(); // Show Favorite Screen when index is 1
              case 2:
                // Index 2 is used for the floating action button, so if this index is selected, navigate to a different route
                return const SizedBox
                    .shrink(); // Placeholder screen for Add (or use any other screen you want)
              case 3:
                return const UserDataScreen(); // Show User Data Screen when index is 3
              case 4:
                return const ProfileScreen(); // Show Profile Screen when index is 4
              default:
                return const Homescreen(); // Default to Home Screen
            }
          }),
          bottomNavigationBar: Obx(() => CustomBottomNavigationBar(
                currentIndex: bottomNavController.currentIndex.value,
                onTap: (index) {
                  if (index == 2) {
                    // Index 2 is meant for the floating action button
                    Navigator.pushNamed(context, Routescreen.form);
                  } else {
                    bottomNavController.changeTabIndex(index);
                  }
                },
              )),
        ),
      ),
    );
  }
}
