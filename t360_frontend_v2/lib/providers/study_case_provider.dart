import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/study_case.dart';
import '../services/api_service.dart';

class StudyCaseProvider with ChangeNotifier {
  final ApiService _apiService; // Instance of ApiService for API calls
  List<StudyCase> _studyCases = []; // List of all study cases

  //! Getter for the list of all study cases
  List<StudyCase> get studyCases => _studyCases;

  StudyCaseProvider({required ApiService apiService})
      : _apiService = apiService;

  //! Fetch all study cases from the API and store them in the provider
  Future<void> fetchStudyCases(String token) async {
    try {
      print("Fetching study cases...");
      _studyCases = await _apiService
          .fetchStudyCases(token); // Fetch study cases from API
      print("Study cases fetched successfully.");
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print("Error fetching study cases: $e");
      rethrow;
    }
  }

  //! Add a new study case and store it in the provider
  Future<void> addStudyCase(StudyCase studyCase, String token,
      Uint8List zipFile, String fileName) async {
    try {
      print("Adding new study case: ${studyCase.nomEtude}");
      final newStudyCase = await _apiService.createStudyCase(
          studyCase, token, zipFile, fileName); // Add new study case via API
      _studyCases.add(newStudyCase); // Add new study case to the list
      print("Study case added successfully.");
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print("Error adding study case: $e");
      rethrow;
    }
  }

  //! Update an existing study case
  Future<void> updateStudyCase(int id, StudyCase updatedStudyCase, String token,
      {Uint8List? zipFile, String? fileName}) async {
    try {
      print("Updating study case information for ID: $id");

      // Update the study case information first
      await _apiService.updateStudyCaseInfo(id, updatedStudyCase, token);

      // If a new zip file is provided, upload it separately
      if (zipFile != null && fileName != null) {
        print("Uploading new zip file for study case ID: $id");
        await _apiService.uploadStudyCaseZipFile(id, zipFile, fileName, token);
      }

      // Update the provider state
      final index = _studyCases.indexWhere((sc) => sc.id == id);
      if (index != -1) {
        _studyCases[index] = updatedStudyCase;
        print("Study case updated in provider.");
        notifyListeners();
      } else {
        print("Study case with ID: $id not found in provider.");
      }
    } catch (e) {
      print("Error updating study case: $e");
      rethrow;
    }
  }

  //! Delete a study case and remove it from the provider
  Future<void> deleteStudyCase(int id, String token) async {
    try {
      print("Deleting study case with ID: $id");
      await _apiService.deleteStudyCase(id, token); // Delete study case via API
      _studyCases
          .removeWhere((sc) => sc.id == id); // Remove study case from the list
      print("Study case deleted successfully.");
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print("Error deleting study case: $e");
      rethrow;
    }
  }
}
