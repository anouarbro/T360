import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/study_case.dart';
import '../models/user.dart';

class ApiService {
  //! Base URL for the API.
  final String baseUrl = 'http://localhost:8000/api';

  //! Register a new user.
  Future<User> registerUser(
      String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  //! Log in a user and retrieve the token along with role.
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to log in: ${response.body}');
    }
  }

  //! Log out a user.
  Future<bool> logoutUser(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to log out: ${response.body}');
    }
  }

  //! Fetch all users from the API.
  Future<List<User>> fetchUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  //! Fetch all connected users.
  Future<List<User>> fetchConnectedUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/connected-users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((connectedUserJson) {
        final userJson = connectedUserJson['user'];
        return User.fromJson(userJson);
      }).toList();
    } else {
      throw Exception('Failed to fetch connected users: ${response.body}');
    }
  }

  //! Update user details including role.
  Future<void> updateUser(int id, String username, String? password,
      String role, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        if (password != null) 'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  //! Delete a user by their ID.
  Future<void> deleteUser(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  //! Fetch all study cases.
  Future<List<StudyCase>> fetchStudyCases(String token) async {
    print("Fetching study cases with token: $token");
    final response = await http.get(
      Uri.parse('$baseUrl/study-cases'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((studyCase) => StudyCase.fromJson(studyCase)).toList();
    } else {
      throw Exception('Failed to fetch study cases');
    }
  }

  //! Fetch a specific study case by its ID.
  Future<StudyCase> fetchStudyCase(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/study-cases/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return StudyCase.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch study case');
    }
  }

  //! Create a new study case with a zip file.
  Future<StudyCase> createStudyCase(StudyCase studyCase, String token,
      Uint8List zipFile, String fileName) async {
    var uri = Uri.parse('$baseUrl/study-cases');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['nom_etude'] = studyCase.nomEtude;
    request.fields['date_debut'] = studyCase.dateDebut;
    request.fields['date_fin'] = studyCase.dateFin;
    request.fields['timing_attendu'] = studyCase.timingAttendu;
    request.fields['timing_reelle'] = studyCase.timingReelle;
    request.fields['cadence_attendu'] = studyCase.cadenceAttendu.toString();
    request.fields['cadence_reelle'] = studyCase.cadenceReelle.toString();

    // Add the zip file to the request
    request.files.add(http.MultipartFile.fromBytes(
      'zipFile',
      zipFile,
      filename: fileName,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return StudyCase.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create study case');
    }
  }

  //! Update study case information.
  Future<void> updateStudyCaseInfo(
      int id, StudyCase studyCase, String token) async {
    var uri = Uri.parse('$baseUrl/study-cases/$id/info');
    var jsonData = jsonEncode(studyCase.toJson());

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var response = await http.put(uri, headers: headers, body: jsonData);

    if (response.statusCode != 200) {
      throw Exception('Failed to update study case');
    }
  }

  //! Upload a zip file for an existing study case.
  Future<void> uploadStudyCaseZipFile(
      int id, Uint8List zipFile, String fileName, String token) async {
    var uri = Uri.parse('$baseUrl/study-cases/$id/upload-zip');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(http.MultipartFile.fromBytes(
      'zipFile',
      zipFile,
      filename: fileName,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload zip file');
    }
  }

  //! Delete a study case by its ID.
  Future<void> deleteStudyCase(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/study-cases/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete study case');
    }
  }

  //! Fetch all comments for a specific study case.
  Future<List<Comment>> fetchComments(int studyCaseId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/study_case/$studyCaseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  //! Add a new comment to a study case.
  Future<void> addComment(Comment comment, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user_id': comment.userId,
        'study_case_id': comment.studyCaseId,
        'comment': comment.comment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error adding comment: ${response.body}');
    }
  }

  //! Update an existing comment by its ID.
  Future<void> updateComment(int id, Comment comment, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comments/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'comment': comment.comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update comment: ${response.body}');
    }
  }

  //! Delete a comment by its ID.
  Future<void> deleteComment(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment: ${response.body}');
    }
  }

  //! Fetch B2B data from the backend
  Future<List<Map<String, dynamic>>> fetchB2BData(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/b2b'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load B2B data. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load B2B data');
    }
  }

  //! Fetch B2C data from the backend
  Future<List<Map<String, dynamic>>> fetchB2CData(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/b2c'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load B2C data. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load B2C data');
    }
  }
}
