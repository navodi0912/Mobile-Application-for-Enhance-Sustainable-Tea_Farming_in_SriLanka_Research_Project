import 'package:flutter/material.dart';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

class DiseaseAnalysisPage extends StatefulWidget {
  const DiseaseAnalysisPage({super.key});

  @override
  _DiseaseAnalysisPageState createState() => _DiseaseAnalysisPageState();
}

class _DiseaseAnalysisPageState extends State<DiseaseAnalysisPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _predictions = [];
  Map<String, Map<String, int>> _diseaseCounts = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    List<Map<String, dynamic>> predictions =
        await _firestoreService.getDiseasePredictions();
    setState(() {
      _predictions = predictions;
      _analyzeData();
    });
  }

  void _analyzeData() {
    _diseaseCounts = {};
    for (var prediction in _predictions) {
      String date = prediction['date'];
      String diseaseClass = prediction['diseaseClass'];

      if (!_diseaseCounts.containsKey(date)) {
        _diseaseCounts[date] = {};
      }

      _diseaseCounts[date]![diseaseClass] =
          (_diseaseCounts[date]![diseaseClass] ?? 0) + 1;
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

  Map<String, Map<String, int>> _getFilteredDiseaseCounts() {
    if (_selectedDate == null) {
      return _diseaseCounts;
    }
    String selectedDateStr = _formatDate(_selectedDate!);
    return {
      selectedDateStr: _diseaseCounts[selectedDateStr] ?? {},
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredDiseaseCounts = _getFilteredDiseaseCounts();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('diseaseAnalysis')),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.purple[50],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.translate('diseaseCount'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            SizedBox(height: 16),
            _buildDatePicker(context),
            SizedBox(height: 16),
            _buildDiseaseCounts(filteredDiseaseCounts),
            SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.translate('diseaseChart'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildChart(filteredDiseaseCounts),
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
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.purple, width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('selectDate'),
            style: TextStyle(fontSize: 16, color: Colors.purple[900]),
          ),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              _selectedDate == null
                  ? AppLocalizations.of(context)!.translate('selectDate')
                  : _formatDate(_selectedDate!),
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple[800],
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCounts(Map<String, Map<String, int>> diseaseCounts) {
    if (_selectedDate == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('selectDateDisease'),
          style: TextStyle(
            fontSize: 16,
            color: Colors.purple[900],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: diseaseCounts.entries.map((entry) {
        String date = entry.key;
        Map<String, int> diseases = entry.value;

        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Colors.purple[200],
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
                    color: Colors.purple[900],
                  ),
                ),
                SizedBox(height: 8),
                ...diseases.entries.map((diseaseEntry) {
                  String disease = diseaseEntry.key;
                  int count = diseaseEntry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.purple[700],
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$disease: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple[900],
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

  Widget _buildChart(Map<String, Map<String, int>> diseaseCounts) {
    // Prepare the chart data
    List<CartesianSeries<ChartData, String>> seriesList = [];

    // Create disease-specific series
    Map<String, List<ChartData>> diseaseSeriesData = {};

    // Organize data by disease type
    diseaseCounts.forEach((date, diseases) {
      diseases.forEach((disease, count) {
        if (!diseaseSeriesData.containsKey(disease)) {
          diseaseSeriesData[disease] = [];
        }

        diseaseSeriesData[disease]!.add(ChartData(date, disease, count));
      });
    });

    // Create a series for each disease type
    diseaseSeriesData.forEach((disease, dataPoints) {
      seriesList.add(ColumnSeries<ChartData, String>(
        name: disease,
        dataSource: dataPoints,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.count,
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ));
    });

    // Calculate width based on number of dates
    final int dateCount = diseaseCounts.keys.length;
    final double minWidth = MediaQuery.of(context).size.width;
    final double widthPerDate = 80; // Allocate 80 pixels per date
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
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
                text: AppLocalizations.of(context)!.translate('count')),
            minimum: 0,
            interval: 1,
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
  final String diseaseClass;
  final int count;

  ChartData(this.date, this.diseaseClass, this.count);
}
