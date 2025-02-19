import 'package:flutter/material.dart';

class Inputvalidation extends StatelessWidget {
  final TextEditingController inputController;
  final String labelText;
  const Inputvalidation(
      {super.key, required this.inputController, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: inputController,
      style: TextStyle(
        color: Colors.grey.shade300,
        fontFamily: 'Kanit',
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Kanit',
          fontSize: 22,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$labelText cannot be empty";
        }
        return null;
      },
    );
  }
}
