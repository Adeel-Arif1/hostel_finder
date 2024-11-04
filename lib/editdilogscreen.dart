import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/aminities_icons.dart';
import 'package:hostelfinder/Custom/textfield.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditHostelDialog extends StatefulWidget {
  final Map<String, dynamic> hostel;
  final VoidCallback onUpdate;

  const EditHostelDialog(
      {super.key, required this.hostel, required this.onUpdate});

  @override
  _EditHostelDialogState createState() => _EditHostelDialogState();
}

class _EditHostelDialogState extends State<EditHostelDialog> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;
  late TextEditingController _ownerController;
  late TextEditingController _owneremailController;
  late TextEditingController _genderController;
  late TextEditingController _priceController;
  late TextEditingController _menuController;

  late String _imageUrl;
  late Map<String, String> _breakfastMenu;
  late Map<String, String> _lunchMenu;
  late Map<String, String> _dinnerMenu;

  late List<Map<String, dynamic>> _rooms =
      []; // Initialize _rooms as an empty list

  final Map<String, TextEditingController> _breakfastControllers = {};
  final Map<String, TextEditingController> _lunchControllers = {};
  final Map<String, TextEditingController> _dinnerControllers = {};

  final String url =
      "https://hostelfinder-8c017-default-rtdb.firebaseio.com/hostels";

  final List<String> _bookingTypes = ['Daily', 'Weekly', 'Monthly'];
  List<String> _selectedBookingTypes = [];
  List<String> _selectedAmenities = [];
  final Map<String, IconData> amenitiesIcons = {
    'WiFi': Icons.wifi,
    'Filter Water': Icons.filter,
    'Security': Icons.security,
    'Laundry': Icons.local_laundry_service,
    'Kitchen': Icons.kitchen,
    'Air Conditioning': Icons.ac_unit,
  };

  @override
  void initState() {
    super.initState();
    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Initialize controllers and fill them with the respective menu data
    for (var day in daysOfWeek) {
      _breakfastControllers[day] = TextEditingController(
          text: widget.hostel['breakfast_menu'][day] ?? '');
      _lunchControllers[day] =
          TextEditingController(text: widget.hostel['lunch_menu'][day] ?? '');
      _dinnerControllers[day] =
          TextEditingController(text: widget.hostel['dinner_menu'][day] ?? '');
    }

    _nameController = TextEditingController(text: widget.hostel['hostel_name']);
    _locationController =
        TextEditingController(text: widget.hostel['hostel_address']);
    _contactController =
        TextEditingController(text: widget.hostel['hostel_contact']);
    _ownerController =
        TextEditingController(text: widget.hostel['hostel_owner']);
    _owneremailController =
        TextEditingController(text: widget.hostel['owner_email']);
    _genderController = TextEditingController(text: widget.hostel['gender']);
    _priceController = TextEditingController(text: widget.hostel['Mess_Price']);
    _menuController = TextEditingController(text: widget.hostel['menu']);
    _selectedBookingTypes =
        List<String>.from(widget.hostel['booking_type'] ?? []);
    _selectedAmenities = List<String>.from(widget.hostel['amenities'] ?? []);
    _imageUrl = widget.hostel['image_url'] ?? '';

    _breakfastMenu =
        Map<String, String>.from(widget.hostel['breakfast_menu'] ?? {});
    _lunchMenu = Map<String, String>.from(widget.hostel['lunch_menu'] ?? {});
    _dinnerMenu = Map<String, String>.from(widget.hostel['dinner_menu'] ?? {});

    // Initialize _rooms if it's provided in the hostel data
    _rooms = List<Map<String, dynamic>>.from(widget.hostel['rooms'] ?? []);
  }

  Future<void> _updateHostel() async {
    // Prepare updated data
    final updatedHostel = {
      'hostel_name': _nameController.text,
      'hostel_address': _locationController.text,
      'hostel_contact': _contactController.text,
      'hostel_owner': _ownerController.text,
      'owner_email': _owneremailController.text,
      'gender': _genderController.text,
      'Mess_Price': _priceController.text,
      'booking_type': _selectedBookingTypes,
      'amenities': _selectedAmenities,
      'menu': _menuController.text,
      'image_url': _imageUrl,
      'breakfast_menu': _breakfastMenu,
      'lunch_menu': _lunchMenu,
      'dinner_menu': _dinnerMenu,
      'rooms': _rooms, // Ensure rooms is passed correctly here
    };

    final response = await http.patch(
      Uri.parse('$url/${widget.hostel['id']}.json'),
      body: json.encode(updatedHostel),
    );

    // Check response
    if (response.statusCode != 200) {
      throw Exception('Failed to update hostel: ${response.body}');
    }

    Navigator.of(context).pop();
    widget.onUpdate(); // Call callback to refresh data
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('hostel_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    }
  }

  Widget _buildMenuSection(
      String title,
      Map<String, String> menu,
      Map<String, TextEditingController> controllers,
      void Function(String day, String menu) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        ...menu.keys.map((day) {
          // Check if the controller for this day exists
          if (!controllers.containsKey(day)) {
            controllers[day] = TextEditingController(text: menu[day] ?? '');
          }
          return _buildMenuItem(day, controllers[day]!, onUpdate);
        }).toList(),
      ],
    );
  }

  Widget _buildMenuItem(String day, TextEditingController controller,
      void Function(String day, String menu) onUpdate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day label
          Text(
            day,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          // Menu text field
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Menu',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.left,
              onChanged: (newValue) {
                onUpdate(day, newValue); // Trigger the update callback
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxListTile(
      String title, bool value, void Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildRoomSection(List<Map<String, dynamic>> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
        ...rooms.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> room = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: TextEditingController(
                        text: room['room_number']?.toString() ?? ''),
                    labelText: 'Room Number',
                    isNumeric: true,
                    onChanged: (newValue) {
                      room['room_number'] = int.tryParse(newValue) ?? 0;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  CustomTextField(
                    controller: TextEditingController(
                        text: room['available_seats']?.toString() ?? ''),
                    labelText: 'Available Seats',
                    isNumeric: true,
                    onChanged: (newValue) {
                      room['available_seats'] = int.tryParse(newValue) ?? 0;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: TextEditingController(
                        text: room['occupied_seats']?.toString() ?? ''),
                    labelText: 'Occupied Seats',
                    isNumeric: true,
                    onChanged: (newValue) {
                      room['occupied_seats'] = int.tryParse(newValue) ?? 0;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: TextEditingController(
                        text: room['price_per_seat']?.toString() ?? ''),
                    labelText: 'Price per Seat',
                    isNumeric: true,
                    onChanged: (newValue) {
                      room['price_per_seat'] = int.tryParse(newValue) ?? 0;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Room Type
                  const Text('Room Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      RadioListTile<String>(
                        title: const Text('1-Seater'),
                        value: '1-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('2-Seater'),
                        value: '2-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('3-Seater'),
                        value: '3-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('4-Seater'),
                        value: '4-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('5-Seater'),
                        value: '5-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('6-Seater'),
                        value: '6-Seater',
                        groupValue: room['room_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['room_type'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Bathroom Type
                  const Text('Washroom Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      RadioListTile<String>(
                        title: const Text('Attached'),
                        value: 'Attached',
                        groupValue: room['Washroom_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['Washroom_type'] = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Common'),
                        value: 'Common',
                        groupValue: room['Washroom_type'],
                        onChanged: (String? value) {
                          setState(() {
                            room['Washroom_type'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Display images with click functionality
                  if (room['images'] != null &&
                      (room['images'] as List<dynamic>).isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          (room['images'] as List<dynamic>).map((imageUrl) {
                        return GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (pickedFile != null) {
                              final file = File(pickedFile.path);
                              final ref = FirebaseStorage.instance
                                  .ref()
                                  .child('hostel_images')
                                  .child(
                                      '${DateTime.now().toIso8601String()}.jpg');
                              await ref.putFile(file);
                              final newUrl = await ref.getDownloadURL();
                              setState(() {
                                final indexToReplace =
                                    (room['images'] as List<dynamic>)
                                        .indexOf(imageUrl);
                                if (indexToReplace != -1) {
                                  room['images'][indexToReplace] = newUrl;
                                }
                              });
                            }
                          },
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (pickedFile != null) {
                            final file = File(pickedFile.path);
                            final ref = FirebaseStorage.instance
                                .ref()
                                .child('hostel_images')
                                .child(
                                    '${DateTime.now().toIso8601String()}.jpg');
                            await ref.putFile(file);
                            final url = await ref.getDownloadURL();
                            setState(() {
                              room['images'] = room['images'] ?? [];
                              room['images'].add(url);
                            });
                          }
                        },
                        child: const Text('Add Image'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            rooms.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(
          onPressed: () {
            setState(() {
              rooms.add({
                'room_number': '',
                'available_seats': '',
                'occupied_seats': '',
                'price': '',
                'room_type': '',
                'Washroom_type': '',
                'images': [],
              });
            });
          },
          child: const Text('Add Room'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'Edit Hostel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload
            Center(
              child: Column(
                children: [
                  ClipOval(
                    child: _imageUrl.isNotEmpty
                        ? Image.network(_imageUrl,
                            height: 100, width: 100, fit: BoxFit.cover)
                        : Container(
                            height: 100, width: 100, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _selectImage,
                    child: const Text('Upload Image'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _nameController,
              labelText: 'Hostel Name',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _ownerController,
              labelText: 'Hostel Owner',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _locationController,
              labelText: 'Hostel Address',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _owneremailController,
              labelText: 'Owner Email',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _genderController,
              labelText: 'Gender',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _contactController,
              labelText: 'Hostel Contact',
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: _priceController,
              labelText: 'Mess Price',
              isNumeric: true,
            ),

            const SizedBox(height: 10),
            const Text(
              'Booking Types',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            Wrap(
              children: _bookingTypes.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _selectedBookingTypes.contains(type),
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedBookingTypes.add(type);
                      } else {
                        _selectedBookingTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Amenities
            // Amenities
            const Text(
              'Amenities',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Column(
              children: amenitiesIcons.keys.map((amenity) {
                return Row(
                  children: [
                    AmenityIcon(amenity: amenity),
                    Checkbox(
                      value: _selectedAmenities.contains(amenity),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected ?? false) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Menu Sections
            _buildMenuSection(
                'Breakfast Menu', _breakfastMenu, _breakfastControllers,
                (day, menu) {
              setState(() {
                _breakfastMenu[day] = menu;
              });
            }),
            const SizedBox(height: 10),

            _buildMenuSection('Lunch Menu', _lunchMenu, _lunchControllers,
                (day, menu) {
              setState(() {
                _lunchMenu[day] = menu;
              });
            }),
            const SizedBox(height: 10),

            _buildMenuSection('Dinner Menu', _dinnerMenu, _dinnerControllers,
                (day, menu) {
              setState(() {
                _dinnerMenu[day] = menu;
              });
            }),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            _buildRoomSection(_rooms),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _updateHostel,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
