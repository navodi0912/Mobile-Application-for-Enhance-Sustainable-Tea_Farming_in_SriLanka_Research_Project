import 'package:flutter/material.dart';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

class HarvestAnalysisPage extends StatefulWidget {
  const HarvestAnalysisPage({super.key});

  @override
  _HarvestAnalysisPageState createState() => _HarvestAnalysisPageState();
}

class _HarvestAnalysisPageState extends State<HarvestAnalysisPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _predictions = [];
  DateTime? _selectedDate;

  // Red color constants
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color lightRed = Color(0xFFFFCDD2);

  @override
  void initState() {
    super.initState();
    _fetchHarvestPredictions();
  }

  Future<void> _fetchHarvestPredictions() async {
    List<Map<String, dynamic>> predictions =
        await _firestoreService.getHarvestPredictions();
    setState(() {
      _predictions = predictions;
    });
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, Map<String, dynamic>> _getFilteredPredictions() {
    if (_selectedDate == null) {
      // If no date is selected, show all data
      Map<String, Map<String, dynamic>> allData = {};
      for (var prediction in _predictions) {
        String date = prediction['date'];
        allData[date] = {
          '10 Days': prediction['tenDays'] ?? 0.0,
          '1 Month': prediction['oneMonth'] ?? 0.0,
          'High': prediction['highQuality'] ?? 0,
          'Medium': prediction['mediumQuality'] ?? 0,
          'Low': prediction['lowQuality'] ?? 0,
        };
      }
      return allData;
    }

    // If a date is selected, filter data for that date
    String selectedDateStr = _formatDate(_selectedDate!);
    var prediction = _predictions.firstWhere(
      (pred) => pred['date'] == selectedDateStr,
      orElse: () => <String, Object>{},
    );

    if (prediction.isNotEmpty) {
      return {
        selectedDateStr: {
          '10 Days': prediction['tenDays'] ?? 0.0,
          '1 Month': prediction['oneMonth'] ?? 0.0,
          AppLocalizations.of(context)!.translate('highQualityLeaves'):
              prediction['highQuality'] ?? 0,
          AppLocalizations.of(context)!.translate('mediumQualityLeaves'):
              prediction['mediumQuality'] ?? 0,
          AppLocalizations.of(context)!.translate('lowQualityLeaves'):
              prediction['lowQuality'] ?? 0,
        },
      };
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    final filteredPredictions = _getFilteredPredictions();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('harvestAnalysis')),
        backgroundColor: primaryRed,
      ),
      body: Container(
        color: lightRed.withOpacity(0.3),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.translate('harvestPrediction'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            SizedBox(height: 16),
            _buildDatePicker(context),
            SizedBox(height: 16),
            if (_selectedDate != null)
              _buildHarvestPredictions(filteredPredictions),
            SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.translate('harvestChart'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildChart(filteredPredictions),
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
        color: lightRed,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: primaryRed, width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('selectDate'),
            style: TextStyle(fontSize: 16, color: primaryRed),
          ),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              _selectedDate == null
                  ? AppLocalizations.of(context)!.translate('selectDate')
                  : _formatDate(_selectedDate!),
              style: TextStyle(
                  fontSize: 16, color: primaryRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestPredictions(
      Map<String, Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('noData'),
          style: TextStyle(
            fontSize: 16,
            color: primaryRed,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: predictions.entries.map((entry) {
        String date = entry.key;
        Map<String, dynamic> harvests = entry.value;

        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: lightRed,
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
                    color: primaryRed,
                  ),
                ),
                SizedBox(height: 8),
                ...harvests.entries.map((harvestEntry) {
                  String harvestType = harvestEntry.key;
                  dynamic value = harvestEntry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: primaryRed,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$harvestType: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          value is double
                              ? '${value.toStringAsFixed(2)} kg'
                              : '$value',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryRed,
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

  Widget _buildChart(Map<String, Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return Center(
        child: Text(
          _selectedDate == null
              ? AppLocalizations.of(context)!.translate('noData')
              : AppLocalizations.of(context)!.translate('noData'),
          style: TextStyle(
            fontSize: 16,
            color: primaryRed,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    List<CartesianSeries<ChartData, String>> seriesList = [];

    List<ChartData> tenDaysData = [];
    List<ChartData> oneMonthData = [];

    predictions.forEach((date, harvests) {
      tenDaysData.add(ChartData(date, '10 Days', harvests['10 Days'] ?? 0));
      oneMonthData.add(ChartData(date, '1 Month', harvests['1 Month'] ?? 0));
    });

    seriesList.add(ColumnSeries<ChartData, String>(
      name: '10 Days',
      dataSource: tenDaysData,
      xValueMapper: (ChartData data, _) => data.date,
      yValueMapper: (ChartData data, _) => data.quantity,
      color: primaryRed.withOpacity(0.7),
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(color: primaryRed),
      ),
    ));

    seriesList.add(ColumnSeries<ChartData, String>(
      name: '1 Month',
      dataSource: oneMonthData,
      xValueMapper: (ChartData data, _) => data.date,
      yValueMapper: (ChartData data, _) => data.quantity,
      color: primaryRed,
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(color: primaryRed),
      ),
    ));

    final int dateCount = predictions.keys.length;
    final double minWidth = MediaQuery.of(context).size.width;
    final double widthPerDate = 80;
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
                text: AppLocalizations.of(context)!.translate('quantity')),
            minimum: 0,
            interval: 50,
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
  final String harvestType;
  final double quantity;

  ChartData(this.date, this.harvestType, this.quantity);
}
