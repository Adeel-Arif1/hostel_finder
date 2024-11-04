import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hostelfinder/Custom/hostelscolors.dart';
import 'package:hostelfinder/allhostelcardscreen.dart';
import 'package:hostelfinder/hosteldetailscreen.dart';
import 'package:http/http.dart' as http;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final String url =
      "https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels.json";
  List<Map<String, dynamic>> _hostels = [];
  List<Map<String, dynamic>> _originalHostels = []; // Store the original list

  final TextEditingController _searchController = TextEditingController();
  final List<String> messages = [
    "Welcome to Hostel Finder!",
    "Discover the best hostels around you.",
    "Find your perfect stay now!",
    "Explore hostels with amazing amenities.",
  ];

  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchHostelData();
    _startMessageRotation();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchHostelData() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(
            'Response data: ${response.body}'); // Print response body for debugging
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          List<Map<String, dynamic>> loadedHostels = [];

          data.forEach((key, value) {
            try {
              // Debug print for the hostel data
              print('Processing hostel key: $key');
              print('Hostel value: $value');

              final hostelData = {
                'id': key,
                'hostel_name': value['hostel_name'] ?? 'No name',
                'hostel_location': value['hostel_address'] ?? 'No address',
                'hostel_contact': value['hostel_contact'] ?? 'No contact',
                'hostel_owner': value['hostel_owner'] ?? 'No owner',
                'owner_email': value['owner_email'] ?? 'No owner email',
                'gender': value['gender'] ?? 'No gender',
                'Mess_Price': value['Mess_price'] ?? 'No Mess_Price',
                'booking_type': value['booking_type'] is List
                    ? (value['booking_type'] as List)
                        .map((item) => item.toString())
                        .toList()
                    : ['No booking type'],
                'amenities': value['amenities'] is List
                    ? (value['amenities'] as List)
                        .map((item) => item.toString())
                        .toList()
                    : ['No amenities'],
                'useruid': value['useruid'] ?? 'No useruid',
                'user_email': value['user_email'] ?? 'No user_email',
                'image_url': value['image_url'] ?? '',
                'price': value['price'] ?? 'No price',
                'breakfast_menu':
                    value['breakfast_menu'] ?? 'No breakfast menu',
                'lunch_menu': value['lunch_menu'] ?? 'No lunch menu',
                'dinner_menu': value['dinner_menu'] ?? 'No dinner menu',
                'room_images': value['room_images'] is List
                    ? (value['room_images'] as List)
                        .map((item) => item.toString())
                        .toList()
                    : ['No room images'],
                'rooms': value['rooms'] is Map
                    ? (value['rooms'] as Map).map((roomKey, roomValue) {
                        return MapEntry(
                          roomKey,
                          {
                            'room_number':
                                roomValue['room_number'] ?? 'No room number',
                            'available_seats': roomValue['available_seats'] ??
                                'No available seats',
                            'occupied_seats': roomValue['occupied_seats'] ??
                                'No occupied seats',
                            'price_per_seat': roomValue['price_per_seat'] ??
                                'No price per seat',
                            'room_type':
                                roomValue['room_type'] ?? 'No room type',
                            'Washroom_type': roomValue['Washroom_type'] ??
                                'No washroom type',
                            'images': roomValue['images'] is List
                                ? (roomValue['images'] as List)
                                    .map((item) => item.toString())
                                    .toList()
                                : ['No images'],
                          },
                        );
                      })
                    : {},
              };

              // Print processed hostel data
              print('Processed Hostel Data: $hostelData');
              loadedHostels.add(hostelData);
            } catch (e) {
              print('Error processing hostel data for key $key: $e');
            }
          });

          setState(() {
            _hostels = loadedHostels;
            _originalHostels = loadedHostels;
          });
        } else {
          print('Data is not a Map<String, dynamic>');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void filterHostels(String query) {
    if (query.isEmpty) {
      setState(() {
        _hostels =
            _originalHostels; // Reset to original list if search query is empty
      });
      return;
    }

    List<Map<String, dynamic>> searchList = _originalHostels.where((hostel) {
      final name = hostel['hostel_name'].toLowerCase();
      final address = hostel['hostel_location'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();

    setState(() {
      _hostels = searchList;
    });
  }

  void _startMessageRotation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pageController.animateToPage(
        (_currentIndex + 1) % messages.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex = (_currentIndex + 1) % messages.length;
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures the view resizes when the keyboard appears
      appBar: AppBar(
        title: const Text(
          'Hostel Finder',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        // LayoutBuilder to handle responsiveness
        builder: (context, constraints) {
          return SingleChildScrollView(
            // SingleChildScrollView to avoid overflow
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight, // Ensures the body takes full height
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(16), // Padding for search bar
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          filterHostels(value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                30.0), // Rounded search bar
                          ),
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              filterHostels('');
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // PageView for the slider messages
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade100,
                              Colors.teal.shade300
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Text(
                                messages[index],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(2, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(AllHostelscardscreen(hostels: _hostels));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors
                                    .teal, // Background color for the button
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.list,
                                      size: 24, color: Colors.white), // Icon
                                  SizedBox(
                                      width:
                                          8), // Spacing between icon and text
                                  Text(
                                    'View More',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _hostels.isEmpty
                          ? const Center(child: Text('No data available'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _hostels.map((hostel) {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        const HostelDetailScreen(),
                                        arguments: hostel,
                                      );
                                    },
                                    child: Container(
                                      width: 180,
                                      height: 200,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 5),
                                      child: Card(
                                        color: HostelColors.cardColors[
                                            _hostels.indexOf(hostel) %
                                                HostelColors.cardColors.length],
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: hostel[
                                                            'image_url'] !=
                                                        ''
                                                    ? NetworkImage(
                                                        hostel['image_url'])
                                                    : const AssetImage(
                                                            'assets/default_image.png')
                                                        as ImageProvider,
                                                radius:
                                                    30, // Smaller avatar size
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                hostel['hostel_name'],
                                                style: const TextStyle(
                                                  fontSize:
                                                      16, // Font size for title
                                                  fontWeight: FontWeight
                                                      .bold, // Bold text
                                                  fontStyle: FontStyle
                                                      .italic, // Italic style
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis, // Handle overflow with ellipsis
                                                maxLines:
                                                    1, // Limit to a single line
                                              ),
                                              const SizedBox(height: 1),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Address: ${hostel['hostel_location']}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      'Contact: ${hostel['hostel_contact']}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      'Owner: ${hostel['hostel_owner']}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
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
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}





// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:hostelfinder/hosteldetailscreen.dart';
// import 'package:hostelfinder/allhostelcardscreen.dart';
// import 'package:hostelfinder/Custom/hostelscolors.dart';

// class Homescreen extends StatefulWidget {
//   const Homescreen({super.key});

//   @override
//   State<Homescreen> createState() => _HomescreenState();
// }

// class _HomescreenState extends State<Homescreen> {
//   final String url = "https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels.json";
//   List<Map<String, dynamic>> _hostels = [];
//   List<Map<String, dynamic>> _originalHostels = []; // Store the original list

//   final TextEditingController _searchController = TextEditingController();
//   final List<String> messages = [
//     "Welcome to Hostel Finder!",
//     "Discover the best hostels around you.",
//     "Find your perfect stay now!",
//     "Explore hostels with amazing amenities.",
//   ];

//   final PageController _pageController = PageController();
//   late Timer _timer;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchHostelData();
//     _startMessageRotation();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
// Future<void> fetchHostelData() async {
//   try {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       print('Response data: ${response.body}'); // Print response body for debugging
//       final data = json.decode(response.body);

//       if (data is Map<String, dynamic>) {
//         List<Map<String, dynamic>> loadedHostels = [];

//         data.forEach((key, value) {
//           try {
//             // Debug print for the hostel data
//             print('Processing hostel key: $key');
//             print('Hostel value: $value');

//             final hostelData = {
//               'id': key,
//               'hostel_name': value['hostel_name'] ?? 'No name',
//               'hostel_location': value['hostel_address'] ?? 'No address',
//               'hostel_contact': value['hostel_contact'] ?? 'No contact',
//               'hostel_owner': value['hostel_owner'] ?? 'No owner',
//               'owner_email': value['owner_email'] ?? 'No owner email',
//               'gender': value['gender'] ?? 'No gender',
//               'Mess_Price': value['Mess_price'] ?? 'No Mess_Price',
//               'booking_type': value['booking_type'] is List
//                 ? (value['booking_type'] as List).map((item) => item.toString()).toList()
//                 : ['No booking type'],
//               'amenities': value['amenities'] is List
//                 ? (value['amenities'] as List).map((item) => item.toString()).toList()
//                 : ['No amenities'],
//               'useruid': value['useruid'] ?? 'No useruid',
//               'user_email': value['user_email'] ?? 'No user_email',
//               'image_url': value['image_url'] ?? '',
//               'price': value['price'] ?? 'No price',
//               'breakfast_menu': value['breakfast_menu'] ?? 'No breakfast menu',
//               'lunch_menu': value['lunch_menu'] ?? 'No lunch menu',
//               'dinner_menu': value['dinner_menu'] ?? 'No dinner menu',
//               'room_images': value['room_images'] is List
//                 ? (value['room_images'] as List).map((item) => item.toString()).toList()
//                 : ['No room images'],
//                 'rooms': value['rooms'] is Map
//         ? (value['rooms'] as Map).map((roomKey, roomValue) {
//             return MapEntry(
//               roomKey,
//               {
//                 'room_number': roomValue['room_number'] ?? 'No room number',
//                 'available_seats': roomValue['available_seats'] ?? 'No available seats',
//                 'occupied_seats': roomValue['occupied_seats'] ?? 'No occupied seats',
//                 'price_per_seat': roomValue['price_per_seat'] ?? 'No price per seat',
//                 'room_type': roomValue['room_type'] ?? 'No room type',
//                 'Washroom_type': roomValue['Washroom_type'] ?? 'No washroom type',
//                 'images': roomValue['images'] is List
//                     ? (roomValue['images'] as List).map((item) => item.toString()).toList()
//                     : ['No images'],
//               },
//             );
//           })
//         : {},
//             };

//             // Print processed hostel data
//             print('Processed Hostel Data: $hostelData');
//             loadedHostels.add(hostelData);
//           } catch (e) {
//             print('Error processing hostel data for key $key: $e');
//           }
//         });

//         setState(() {
//           _hostels = loadedHostels;
//           _originalHostels = loadedHostels;
//         });
//       } else {
//         print('Data is not a Map<String, dynamic>');
//       }
//     } else {
//       print('Failed to load data. Status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error fetching data: $e');
//   }
// }


//   void filterHostels(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         _hostels = _originalHostels; // Reset to original list if search query is empty
//       });
//       return;
//     }

//     List<Map<String, dynamic>> searchList = _originalHostels.where((hostel) {
//       final name = hostel['hostel_name'].toLowerCase();
//       final address = hostel['hostel_location'].toLowerCase();
//       final searchQuery = query.toLowerCase();
//       return name.contains(searchQuery) || address.contains(searchQuery);
//     }).toList();

//     setState(() {
//       _hostels = searchList;
//     });
//   }

//   void _startMessageRotation() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       _pageController.animateToPage(
//         (_currentIndex + 1) % messages.length,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//       setState(() {
//         _currentIndex = (_currentIndex + 1) % messages.length;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold( 
//        resizeToAvoidBottomInset: true,
//        appBar: AppBar(
//         title: const Text(
//           'Hostel finder',
//            style: TextStyle(
//       fontStyle: FontStyle.italic, 
//       fontWeight: FontWeight.bold,
//     ),
//       ),
//         backgroundColor: Colors.teal,
//       ),
//       body: Column(
//         children: [
//           Padding(
//   padding: const EdgeInsets.all(16), // Padding for search bar
//   child: TextField(
//     controller: _searchController,
//     onChanged: (value) {
//       filterHostels(value);
//     },
//     decoration: InputDecoration(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.0), // Increased border radius for round corners
//       ),
//       hintText: 'Search',
//       prefixIcon: const Icon(Icons.search),
//       suffixIcon: IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           _searchController.clear();
//           filterHostels('');
//         },
//       ),
//     ),
//   ),
// ),
// const SizedBox(
//   height: 15,
// ),
// // page view builder means sylider that show the different text on screen
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding on the left and right sides
//   child: Container(
//     height: 150, 
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [Colors.teal.shade100, Colors.teal.shade300],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.2),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: PageView.builder(
//       controller: _pageController,
//       itemCount: messages.length,
//       itemBuilder: (context, index) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           alignment: Alignment.center,
//           child: Text(
//             messages[index],
//             style: TextStyle(
//               fontSize: 24,
//                fontStyle: FontStyle.italic, 
//               fontWeight: FontWeight.bold,
//               color: Colors.teal.shade900,
//               shadows: [
//                 Shadow(
//                   color: Colors.black.withOpacity(0.5),
//                   offset: const Offset(2, 2),
//                   blurRadius: 6,
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         );
//       },
//     ),
//   ),
// ),
//           const SizedBox(height: 10,),
//   Padding(
//   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       GestureDetector(
//         onTap: () {
//           Get.to(AllHostelscardscreen(hostels: _hostels));
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.teal, // Background color for the button
//             borderRadius: BorderRadius.circular(30), // Rounded corners
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: const Row(
//             children: [
//               Icon(Icons.list, size: 24, color: Colors.white), // Icon
//               SizedBox(width: 8), // Spacing between icon and text
//               Text(
//                 'View More',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // Text color
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// Expanded(
//   child: _hostels.isEmpty
//       ? const Center(child: Text('No data available'))
//       : SingleChildScrollView(
//           scrollDirection: Axis.horizontal, 
//           child: Row(
//             children: _hostels.map((hostel) {
//               return GestureDetector(
//                 onTap: () {
//                   Get.to(
//                     HostelDetailScreen(),
//                     arguments: hostel,
//                   );
//                 },
//                 child: Container(
//                   width: 180, // Adjust the width of each card
//                   height: 200, // Fixed height for the card
//                   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5), // Reduced margins
//                   child: Card(
//                     color: HostelColors.cardColors[_hostels.indexOf(hostel) % HostelColors.cardColors.length],
//                     child: Padding(
//                       padding: const EdgeInsets.all(8), // Adjust padding for compact size
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CircleAvatar(
//                             backgroundImage: hostel['image_url'] != ''
//                                 ? NetworkImage(hostel['image_url'])
//                                 : const AssetImage('assets/default_image.png') as ImageProvider,
//                             radius: 30, // Smaller avatar size
//                           ),
//                           const SizedBox(height: 1), // Space between avatar and text
//                           Text(
//                             hostel['hostel_name'],
//                             style: const TextStyle(
//                               fontSize: 16, // Font size for title
//                               fontWeight: FontWeight.bold, // Bold text
//                               fontStyle: FontStyle.italic, // Italic style
//                             ),
//                             overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
//                             maxLines: 1, // Limit to a single line
//                           ),
//                           const SizedBox(height: 1),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center, // Center align the content vertically
//                               children: [
//                                 Text(
//                                   'Address: ${hostel['hostel_location']}',
//                                   style: const TextStyle(
//                                     fontSize: 14, // Font size for details
//                                     fontWeight: FontWeight.bold, // Bold text
//                                     fontStyle: FontStyle.italic, // Italic style
//                                   ),
//                                   overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
//                                   maxLines: 1, // Limit to a single line
//                                 ),
//                                 const SizedBox(height: 1),
//                                 Text(
//                                   'Contact: ${hostel['hostel_contact']}',
//                                   style: const TextStyle(
//                                     fontSize: 14, // Font size for details
//                                     fontWeight: FontWeight.bold, // Bold text
//                                     fontStyle: FontStyle.italic, // Italic style
//                                   ),
//                                   overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
//                                   maxLines: 1, // Limit to a single line
//                                 ),
//                                 const SizedBox(height: 1),
//                                 Text(
//                                   'Owner: ${hostel['hostel_owner']}',
//                                   style: const TextStyle(
//                                     fontSize: 14, // Font size for details
//                                     fontWeight: FontWeight.bold, // Bold text
//                                     fontStyle: FontStyle.italic, // Italic style
//                                   ),
//                                   overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
//                                   maxLines: 1, // Limit to a single line
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
// ),

//         ],
//       ),
//     );
  
//   }
// }

