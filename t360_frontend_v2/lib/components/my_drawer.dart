import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences for page persistence

import '../pages/view/dashboard.dart';
import '../pages/view/exportation.dart';
import '../pages/view/manage_team.dart';
import '../pages/view/profile.dart';
import '../pages/view/settings.dart';
import '../pages/view/study_case.dart';
import '../providers/auth_provider.dart';
import 'my_constants.dart';

class MyDrawer extends StatefulWidget {
  final Function(Widget, String)
      onPageSelected; // Pass both widget and page name
  const MyDrawer({super.key, required this.onPageSelected});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _selectedIndex = 0; // Variable to track the selected index
  int _hoveredIndex = -1; // Variable to track the hovered index
  static const _currentPageKey =
      'current_page'; // Key to store current page in SharedPreferences

  //! Initialize state and load the last selected page from SharedPreferences
  @override
  void initState() {
    super.initState();
    _loadLastSelectedPage(); // Load the last selected page on initialization
  }

  //! Load the last selected page from SharedPreferences
  Future<void> _loadLastSelectedPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPage = prefs.getString(_currentPageKey);

    //! Update selectedIndex based on the saved page
    setState(() {
      if (savedPage == 'dashboard') {
        _selectedIndex = 0;
        widget.onPageSelected(const Dashboard(), 'dashboard');
      } else if (savedPage == 'exportation') {
        _selectedIndex = 1;
        widget.onPageSelected(const Exportation(), 'exportation');
      } else if (savedPage == 'manage_team') {
        _selectedIndex = 2;
        widget.onPageSelected(const ManageTeam(), 'manage_team');
      } else if (savedPage == 'profile') {
        _selectedIndex = 3;
        widget.onPageSelected(const Profile(), 'profile');
      } else if (savedPage == 'study_cases') {
        _selectedIndex = 4;
        widget.onPageSelected(const StudyCaseScreen(), 'study_cases');
      } else if (savedPage == 'settings') {
        _selectedIndex = 5;
        widget.onPageSelected(const Settings(), 'settings');
      }
    });
  }

  //! Save the selected page in SharedPreferences
  Future<void> _saveSelectedPage(String pageName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _currentPageKey, pageName); // Store the selected page name
  }

  //! Function to show SnackBar
  void _showSnackBar(String message, Color color, String secondaryMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(secondaryMessage),
          ],
        ),
      ),
    );
  }

  //! Function to show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  //! Build the Drawer widget with various pages
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.role; // Get the user's role

    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(
                FluentIcons.person_24_filled,
                size: 64,
              ),
            ),
            _buildDrawerItem(
              index: 0,
              icon: FluentIcons.home_24_filled,
              text: 'D A S H B O A R D',
              page: const Dashboard(),
              pageName: 'dashboard',
            ),
            _buildDrawerItem(
              index: 1,
              icon: FluentIcons.share_screen_start_24_filled,
              text: 'E X P O R T A T I O N',
              page: const Exportation(),
              pageName: 'exportation',
            ),
            if (userRole == 'admin') // Only show Manage Team for admins
              _buildDrawerItem(
                index: 2,
                icon: FluentIcons.people_team_24_filled,
                text: 'M A N A G E   T E A M',
                page: const ManageTeam(),
                pageName: 'manage_team',
              ),
            _buildDrawerItem(
              index: 3,
              icon: FluentIcons.person_24_filled,
              text: 'P R O F I L E',
              page: const Profile(),
              pageName: 'profile',
            ),
            _buildDrawerItem(
              index: 4,
              icon: FluentIcons.briefcase_24_filled,
              text: 'S T U D Y   C A S E S',
              page: const StudyCaseScreen(),
              pageName: 'study_cases',
            ),
            _buildDrawerItem(
              index: 5,
              icon: FluentIcons.settings_24_filled,
              text: 'S E T T I N G S',
              page: const Settings(),
              pageName: 'settings',
            ),
            const Spacer(),
            _buildDrawerItem(
              index: 6,
              icon: FluentIcons.sign_out_24_filled,
              text: 'L O G O U T',
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  //! Method to build a drawer item for each page
  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String text,
    Widget? page,
    String? pageName, // Pass the page name to save in SharedPreferences
    bool isLogout = false,
  }) {
    final Color? defaultColor =
        Theme.of(context).textTheme.headlineMedium?.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = -1;
        });
      },
      child: GestureDetector(
        onTap: () async {
          if (isLogout) {
            // Show loading circle
            _showLoadingDialog(context);

            // Attempt logout
            bool isSuccess =
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();

            // Dismiss loading dialog
            Navigator.of(context).pop();

            if (isSuccess) {
              _showSnackBar(
                'Logout success',
                Colors.green,
                'You have been successfully logged out.',
              );
              navigateWithoutAnimation(context, '/');
            } else {
              _showSnackBar(
                'Error during logout',
                Colors.orange,
                'Please try again later.',
              );
            }
          } else {
            setState(() {
              _selectedIndex = index; // Update the selected index
            });
            if (page != null) {
              widget.onPageSelected(
                  page, pageName!); // Pass the page and page name
              _saveSelectedPage(
                  pageName); // Save the selected page in SharedPreferences
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: _hoveredIndex == index
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              _hoveredIndex == index
                  ? 10.0
                  : 0.0, // More circular border on hover
            ),
          ),
          child: ListTile(
            tileColor: Theme.of(context).scaffoldBackgroundColor,
            leading: Icon(
              icon,
              color: _selectedIndex == index
                  ? Theme.of(context).colorScheme.primary
                  : defaultColor,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            title: Text(
              text,
              style: TextStyle(
                color: _selectedIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : defaultColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
