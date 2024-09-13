class User {
  //! Unique identifier for the user.
  int id;

  //! Username of the user.
  String username;

  //! Role of the user (e.g., Admin, Visitor, etc.).
  String role; // New role field

  //! Date when the user was created in the system, can be null.
  DateTime? createdAt; // Made nullable

  //! Date when the user was last updated in the system, can be null.
  DateTime? updatedAt; // Made nullable

  //! Constructor for the User class. Requires id, username, and role.
  User({
    required this.id, // ID is required
    required this.username, // Username is required
    required this.role, // Role is required
    this.createdAt, // createdAt is optional and can be null
    this.updatedAt, // updatedAt is optional and can be null
  });

  //! Factory method to create a User instance from a JSON object.
  //! The JSON keys must match the server response.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Parse ID from the JSON
      username: json['username'], // Parse username from the JSON
      role: json['role'], // Parse the role from the JSON
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null, // Parse created_at as DateTime, or set to null if missing
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null, // Parse updated_at as DateTime, or set to null if missing
    );
  }

  //! Method to convert a User instance back into a JSON object.
  //! This can be used when sending data to a server.
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID in JSON
      'username': username, // Include username in JSON
      'role': role, // Include role in JSON
      if (createdAt != null)
        'created_at': createdAt!
            .toIso8601String(), // Convert createdAt to ISO 8601 string, if not null
      if (updatedAt != null)
        'updated_at': updatedAt!
            .toIso8601String(), // Convert updatedAt to ISO 8601 string, if not null
    };
  }
}
