import 'package:flutter/material.dart';

final ThemeData darkMode = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00668c), // Updated primary
    secondary: Color(0xFF006fff), // accent-100
    error: Color(0xFFB00020),
    onPrimary: Color(0xFFFFFFFF), // text-100
    onSecondary: Color(0xFFe1ffff), // accent-200
    onError: Color(0xFFe1ffff), // accent-200
  ),
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1E1E1E), // bg-100

  listTileTheme: ListTileThemeData(
    tileColor: const Color(0xFF2d2d2d), // bg-200
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),

  appBarTheme: const AppBarTheme(
    color: Color(0xFF1E1E1E), // bg-100
    iconTheme: IconThemeData(
      color: Color(0xFFFFFFFF), // text-100
      size: 20.0,
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF006fff), // accent-100
    selectedItemColor: Color(0xFFe1ffff), // accent-200
    unselectedItemColor: Color(0xFF69b4ff), // primary-200
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 16.0,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF00668c), // Updated primary
      fontSize: 14.0,
    ),
    displayLarge: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 32.0,
    ),
    displayMedium: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 24.0,
    ),
    displaySmall: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 20.0,
    ),
    headlineMedium: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 16.0,
    ),
    headlineSmall: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Color(0xFFFFFFFF), // text-100
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF9e9e9e), // text-200
      fontSize: 16.0,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF9e9e9e), // text-200
      fontSize: 14.0,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF9e9e9e), // text-200
      fontSize: 12.0,
    ),
    labelLarge: TextStyle(
      color: Color(0xFFe1ffff), // accent-200
      fontSize: 14.0,
    ),
  ),

  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF00668c), // Updated primary
    splashColor: Color(0xFF0085ff), // primary-100
    textTheme: ButtonTextTheme.primary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFF0085ff); // primary-100
        }
        return const Color(0xFF00668c); // Updated primary
      }),
      foregroundColor: WidgetStateProperty.all<Color>(
        const Color(0xFF1E1E1E), // bg-100
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF00668c), // Updated primary
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF00668c), // Updated primary
    foregroundColor: Color(0xFF1E1E1E), // bg-100
  ),
);
