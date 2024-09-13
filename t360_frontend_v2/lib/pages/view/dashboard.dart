import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For using Provider to access AuthProvider

import '../../components/my_box.dart'; // Importing custom widget for displaying box info
import '../../components/my_constants.dart'; // Constants used in the application
import '../../providers/auth_provider.dart'; // Importing AuthProvider for authentication token

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context,
        listen: false); // Access the AuthProvider
    final token = authProvider.token; // Retrieve the authentication token

    //! Check if the user is authenticated
    if (token == null) {
      return Center(
        child: Text(
          'Please log in to access the dashboard', // Show message if not logged in
          style:
              Theme.of(context).textTheme.headlineSmall, // Styling the message
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    //! Layout for the dashboard
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height =
            MediaQuery.of(context).size.height * 0.4; // Set height for boxes
        return Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false), // Disable scrollbars
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //! Title container for B2B information
                      buildTitleContainer(context, 'B2B Infos'),
                      //! Horizontal scroll view for B2B data
                      buildHorizontalScrollView(
                        height,
                        boxData.sublist(0, 5), // Get first 5 items for B2B
                        b2bLabels,
                        context,
                        screenWidth,
                        screenHeight,
                      ),
                      //! Title container for B2C information
                      buildTitleContainer(context, 'B2C Infos'),
                      //! Horizontal scroll view for B2C data
                      buildHorizontalScrollView(
                        height,
                        boxData.sublist(5, 10), // Get next 5 items for B2C
                        b2cLabels,
                        context,
                        screenWidth,
                        screenHeight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //! Build method for the title container (e.g., 'B2B Infos', 'B2C Infos')
  Widget buildTitleContainer(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primary, // Primary color from theme
        borderRadius: const BorderRadius.all(
          Radius.circular(10), // Rounded corners for the container
        ),
      ),
      padding: const EdgeInsets.all(8.0), // Padding inside the container
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical margin
      child: Text(
        title, // Display the passed title
        style: Theme.of(context)
            .textTheme
            .displaySmall, // Style the title using the theme
      ),
    );
  }

  //! Build method for the horizontal scroll view containing the data boxes
  Widget buildHorizontalScrollView(
    double height,
    List<Map<String, dynamic>> data, // Data for the boxes
    List<String> labels, // Labels for the boxes
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return SizedBox(
      height: height, // Set the height of the scrollable area
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Horizontal scroll direction
          child: Row(
            //! Generate the boxes for the data
            children: List.generate(data.length, (index) {
              final itemData = data[index]; // Get the data for the current box
              final label = labels[index]; // Get the label for the current box
              return Padding(
                padding:
                    const EdgeInsets.only(right: 8.0), // Padding between boxes
                child: GestureDetector(
                  //! Show an alert dialog with more details when the box is tapped
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return buildAlertDialog(
                          context,
                          label,
                          itemData,
                          screenWidth,
                          screenHeight,
                        );
                      },
                    );
                  },
                  //! Custom widget displaying the box with percentage, number, and label
                  child: MyBox(
                    boxSize: height, // Size of the box
                    percentage: itemData['percentage'], // Percentage value
                    number: itemData['number'], // Number value
                    label: label, // Label for the box
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  //! Build method for the alert dialog displaying details when a box is clicked
  Widget buildAlertDialog(
    BuildContext context,
    String label,
    Map<String, dynamic> itemData,
    double screenWidth,
    double screenHeight,
  ) {
    return Center(
      child: AlertDialog(
        backgroundColor: Theme.of(context)
            .listTileTheme
            .tileColor, // Background color from theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align close button to the right
          children: [
            Text(
              'Details for $label', // Display details for the selected item
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface, // Text color from theme
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close, // Close icon for the dialog
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Icon color from theme
              ),
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
            ),
          ],
        ),
        //! Content of the dialog displaying the table with details
        content: SizedBox(
          width: screenWidth * 0.5, // Width of the dialog content
          height: screenHeight * 0.5, // Height of the dialog content
          child: SingleChildScrollView(
            child: buildTable(
                context, label, itemData), // Build the table with details
          ),
        ),
      ),
    );
  }

  //! Build method for the table inside the alert dialog
  Widget buildTable(
      BuildContext context, String label, Map<String, dynamic> itemData) {
    return Table(
      //! Table borders
      border: TableBorder(
        horizontalInside: BorderSide(
          color:
              Theme.of(context).colorScheme.primary, // Border color from theme
          width: 1, // Border width
        ),
        verticalInside: BorderSide(
          color:
              Theme.of(context).colorScheme.primary, // Border color from theme
          width: 1,
        ),
        borderRadius:
            BorderRadius.circular(10), // Rounded corners for the table
      ),
      columnWidths: const {
        0: FlexColumnWidth(2), // First column (Subitem) width
        1: FlexColumnWidth(1), // Second column (Number) width
        2: FlexColumnWidth(1), // Third column (Percentage) width
      },
      //! Table rows displaying the subitem, number, and percentage
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .listTileTheme
                .tileColor, // Background color for the row
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Subitem', // Table header
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant, // Text color from theme
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Number', // Table header
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Percentage', // Table header
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        //! Table row displaying the data (label, number, percentage)
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .listTileTheme
                .tileColor, // Background color for the row
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                label, // Display the label as the subitem
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface, // Text color from theme
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '${itemData['number']}', // Display the number
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface, // Text color from theme
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '${itemData['percentage'].toStringAsFixed(1)}%', // Display the percentage
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface, // Text color from theme
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
