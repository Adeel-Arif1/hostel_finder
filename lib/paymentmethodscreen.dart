import 'package:flutter/material.dart';

// Adjust the import according to your project structure
import 'package:hostelfinder/booking/bookingscreen.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final String hostelName;
  final Map<String, String> paymentMethods;
  final List<String> roomNumbers;
  final String hostelId;

  PaymentDetailsScreen(
      {super.key,
      required this.hostelName,
      required this.paymentMethods,
      required this.roomNumbers,
      required this.hostelId}) {
    print('PaymentDetailsScreen Initialized with: $paymentMethods');
  }

  @override
  Widget build(BuildContext context) {
    print('Building PaymentDetailsScreen with: $paymentMethods');
    print('roomNumbers: $roomNumbers');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Add a light, subtle gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                // Add an image or icon to make the screen more lively
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Icon(
                    Icons.home_work,
                    color: Colors.teal,
                    size: 100, // Large decorative icon
                  ),
                ),
                Text(
                  hostelName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                    height:
                        24), // Add spacing between the title and payment options
                ...paymentMethods.entries.map((entry) {
                  print('Processing entry: ${entry.key} -> ${entry.value}');

                  if (entry.value.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the BookingScreen with the selected payment method
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              hostelName: hostelName,
                              hostelId: entry.value,
                              roomNumbers: roomNumbers,
                              hostelIds: hostelId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8, // Subtle shadow to lift the card
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center text horizontally
                            children: [
                              // Add an icon for the payment method
                              Icon(
                                Icons.payment,
                                color: Colors.teal.shade800,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade900,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Returns an empty widget if value is empty
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
