import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:harvest_pro/screen/function_2_Part2/harvestAnalysis/harvestAnalysis.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

class HarvestSeparate extends StatefulWidget {
  const HarvestSeparate({super.key});

  @override
  _HarvestSeparateState createState() => _HarvestSeparateState();
}

class _HarvestSeparateState extends State<HarvestSeparate> {
  final List<Map<String, dynamic>> _capturedImages = [];
  final int _minRequiredImages = 10;
  bool _isLoading = false;
  bool _showSummary = false;
  Map<String, dynamic> _summaryResult = {};
  // ignore: unused_field
  final FirestoreService _firestoreService = FirestoreService();

  // Red color constants
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color lightRed = Color(0xFFFFCDD2);

  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate('harvestTittle'),
        leadingImage: 'assets/icons/Back.png',
        onLeadingPressed: () {
          print("Leading icon pressed");
          Navigator.pop(context);
        },
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
          color: lightRed.withOpacity(0.3),
          child: Stack(
            children: [
              _showSummary ? _buildSummaryView() : _buildCaptureView(),
              if (_isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProgressHeader(),
            const SizedBox(height: 20),
            _capturedImages.isNotEmpty ? _buildImageGrid() : _buildEmptyState(),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _captureAndAnalyzeImage,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/page-1/images/cameraRed.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.translate('leafchooseimage'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(colorRed),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.image,
                color: const Color(colorRed),
                size: 60,
              ),
              onPressed: () => _chooseAndAnalyzeImage(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canSubmit() ? _submitBatchAnalysis : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit() ? primaryRed : Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.translate('submit')} ${_capturedImages.length}/${_minRequiredImages} ${AppLocalizations.of(context)!.translate('imagesAnalysis')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC62828),
                    Color(0xFFEF9A9A),
                  ],
                ),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HarvestAnalysisPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('viewHistory'),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.translate('TeaHarvestTittle'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.translate('captureImages'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: _capturedImages.length / _minRequiredImages,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
            ),
            const SizedBox(height: 8),
            Text(
              '${_capturedImages.length} - $_minRequiredImages ${AppLocalizations.of(context)!.translate('capturedImages')}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _capturedImages.length,
      itemBuilder: (context, index) {
        final imageData = _capturedImages[index];
        return _buildImageTile(imageData, index);
      },
    );
  }

  Widget _buildImageTile(Map<String, dynamic> imageData, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.file(
              File(imageData['path']),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            color: Colors.black.withOpacity(0.7),
            child: Text(
              imageData['growth_cls'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          left: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _capturedImages.removeAt(index);
              });
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 15),
          Text(
            AppLocalizations.of(context)!.translate('noImages'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.translate('pleaseCaptureImages'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _capturedImages.length >= _minRequiredImages;
  }

  Future<void> _captureAndAnalyzeImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _analyzeImage(image.path);
    }
  }

  Future<void> _chooseAndAnalyzeImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _analyzeImage(image.path);
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      setState(() {
        _isLoading = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$mlIP:8000/Function02/growth'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('image_file', imagePath));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Response: $result");

        int status = result['status'] ?? 0;

        if (status == 1) {
          // Only add tea leaf images
          result['path'] = imagePath;
          setState(() {
            _capturedImages.add(result);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Not a tea leaf. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error analyzing image. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBatchAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
      });

      int highCount = 0;
      int mediumCount = 0;
      int lowCount = 0;

      for (var img in _capturedImages) {
        String growthClass = img['growth_cls']?.toLowerCase() ?? '';
        if (growthClass == 'high') {
          highCount++;
        } else if (growthClass == 'medium') {
          mediumCount++;
        } else if (growthClass == 'law') {
          lowCount++;
        }
      }

      int total = _capturedImages.length;
      double highPercentage = total > 0 ? (highCount / total * 100) : 0;
      double mediumPercentage = total > 0 ? (mediumCount / total * 100) : 0;
      double lowPercentage = total > 0 ? (lowCount / total * 100) : 0;

      // Send API request with query parameters
      var uri = Uri.parse('http://$mlIP:8000/Function02/harvest').replace(
        queryParameters: {
          'heigh': highPercentage.toStringAsFixed(2),
          'medium': mediumPercentage.toStringAsFixed(2),
          'law': lowPercentage.toStringAsFixed(2),
        },
      );

      var response = await http.post(uri);

      if (response.statusCode == 200) {
        var summaryResult = jsonDecode(response.body);
        print("Summary Response: $summaryResult");

        if (summaryResult['status'] == 1) {
          await _firestoreService.storeHarvestPrediction(
            highQuality: highCount,
            mediumQuality: mediumCount,
            lowQuality: lowCount,
            tenDays: summaryResult['10_days'],
            oneMonth: summaryResult['month'],
          );

          summaryResult['high_percentage'] = highPercentage;
          summaryResult['medium_percentage'] = mediumPercentage;
          summaryResult['low_percentage'] = lowPercentage;

          setState(() {
            _summaryResult = summaryResult;
            _showSummary = true;
            _isLoading = false;
          });
        } else {
          // If API returns status 0, use local fallback
          throw Exception("API returned status 0");
        }
      } else {
        throw Exception(
            "Failed to submit batch analysis: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in batch submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Error submitting batch analysis. Using local summary instead."),
          backgroundColor: Colors.red,
        ),
      );

      int validCount = _capturedImages.length;
      int highCount = _capturedImages
          .where((img) => img['growth_cls']?.toLowerCase() == 'high')
          .length;
      int mediumCount = _capturedImages
          .where((img) => img['growth_cls']?.toLowerCase() == 'medium')
          .length;
      int lowCount = _capturedImages
          .where((img) => img['growth_cls']?.toLowerCase() == 'law')
          .length;

      double highPercentage =
          validCount > 0 ? (highCount / validCount * 100) : 0;
      double mediumPercentage =
          validCount > 0 ? (mediumCount / validCount * 100) : 0;
      double lowPercentage = validCount > 0 ? (lowCount / validCount * 100) : 0;

      setState(() {
        _summaryResult = {
          'status': 0,
          '10_days': 0,
          'month': 0,
          'high_percentage': highPercentage,
          'medium_percentage': mediumPercentage,
          'low_percentage': lowPercentage,
        };
        _showSummary = true;
        _isLoading = false;
      });
    }
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: primaryRed,
                      size: 60,
                    ),
                    SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context)!
                          .translate('predictionCompleted'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildPredictionCard(),
                    SizedBox(height: 40),
                    _buildPercentagesCard(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSummary = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('backToImages'),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HarvestAnalysisPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('viewHistory'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.red[200],
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: primaryRed),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.translate('predictedHarvest'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text:
                        '${AppLocalizations.of(context)!.translate('tenDays')}: ',
                  ),
                  TextSpan(
                    text:
                        '${_summaryResult['10_days']?.toStringAsFixed(2) ?? 'N/A'} kg',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text:
                        '${AppLocalizations.of(context)!.translate('oneMonth')}: ',
                  ),
                  TextSpan(
                    text:
                        '${_summaryResult['month']?.toStringAsFixed(2) ?? 'N/A'} kg',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentagesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('growthDistribution'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 15),
            _buildPercentageRow(
              AppLocalizations.of(context)!.translate('highQuality'),
              (_summaryResult['high_percentage'] ?? 0).toDouble(),
              Colors.green,
            ),
            SizedBox(height: 10),
            _buildPercentageRow(
              AppLocalizations.of(context)!.translate('mediumQuality'),
              (_summaryResult['medium_percentage'] ?? 0).toDouble(),
              Colors.orange,
            ),
            SizedBox(height: 10),
            _buildPercentageRow(
              AppLocalizations.of(context)!.translate('lowQuality'),
              (_summaryResult['low_percentage'] ?? 0).toDouble(),
              Colors.red,
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('totalImages'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_capturedImages.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageRow(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
