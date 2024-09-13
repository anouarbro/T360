class Comment {
  //! Unique identifier for the comment.
  final int id;

  //! ID of the user who made the comment.
  final int userId;

  //! ID of the study case to which the comment is related.
  final int studyCaseId;

  //! The content of the comment.
  final String comment;

  //! Date when the comment was created (can be empty string if null in JSON).
  final String createdAt;

  //! Date when the comment was last updated (can be empty string if null in JSON).
  final String updatedAt;

  //! Constructor for the Comment class. All fields are required.
  Comment({
    required this.id, // Comment ID is required
    required this.userId, // User ID is required
    required this.studyCaseId, // Study Case ID is required
    required this.comment, // Comment content is required
    required this.createdAt, // Created at date is required, defaults to empty string if null
    required this.updatedAt, // Updated at date is required, defaults to empty string if null
  });

  //! Factory method to create a Comment instance from a JSON object.
  //! The created_at and updated_at fields default to an empty string if null in the JSON.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'], // Parse ID from the JSON
      userId: json['user_id'], // Parse user ID from the JSON
      studyCaseId: json['study_case_id'], // Parse study case ID from the JSON
      comment: json['comment'], // Parse the comment content
      createdAt: json['created_at'] ??
          '', // Default to empty string if created_at is null
      updatedAt: json['updated_at'] ??
          '', // Default to empty string if updated_at is null
    );
  }

  //! Method to convert a Comment instance back into a JSON object.
  //! Useful for sending comment data to a server. The ID fields are used to associate
  //! the comment with a user and a study case, but the createdAt and updatedAt fields
  //! are not included as they are usually set by the server.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId, // Include user ID in the JSON
      'study_case_id': studyCaseId, // Include study case ID in the JSON
      'comment': comment, // Include comment content in the JSON
    };
  }
}
