import 'package:flutter/material.dart';

import '../models/comment.dart' as comment_model;
import '../services/api_service.dart';

class CommentProvider with ChangeNotifier {
  final ApiService apiService; // Instance of ApiService for API calls
  List<comment_model.Comment> _comments = []; // List of all comments

  //! Getter for the list of all comments
  List<comment_model.Comment> get comments => _comments;

  CommentProvider({required this.apiService});

  //! Fetch comments for a specific study case and store them in the provider
  Future<void> fetchComments(int studyCaseId, String token) async {
    try {
      _comments = await apiService.fetchComments(
          studyCaseId, token); // Fetch comments from API
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      print('Error fetching comments: $error');
      rethrow;
    }
  }

  //! Add a new comment and refresh the comments list
  Future<void> addComment(comment_model.Comment comment, String token) async {
    try {
      await apiService.addComment(comment, token); // Add comment via API
      await fetchComments(comment.studyCaseId, token); // Refresh comments list
      notifyListeners(); // Notify listeners to refresh UI
    } catch (error) {
      print('Error adding comment: $error');
      rethrow;
    }
  }

  //! Update an existing comment and refresh the comments list
  Future<void> updateComment(
      int id, comment_model.Comment comment, String token) async {
    try {
      await apiService.updateComment(
          id, comment, token); // Update comment via API
      await fetchComments(comment.studyCaseId, token); // Refresh comments list
    } catch (error) {
      print('Error updating comment: $error');
      rethrow;
    }
  }

  //! Delete a comment and refresh the comments list
  Future<void> deleteComment(int id, int studyCaseId, String token) async {
    try {
      await apiService.deleteComment(id, token); // Delete comment via API
      await fetchComments(studyCaseId, token); // Refresh comments list
    } catch (error) {
      print('Error deleting comment: $error');
      rethrow;
    }
  }
}
