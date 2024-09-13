import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBox extends StatelessWidget {
  // Parameters for customization
  final double? boxSize; // Size of the box (optional)
  final double? percentage; // Percentage value for the chart (optional)
  final int? number; // Number to display (optional)
  final String label; // Label to display at the bottom of the box

  const MyBox({
    super.key,
    this.boxSize, // Initialize optional box size
    this.percentage, // Initialize optional percentage
    this.number, // Initialize optional number
    required this.label, // Label is required
  });

  @override
  Widget build(BuildContext context) {
    // Theme-related variables for colors
    final theme = Theme.of(context);
    final Color chartColor = theme.colorScheme.primary; // Main color from theme
    final Color? backgroundColor =
        theme.listTileTheme.tileColor; // Background color for box
    final Color lighterChartColor = chartColor
        .withOpacity(0.4); // Lighter shade for unused portion of chart

    // Data for the pie chart
    List<PieChartSectionData> pieChartData = [
      PieChartSectionData(
        color: chartColor, // Use the main color for the percentage portion
        value: percentage ?? 0, // Display the provided percentage
        title: '', // No title inside the pie chart
        radius: 10.0, // Thin ring for pie chart
        titlePositionPercentageOffset: 0.55, // Positioning inside the ring
      ),
      PieChartSectionData(
        color: lighterChartColor, // Use lighter color for remainder
        value: 100 - (percentage ?? 0), // Remainder percentage
        title: '', // No title inside the pie chart
        radius: 10.0, // Thin ring for pie chart
        titlePositionPercentageOffset: 0.55,
      ),
    ];

    // Box layout with padding
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: boxSize ?? 150, // Box width (default 150)
        height: boxSize ?? 150, // Box height (default 150)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), // Rounded corners for the box
          color: backgroundColor, // Adapt background color based on theme
        ),
        child: Stack(
          children: [
            //! Pie chart with percentage data
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  sections: pieChartData, // Data for the chart
                  borderData:
                      FlBorderData(show: false), // No border for the chart
                  sectionsSpace: 0, // No space between sections
                  centerSpaceRadius:
                      60, // Space in the center for displaying data
                ),
              ),
            ),
            //! Display percentage and number in the center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //! Percentage text
                  Text(
                    '${percentage?.toStringAsFixed(1) ?? '0.0'}%', // Display the percentage with one decimal
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall, // Style based on theme
                  ),
                  const SizedBox(
                      height: 4), // Space between percentage and number

                  //! Number text
                  Text(
                    '$number', // Display the number
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge, // Style based on theme
                  ),
                ],
              ),
            ),
            //! Label at the bottom of the box
            Align(
              alignment:
                  Alignment.bottomCenter, // Align label to the bottom center
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label, // Display the passed label
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge, // Style the label based on theme
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
