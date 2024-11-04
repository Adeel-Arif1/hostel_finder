import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   FavoriteScreen({super.key});

  Future<void> _toggleFavorite(String docId) async {
    // Remove the hostel from the Firestore 'favorites' collection
    await _firestore.collection('favorites').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
         leading: const BackButton(),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('favorites').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteHostels = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteHostels.length,
            itemBuilder: (context, index) {
              final data = favoriteHostels[index];
              final docId = data.id; // Document ID for this favorite hostel
              final name = data['hostel_name'];
              final image = data['image_url'];
              final owner = data['hostel_owner'];
              final address = data['hostel_location'];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(image),
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontStyle: FontStyle.italic, // Italic style for hostel name
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Owner: $owner',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontStyle: FontStyle.italic, // Italic style for owner
                        ),
                      ),
                      Text(
                        'Location: $address',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontStyle: FontStyle.italic, // Italic style for location
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red, // Red if it's a favorite
                    ),
                    onPressed: () {
                      // Call the toggle favorite function to unfavorite the hostel
                      _toggleFavorite(docId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
