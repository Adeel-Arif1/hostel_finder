import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:hostelfinder/editprofilescreen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth.User? user = auth.FirebaseAuth.instance.currentUser;
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String filePath = 'profile_images/${user!.uid}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      await storageRef.putFile(_imageFile!);

      String downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'profileImageUrl': downloadUrl,
      });

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> _logout() async {
    if (user != null) {
      try {
        // Delete user from Firebase Auth
        await user!.delete();

        // Optionally, delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .delete();

        // Sign out of Firebase Auth
        await auth.FirebaseAuth.instance.signOut();

        // Navigate to login or welcome screen
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool confirmLogout = await _showLogoutDialog();
              if (confirmLogout) {
                _logout();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String? profileImageUrl = userData['profileImageUrl'];
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';
          String email = userData['email'] ?? '';
          String mobileNumber = userData['mobileNumber'] ?? '';

          String fullName = '$firstName $lastName';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null),
                        child: _imageFile == null && profileImageUrl == null
                            ? const Icon(Icons.person,
                                size: 80, color: Colors.grey)
                            : null,
                      ),
                      if (_isUploading)
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.teal,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.teal,
                    fontStyle: FontStyle.italic, // Italic style for email
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic, // Italic style for name
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mobileNumber.length == 11 ? mobileNumber : 'Invalid number',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.teal,
                    fontStyle:
                        FontStyle.italic, // Italic style for mobile number
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(userData: userData)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontStyle: FontStyle.italic, // Italic style for the title
                ),
              ),
              content: const Text(
                'Are you sure you want to delete your account and log out? This action cannot be undone.',
                style: TextStyle(
                  fontStyle: FontStyle.italic, // Italic style for the message
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
