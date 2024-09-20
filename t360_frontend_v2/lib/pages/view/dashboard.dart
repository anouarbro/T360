import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/exportation_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();

    // Delay the fetching of data until after the initial build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData(); // Fetch B2B and B2C data
    });
  }

  Future<void> fetchDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token; // Retrieve the authentication token

    if (token != null) {
      await Provider.of<ExportationProvider>(context, listen: false)
          .fetchData(token); // Fetch the B2B and B2C data
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportationProvider = Provider.of<ExportationProvider>(context);

    //! Check if the data is still loading
    if (exportationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    //! If data is loaded, build the UI with different charts
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define the layout: 2 columns on large screens, 1 column on small screens
            bool isLargeScreen = constraints.maxWidth > 800;

            return isLargeScreen
                ? _buildTwoColumnLayout(context, exportationProvider)
                : _buildSingleColumnLayout(context, exportationProvider);
          },
        ),
      ),
    );
  }

  //! Build the layout for larger screens with two columns
  Widget _buildTwoColumnLayout(
      BuildContext context, ExportationProvider exportationProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildChartCard(
                context,
                'B2B Distribution by Sector',
                buildPieChart(
                  extractSectorDistribution(exportationProvider.b2bItems),
                  ['Public', 'Private'],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildChartCard(
                context,
                'B2B Company Size Distribution',
                buildBarChart(
                    extractSizeDistribution(exportationProvider.b2bItems)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildChartCard(
                context,
                'B2B Companies Created by Year',
                buildLineChart(
                    extractCompaniesByYear(exportationProvider.b2bItems)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildChartCard(
                context,
                'B2C Distribution by Gender',
                buildPieChart(
                  extractGenderDistribution(exportationProvider.b2cItems),
                  ['Male', 'Female'],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildChartCard(
          context,
          'B2C Age Distribution',
          buildBarChart(extractAgeDistribution(exportationProvider.b2cItems)),
        ),
      ],
    );
  }

  //! Build the layout for smaller screens with a single column
  Widget _buildSingleColumnLayout(
      BuildContext context, ExportationProvider exportationProvider) {
    return Column(
      children: [
        // B2B Pie Chart by Sector
        buildChartCard(
          context,
          'B2B Distribution by Sector',
          buildPieChart(
            extractSectorDistribution(exportationProvider.b2bItems),
            ['Public', 'Private'],
          ),
        ),
        // B2B Bar Chart by Company Size
        buildChartCard(
          context,
          'B2B Company Size Distribution',
          buildBarChart(extractSizeDistribution(exportationProvider.b2bItems)),
        ),
        // B2B Line Chart (Companies Created by Year)
        buildChartCard(
          context,
          'B2B Companies Created by Year',
          buildLineChart(extractCompaniesByYear(exportationProvider.b2bItems)),
        ),
        // B2C Pie Chart by Gender
        buildChartCard(
          context,
          'B2C Distribution by Gender',
          buildPieChart(
            extractGenderDistribution(exportationProvider.b2cItems),
            ['Male', 'Female'],
          ),
        ),
        // B2C Bar Chart by Age
        buildChartCard(
          context,
          'B2C Age Distribution',
          buildBarChart(extractAgeDistribution(exportationProvider.b2cItems)),
        ),
      ],
    );
  }

  //! Build method for a card that wraps around each chart section
  Widget buildChartCard(BuildContext context, String title, Widget chart) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            chart,
          ],
        ),
      ),
    );
  }

  //! Build method for the Pie Chart (e.g., B2B Sector Distribution)
  Widget buildPieChart(
      List<PieChartSectionData> sections, List<String> labels) {
    if (sections.isEmpty || sections.any((section) => section.value.isNaN)) {
      return const Text('No valid data to display.');
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            labels.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  if (index < sections.length) ...[
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: sections[index].color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      labels[index],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //! Build method for the Bar Chart (e.g., B2B Company Size Distribution)
  Widget buildBarChart(List<BarChartGroupData> barGroups) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style =
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      ['Small', 'Medium', 'Large']
                              .asMap()
                              .containsKey(value.toInt())
                          ? ['Small', 'Medium', 'Large'][value.toInt()]
                          : '', // Prevent out-of-range index
                      style: style,
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  //! Build method for the Line Chart (e.g., B2B Companies Created by Year)
  Widget buildLineChart(List<FlSpot> spots) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              belowBarData: BarAreaData(show: false),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  //! Extract sector distribution (Public vs Private) for B2B Pie Chart
  List<PieChartSectionData> extractSectorDistribution(
      List<Map<String, dynamic>> b2bItems) {
    int publicCount = 0;
    int privateCount = 0;

    for (var item in b2bItems) {
      String sector = item['SECTEUR'] ?? 'Unknown';
      if (sector == 'Public') {
        publicCount++;
      } else if (sector == 'Private') {
        privateCount++;
      }
    }

    int total = publicCount + privateCount;

    // Handle case where total is zero to avoid NaN values
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 100,
          title: 'No Data',
          color: Colors.grey,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: (publicCount / total) * 100,
        title: '${(publicCount / total * 100).toStringAsFixed(1)}%',
        color: Colors.green,
      ),
      PieChartSectionData(
        value: (privateCount / total) * 100,
        title: '${(privateCount / total * 100).toStringAsFixed(1)}%',
        color: Colors.orange,
      ),
    ];
  }

  //! Extract size distribution for B2B Bar Chart
  List<BarChartGroupData> extractSizeDistribution(
      List<Map<String, dynamic>> b2bItems) {
    int smallCount = 0;
    int mediumCount = 0;
    int largeCount = 0;

    for (var item in b2bItems) {
      String size = item['trancheEffectifsUniteLegale'] ?? 'Unknown';
      if (size.contains('1-10')) {
        smallCount++;
      } else if (size.contains('11-50')) {
        mediumCount++;
      } else if (size.contains('51-100')) {
        largeCount++;
      }
    }

    return [
      BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(toY: smallCount.toDouble(), width: 20)]),
      BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(toY: mediumCount.toDouble(), width: 20)]),
      BarChartGroupData(
          x: 2,
          barRods: [BarChartRodData(toY: largeCount.toDouble(), width: 20)]),
    ];
  }

  //! Extract companies created by year for B2B Line Chart
  List<FlSpot> extractCompaniesByYear(List<Map<String, dynamic>> b2bItems) {
    Map<int, int> companiesByYear = {};

    for (var item in b2bItems) {
      String date = item['dateCreationUniteLegale'] ?? 'Unknown';
      int year = DateTime.tryParse(date)?.year ?? 0;
      if (year > 0) {
        companiesByYear[year] = (companiesByYear[year] ?? 0) + 1;
      }
    }

    List<FlSpot> spots = [];
    companiesByYear.forEach((year, count) {
      spots.add(FlSpot(year.toDouble(), count.toDouble()));
    });

    return spots;
  }

  //! Extract gender distribution for B2C Pie Chart
  List<PieChartSectionData> extractGenderDistribution(
      List<Map<String, dynamic>> b2cItems) {
    int maleCount = 0;
    int femaleCount = 0;

    for (var item in b2cItems) {
      String gender = item['Sexe'] ?? 'Unknown';
      if (gender == 'M') {
        maleCount++;
      } else if (gender == 'F') {
        femaleCount++;
      }
    }

    int total = maleCount + femaleCount;

    return [
      PieChartSectionData(
        value: (maleCount / total) * 100,
        title: '${(maleCount / total * 100).toStringAsFixed(1)}%',
        color: Colors.blue,
      ),
      PieChartSectionData(
        value: (femaleCount / total) * 100,
        title: '${(femaleCount / total * 100).toStringAsFixed(1)}%',
        color: Colors.pink,
      ),
    ];
  }

  //! Extract age distribution for B2C Bar Chart
  List<BarChartGroupData> extractAgeDistribution(
      List<Map<String, dynamic>> b2cItems) {
    Map<String, int> ageGroups = {
      '18-30': 0,
      '31-40': 0,
      '41-50': 0,
      '51-60': 0,
      '60+': 0,
    };

    for (var item in b2cItems) {
      int age = int.tryParse(item['Age'].toString()) ?? 0;
      if (age >= 18 && age <= 30) {
        ageGroups['18-30'] = ageGroups['18-30']! + 1;
      } else if (age >= 31 && age <= 40) {
        ageGroups['31-40'] = ageGroups['31-40']! + 1;
      } else if (age >= 41 && age <= 50) {
        ageGroups['41-50'] = ageGroups['41-50']! + 1;
      } else if (age >= 51 && age <= 60) {
        ageGroups['51-60'] = ageGroups['51-60']! + 1;
      } else if (age > 60) {
        ageGroups['60+'] = ageGroups['60+']! + 1;
      }
    }

    List<BarChartGroupData> barGroups = [];
    int index = 0;
    ageGroups.forEach((ageGroup, count) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
                toY: count.toDouble(), width: 20, color: Colors.purple),
          ],
        ),
      );
    });

    return barGroups;
  }
}
