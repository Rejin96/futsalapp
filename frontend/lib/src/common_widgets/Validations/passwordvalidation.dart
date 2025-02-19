import 'package:flutter/material.dart';

class PasswordValidation extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? confirmPasswordController; // For confirm password
  final String labelText;

  PasswordValidation({
    super.key,
    required this.controller,
    this.confirmPasswordController,
    required this.labelText,
  });

  @override
  State<PasswordValidation> createState() => _PasswordValidationState();
}

class _PasswordValidationState extends State<PasswordValidation> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, // Use the correct controller
      obscureText: _obscureText,
      style: TextStyle(
        color: Colors.grey.shade300,
        fontFamily: 'Kanit',
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
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
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "${widget.labelText} cannot be empty";
        }
        if (widget.labelText == 'Password' && value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        if (widget.labelText == 'Confirm Password' &&
            widget.confirmPasswordController != null &&
            value != widget.confirmPasswordController!.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}
