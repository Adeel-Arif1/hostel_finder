import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isNumeric;
  final bool isPassword; // Add a flag to determine if it's a password field
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const CustomTextField({super.key, 
    required this.controller,
    required this.labelText,
    this.isNumeric = false,
    this.isPassword = false, // By default, it's not a password field
    this.validator,
    this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true; // To control password visibility

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.text,
      obscureText: widget.isPassword ? _isObscure : false, // Handle password visibility
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure; // Toggle password visibility
                  });
                },
              )
            : null, // No suffix icon if it's not a password field
      ),
      onChanged: widget.onChanged,
      validator: widget.validator, // Add the validator here
      textDirection: TextDirection.ltr,
    );
  }
}


// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final bool isNumeric;
//   final ValueChanged<String>? onChanged;

//   CustomTextField({
//     required this.controller,
//     required this.labelText,
//     this.isNumeric = false,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(
//           fontSize: 14,
//         ),
//         border: OutlineInputBorder(),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blue, width: 2.0),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey, width: 1.0),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       ),
//       onChanged: onChanged,
//       textDirection: TextDirection.ltr, // Set text direction to LTR
//     );
//   }
// }


