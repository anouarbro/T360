import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/my_filter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exportation_provider.dart';

class Exportation extends StatefulWidget {
  const Exportation({super.key});

  @override
  _ExportationState createState() => _ExportationState();
}

class _ExportationState extends State<Exportation> {
  int _lastSelectedTabIndex = 0; // Track the last selected tab index

  @override
  void initState() {
    super.initState();
    // Fetch the B2B and B2C data using the token from AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token; // Get the user token
      print("Token retrieved: $token"); // Debugging log

      if (token != null) {
        Provider.of<ExportationProvider>(context, listen: false)
            .fetchData(token)
            .then((_) {
          print("Data fetched successfully");
        }).catchError((error) {
          print("Error fetching data: $error");
        });
      } else {
        // Handle case where token is null
        print('No token available');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exportationProvider = Provider.of<ExportationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Filter and Export buttons
          _buildFilterExportRow(theme, exportationProvider),
          Expanded(
            flex: 2,
            child: exportationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : exportationProvider.selectedItems.isEmpty
                    ? Center(
                        child: Text(
                          'No filter selected',
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: exportationProvider.selectedItems
                              .where((item) => _isValidItem(
                                  item)) // Ensure valid items are displayed
                              .map<Widget>((item) {
                            return _buildExpansionTile(item, theme);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Check if the item is valid (has sufficient information)
  bool _isValidItem(Map<String, dynamic> item) {
    return (item['Nom_du_champ'] != null &&
            item['Nom_du_champ'].toString().isNotEmpty) ||
        (item['Nom'] != null && item['Nom'].toString().isNotEmpty);
  }

  Widget _buildFilterExportRow(ThemeData theme, ExportationProvider provider) {
    return Row(
      children: [
        // Filter button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _showMultiSelect,
              child: _buildFilterExportContainer(
                theme,
                'F I L T E R',
                Icons.filter_list,
              ),
            ),
          ),
        ),
        // Export button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Avoid calling any build-affecting logic directly in onTap
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final exportationProvider =
                      Provider.of<ExportationProvider>(context, listen: false);
                  if (exportationProvider.selectedItems.isNotEmpty) {
                    exportationProvider
                        .exportItems(exportationProvider.selectedItems);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No items selected to export')),
                    );
                  }
                });
              },
              child: _buildFilterExportContainer(
                theme,
                'E X P O R T',
                Icons.share,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFilterExportContainer(
      ThemeData theme, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: theme.colorScheme.primary,
      ),
      width: double.infinity,
      height: 50,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: theme.textTheme.labelLarge!.color,
          ),
        ),
        trailing: Icon(
          icon,
          color: theme.textTheme.labelLarge?.color,
          size: theme.textTheme.headlineMedium?.fontSize,
        ),
      ),
    );
  }

  Widget _buildExpansionTile(Map<String, dynamic> item, ThemeData theme) {
    // Ensure item data is handled properly to avoid null errors
    String title = item['Nom_du_champ'] ?? item['Nom'] ?? 'Unknown Item';

    // Filter out empty subItems
    List subItems = item.entries
        .where((entry) =>
            entry.key != 'Nom_du_champ' &&
            entry.key != 'Nom' &&
            entry.value != null &&
            entry.value.toString().isNotEmpty)
        .map((entry) => {'label': entry.key, 'value': entry.value.toString()})
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.listTileTheme.tileColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ExpansionTile(
          iconColor: theme.colorScheme.onSurface,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          children: subItems.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No details available"),
                  ),
                ]
              : subItems.map((subItem) {
                  return ListTile(
                    title: Text(
                      '${subItem['label']}: ${subItem['value']}',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  // Show filter dialog with last selected tab index
  void _showMultiSelect() async {
    final exportationProvider =
        Provider.of<ExportationProvider>(context, listen: false);

    final List<Map<String, dynamic>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyFilter(
          b2bItems: exportationProvider.b2bItems,
          b2cItems: exportationProvider.b2cItems,
          selectedItems: exportationProvider.selectedItems,
          initialTabIndex: _lastSelectedTabIndex, // Pass last selected tab
        );
      },
    );

    if (results != null && mounted) {
      exportationProvider.updateSelectedItems(results);
    }
  }
}
