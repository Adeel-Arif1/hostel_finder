import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hostelfinder/routescreen.dart';
import 'package:hostelfinder/shareprefrence.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    String? userUid = await SharedPreferencesHelper.getUserUid();
    // If userUid is available, navigate to dashboard; otherwise, show splash screens
    if (userUid != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, Routescreen.dashboard);
      });
    } else {
      // Start splash screen sequence
      _startSplashSequence();
    }
  }

  void _startSplashSequence() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
        // Navigate to the login screen after the last splash screen
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, Routescreen.login);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildPageContent(Icons.house, 'Find Your Perfect Hostel'),
              _buildPageContent(Icons.search, 'Connect with Hostels'),
              _buildPageContent(Icons.location_on, 'Find Hostels Nearby'),
            ],
          ),

          // Page indicators
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Number of pages
                (index) => _buildPageIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 100.0,
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: _currentPage == index ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}


// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:hostelfinder/routescreen.dart';
// import 'package:hostelfinder/shareprefrence.dart';

// class Splashscreen extends StatefulWidget {
//   const Splashscreen({super.key});

//   @override
//   _SplashscreenState createState() => _SplashscreenState();
// }

// class _SplashscreenState extends State<Splashscreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _checkUserStatus();
//   }

//   Future<void> _checkUserStatus() async {
//     String? userUid = await SharedPreferencesHelper.getUserUid();
//     // If userUid is available, navigate to home; otherwise, show splash screen
//     if (userUid != null) {
//       // Navigate directly to home if userUid exists
//       Future.delayed(Duration.zero, () {
//         Navigator.pushReplacementNamed(context, Routescreen.dashboard);
//       });
//     } else {
//       // Start splash screen sequence
//       _startSplashSequence();
//     }
//   }

//   void _startSplashSequence() {
//     // Timer to auto-navigate to the next page after 2 seconds
//     _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
//       if (_currentPage < 2) {
//         _currentPage++;
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//         );
//       } else {
//         _timer.cancel();
//         Navigator.pushReplacementNamed(context, Routescreen.login);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal,
//       body: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: (int page) {
//               setState(() {
//                 _currentPage = page;
//               });
//             },
//             children: [
//               _buildPageContent(Icons.house, 'Find Your Perfect Hostel'),
//               _buildPageContent(Icons.search, 'Connect with Hostels'),
//               _buildPageContent(Icons.location_on, 'Find Hostels Nearby'),
//             ],
//           ),

//           // Page indicators
//           Positioned(
//             bottom: 10,
//             left: MediaQuery.of(context).size.width / 2 - 30,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 3, // Number of pages
//                 (index) => _buildPageIndicator(index),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPageContent(IconData icon, String text) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//   
//        Icon(
//             icon,
//             color: Colors.white,
//             size: 100.0,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             text,
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPageIndicator(int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//       width: _currentPage == index ? 12.0 : 8.0,
//       height: _currentPage == index ? 12.0 : 8.0,
//       decoration: BoxDecoration(
//         color: _currentPage == index
//             ? Colors.white
//             : Colors.white.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//     );
//   }
// }