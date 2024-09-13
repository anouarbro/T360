import 'dart:math';

import 'package:flutter/material.dart';

import '../pages/controller/responsive_layout.dart'; // Responsive layout for mobile, tablet, and desktop
import '../pages/ui/desktop.dart'; // Desktop view
import '../pages/ui/mobile.dart'; // Mobile view
import '../pages/ui/tablet.dart'; // Tablet view
import '../pages/view/login.dart'; // Login screen

//! Function to navigate between screens without animation
void navigateWithoutAnimation(BuildContext context, String routeName) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        //! Navigate to login screen if routeName is '/'
        //! Otherwise, navigate to the responsive layout for mobile, tablet, and desktop
        return routeName == '/'
            ? const LoginScreen()
            : const ResponsiveLayout(
                mobileBody: Mobile(), // Mobile layout
                tabletBody: Tablet(), // Tablet layout
                desktopBody: Desktop(), // Desktop layout
              );
      },
      //! Transition builder with no animation
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // Return the child directly to disable animation
      },
    ),
  );
}

//! Generate random box data for UI components
final List<Map<String, dynamic>> boxData = List.generate(10, (index) {
  final double percentage =
      Random().nextDouble() * 100; // Random percentage between 0 and 100
  final int randomNumber =
      1000 + Random().nextInt(1001); // Random number between 1000 and 2000
  return {
    'percentage': percentage,
    'number': randomNumber
  }; // Return a map with percentage and number
});

//! Labels for B2B data representation
final List<String> b2bLabels = [
  'Taille Salarial', // Company size
  'Secteur', // Sector
  'Sous Secteur', // Sub-sector
  'UDA9', // UDA9
  'Etablissement Siege' // Headquarters
];

//! Labels for B2C data representation
final List<String> b2cLabels = [
  'Sexe', // Gender
  'Fonction', // Function
  'UDA9', // UDA9
  'Niveau de Revenu', // Income level
  'Religion' // Religion
];
