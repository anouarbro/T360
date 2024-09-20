import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0A79A7), // updated primary
    secondary: Color(0xFF00668c), // accent-200
    error: Color(0xFFB00020),
    onPrimary: Color(0xFF1d1c1c), // text-100
    onSecondary: Color(0xFFfffefb), // bg-100
    onError: Color(0xFFfffefb), // bg-100
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFf5f4f1), // bg-200

  listTileTheme: ListTileThemeData(
    tileColor: const Color(0xFFfffefb), // bg-100
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),

  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 20.0,
    ),
    color: Color(0xFFf5f4f1), // bg-200
    iconTheme: IconThemeData(
      color: Color(0xFF1d1c1c), // text-100
      size: 20.0,
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF00668c), // accent-200
    selectedItemColor: Color(0xFFfffefb), // bg-100
    unselectedItemColor: Color(0xFF71c4ef), // accent-100
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 16.0,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF00668c), // accent-200
      fontSize: 14.0,
    ),
    displayLarge: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 32.0,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 24.0,
    ),
    displaySmall: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 20.0,
    ),
    headlineMedium: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 16.0,
    ),
    headlineSmall: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF1d1c1c), // text-100
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF313d44), // text-200
      fontSize: 16.0,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF313d44), // text-200
      fontSize: 14.0,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF313d44), // text-200
      fontSize: 12.0,
    ),
    labelLarge: TextStyle(
      color: Color(0xFFfffefb), // bg-100
      fontSize: 14.0,
    ),
  ),

  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF0A79A7), // updated primary
    splashColor: Color(0xFF71c4ef), // accent-100
    textTheme: ButtonTextTheme.primary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFF71c4ef); // accent-100
        }
        return const Color(0xFF0A79A7); // updated primary
      }),
      foregroundColor: WidgetStateProperty.all<Color>(
        const Color(0xFF1d1c1c), // text-100
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF0A79A7), // updated primary
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF0A79A7), // updated primary
    foregroundColor: Color(0xFF1d1c1c), // text-100
  ),
);
