import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  static const _storageKey =
      'auth_token'; // Key to store the token in local storage
  String? _token; // Token retrieved from API or local storage
  User? _user; // User object representing the authenticated user

  //! Getter for the token
  String? get token => _token;

  //! Getter for the user object
  User? get user => _user;

  //! Getter for the role of the user
  String? get role => _user?.role;

  //! Constructor to initialize and load user data from storage
  AuthProvider() {
    _loadTokenAndUser(); // Load token and user from local storage on initialization
  }

  //! Load token and user data from SharedPreferences
  Future<void> _loadTokenAndUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_storageKey); // Load token from storage
    final userData = prefs.getString('user_data'); // Load user data
    if (userData != null) {
      _user =
          User.fromJson(jsonDecode(userData)); // Convert JSON to User object
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  //! Handle login and store the token and user data in SharedPreferences
  Future<String?> login(String username, String password) async {
    try {
      final Map<String, dynamic> response =
          await ApiService().loginUser(username, password);

      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw Exception('Invalid login response: Missing token or user data');
      }

      _token = token;
      _user = User.fromJson(user);

      // Save token and user data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _token!);
      await prefs.setString(
          'user_data', jsonEncode(_user!.toJson())); // Store user data

      notifyListeners(); // Notify listeners to update the UI

      return null; // No error
    } catch (e) {
      print('Login failed: $e');
      return 'Login failed: ${e.toString()}'; // Return the error message
    }
  }

  //! Handle user logout and remove token and user data from SharedPreferences
  Future<bool> logout() async {
    if (_token != null) {
      try {
        bool isSuccess = await ApiService().logoutUser(_token!);
        if (!isSuccess) {
          return false; // Logout failed
        }
      } catch (e) {
        return false; // Handle error during logout
      }

      // Clear token and user data
      _token = null;
      _user = null;

      // Remove from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove('user_data');
      notifyListeners();

      return true; // Logout successful
    }
    return false;
  }

  //! Register a new user and notify listeners
  Future<String?> register(
      String username, String password, String role) async {
    try {
      await ApiService().registerUser(username, password, role);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Registration failed: ${e.toString()}'; // Return error message
    }
  }
}
