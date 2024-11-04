import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  final auth.User? user = auth.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userData['firstName'];
    _lastNameController.text = widget.userData['lastName'];
    _mobileNumberController.text = widget.userData['mobileNumber'];
    _loadProfileImage(); // Load existing profile image if available
  }

  Future<void> _loadProfileImage() async {
    // Get the profile image URL from userData
    String? profileImageUrl = widget.userData['profileImageUrl'];
    if (profileImageUrl != null) {
      setState(() {
        _imageFile = null; // Clear the local image file
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.userData['profileImageUrl'] != null
                              ? NetworkImage(widget.userData['profileImageUrl'])
                              : null),
                      child: _imageFile == null &&
                              widget.userData['profileImageUrl'] == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_imageFile != null) {
                          await _uploadImage();
                        }
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .update({
                            'firstName': _firstNameController.text.trim(),
                            'lastName': _lastNameController.text.trim(),
                            'mobileNumber':
                                _mobileNumberController.text.trim(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully')),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update profile')),
                          );
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

// class EditProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> userData;

//   EditProfileScreen({required this.userData});

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _mobileNumberController = TextEditingController();
//   File? _imageFile;
//   bool _isUploading = false;

//   final auth.User? user = auth.FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController.text = widget.userData['firstName'];
//     _lastNameController.text = widget.userData['lastName'];
//     _mobileNumberController.text = widget.userData['mobileNumber'];
//     // Load existing profile image if available
//     _loadProfileImage();
//   }

//   Future<void> _loadProfileImage() async {
//     // Get the profile image URL from userData
//     String? profileImageUrl = widget.userData['profileImageUrl'];
//     if (profileImageUrl != null) {
//       setState(() {
//         _imageFile = null; // Clear the local image file
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_imageFile == null || user == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       String filePath = 'profile_images/${user!.uid}.jpg';
//       final storageRef = FirebaseStorage.instance.ref().child(filePath);
//       await storageRef.putFile(_imageFile!);

//       String downloadUrl = await storageRef.getDownloadURL();
//       await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
//         'profileImageUrl': downloadUrl,
//       });

//       setState(() {
//         _isUploading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Profile image updated successfully')),
//       );
//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to upload image')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile',
//         style: TextStyle(
//       fontStyle: FontStyle.italic, 
//       fontWeight: FontWeight.bold,
//     ),),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage: _imageFile != null
//                         ? FileImage(_imageFile!)
//                         : (widget.userData['profileImageUrl'] != null
//                             ? NetworkImage(widget.userData['profileImageUrl'])
//                             : null),
//                     child: _imageFile == null && widget.userData['profileImageUrl'] == null
//                         ? Icon(Icons.person, size: 60, color: Colors.grey)
//                         : null,
//                   ),
//                   if (_isUploading)
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Icon(
//                       Icons.camera_alt,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _firstNameController,
//               decoration: InputDecoration(labelText: 'First Name'),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: _lastNameController,
//               decoration: InputDecoration(labelText: 'Last Name'),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: _mobileNumberController,
//               decoration: InputDecoration(labelText: 'Mobile Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_imageFile != null) {
//                   await _uploadImage();
//                 }
//                 try {
//                   await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
//                     'firstName': _firstNameController.text.trim(),
//                     'lastName': _lastNameController.text.trim(),
//                     'mobileNumber': _mobileNumberController.text.trim(),
//                   });

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Profile updated successfully')),
//                   );

//                   Navigator.pop(context);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to update profile')),
//                   );
//                 }
//               },
//               child: Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


