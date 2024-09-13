import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart'; // User model
import '../../providers/auth_provider.dart'; // AuthProvider for authentication
import '../../providers/user_provider.dart'; // UserProvider for managing users

class ManageTeam extends StatelessWidget {
  const ManageTeam({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    if (token == null) {
      //! Show loading indicator while fetching token or if user is not authenticated
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildStaticHeader(context), // Static Header with "Add Member" button
          const SizedBox(height: 10),
          //! Expanded widget for the main content (list of users)
          Expanded(
            child: FutureBuilder(
              //! Fetch users and connected users in parallel
              future: Future.wait([
                Provider.of<UserProvider>(context, listen: false)
                    .fetchUsers(token),
                Provider.of<UserProvider>(context, listen: false)
                    .fetchConnectedUsers(token),
              ]),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  //! Show loading indicator while data is being fetched
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  //! Display error message if fetching fails
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  //! Display the list of users
                  return Consumer<UserProvider>(
                    builder: (ctx, userProvider, _) {
                      if (userProvider.users.isEmpty) {
                        //! Display message if no users are found
                        return const Center(child: Text('No users found'));
                      }
                      //! Build a list of users
                      return ListView.builder(
                        itemCount: userProvider.users.length,
                        itemBuilder: (ctx, index) {
                          final user = userProvider.users[index];
                          final isConnected = userProvider.connectedUsers.any(
                              (connectedUser) => connectedUser.id == user.id);

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              //! User avatar shows online (green) or offline (grey)
                              leading: CircleAvatar(
                                backgroundColor:
                                    isConnected ? Colors.green : Colors.grey,
                                radius: 20,
                                child: Text(
                                  user.username[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              //! Display username and role
                              title: Text(
                                user.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Role: ${user.role}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                              trailing: _buildActions(context, user, token),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //! Static Header with "Add Member" button
  Widget _buildStaticHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //! Team Members title
          Text(
            'Team Members',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          //! Add Member button
          ElevatedButton.icon(
            onPressed: () {
              _showCreateUserDialog(context); // Show dialog to create new user
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                const Text('Add Member', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //! Action buttons for editing and deleting a user
  Widget _buildActions(BuildContext context, User user, String token) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //! Edit button
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () {
            _showEditUserDialog(context, user); // Show edit user dialog
          },
        ),
        //! Delete button
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            final confirmDelete = await _showDeleteConfirmationDialog(context);
            if (confirmDelete) {
              //! If confirmed, delete user and refresh user list
              await Provider.of<UserProvider>(context, listen: false)
                  .deleteUser(user.id, token);
              Provider.of<UserProvider>(context, listen: false)
                  .fetchUsers(token);
            }
          },
        ),
      ],
    );
  }

  //! Show confirmation dialog before deleting a user
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  //! Show dialog to edit user details
  void _showEditUserDialog(BuildContext context, User user) {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController();
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //! Username text field
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 10),
                //! Password field (optional)
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password (leave blank to keep current)'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                //! Role dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: <String>['admin', 'visitor']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              //! Save button to update user details
              ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a username')),
                    );
                    return;
                  }

                  //! Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  //! Update the user details
                  await Provider.of<UserProvider>(context, listen: false)
                      .updateUser(
                    user.id,
                    usernameController.text,
                    passwordController.text.isEmpty
                        ? null
                        : passwordController.text,
                    selectedRole,
                    Provider.of<AuthProvider>(context, listen: false).token!,
                  );

                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.of(context).pop(); // Close edit dialog
                  //! Refresh the user list after editing
                  Provider.of<UserProvider>(context, listen: false).fetchUsers(
                    Provider.of<AuthProvider>(context, listen: false).token!,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  //! Show dialog to create a new user
  void _showCreateUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'visitor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //! Username input field
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 10),
                //! Password input field
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                //! Role dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: <String>['admin', 'visitor']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              //! Create button to add the new user
              ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill out all fields'),
                      ),
                    );
                    return;
                  }

                  //! Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final currentToken =
                      authProvider.token; // Store current user token

                  //! Create the user and handle errors if any
                  String? errorMessage = await authProvider.register(
                    usernameController.text,
                    passwordController.text,
                    selectedRole,
                  );

                  Navigator.of(context).pop(); // Close loading dialog

                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User created successfully'),
                      ),
                    );
                    //! Fetch users again to update the list while maintaining session
                    Provider.of<UserProvider>(context, listen: false).fetchUsers(
                        currentToken!); // Use the current token to avoid session disruption
                    Navigator.of(context).pop(); // Close the create dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
