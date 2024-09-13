import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // For using Provider to access AuthProvider

import '../../components/my_text_field.dart'; // Custom text field component
import '../../providers/auth_provider.dart'; // Importing AuthProvider for user authentication

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController =
      TextEditingController(); // Controller for username field
  final _passwordController =
      TextEditingController(); // Controller for password field
  bool _obscureText = true; // Control visibility of password field

  @override
  void dispose() {
    _usernameController
        .dispose(); // Dispose controllers when widget is disposed
    _passwordController.dispose();
    super.dispose();
  }

  //! Method to show SnackBar messages (success/error)
  void _showSnackBar(String message, Color color, String secondaryMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color, // Set background color (based on success/error)
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                  fontWeight: FontWeight.bold), // Primary message
            ),
            Text(secondaryMessage), // Secondary message
          ],
        ),
      ),
    );
  }

  //! Build method for username and password text fields
  Widget _buildTextFields() {
    return Column(
      children: [
        //! Username text field
        MyTextField(
          controller: _usernameController,
          hintText: 'Username',
          prefixIcon: Icons.account_circle, // Icon for username
        ),
        const SizedBox(height: 10),
        //! Password text field with toggleable visibility
        MyTextField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: _obscureText, // Control password visibility
          prefixIcon: Icons.lock, // Icon for password
          suffixIcon: _obscureText
              ? Icons.visibility_off
              : Icons.visibility, // Toggle icon for visibility
          onSuffixIconPressed: () {
            setState(() {
              _obscureText = !_obscureText; // Toggle password visibility
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  //! Build method for the login button
  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(
          Size(MediaQuery.of(context).size.width * 0.8, 50), // Button size
        ),
      ),
      //! When the login button is pressed
      onPressed: () async {
        if (_usernameController.text.isEmpty ||
            _passwordController.text.isEmpty) {
          // Show SnackBar if fields are empty
          _showSnackBar(
            'Error: Please enter both fields', // Primary message
            Colors.orange, // Warning color
            'Please insert the necessary information in order to be connected.', // Secondary message
          );
          return;
        }

        //! Show loading dialog during login attempt
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            );
          },
        );

        //! Attempt login using AuthProvider
        String? errorMessage =
            await Provider.of<AuthProvider>(context, listen: false).login(
          _usernameController.text,
          _passwordController.text,
        );

        Navigator.of(context).pop(); // Close loading dialog

        if (errorMessage == null) {
          // Show success SnackBar and navigate to dashboard if login succeeds
          _showSnackBar(
            'Login success',
            Colors.green, // Success color
            'You have been successfully logged in to your account.',
          );
          Navigator.pushReplacementNamed(
              context, '/dashboard'); // Navigate to dashboard
        } else {
          // Show error SnackBar if login fails
          _showSnackBar(
            'Error: Username or password is not correct',
            Colors.red, // Error color
            'Please provide the correct login information.',
          );
        }
      },
      child: const Text(
        'S I G N  I N', // Button text
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
    );
  }

  //! Build the card content containing text fields and login button
  Widget _buildCardContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Minimize the size of the card
      children: [
        const DrawerHeader(
          child: Icon(
            FluentIcons.person_24_filled, // Person icon
            size: 62,
          ),
        ),
        const SizedBox(height: 30),
        _buildTextFields(), // Display text fields
        _buildLoginButton(context), // Display login button
        const SizedBox(height: 30),
      ],
    );
  }

  //! Build layout for wide screens (desktops/tablets)
  Widget _buildWideScreenLayout(BuildContext context) {
    return Row(
      children: [
        //! Left side of the screen with a welcome message and image
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF213B74), // Background color
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome back! Please sign in to your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // Bold white text
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 500,
                    width: 500,
                    child: SvgPicture.asset(
                        'lib/assets/login_image.svg'), // Display SVG image
                  )
                ],
              ),
            ),
          ),
        ),
        //! Right side of the screen with login card
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 400), // Limit card width
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color:
                      Theme.of(context).cardColor, // Card color based on theme
                  elevation: 8.0, // Card elevation for shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Rounded card corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildCardContent(context), // Display card content
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //! Build layout for mobile screens
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 400), // Limit card width for mobile
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Theme.of(context).cardColor, // Card color based on theme
            elevation: 8.0, // Card elevation for shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded card corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildCardContent(context), // Display card content
            ),
          ),
        ),
      ),
    );
  }

  //! Main build method for the login screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Set background color
      body: LayoutBuilder(
        //! Adapt layout based on screen width
        builder: (context, constraints) {
          if (constraints.maxWidth > 1100) {
            return _buildWideScreenLayout(
                context); // Use wide screen layout for larger screens
          } else {
            return _buildMobileLayout(
                context); // Use mobile layout for smaller screens
          }
        },
      ),
    );
  }
}
