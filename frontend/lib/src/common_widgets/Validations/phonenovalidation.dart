import 'package:flutter/material.dart';

class Phonenovalidation extends StatelessWidget {
  final TextEditingController phoneController;
  final String labelText;
  const Phonenovalidation(
      {super.key, required this.phoneController, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: Colors.grey.shade300, fontSize: 18),
      decoration: InputDecoration(
        labelText: "Phone Number",
        labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Kanit'),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone number cannot be empty";
        }
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
    );
  }
}
