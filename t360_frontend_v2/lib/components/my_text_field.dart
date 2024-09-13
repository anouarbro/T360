import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller; // Controller to manage the input text
  final String hintText; // Placeholder text for the text field
  final bool
      obscureText; // Whether the text field should obscure the input (for passwords)
  final IconData prefixIcon; // Icon displayed at the start of the text field
  final IconData?
      suffixIcon; // Optional icon displayed at the end of the text field
  final VoidCallback?
      onSuffixIconPressed; // Callback when suffix icon is pressed (optional)

  const MyTextField({
    super.key,
    required this.controller, // Required parameter for managing input
    required this.hintText, // Required parameter for hint text
    this.obscureText =
        false, // Optional parameter, defaults to false (not obscured)
    required this.prefixIcon, // Required parameter for prefix icon
    this.suffixIcon, // Optional parameter for suffix icon
    this.onSuffixIconPressed, // Optional callback for suffix icon press
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final borderColor = theme.colorScheme.onSurface
        .withOpacity(0.4); // Set border color based on theme
    final fillColor =
        theme.colorScheme.surface; // Set background color based on theme
    final iconColor = theme.colorScheme.onSurface
        .withOpacity(0.6); // Set icon color with opacity

    //! Main TextField widget with custom decoration
    return TextField(
      controller: controller, // Link the controller to manage the text input
      obscureText:
          obscureText, // Control whether the input is obscured (e.g., for passwords)
      decoration: InputDecoration(
        filled: true, // Fill the background of the text field
        fillColor: fillColor, // Set the background color
        //! Define the border for when the text field is enabled but not focused
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor, // Use theme-based border color
            width: 1, // Set border width
          ),
          borderRadius: BorderRadius.circular(10), // Set rounded corners
        ),
        //! Define the border for when the text field is focused
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor, // Use theme-based border color
            width: 2, // Set thicker border width when focused
          ),
          borderRadius: BorderRadius.circular(10), // Set rounded corners
        ),
        hintText: hintText, // Display the hint text when the field is empty
        //! Display a prefix icon (always shown at the start of the field)
        prefixIcon: Icon(
          prefixIcon, // Set the icon to the one passed in
          color: iconColor, // Use theme-based color for the icon
        ),
        //! Display a suffix icon (optional, shown at the end of the field)
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: iconColor), // Set the suffix icon
                onPressed:
                    onSuffixIconPressed, // Handle suffix icon press if provided
              )
            : null, // If no suffix icon is provided, show nothing
      ),
    );
  }
}
