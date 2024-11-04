import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hostelfinder/Custom/hostelscolors.dart';
import 'package:hostelfinder/filterdilogscreen.dart';
import 'package:hostelfinder/hosteldetailscreen.dart';
import 'package:hostelfinder/sortingdilogscreen.dart';

class AllHostelscardscreen extends StatefulWidget {
  final List<Map<String, dynamic>> hostels;

  const AllHostelscardscreen({super.key, required this.hostels});

  @override
  _AllHostelscardscreenState createState() => _AllHostelscardscreenState();
}

class _AllHostelscardscreenState extends State<AllHostelscardscreen> {
  List<Map<String, dynamic>> filteredHostels = [];
  List<Map<String, dynamic>> _hostels = [];

  String selectedSortingOption = 'None';
  Map<String, dynamic> selectedFilters = {};

  @override
  void initState() {
    super.initState();
    filteredHostels = widget.hostels;
    _hostels = widget.hostels; // Initialize _hostels
  }

  void _showSortingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SortingOptionsDialog(
            onApply: (option) {
              setState(() {
                selectedSortingOption = option;
                _applyFiltersAndSorting();
              });
            },
          ),
        );
      },
    );
  }

  void _showFiltersOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: FilterOptionsDialog(
            onApply: (filters) {
              setState(() {
                selectedFilters = filters;
                _applyFiltersAndSorting();
              });
            },
          ),
        );
      },
    );
  }

  void _applyFiltersAndSorting() {
    List<Map<String, dynamic>> tempHostels = widget.hostels.where((hostel) {
      bool matches = true;

      // Check gender
      if (selectedFilters['gender'] != null &&
          hostel['gender'] != selectedFilters['gender']) {
        matches = false;
      }

      // Check booking type
      if (selectedFilters['bookingType'] != null) {
        var bookingTypes = selectedFilters['bookingType'];
        if (bookingTypes is String) {
          bookingTypes = [bookingTypes];
        }
        List<String> selectedBookingTypes = bookingTypes.cast<String>();

        List<String> hostelBookingTypes = hostel['booking_type'] is List
            ? hostel['booking_type'].cast<String>()
            : [hostel['booking_type']];
        if (!selectedBookingTypes
            .any((type) => hostelBookingTypes.contains(type))) {
          matches = false;
        }
      }

      // Check amenities
      if (selectedFilters['amenities'] != null) {
        var amenities = selectedFilters['amenities'];
        if (amenities is String) {
          amenities = [amenities];
        }
        List<String> selectedAmenities = amenities.cast<String>();

        List<String> hostelAmenities = hostel['amenities'] is List
            ? hostel['amenities'].cast<String>()
            : [hostel['amenities']];
        if (!selectedAmenities
            .any((amenity) => hostelAmenities.contains(amenity))) {
          matches = false;
        }
      }

      return matches;
    }).toList();

    _applySorting(tempHostels, selectedSortingOption);

    setState(() {
      filteredHostels = tempHostels;
    });
  }

  void _applySorting(
      List<Map<String, dynamic>> tempHostels, String selectedSortingOption) {
    // Convert prices to double
    for (var hostel in tempHostels) {
      try {
        hostel['price'] = double.parse(hostel['price'].toString());
      } catch (e) {
        hostel['price'] = 0.0; // Set to default value if parsing fails
      }
    }

    // Check if tempHostels list is not empty
    if (tempHostels.isEmpty) {
      print('No hostels available to sort');
      return;
    }

    // Sort hostels based on the selected sorting option
    if (selectedSortingOption == 'Price Low to High') {
      tempHostels.sort(
          (a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else if (selectedSortingOption == 'Price High to Low') {
      tempHostels.sort(
          (a, b) => (b['price'] as double).compareTo(a['price'] as double));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEmptyFilteredHostels =
        filteredHostels.isEmpty && selectedFilters.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Hostels',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showFiltersOptions(context),
                  icon: const Icon(Icons.filter_list,
                      color: Colors.white), // Icon color white
                  label: const Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.white, // Font color white
                      fontStyle: FontStyle.italic, // Italic text
                      fontWeight: FontWeight.bold, // Bold text
                      fontSize: 16, // Adjust font size as needed
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.teal, // Button background color teal
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showSortingOptions(context),
                  icon: const Icon(Icons.sort,
                      color: Colors.white), // Icon color white
                  label: const Text(
                    'Sort',
                    style: TextStyle(
                      color: Colors.white, // Font color white
                      fontStyle: FontStyle.italic, // Italic text
                      fontWeight: FontWeight.bold, // Bold text
                      fontSize: 16, // Adjust font size as needed
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.teal, // Button background color teal
                  ),
                ),
              ],
            ),
          ),
          if (isEmptyFilteredHostels)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No hostels match the applied filters.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic, // Italic text
                  color: Colors
                      .black, // Color for "No hostels match the applied filters."
                ),
              ),
            )
          else if (widget.hostels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No hostels available.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic, // Italic text
                  color: Colors.black, // Color for "No hostels available."
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHostels.isNotEmpty
                  ? filteredHostels.length
                  : widget.hostels.length,
              itemBuilder: (context, index) {
                var hostel = filteredHostels.isNotEmpty
                    ? filteredHostels[index]
                    : widget.hostels[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(const HostelDetailScreen(), arguments: hostel);
                  },
                  child: Card(
                      color: HostelColors
                          .cardColors[index % HostelColors.cardColors.length],
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hostel['hostel_name'] ?? 'No name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Address: ${hostel['hostel_location'] ?? 'No address'}',
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Mess Price: ${hostel['price'] ?? 'No price'}',
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Gender: ${hostel['gender'] ?? 'Not specified'}',
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Owner Email: ${hostel['owner_email'] ?? 'Not specified'}',
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Booking Type: ${hostel['booking_type']?.join(', ') ?? 'None'}', // Join list items with comma
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Amenities: ${hostel['amenities']?.join(', ') ?? 'None'}', // Join list items with comma
                              style: const TextStyle(
                                fontSize: 12, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    FontStyle.italic, // Italic and bold text
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
