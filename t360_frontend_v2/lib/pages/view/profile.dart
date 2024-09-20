import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart'; // AuthProvider for managing user authentication
import '../../providers/user_provider.dart'; // UserProvider for managing user data

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _usernameController =
      TextEditingController(); // Username input controller
  final _passwordController =
      TextEditingController(); // Password input controller
  bool _isPasswordChanged = false; // Track if password is changed
  bool _isUsernameChanged = false; // Track if username is changed
  bool _isSaving = false; // To show loading indicator during save
  bool _canSave = false; // To enable or disable the Save button

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController.text =
        authProvider.user?.username ?? ''; // Pre-fill username

    _usernameController
        .addListener(_checkChanges); // Listen for username changes
    _passwordController
        .addListener(_checkChanges); // Listen for password changes
  }

  //! Method to check if any changes were made to username or password
  void _checkChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser != null) {
      final usernameChanged =
          _usernameController.text.trim() != currentUser.username;
      final passwordChanged = _passwordController.text.isNotEmpty;

      if (mounted) {
        setState(() {
          _canSave = usernameChanged || passwordChanged;
          _isUsernameChanged = usernameChanged;
          _isPasswordChanged = passwordChanged;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;
    final user = authProvider.user;

    //! Redirect to login screen if not authenticated
    if (token == null) {
      return _buildLoginPrompt(context);
    }

    //! Display different layouts based on screen size (responsive)
    return Scaffold(
      appBar: AppBar(
        iconTheme: null,
        title: const Text('Profile Management'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout(context, user); // Tablet/Desktop layout
          } else {
            return _buildNarrowLayout(context, user); // Mobile layout
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout, // Call the custom logout method
        label: const Text('Logout'),
        icon: const Icon(Icons.logout),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  //! Logout function similar to the drawer logout logic
  Future<void> _logout() async {
    _showLoadingDialog(); // Show loading indicator while logging out

    // Attempt to log out using AuthProvider
    bool isSuccess =
        await Provider.of<AuthProvider>(context, listen: false).logout();

    // Dismiss loading dialog
    Navigator.of(context).pop();

    if (isSuccess) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout success'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to the login screen
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during logout. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //! Show loading dialog during logout
  void _showLoadingDialog() {
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

  //! Build layout for wider screens (Tablet/Desktop)
  Widget _buildWideLayout(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          //! Display user avatar on the left
          Expanded(
            flex: 1,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                user?.username[0].toUpperCase() ?? '',
                style: const TextStyle(fontSize: 50, color: Colors.white),
              ),
            ),
          ),
          //! Display user information on the right
          Expanded(
            flex: 2,
            child: _buildUserInfo(context),
          ),
        ],
      ),
    );
  }

  //! Build layout for narrower screens (Mobile)
  Widget _buildNarrowLayout(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          //! Display user avatar at the top
          CircleAvatar(
            radius: 80,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              user?.username[0].toUpperCase() ?? '',
              style: const TextStyle(fontSize: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          //! Display user information below the avatar
          _buildUserInfo(context),
        ],
      ),
    );
  }

  //! Build user info fields (Username and Password input)
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //! Username input field
        TextField(
          controller: _usernameController,
          enabled: !_isSaving, // Disable when saving
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 10),
        //! Password input field
        TextField(
          controller: _passwordController,
          enabled: !_isSaving, // Disable when saving
          decoration: const InputDecoration(
              labelText: 'Password (leave blank to keep current)'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        //! Save button (or loading indicator when saving)
        _isSaving
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _canSave
                    ? () async {
                        setState(() {
                          _isSaving = true; // Show loading indicator
                        });

                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        final currentUser = authProvider.user;

                        if (currentUser == null) {
                          //! Redirect to login if the current user is null
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (Route<dynamic> route) => false);
                          return;
                        }

                        try {
                          //! Update the user details
                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .updateUser(
                            currentUser.id,
                            _usernameController.text.trim(),
                            _passwordController.text.isEmpty
                                ? null
                                : _passwordController.text,
                            currentUser.role,
                            authProvider.token!,
                          );

                          //! Show success message after update
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green),
                          );

                          //! Log out if username or password changed
                          if (_isUsernameChanged || _isPasswordChanged) {
                            // Attempt logout
                            await Provider.of<AuthProvider>(context,
                                    listen: false)
                                .logout();

                            // Dismiss loading dialog
                            if (mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          } else {
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        } catch (e) {
                          //! Handle update failure and show error message
                          setState(() {
                            _isSaving = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update profile: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    : null, // Disable button if no changes were made
                child: const Text('Save'),
              ),
      ],
    );
  }

  //! Build login prompt if the user is not authenticated
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'You are not logged in. Please log in to view your profile.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/login'); // Navigate to login screen
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose(); // Clean up username controller
    _passwordController.dispose(); // Clean up password controller
    super.dispose();
  }
}
