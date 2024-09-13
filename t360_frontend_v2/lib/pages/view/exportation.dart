import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../components/my_filter.dart'; // Import the custom MyFilter widget

class Exportation extends StatefulWidget {
  const Exportation({super.key});

  @override
  State<Exportation> createState() => _ExportationState();
}

class _ExportationState extends State<Exportation> {
  List<Map<String, dynamic>> _selectedItems =
      []; // List to hold selected filter items

  //! Method to show the multi-select filter dialog
  void _showMultiSelect() async {
    final List<Map<String, dynamic>> items = [
      {
        "category": "Fruits",
        "items": [
          {
            "name": "Apple",
            "subItems": ["Green Apple", "Red Apple"] // Sub-items for Apple
          },
          {
            "name": "Banana",
            "subItems": [
              "Cavendish Banana",
              "Red Banana"
            ] // Sub-items for Banana
          }
        ]
      },
      {
        "category": "Vegetables",
        "items": [
          {
            "name": "Carrot",
            "subItems": [
              "Nantes Carrot",
              "Imperator Carrot"
            ] // Sub-items for Carrot
          },
          {
            "name": "Broccoli",
            "subItems": [
              "Calabrese Broccoli",
              "Sprouting Broccoli"
            ] // Sub-items for Broccoli
          }
        ]
      }
    ];

    //! Show filter dialog and capture selected items
    final List<List<String>>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyFilter(
          items: items, // Pass filter options
          selectedItems: _selectedItems
              .expand((item) => item['subItems'].map((subItem) => [
                    item['category'] as String,
                    item['items'] as String,
                    subItem['name'] as String
                  ]))
              .toList()
              .cast<List<String>>(), // Flatten selected items list
        );
      },
    );

    //! Process selected items if the user made a selection
    if (results != null && mounted) {
      setState(() {
        Map<String, Set<String>> groupedItems = {};

        for (var item in results) {
          String category = item[0]; // Category (e.g., Fruits, Vegetables)
          String mainItem = item[1]; // Main item (e.g., Apple, Carrot)
          String subItem = item[2]; // Sub-item (e.g., Green Apple)

          //! Group selected items by category and main item
          if (!groupedItems.containsKey('$category|$mainItem')) {
            groupedItems['$category|$mainItem'] = {};
          }

          groupedItems['$category|$mainItem']!.add(subItem);
        }

        //! Update the selected items list
        _selectedItems = groupedItems.entries.map((entry) {
          var keys = entry.key.split('|');
          return {
            'category': keys[0],
            'items': keys[1],
            'subItems': entry.value.map((subItem) {
              return {
                'name': subItem,
                'number': 1, // Default number (can be customized)
              };
            }).toList(),
            'isExpanded': false,
          };
        }).toList();
      });
    }
  }

  //! Main build method for the Exportation screen
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Set the background color
      body: Column(
        children: [
          //! Filter and Export buttons
          _buildFilterExportRow(theme),
          Expanded(
            flex: 2,
            //! Display message if no filter is selected
            child: _selectedItems.isEmpty
                ? Center(
                    child: Text(
                      'No filter selected',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Style the text
                      ),
                    ),
                  )
                //! Display selected items if filters are applied
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: _selectedItems.map<Widget>((item) {
                        return _buildExpansionTile(item,
                            theme); // Create expansion tiles for each item
                      }).toList(),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  //! Build row containing the Filter and Export buttons
  Widget _buildFilterExportRow(ThemeData theme) {
    return Row(
      children: [
        //! Filter button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _showMultiSelect, // Show multi-select filter dialog
              child: _buildFilterExportContainer(
                theme,
                'F I L T E R',
                FluentIcons.arrow_sort_down_lines_24_filled, // Filter icon
              ),
            ),
          ),
        ),
        //! Export button (currently only visual, no action)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: _buildFilterExportContainer(
                theme,
                'E X P O R T',
                FluentIcons.share_24_filled, // Export icon
              ),
            ),
          ),
        ),
      ],
    );
  }

  //! Build the Filter/Export container widget (used for both buttons)
  Widget _buildFilterExportContainer(
      ThemeData theme, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.all(Radius.circular(10)), // Rounded corners
        color: theme.colorScheme.primary, // Primary color from theme
      ),
      width: double.infinity, // Full width of the container
      height: 50, // Height of the container
      child: ListTile(
        title: Text(
          title, // Display the title ('FILTER' or 'EXPORT')
          style: TextStyle(
            color: theme.textTheme.labelLarge!.color, // Text color from theme
          ),
        ),
        trailing: Icon(
          icon, // Display the icon (filter or export)
          color: Theme.of(context)
              .textTheme
              .labelLarge
              ?.color, // Icon color from theme
          size: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.fontSize, // Icon size from theme
        ),
      ),
    );
  }

  //! Build the expansion tile for displaying selected items
  Widget _buildExpansionTile(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Bottom margin between tiles
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners for the tile
        color:
            Theme.of(context).listTileTheme.tileColor, // Tile color from theme
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Shadow color
            blurRadius: 4, // Blur radius for shadow
            offset: Offset(2, 2), // Shadow offset
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent, // Remove divider color
            splashColor: Colors.transparent, // Remove splash effect
            highlightColor: Colors.transparent, // Remove highlight effect
          ),
          child: ExpansionTile(
            iconColor: theme.colorScheme.onSurface, // Icon color for expansion
            title: Text(
              item['items'], // Display the main item (e.g., Apple, Carrot)
              style: TextStyle(
                fontWeight: FontWeight.bold, // Bold text
                color: theme.colorScheme.onSurface, // Text color from theme
              ),
            ),
            //! Display the sub-items inside the expansion tile
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    _buildItemTable(item, theme), // Build table with sub-items
              ),
            ],
          ),
        ),
      ),
    );
  }

  //! Build the table inside the expansion tile displaying sub-items
  Widget _buildItemTable(Map<String, dynamic> item, ThemeData theme) {
    return Table(
      //! Table borders
      border: TableBorder(
        horizontalInside: BorderSide(
          color: theme.textTheme.bodyLarge?.color ??
              Colors.black, // Horizontal borders
          width: 1,
        ),
        verticalInside: BorderSide(
          color: theme.textTheme.bodyLarge?.color ??
              Colors.black, // Vertical borders
          width: 1,
        ),
        borderRadius:
            BorderRadius.circular(10), // Rounded corners for the table
      ),
      columnWidths: const {
        0: FlexColumnWidth(2), // Subitem column width
        1: FlexColumnWidth(1), // Number column width
        2: FlexColumnWidth(1), // Percentage column width
      },
      //! Table rows (header + data rows)
      children: [
        //! Table header row
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .listTileTheme
                .tileColor, // Header background color
          ),
          children: [
            _buildTableCell('Subitem', theme,
                isHeader: true), // Header cell (Subitem)
            _buildTableCell('Number', theme,
                isHeader: true), // Header cell (Number)
            _buildTableCell('Percentage', theme,
                isHeader: true), // Header cell (Percentage)
          ],
        ),
        //! Table data rows
        ...item['subItems'].map<TableRow>((subItem) {
          return TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .listTileTheme
                  .tileColor, // Row background color
            ),
            children: [
              _buildTableCell(subItem['name'], theme), // Subitem name
              _buildTableCell(subItem['number'].toString(), theme), // Number
              _buildTableCell(
                (subItem['number'] /
                            item['subItems']
                                .fold(0, (sum, el) => sum + el['number']) *
                            100)
                        .toStringAsFixed(2) +
                    '%', // Calculate percentage
                theme,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  //! Build table cell widget
  Widget _buildTableCell(String text, ThemeData theme,
      {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Padding inside the cell
      child: Text(
        text, // Display the cell text
        style: TextStyle(
          fontWeight: isHeader
              ? FontWeight.bold
              : FontWeight.normal, // Bold for headers
          fontSize: isHeader ? 16 : 14, // Font size for headers and data
          color: isHeader
              ? theme.colorScheme.onSurfaceVariant // Header text color
              : theme.colorScheme.onSurface, // Data text color
        ),
      ),
    );
  }
}
