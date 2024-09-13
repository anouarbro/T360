import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/study_case.dart'; // Import the StudyCase model
import '../../providers/auth_provider.dart'; // Import the AuthProvider
import '../../providers/study_case_provider.dart'; // Import the StudyCaseProvider
import 'comment.dart'; // Import the CommentScreen

//! Main screen for displaying and managing study cases
class StudyCaseScreen extends StatelessWidget {
  const StudyCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //! Access the auth provider to get the token
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    //! If user is not authenticated, show loading spinner
    if (token == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //! Fetch study cases using FutureBuilder
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<StudyCaseProvider>(context, listen: false)
            .fetchStudyCases(token),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); //! Show loading indicator while waiting
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); //! Display error message if something went wrong
          } else {
            return Consumer<StudyCaseProvider>(
              builder: (ctx, studyCaseProvider, _) {
                //! If no study cases are available, show a message
                if (studyCaseProvider.studyCases.isEmpty) {
                  return const Center(child: Text('No study cases found'));
                }
                //! Build list of study cases
                return ListView.builder(
                  itemCount: studyCaseProvider.studyCases.length,
                  itemBuilder: (ctx, index) {
                    final studyCase = studyCaseProvider.studyCases[index];
                    return ListTile(
                      title: Text(studyCase.nomEtude),
                      subtitle: Text(
                          'Start at: ${studyCase.dateDebut} - End at: ${studyCase.dateFin}'),
                      //! Remove animation when navigating to comments
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return CommentScreen(studyCaseId: studyCase.id);
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child; //! No animation transition
                            },
                          ),
                        );
                      },
                      trailing: _buildActionButtons(context, studyCase),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      //! Floating action button to create a new study case
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateStudyCaseDialog(
              context); //! Open dialog to create study case
        },
        tooltip: 'Create New Study Case',
        child: const Icon(Icons.add),
      ),
    );
  }

  //! Build action buttons for each study case (view, edit, delete)
  Widget _buildActionButtons(BuildContext context, StudyCase studyCase) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_red_eye),
          onPressed: () {
            _showViewStudyCaseDialog(
                context, studyCase); //! View study case details
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _showEditStudyCaseDialog(context, studyCase); //! Edit study case
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            //! Confirm deletion
            final confirmDelete = await _showDeleteConfirmationDialog(context);
            if (confirmDelete) {
              await Provider.of<StudyCaseProvider>(context, listen: false)
                  .deleteStudyCase(
                      studyCase.id, token!); //! Delete the study case
            }
          },
        ),
      ],
    );
  }

  //! Show dialog for creating a new study case
  Future<void> _showCreateStudyCaseDialog(BuildContext context) async {
    final nomEtudeController = TextEditingController();
    final dateDebutController = TextEditingController();
    final dateFinController = TextEditingController();
    final timingAttenduController = TextEditingController();
    final timingReelleController = TextEditingController();
    final cadenceAttenduController = TextEditingController();
    final cadenceReelleController = TextEditingController();
    final zipFileNameController = TextEditingController();

    Uint8List? zipFile;
    String? fileName;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: screenSize.width * 0.5,
                height: screenSize.height * 0.6,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Create New Study Case',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //! Input fields for study case information
                            _buildTextField(nomEtudeController, 'Study Name'),
                            _buildDatePicker(
                                context, dateDebutController, 'Start Date'),
                            _buildDatePicker(
                                context, dateFinController, 'End Date'),
                            _buildTimePicker(context, timingAttenduController,
                                'Expected Timing'),
                            _buildTimePicker(
                                context, timingReelleController, 'Real Timing'),
                            _buildTextField(
                                cadenceAttenduController, 'Expected Cadence'),
                            _buildTextField(
                                cadenceReelleController, 'Real Cadence'),
                            _buildFilePicker(context, 'Upload Zip File',
                                (bytes, name) {
                              zipFile = bytes;
                              fileName = name;
                              zipFileNameController.text = name;
                            }, zipFileNameController),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                    if (!isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context)
                                .pop(), //! Close the dialog
                          ),
                          TextButton(
                            child: const Text('Create'),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                //! Ensure all fields are filled
                                if (nomEtudeController.text.isEmpty ||
                                    dateDebutController.text.isEmpty ||
                                    dateFinController.text.isEmpty ||
                                    timingAttenduController.text.isEmpty ||
                                    timingReelleController.text.isEmpty ||
                                    zipFile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please fill out all fields')),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                final studyCaseProvider =
                                    Provider.of<StudyCaseProvider>(context,
                                        listen: false);

                                //! Create new study case
                                StudyCase newStudyCase = StudyCase(
                                  id: 0,
                                  nomEtude: nomEtudeController.text,
                                  dateDebut: dateDebutController.text,
                                  dateFin: dateFinController.text,
                                  timingAttendu: timingAttenduController.text,
                                  timingReelle: timingReelleController.text,
                                  cadenceAttendu: double.parse(
                                      cadenceAttenduController.text),
                                  cadenceReelle: double.parse(
                                      cadenceReelleController.text),
                                  zipFile: '',
                                );

                                //! Add the new study case with the attached file
                                await studyCaseProvider.addStudyCase(
                                    newStudyCase,
                                    authProvider.token!,
                                    zipFile!,
                                    fileName!);

                                Navigator.of(context)
                                    .pop(); //! Close the dialog
                              } catch (e) {
                                print('Error creating study case: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'An error occurred while creating the study case')),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //! Helper method to confirm deletion of a study case
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this study case?'),
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

  //! Dialog to view study case details
  void _showViewStudyCaseDialog(BuildContext context, StudyCase studyCase) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: screenSize.width * 0.5,
            height: screenSize.height * 0.6,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //! Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Study Case Details'),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          Navigator.of(context).pop(), //! Close dialog
                    ),
                  ],
                ),
                //! Display study case details
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildReadOnlyField('Study Name', studyCase.nomEtude),
                        _buildReadOnlyField('Start Date', studyCase.dateDebut),
                        _buildReadOnlyField('End Date', studyCase.dateFin),
                        _buildReadOnlyField(
                            'Expected Timing', studyCase.timingAttendu),
                        _buildReadOnlyField(
                            'Real Timing', studyCase.timingReelle),
                        _buildReadOnlyField('Expected Cadence',
                            studyCase.cadenceAttendu.toString()),
                        _buildReadOnlyField(
                            'Real Cadence', studyCase.cadenceReelle.toString()),
                        _buildReadOnlyField('File URL', studyCase.zipFile),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(), //! Close dialog
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//! Method to show the dialog for editing a study case
  void _showEditStudyCaseDialog(BuildContext context, StudyCase studyCase) {
    // Controllers for form fields
    final nomEtudeController = TextEditingController(text: studyCase.nomEtude);
    final dateDebutController =
        TextEditingController(text: studyCase.dateDebut);
    final dateFinController = TextEditingController(text: studyCase.dateFin);
    final timingAttenduController =
        TextEditingController(text: studyCase.timingAttendu);
    final timingReelleController =
        TextEditingController(text: studyCase.timingReelle);
    final cadenceAttenduController =
        TextEditingController(text: studyCase.cadenceAttendu.toString());
    final cadenceReelleController =
        TextEditingController(text: studyCase.cadenceReelle.toString());
    final zipFileNameController = TextEditingController();

    Uint8List? zipFile; // Variable to store the zip file
    String? fileName; // Variable to store the file name
    bool isLoading = false; // Track loading state

    //! Show a dialog for editing the study case
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: screenSize.width * 0.5,
                height: screenSize.height * 0.6,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Edit Study Case', //! Dialog title
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //! Input fields for the study case details
                            _buildTextField(nomEtudeController, 'Study Name'),
                            _buildDatePicker(
                                context, dateDebutController, 'Start Date'),
                            _buildDatePicker(
                                context, dateFinController, 'End Date'),
                            _buildTimePicker(context, timingAttenduController,
                                'Expected Timing'),
                            _buildTimePicker(
                                context, timingReelleController, 'Real Timing'),
                            _buildTextField(
                                cadenceAttenduController, 'Expected Cadence'),
                            _buildTextField(
                                cadenceReelleController, 'Real Cadence'),
                            _buildFilePicker(context, 'Upload Zip File',
                                (bytes, name) {
                              zipFile = bytes;
                              fileName = name;
                              zipFileNameController.text = name;
                            }, zipFileNameController),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                    //! Action buttons for saving or cancelling the edit
                    if (!isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Save'),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                //! Validation of required fields
                                if (nomEtudeController.text.isEmpty ||
                                    dateDebutController.text.isEmpty ||
                                    dateFinController.text.isEmpty ||
                                    timingAttenduController.text.isEmpty ||
                                    timingReelleController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please fill out all fields')),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                //! Update the study case with the new data
                                final studyCaseProvider =
                                    Provider.of<StudyCaseProvider>(context,
                                        listen: false);
                                final token = Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .token!;

                                await studyCaseProvider.updateStudyCase(
                                  studyCase.id,
                                  StudyCase(
                                    id: studyCase.id,
                                    nomEtude: nomEtudeController.text,
                                    dateDebut: dateDebutController.text,
                                    dateFin: dateFinController.text,
                                    timingAttendu: timingAttenduController.text,
                                    timingReelle: timingReelleController.text,
                                    cadenceAttendu: double.parse(
                                        cadenceAttenduController.text),
                                    cadenceReelle: double.parse(
                                        cadenceReelleController.text),
                                    zipFile: '', //! Placeholder for zipFile
                                  ),
                                  token,
                                  zipFile:
                                      zipFile, //! Pass the zip file if uploaded
                                  fileName:
                                      fileName, //! Pass the file name if uploaded
                                );

                                Navigator.of(context).pop();
                                studyCaseProvider.fetchStudyCases(token);
                              } catch (e, stackTrace) {
                                print('Error updating study case: $e');
                                print(stackTrace);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'An error occurred while updating the study case')),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //! Helper to build readonly text field
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 7, child: Text(value)),
        ],
      ),
    );
  }

  //! Input text field builder
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  //! Build date picker
  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toIso8601String().split('T').first;
        }
      },
    );
  }

  //! Build time picker
  Widget _buildTimePicker(
      BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          final now = DateTime.now();
          final dateTime = DateTime(now.year, now.month, now.day,
              pickedTime.hour, pickedTime.minute, 0);
          final formattedTime =
              dateTime.toIso8601String().split('T').last.substring(0, 8);
          controller.text = formattedTime;
        }
      },
    );
  }

  //! Build file picker for zip files
  Widget _buildFilePicker(
      BuildContext context,
      String label,
      Function(Uint8List, String) onFilePicked,
      TextEditingController fileNameController) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: fileNameController,
            decoration: InputDecoration(labelText: label),
            readOnly: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              onFilePicked(
                  result.files.single.bytes!, result.files.single.name);
            }
          },
        ),
      ],
    );
  }
}
