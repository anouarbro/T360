import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService apiService; // Instance of ApiService for API calls
  List<User> _users = []; // List of all users
  List<User> _connectedUsers = []; // List of connected users
  Map<int, String> _userMap = {}; // Map of user IDs to usernames

  UserProvider({required this.apiService});

  //! Getter for the list of all users
  List<User> get users => _users;

  //! Getter for the list of connected users
  List<User> get connectedUsers => _connectedUsers;

  //! Getter for the map of user IDs to usernames
  Map<int, String> get userMap => _userMap;

  //! Fetch all users from the API and store them in the provider
  Future<void> fetchUsers(String token) async {
    try {
      _users = await apiService.fetchUsers(token); // Fetch users from API
      _userMap = {
        for (var user in _users) user.id: user.username
      }; // Create a map of user IDs to usernames
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print("Error fetching users: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }

  //! Fetch connected users from the API and store them in the provider
  Future<void> fetchConnectedUsers(String token) async {
    try {
      _connectedUsers = await apiService
          .fetchConnectedUsers(token); // Fetch connected users from API
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print("Error fetching connected users: $e");
      rethrow;
    }
  }

  //! Update user details and refresh the user list
  Future<void> updateUser(int id, String username, String? password,
      String role, String token) async {
    try {
      await apiService.updateUser(
          id, username, password, role, token); // Update user details via API
      await fetchUsers(token); // Refresh the user list after update
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  //! Delete a user and refresh the user list
  Future<void> deleteUser(int id, String token) async {
    try {
      await apiService.deleteUser(id, token); // Delete user via API
      await fetchUsers(token); // Refresh the user list after deletion
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }
}
