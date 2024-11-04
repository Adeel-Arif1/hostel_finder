import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hostelfinder/shareprefrence.dart';
import 'package:hostelfinder/routescreen.dart';
import 'package:hostelfinder/Custom/elevatedbutton.dart';
import 'package:hostelfinder/Custom/textfield.dart';
class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool loading = false;
  final bool _isObscure = false;
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passswordController = TextEditingController();
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    emailController.clear();
    passswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      try {
        final auth.UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passswordController.text.trim(),
        );
        if (userCredential.user != null) {
          await SharedPreferencesHelper.saveUserUid(userCredential.user!.uid);
        }
        Navigator.pushReplacementNamed(context, Routescreen.dashboard)
            .then((_) {
          emailController.clear();
          passswordController.clear();
          setState(() {
            loading = false;
          });
        });
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User not found. Register first.'),
              action: SnackBarAction(
                label: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, Routescreen.register);
                },
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong password.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}'),
            ),
          );
        }
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: true, // This is the default; you can set it to false if needed
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Center(
  //       child: SingleChildScrollView(
  //         padding: EdgeInsets.all(20.0),
  //         child: Form(
  //           key: _formkey,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Home away?',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Let\'s find your perfect stay!!!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20.0),
                CustomTextField(
  controller: emailController,
  labelText: 'Email',
  isNumeric: false, // for emails, this should be false
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Enter email';
    }
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  },
),
                const SizedBox(height: 20.0),
//                
CustomTextField(
  controller: passswordController,
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
                const SizedBox(height: 20.0),
              CustomLoadingButton(
              label: 'Sign In',
            onPressed: _login,  // This should be your async function for login
          buttonColor: Colors.blue, // Set the button color to teal
),

                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routescreen.password);
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routescreen.register);
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Made by Qudsia & Hadia',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}




// import 'package:flutter/material.dart';
// import 'package:hostelfinder/register_screen.dart';
// import 'package:hostelfinder/routescreen.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:hostelfinder/shareprefrence.dart';

// class Loginpage extends StatefulWidget {
//   @override
//   State createState() => _LoginpageState();
// }

// class _LoginpageState extends State<Loginpage> {
//   bool loading = false;
//   bool _isObscure = false;
//   final _formkey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passswordController = TextEditingController();
//   final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     emailController.clear();
//     passswordController.clear();
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20.0),
//           child: Form(
//             key: _formkey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'Login to your account',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.italic,
//                     fontSize: 18,
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 Text(
//                   'Home away?',
//                   style: TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontWeight: FontWeight.normal, // normal weight
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 Text(
//                   'Let\'s find your perfect stay!!!',
//                   style: TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontWeight: FontWeight.normal, // normal weight
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 TextFormField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     labelStyle: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     hintStyle: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Enter email';
//                     }
//                     final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20.0),
//                 TextFormField(
//                   controller: passswordController,
//                   obscureText: !_isObscure,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     prefixIcon: Icon(Icons.lock_open),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isObscure ? Icons.visibility : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isObscure = !_isObscure;
//                         });
//                       },
//                     ),
//                     labelStyle: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     hintStyle: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Enter password';
//                     } else if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20.0),
//                 ElevatedButton(
//                   onPressed: loading
//                       ? null
//                       : () async {
//                           if (_formkey.currentState!.validate()) {
//                             setState(() {
//                               loading = true;
//                             });
//                             try {
//                               final auth.UserCredential userCredential =
//                                   await _firebaseAuth.signInWithEmailAndPassword(
//                                 email: emailController.text.trim(),
//                                 password: passswordController.text.trim(),
//                               );
//                               if (userCredential.user != null) {
//                                 await SharedPreferencesHelper.saveUserUid(
//                                     userCredential.user!.uid);
//                               }
//                               Navigator.pushReplacementNamed(
//                                       context, Routescreen.dashboard)
//                                   .then((_) {
//                                 emailController.clear();
//                                 passswordController.clear();
//                                 setState(() {
//                                   loading = false;
//                                 });
//                               });
//                             } on auth.FirebaseAuthException catch (e) {
//                               if (e.code == 'user-not-found') {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                         'User not found. Register first.'),
//                                     action: SnackBarAction(
//                                       label: 'Register',
//                                       onPressed: () {
//                                         Navigator.pushNamed(
//                                             context, Routescreen.register);
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               } else if (e.code == 'wrong-password') {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('Wrong password.'),
//                                   ),
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('Error: ${e.message}'),
//                                   ),
//                                 );
//                               }
//                               setState(() {
//                                 loading = false;
//                               });
//                             }
//                           }
//                         },
//                   child: loading
//                       ? Column(
//                           children: [
//                             CircularProgressIndicator(color: Colors.white),
//                             SizedBox(height: 2),
//                           ],
//                         )
//                       : Text(
//                           'Sign In',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                   style: ButtonStyle(
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(Colors.blue),
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, Routescreen.password);
//                   },
//                   child: Text(
//                     'Forgot password?',
//                     style: TextStyle(color: Colors.blueAccent),
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, Routescreen.register);
//                   },
//                   child: Text(
//                     'Don\'t have an account? Register',
//                     style: TextStyle(fontStyle: FontStyle.italic),
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 Text(
//                   'Made by Qudsia & Hadia',
//                   style: TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


