import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import '../../components/my_app_bar.dart'; // Custom app bar component
import '../../components/my_drawer.dart'; // Custom drawer component
import '../../providers/auth_provider.dart'; // Auth provider for user authentication
import '../view/dashboard.dart'; // Dashboard view
import '../view/exportation.dart'; // Exportation view
import '../view/manage_team.dart'; // Manage Team view
import '../view/profile.dart'; // Profile view
import '../view/settings.dart'; // Settings view
import '../view/study_case.dart'; // Study Case view

class Tablet extends StatefulWidget {
  const Tablet({super.key});

  @override
  State<Tablet> createState() => _TabletState();
}

class _TabletState extends State<Tablet> {
  static const _currentPageKey =
      'current_page'; // Key for storing current page in SharedPreferences
  Widget currentPage = const Dashboard(); // Default to Dashboard

  //! Method to load the last viewed page from SharedPreferences
  Future<void> _loadLastViewedPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPage = prefs.getString(_currentPageKey);

    //! Set the currentPage based on the saved page
    setState(() {
      if (savedPage == 'dashboard') {
        currentPage = const Dashboard(); // Load Dashboard if saved
      } else if (savedPage == 'exportation') {
        currentPage = const Exportation(); // Load Exportation if saved
      } else if (savedPage == 'manage_team') {
        currentPage = const ManageTeam(); // Load Manage Team if saved
      } else if (savedPage == 'profile') {
        currentPage = const Profile(); // Load Profile if saved
      } else if (savedPage == 'study_cases') {
        currentPage = const StudyCaseScreen(); // Load Study Cases if saved
      } else if (savedPage == 'settings') {
        currentPage = const Settings(); // Load Settings if saved
      }
    });
  }

  //! Method to save the current page in SharedPreferences
  Future<void> _saveCurrentPage(String pageName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPageKey, pageName); // Save the current page
  }

  //! Method to update the current page and save the new page state
  void _updateContent(Widget newPage, String pageName) {
    setState(() {
      currentPage = newPage; // Update the current page
    });
    _saveCurrentPage(pageName); // Save the new page to SharedPreferences
  }

  @override
  void initState() {
    super.initState();
    _loadLastViewedPage(); // Load the last viewed page on initialization
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    //! If the user is not authenticated, show a loading indicator
    if (authProvider.token == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //! Main scaffold layout with app bar, drawer, and content area
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const MyAppBar(), // Custom app bar
      drawer: MyDrawer(
        onPageSelected: (Widget newPage, String pageName) =>
            _updateContent(newPage, pageName), // Pass page name for storage
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: currentPage, // Display the currently selected page
      ),
    );
  }
}
