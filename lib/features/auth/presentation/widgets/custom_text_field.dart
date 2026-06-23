import 'package:flutter/material.dart';

/// Input field Swiss — label uppercase di atas, underline hairline,
/// tanpa rounded corner atau filled background.
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      style: Theme.of(context).textTheme.bodyLarge,
      cursorColor: Theme.of(context).colorScheme.onSurface,
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}