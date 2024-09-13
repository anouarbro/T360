import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/comment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/user_provider.dart';

//! Main screen to display and manage comments
class CommentScreen extends StatelessWidget {
  final int studyCaseId;

  // Constructor to initialize the study case ID
  const CommentScreen({super.key, required this.studyCaseId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token; // Get user token
    final userId = authProvider.user?.id; // Get user ID

    //! If the user is not authenticated, show a loading indicator
    if (token == null || userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //! Main scaffold for displaying comments
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'), // Title for the comments screen
      ),
      body: FutureBuilder(
        future: Future.wait([
          Provider.of<CommentProvider>(context, listen: false)
              .fetchComments(studyCaseId, token), // Fetch comments
          Provider.of<UserProvider>(context, listen: false)
              .fetchUsers(token), // Fetch users to populate userMap
        ]),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //! Show a loading indicator while waiting for comments to load
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            //! Display an error message if there's an issue fetching comments
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            //! Once comments and users are loaded, display them in a list
            return Consumer<CommentProvider>(
              builder: (ctx, commentProvider, _) {
                if (commentProvider.comments.isEmpty) {
                  //! If no comments are found, show a message
                  return const Center(child: Text('No comments found'));
                }

                //! Display the list of comments
                return ListView.builder(
                  itemCount: commentProvider.comments.length,
                  itemBuilder: (ctx, index) {
                    final comment = commentProvider.comments[index];
                    final isOwner = comment.userId ==
                        userId; // Check if the comment belongs to the user

                    //! Get the username from the userMap
                    final username =
                        Provider.of<UserProvider>(context, listen: false)
                                .userMap[comment.userId] ??
                            "Unknown User";

                    //! Individual comment item with options to edit or delete if owned by the user
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(comment
                                .comment), //! Display the comment content
                          ],
                        ),
                        //! Display the formatted date and edited status
                        subtitle: Text(_formatSubtitle(comment)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOwner) ...[
                              //! Edit button for the comment owner
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditCommentDialog(
                                      context, comment, token);
                                },
                              ),
                              //! Delete button for the comment owner
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirmDelete =
                                      await _showDeleteConfirmationDialog(
                                          context);
                                  if (confirmDelete) {
                                    await Provider.of<CommentProvider>(context,
                                            listen: false)
                                        .deleteComment(
                                            comment.id, studyCaseId, token);
                                  }
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      //! Floating action button to add a new comment
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateCommentDialog(context, token);
        },
        tooltip: 'Add Comment',
        child: const Icon(Icons.add),
      ),
    );
  }

  //! Helper method to format the subtitle of the comment with date and "edited" if applicable
  String _formatSubtitle(Comment comment) {
    final DateTime createdAt = DateTime.parse(comment.createdAt).toLocal();
    final DateTime updatedAt = DateTime.parse(comment.updatedAt).toLocal();

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    String formattedDate = formatter.format(updatedAt);

    if (createdAt != updatedAt) {
      formattedDate +=
          ' (edited)'; //! Append "edited" if the comment was updated
    }

    return 'Posted on: $formattedDate';
  }

  //! Helper method to show a confirmation dialog before deleting a comment
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this comment?'),
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

  //! Helper method to show the dialog for editing a comment
  void _showEditCommentDialog(
      BuildContext context, Comment comment, String token) {
    final contentController = TextEditingController(text: comment.comment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter content'),
                ));
                return;
              }

              //! Update the comment with the new content
              await Provider.of<CommentProvider>(context, listen: false)
                  .updateComment(
                comment.id,
                Comment(
                  id: comment.id,
                  studyCaseId: comment.studyCaseId,
                  userId: comment.userId,
                  comment: contentController.text,
                  createdAt: comment.createdAt,
                  updatedAt: DateTime.now().toIso8601String(),
                ),
                token,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  //! Helper method to show the dialog for creating a new comment
  void _showCreateCommentDialog(BuildContext context, String token) {
    final contentController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              if (contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter content')),
                );
                return;
              }

              //! Add the new comment
              await Provider.of<CommentProvider>(context, listen: false)
                  .addComment(
                Comment(
                  id: 0,
                  studyCaseId: studyCaseId,
                  userId: authProvider.user!.id, // Set the userId
                  comment: contentController.text,
                  createdAt: DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                ),
                token,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
