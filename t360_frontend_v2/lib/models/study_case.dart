class StudyCase {
  //! Unique identifier for the study case.
  final int id;

  //! Name of the study (nom_etude).
  final String nomEtude;

  //! Start date of the study.
  final String dateDebut;

  //! End date of the study.
  final String dateFin;

  //! Expected timing for the study.
  final String timingAttendu;

  //! Actual timing of the study.
  final String timingReelle;

  //! Expected cadence value (rate) for the study.
  final double cadenceAttendu;

  //! Actual cadence value (rate) for the study.
  final double cadenceReelle;

  //! Path or URL to the ZIP file associated with the study case.
  final String zipFile;

  //! Constructor for the StudyCase class. All fields are required.
  StudyCase({
    required this.id, // ID is required
    required this.nomEtude, // Study name is required
    required this.dateDebut, // Start date is required
    required this.dateFin, // End date is required
    required this.timingAttendu, // Expected timing is required
    required this.timingReelle, // Actual timing is required
    required this.cadenceAttendu, // Expected cadence is required
    required this.cadenceReelle, // Actual cadence is required
    required this.zipFile, // ZIP file is required
  });

  //! Factory method to create a StudyCase instance from a JSON object.
  //! This method parses the JSON fields and converts them into the appropriate types.
  factory StudyCase.fromJson(Map<String, dynamic> json) {
    return StudyCase(
      id: json['id'], // Parse ID from the JSON
      nomEtude: json['nom_etude'], // Parse study name
      dateDebut: json['date_debut'], // Parse start date
      dateFin: json['date_fin'], // Parse end date
      timingAttendu: json['timing_attendu'], // Parse expected timing
      timingReelle: json['timing_reelle'], // Parse actual timing
      cadenceAttendu: double.parse(
          json['cadence_attendu']), // Parse expected cadence as a double
      cadenceReelle: double.parse(
          json['cadence_reelle']), // Parse actual cadence as a double
      zipFile: json['zipFile'], // Parse the ZIP file path or URL
    );
  }

  //! Method to convert a StudyCase instance back into a JSON object.
  //! Useful when sending data back to a server in a structured format.
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID in the JSON
      'nom_etude': nomEtude, // Include study name
      'date_debut': dateDebut, // Include start date
      'date_fin': dateFin, // Include end date
      'timing_attendu': timingAttendu, // Include expected timing
      'timing_reelle': timingReelle, // Include actual timing
      'cadence_attendu':
          cadenceAttendu.toString(), // Convert expected cadence to string
      'cadence_reelle':
          cadenceReelle.toString(), // Convert actual cadence to string
      'zipFile': zipFile, // Include the ZIP file path or URL
    };
  }
}
