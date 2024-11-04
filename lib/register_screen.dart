import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:hostelfinder/Custom/Appbar.dart';
import 'package:hostelfinder/Custom/elevatedbutton.dart';
import 'package:hostelfinder/Custom/textfield.dart';
import 'package:hostelfinder/routescreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final bool _isObscure = true;
  bool _loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'mobileNumber': mobileNumberController.text.trim(),
        'email': emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered')),
      );

      Navigator.pushNamed(context, Routescreen.login);
    } on auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Register'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Create your account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Custom Text Fields Usage
            CustomTextField(
              controller: firstNameController,
              labelText: 'First Name',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: lastNameController,
              labelText: 'Last Name',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: mobileNumberController,
              labelText: 'Mobile Number',
              isNumeric: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              isNumeric: false, // Since it's an email
            ),
            const SizedBox(height: 20),

            // Custom Password Field for Password
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              isPassword: true, // Enable password toggle
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              isPassword: true, // Enable password toggle
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Loading Button
            _loading
                ? const CircularProgressIndicator()
                : CustomLoadingButton(
                    label: 'Register',
                    onPressed: _register,
                    buttonColor: Colors.blue,
                  ),
          ],
        ),
      ),
    );
  }
}
