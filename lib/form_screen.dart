import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:hostelfinder/Custom/elevatedbutton.dart';
import 'package:hostelfinder/Custom/textfield.dart';
import 'package:hostelfinder/routescreen.dart';
import 'package:hostelfinder/shareprefrence.dart';
import 'package:image_picker/image_picker.dart';

class Formscreen extends StatefulWidget {
  const Formscreen({super.key});

  @override
  _FormscreenState createState() => _FormscreenState();
}

class _FormscreenState extends State<Formscreen> {
  final TextEditingController _hostelnameController = TextEditingController();
  final TextEditingController _hostelownerController = TextEditingController();
  final TextEditingController _owneremailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<TextEditingController> _breakfastControllers =
      List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> _lunchControllers =
      List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> _dinnerControllers =
      List.generate(7, (_) => TextEditingController());

  final List<RoomDetail> _rooms = [];
  String selectedGender = "";
  List<String> selectedAmenities = [];
  List<String> selectedBookingTypes = [];
  File? _imageFile;

  final picker = ImagePicker();
  final databaseReference = FirebaseDatabase.instance.ref();
  final storageReference = FirebaseStorage.instance.ref();
  final bool _isLoading = false;

  final _contactNumberRegExp = RegExp(r'^\d{11}$');
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _pageNotifier.value = _pageController.page?.round() ?? 0;
    });
    _addRoom(); // Initially add one room
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  //hostel iamge
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _getGalleryImage,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Make the container circular
          color: Colors.grey[300],
          image: _imageFile != null
              ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imageFile == null
            ? Icon(
                Icons.add_a_photo,
                color: Colors.grey[700],
              )
            : null,
      ),
    );
  }

  bool _validateForm() {
    if (_hostelnameController.text.isEmpty ||
        _hostelownerController.text.isEmpty ||
        _owneremailController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _priceController.text.isEmpty ||
        selectedAmenities.isEmpty ||
        selectedBookingTypes.isEmpty ||
        _imageFile == null ||
        _breakfastControllers.any((controller) => controller.text.isEmpty) ||
        _lunchControllers.any((controller) => controller.text.isEmpty) ||
        _dinnerControllers.any((controller) => controller.text.isEmpty) ||
        _rooms.any((room) => !room.isComplete())) {
      return false;
    }
    if (!_contactNumberRegExp.hasMatch(_contactController.text)) {
      return false;
    }
    if (double.tryParse(_priceController.text) == null) {
      return false;
    }
    return true;
  }

  Future<void> _getGalleryImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image picked');
      }
    });
  }

  Future<List<String?>> _uploadRoomImages() async {
    List<String?> imageUrls = [];
    try {
      for (var room in _rooms) {
        for (var image in room.images) {
          final fileName = '${DateTime.now().toIso8601String()}_$room';
          final ref = storageReference.child('room_images/$fileName');
          await ref.putFile(image);
          final imageUrl = await ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }
    } catch (e) {
      print('Error uploading room images: $e');
    }
    return imageUrls;
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      final fileName = DateTime.now().toIso8601String();
      final ref = storageReference.child('images/$fileName');
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveData() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    final userUid = await SharedPreferencesHelper.getUserUid();
    print('User UID: $userUid');

    try {
      final imageUrl = await _uploadImage();
      final roomImageUrls = await _uploadRoomImages();
      final newRecordKey = databaseReference.child('hostels').push().key;
      final daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];

      final breakfastMenu = Map.fromIterables(
          daysOfWeek, _breakfastControllers.map((c) => c.text));
      final lunchMenu =
          Map.fromIterables(daysOfWeek, _lunchControllers.map((c) => c.text));
      final dinnerMenu =
          Map.fromIterables(daysOfWeek, _dinnerControllers.map((c) => c.text));

      await databaseReference.child('hostels/$newRecordKey').set({
        "hostel_name": _hostelnameController.text,
        "hostel_owner": _hostelownerController.text,
        "owner_email": _owneremailController.text,
        "hostel_address": _addressController.text,
        "hostel_contact": _contactController.text,
        "price": _priceController.text,
        "gender": selectedGender,
        "booking_type": selectedBookingTypes,
        "amenities": selectedAmenities,
        "useruid": userUid,
        "image_url": imageUrl,
        "breakfast_menu": breakfastMenu,
        "lunch_menu": lunchMenu,
        "dinner_menu": dinnerMenu,
        "room_images": roomImageUrls,
        "rooms": _rooms.map((room) => room.toMap()).toList(),
      });

      // Clear the form after saving
      _hostelnameController.clear();
      _hostelownerController.clear();
      _addressController.clear();
      _contactController.clear();
      _priceController.clear();

      setState(() {
        selectedAmenities.clear();
        selectedBookingTypes.clear();
        _imageFile = null;
        _rooms.clear();
        _addRoom();
        for (var c in _breakfastControllers) {
          c.clear();
        }
        for (var c in _lunchControllers) {
          c.clear();
        }
        for (var c in _dinnerControllers) {
          c.clear();
        }
      });

      Navigator.pushNamed(context, Routescreen.home);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void _addRoom() {
    setState(() {
      _rooms.add(RoomDetail(roomNumber: _rooms.length + 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Hostel Detail'),
      body: PageView(
        controller: _pageController,
        children: [
          _buildHostelDetailsPage(),
          _buildRoomImagesPage(),
          _buildMenuDetailsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

// bottom navigation bar next and prebious icon
  Widget _buildBottomNavigationBar() {
    return ValueListenableBuilder<int>(
      valueListenable: _pageNotifier,
      builder: (context, pageIndex, child) {
        return BottomAppBar(
          child: Row(
            children: [
              if (pageIndex >
                  0) // Show Previous button only if not on the first page
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.teal),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              const Spacer(),
              if (pageIndex <
                  2) // Show Next button only if not on the last page
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.teal),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHostelDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePicker(),
          const SizedBox(height: 16.0),
          _buildCard(
            title: 'Hostel Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Hostel Name', _hostelnameController),
                _buildTextField('Hostel Owner', _hostelownerController),
                _buildTextField('Owner Email', _owneremailController),
                _buildTextField('Address', _addressController),
                _buildTextField('Contact Number', _contactController,
                    keyboardType: TextInputType.phone),
                _buildTextField(' Mess_Price', _priceController,
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _buildCard(
            title: '',
            child: _buildGenderSelector(),
          ),
          const SizedBox(height: 16.0),
          _buildCard(
            title: '',
            child: _buildBookingTypeSelector(),
          ),
          const SizedBox(height: 16.0),
          _buildCard(
            title: '',
            child: _buildAmenitiesSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMenuFields(
            'Breakfast Menu',
            _breakfastControllers,
          ),
          const SizedBox(height: 16.0),
          _buildMenuFields('Lunch Menu', _lunchControllers),
          const SizedBox(height: 16.0),
          _buildMenuFields('Dinner Menu', _dinnerControllers),
          const SizedBox(height: 16.0),
          CustomLoadingButton(
            label: 'Save',
            onPressed:
                _saveData, // This should be your async function for login
            buttonColor: Colors.teal, // Set the button color to teal
          ),
        ],
      ),
    );
  }

  Widget _buildRoomImagesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          for (var room in _rooms) room.buildRoomDetailCard(context),
          ElevatedButton(
            onPressed: _addRoom,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Colors.teal), // Set background color to teal
            ),
            child: const Text(
              'Add Room',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuFields(
      String label, List<TextEditingController> controllers) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(7, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: daysOfWeek[index],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender'),
        RadioListTile(
          title: const Text('Male'),
          value: 'Male',
          groupValue: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value.toString();
            });
          },
        ),
        RadioListTile(
          title: const Text('Female'),
          value: 'Female',
          groupValue: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value.toString();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesSelector() {
    List<String> amenities = [
      'WiFi',
      'TV',
      'kitchen',
      'Filter Water',
      'Security',
      'Laundry',
      'Air Conditioning'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: amenities.map((amenity) {
            return FilterChip(
              label: Text(amenity),
              selected: selectedAmenities.contains(amenity),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedAmenities.add(amenity);
                  } else {
                    selectedAmenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingTypeSelector() {
    List<String> bookingTypes = ['One day', 'Weekly', 'Monthly'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Type',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: bookingTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: selectedBookingTypes.contains(type),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedBookingTypes.add(type);
                  } else {
                    selectedBookingTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RoomDetail {
  final int roomNumber;
  final TextEditingController availableSeatsController =
      TextEditingController();
  final TextEditingController occupiedSeatsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? roomType; // Variable for room type
  String? washroomtype; // Variable for bathroom type
  List<File> images = [];
  List<String> imageUrls = []; // List to store image URLs

  RoomDetail({required this.roomNumber});

  bool isComplete() {
    return availableSeatsController.text.isNotEmpty &&
        occupiedSeatsController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        roomType != null &&
        washroomtype != null &&
        imageUrls.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'room_number': roomNumber,
      'room_type': roomType,
      'Washroom_type': washroomtype,
      'images': imageUrls, // Save URLs instead of paths
      'available_seats': availableSeatsController.text,
      'occupied_seats': occupiedSeatsController.text,
      'price_per_seat': priceController.text,
    };
  }

  Future<void> _getRoomImages(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    // Upload images and get URLs
    imageUrls = await _uploadRoomImages();
  }

  Future<List<String>> _uploadRoomImages() async {
    List<String> imageUrls = [];
    try {
      for (var image in images) {
        final fileName = '${DateTime.now().toIso8601String()}_$roomNumber';
        final ref =
            FirebaseStorage.instance.ref().child('room_images/$fileName');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      print('Error uploading room images: $e');
    }
    return imageUrls;
  }

  Widget buildRoomDetailCard(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Number Section
                Center(
                  child: Text(
                    'Room $roomNumber',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1.5),
                const Text(
                  'Room Images:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    ...imageUrls.map((url) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(url, width: 50, height: 50),
                        )),
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: () => _getRoomImages(context),
                    ),
                  ],
                ),
                // Room Type Section
                const Text(
                  'Room Type:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('1-Seater'),
                      value: '1-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('2-Seater'),
                      value: '2-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('3-Seater'),
                      value: '3-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('4-Seater'),
                      value: '4-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('5-Seater'),
                      value: '5-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('6-Seater'),
                      value: '6-Seater',
                      groupValue: roomType,
                      onChanged: (String? value) {
                        setState(() {
                          roomType = value;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1.5),

                // Available Seats Section
                const SizedBox(height: 8.0),
                CustomTextField(
                  controller: availableSeatsController,
                  labelText: 'Enter available seats',
                  isNumeric: true,
                ),
                // TextField(
                //   controller: availableSeatsController,
                //   keyboardType: TextInputType.number,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     hintText: 'Enter available seats',
                //   ),
                // ),
                const SizedBox(height: 16.0),

                CustomTextField(
                  controller: occupiedSeatsController,
                  labelText: 'Enter Occupied seats',
                  isNumeric: true,
                ),
                const SizedBox(height: 8.0),
                CustomTextField(
                  controller: priceController,
                  labelText: 'Enter price_per_seat',
                  isNumeric: true,
                ),
                // Washroom Type Section
                const Text(
                  'Washroom Type:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Attached'),
                      value: 'Attached',
                      groupValue: washroomtype,
                      onChanged: (String? value) {
                        setState(() {
                          washroomtype = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Common'),
                      value: 'Common',
                      groupValue: washroomtype,
                      onChanged: (String? value) {
                        setState(() {
                          washroomtype = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
