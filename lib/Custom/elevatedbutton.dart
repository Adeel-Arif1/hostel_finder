import 'package:flutter/material.dart';

class CustomLoadingButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onPressed;
  final bool loading;
  final Color buttonColor; // Button background color
  final Color fontColor; // Font color

  const CustomLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.buttonColor = Colors.blue, // Default button color
    this.fontColor = Colors.white, // Default font color
  });

  @override
  _CustomLoadingButtonState createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading
          ? null
          : () async {
              setState(() {
                _loading = true;
              });
              try {
                await widget.onPressed();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
              setState(() {
                _loading = false;
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.buttonColor, // Customizable button color
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: _loading
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(width: 10),
                Text('Loading...', style: TextStyle(color: Colors.white)),
              ],
            )
          : Text(
              widget.label,
              style:
                  TextStyle(color: widget.fontColor), // Customizable font color
            ),
    );
  }
}



// import 'package:flutter/material.dart';

// class CustomLoadingButton extends StatefulWidget {
//   final String label;
//   final Future<void> Function() onPressed;
//   final bool loading;
//   final Color color;

//   const CustomLoadingButton({
//     Key? key,
//     required this.label,
//     required this.onPressed,
//     this.loading = false,
//     this.color = Colors.blue, // Default color is blue, you can pass teal as well
//   }) : super(key: key);

//   @override
//   _CustomLoadingButtonState createState() => _CustomLoadingButtonState();
// }

// class _CustomLoadingButtonState extends State<CustomLoadingButton> {
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: _loading
//           ? null
//           : () async {
//               setState(() {
//                 _loading = true;
//               });
//               try {
//                 await widget.onPressed();
//               } catch (error) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error: $error')),
//                 );
//               }
//               setState(() {
//                 _loading = false;
//               });
//             },
//       child: _loading
//           ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//                 SizedBox(width: 10),
//                 Text('Loading...', style: TextStyle(color: Colors.white)),
//               ],
//             )
//           : Text(
//               widget.label,
//               style: TextStyle(color: Colors.white),
//             ),
//       style: ElevatedButton.styleFrom(
//         // primary: widget.color,
//         padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
//         textStyle: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
