import 'package:flutter/material.dart';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

class GrowthAnalysisPage extends StatefulWidget {
  const GrowthAnalysisPage({super.key});

  @override
  _GrowthAnalysisPageState createState() => _GrowthAnalysisPageState();
}

class _GrowthAnalysisPageState extends State<GrowthAnalysisPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _predictions = [];
  Map<String, Map<String, double>> _growthCounts = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchGrowthPredictions();
  }

  Future<void> _fetchGrowthPredictions() async {
    List<Map<String, dynamic>> predictions =
        await _firestoreService.getGrowthPredictions();
    setState(() {
      _predictions = predictions;
      _analyzeData();
    });
  }

  void _analyzeData() {
    _growthCounts = {};
    for (var prediction in _predictions) {
      String date = prediction['date'];
      String growthClass = prediction['growthClass'];
      double percentageClass =
          prediction['percentageClass']; // Ensure this is a double

      if (!_growthCounts.containsKey(date)) {
        _growthCounts[date] = {};
      }

      _growthCounts[date]![growthClass] = percentageClass;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Map<String, Map<String, double>> _getFilteredGrowthCounts() {
    if (_selectedDate == null) {
      return _growthCounts;
    }
    String selectedDateStr = _formatDate(_selectedDate!);
    return {
      selectedDateStr: _growthCounts[selectedDateStr] ?? {},
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredGrowthCounts = _getFilteredGrowthCounts();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('growthAnalysis')),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.translate('growthCount'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
            _buildDatePicker(context),
            SizedBox(height: 16),
            _buildGrowthCounts(filteredGrowthCounts),
            SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.translate('growthChart'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildChart(filteredGrowthCounts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.lightBlue, width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('selectDate'),
            style: TextStyle(fontSize: 16, color: Colors.blue[900]),
          ),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              _selectedDate == null
                  ? AppLocalizations.of(context)!.translate('selectDate')
                  : _formatDate(_selectedDate!),
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCounts(Map<String, Map<String, double>> growthCounts) {
    if (_selectedDate == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('selectDateGrowth'),
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue[900],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: growthCounts.entries.map((entry) {
        String date = entry.key;
        Map<String, double> growths = entry.value;

        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Colors.lightBlue[200],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.translate('date:')} $date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 8),
                ...growths.entries.map((growthEntry) {
                  String growth = growthEntry.key;
                  double percentage = growthEntry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$growth: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(Map<String, Map<String, double>> growthCounts) {
    // Prepare the chart data
    List<CartesianSeries<ChartData, String>> seriesList = [];

    // Create growth-specific series
    Map<String, List<ChartData>> growthSeriesData = {};

    // Organize data by growth type
    growthCounts.forEach((date, growths) {
      growths.forEach((growth, percentage) {
        if (!growthSeriesData.containsKey(growth)) {
          growthSeriesData[growth] = [];
        }

        growthSeriesData[growth]!.add(ChartData(date, growth, percentage));
      });
    });

    // Create a series for each growth type
    growthSeriesData.forEach((growth, dataPoints) {
      seriesList.add(ColumnSeries<ChartData, String>(
        name: growth,
        dataSource: dataPoints,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.percentage,
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ));
    });

    // Calculate width based on number of dates
    final int dateCount = growthCounts.keys.length;
    final double minWidth = MediaQuery.of(context).size.width;
    final double widthPerDate = 100; // Increase width per date for more space
    final double totalWidth = math.max(minWidth, dateCount * widthPerDate);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: totalWidth,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: AxisTitle(
                text: AppLocalizations.of(context)!.translate('date')),
            majorGridLines: MajorGridLines(width: 0),
            labelRotation: -45, // Rotate labels for better readability
            labelPlacement:
                LabelPlacement.betweenTicks, // Add space between labels
            interval: 1, // Show every label
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
                text: AppLocalizations.of(context)!.translate('percentage')),
            minimum: 0,
            maximum: 100,
            interval: 10,
            decimalPlaces: 0,
            majorGridLines: MajorGridLines(width: 1),
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: seriesList,
        ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final String growthClass;
  final double percentage;

  ChartData(this.date, this.growthClass, this.percentage);
}
