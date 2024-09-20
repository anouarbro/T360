import 'dart:html' as html; // For web download

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../services/api_service.dart';

class ExportationProvider with ChangeNotifier {
  List<Map<String, dynamic>> b2bItems = [];
  List<Map<String, dynamic>> b2cItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  bool isLoading = false;

  final ApiService _apiService = ApiService();

  //! Fetch data from Laravel API using token
  Future<void> fetchData(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch B2B and B2C data from the API
      List<Map<String, dynamic>> rawB2BItems =
          await _apiService.fetchB2BData(token);
      List<Map<String, dynamic>> rawB2CItems =
          await _apiService.fetchB2CData(token);

      // Safeguard: Check if data is empty before processing
      if (rawB2BItems.isNotEmpty) {
        b2bItems = rawB2BItems.map((item) {
          Map<String, dynamic> newItem = Map.of(item);
          newItem.remove('id');
          return newItem;
        }).toList();
      }

      if (rawB2CItems.isNotEmpty) {
        b2cItems = rawB2CItems.map((item) {
          Map<String, dynamic> newItem = Map.of(item);
          newItem.remove('id');
          return newItem;
        }).toList();
      }

      print("B2B Items: $b2bItems");
      print("B2C Items: $b2cItems");
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //! Update selected items
  void updateSelectedItems(List<Map<String, dynamic>> items) {
    selectedItems = items;
    notifyListeners();
  }

  //! Placeholder function for exporting items
  Future<void> exportItems(List<Map<String, dynamic>> selectedItems) async {
    // Ensure there's selected data
    if (selectedItems.isNotEmpty) {
      // Create an Excel document
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Determine if the data is B2B or B2C based on the first item's structure
      bool isB2B = selectedItems.first.containsKey('EntrepriseID');

      // Define the headers for B2B and B2C
      List<String> b2bHeaders = [
        'EntrepriseID',
        'Nom_du_champ',
        'TEL',
        'TEL2',
        'TEL3',
        'SIRET',
        'dateCreationUniteLegale',
        'trancheEffectifsUniteLegale',
        'categorieEntreprise',
        'nomUniteLegale_def',
        'categorieJuridiqueUniteLegale',
        'activitePrincipaleUniteLegale_def',
        'trancheEffectifsEtablissement',
        'etablissementSiege',
        'adresse',
        'codePostalEtablissement',
        'libelleCommuneEtablissement',
        'codeCommuneEtablissement',
        'DEPT',
        'etatAdministratifEtablissement',
        'NIVI',
        'TAILLEII',
        'SECTEUR',
        'SECTEUR_QUOTA',
        'UDA9_Info_Fichier',
        'Region13',
        'Confirmation_du_nom',
        'DATEI',
        'NBR_APPELI',
        'RESULTI',
        'SEEDI'
      ];

      List<String> b2cHeaders = [
        'Nom',
        'TEL',
        'Age',
        'Sexe',
        'DEP',
        'UDA9',
        'Region13',
        'Type_TEL',
        'Habitat',
        'CSP_Interviewe',
        'SEEDI',
        'Heure_FIN'
      ];

      // Choose the appropriate headers based on the data type (B2B or B2C)
      List<String> headers = isB2B ? b2bHeaders : b2cHeaders;

      try {
        // Append the headers to the sheet using a foreach loop
        for (int i = 0; i < headers.length; i++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .value = headers[i];
        }

        // Insert the selected items into the sheet
        for (int rowIndex = 0; rowIndex < selectedItems.length; rowIndex++) {
          Map<String, dynamic> item = selectedItems[rowIndex];
          for (int colIndex = 0; colIndex < headers.length; colIndex++) {
            String header = headers[colIndex];
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: colIndex, rowIndex: rowIndex + 1))
                .value = item[header];
          }
        }

        // Save the Excel file as bytes
        var bytes = excel.save();

        // Encode and create Blob to download in the browser
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create an anchor element and simulate click to download the file
        html.AnchorElement(href: url)
          ..setAttribute(
              'download', isB2B ? 'b2b_export.xlsx' : 'b2c_export.xlsx')
          ..click();

        // Cleanup URL
        html.Url.revokeObjectUrl(url);
        print('File generated with headers only.');
      } catch (e) {
        // Catch any error and ignore it, focusing on header generation only
        print('Error during file generation: $e');
      }
    } else {
      print('No data available to export.');
    }
  }

  //! Return an item based on some property other than 'id'
  Map<String, dynamic>? findItemByProperty(String property, String value) {
    // Search in B2B items first
    final b2bItem = b2bItems.firstWhere(
      (item) => item[property].toString() == value,
      orElse: () => {},
    );

    // If not found, search in B2C items
    if (b2bItem.isNotEmpty) {
      return b2bItem;
    } else {
      return b2cItems.firstWhere(
        (item) => item[property].toString() == value,
        orElse: () => {},
      );
    }
  }
}
