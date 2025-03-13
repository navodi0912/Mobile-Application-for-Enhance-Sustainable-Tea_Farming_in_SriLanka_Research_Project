import 'dart:convert';
import 'dart:ui';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/screen/function_2/growthAnalysis/growthAnalysis.dart';
import 'package:harvest_pro/screen/function_2/growthQualit/components/imagebox.dart';
import 'package:harvest_pro/screen/function_2/growthQualit/components/leafcapture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

class GrowthQuality extends StatefulWidget {
  const GrowthQuality({super.key});

  @override
  _GrowthQualityState createState() => _GrowthQualityState();
}

class _GrowthQualityState extends State<GrowthQuality> {
  String _capturedImagePath = '';
  String _analysisResult = '';
  Color textColor = Colors.black;
  List<String> recommendationGrowthList = [];
  final user = FirebaseAuth.instance.currentUser!;
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _currentGrowthClass = '';
  String _currentPercentageClass = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_analysisResult == "This is not a Tea Leaf.") {
      _analysisResult = AppLocalizations.of(context)!.translate('notTeaLeaf');
    } else if (_analysisResult == "මෙය තේ කොළයක් නොවේ." &&
        AppLocalizations.of(context)!.translate('notTeaLeaf') !=
            "මෙය තේ කොළයක් නොවේ.") {
      _analysisResult = AppLocalizations.of(context)!.translate('notTeaLeaf');
    }

    if (_currentGrowthClass.isNotEmpty) {
      if (_analysisResult.isNotEmpty &&
          _analysisResult != "This is not a Tea Leaf." &&
          !_analysisResult.contains('error')) {
        _analysisResult =
            '${AppLocalizations.of(context)!.translate('growthClass')} : $_currentGrowthClass\n'
            '${AppLocalizations.of(context)!.translate('percentageClass')} : $_currentPercentageClass';
      }
    }
  }

  void _onImageCaptured(String path) async {
    setState(() {
      _capturedImagePath = path;
    });
    var result = await _uploadImage(path);
    _processResult(result);
  }

  Future<Map<String, dynamic>> _uploadImage(String imagePath) async {
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

      print("Response:${jsonDecode(response.body)}");
      setState(() {
        _isLoading = false;
      });

      return response.statusCode == 200
          ? jsonDecode(response.body)
          : {'error': 'Server error with status code: ${response.statusCode}'};
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  void _processResult(Map<String, dynamic> result) async {
    setState(() {
      _isLoading = true;
    });
    if (result.containsKey('error')) {
      _analysisResult = result['error'];
      _currentGrowthClass = '';
      _currentPercentageClass = '';
    } else {
      int status = result['status'] ?? 0;
      String growthClass = result['growth_cls'] ?? 'Unknown leaf class';
      String percentageClass = result['detect %'] ?? 'Unknown disease class';

      if (percentageClass != 'Unknown disease class') {
        double percentage = double.parse(percentageClass) * 100;
        percentageClass = percentage.toStringAsFixed(2);
      }

      if (status == 0) {
        _analysisResult = AppLocalizations.of(context)!.translate('notTeaLeaf');
        _currentPercentageClass = '';
        _currentGrowthClass = '';
      } else {
        _analysisResult =
            '${AppLocalizations.of(context)!.translate('growthClass')} : $growthClass\n'
            '${AppLocalizations.of(context)!.translate('percentageClass')} : $percentageClass%';

        await _firestoreService.storeGrowthQuality(
            growthClass: growthClass, percentageClass: percentageClass);

        _currentGrowthClass = growthClass;
        _currentPercentageClass = percentageClass;
      }

      textColor = Colors.red;
    }
    setState(() {
      _isLoading = false;
    });
    setState(() {});
  }

  List<String> getRecommendationList() {
    if (_currentGrowthClass.isEmpty) {
      return [];
    }
    return _getRecommendationsForQuality(_currentGrowthClass);
  }

  Future<void> _chooseAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _onImageCaptured(image.path);
    }
  }

  List<String> _getRecommendationsForQuality(String diseaseClass) {
    Locale currentLocale = Localizations.localeOf(context);
    Map<String, List<String>> recommendations =
        currentLocale.languageCode == 'si'
            ? recommendationsForQualitySi
            : recommendationsForQualityEn;

    return recommendations[diseaseClass] ??
        ["No specific recommendations available for this condition."];
  }

  Map<String, List<String>> recommendationsForQualityEn = {
    "high": [
      "Increase nitrogen-based fertilizers moderately to boost leaf production.",
      "Reduce plant spacing slightly for more plants per area.",
      "Improve irrigation to support faster growth.",
      "Implement precision pruning to enhance shoot development.",
      "Extend plucking intervals slightly to increase harvest volume without losing quality.",
    ],
    "medium": [
      "Optimize fertilization with a mix of organic and synthetic nutrients.",
      "Adjust irrigation frequency to ensure consistent growth.",
      "Use growth stimulants (e.g., seaweed extracts) to enhance leaf regeneration.",
      "Introduce controlled shade to prevent excessive stress on plants.",
      "Improve soil health with compost and mulching for better nutrient retention.",
    ],
    "law": [
      "Increase pruning frequency to encourage new shoots.",
      "Optimize fertilization with high-nitrogen inputs to sustain rapid growth.",
      "Enhance irrigation efficiency for continuous hydration.",
      "Reduce harvesting intervals to maintain steady production.",
      "Improve pest and disease management to prevent yield loss.",
    ],
  };

  Map<String, List<String>> recommendationsForQualitySi = {
    "high": [
      "කොළ නිෂ්පාදනය වැඩි කිරීම සඳහා නයිට්‍රජන් මත පදනම් වූ පොහොර මධ්‍යස්ථව වැඩි කරන්න.",
      "ප්‍රදේශයකට වැඩි ශාක සඳහා ශාක පරතරය තරමක් අඩු කරන්න.",
      "වේගවත් වර්ධනයට සහාය වීම සඳහා වාරිමාර්ග වැඩි දියුණු කරන්න.",
      "රිකිලි සංවර්ධනය වැඩි දියුණු කිරීම සඳහා නිරවද්‍ය කප්පාදු කිරීම ක්‍රියාත්මක කරන්න.",
      "ගුණාත්මකභාවය නැති නොකර අස්වැන්න පරිමාව වැඩි කිරීම සඳහා නෙලීමේ කාල පරතරයන් තරමක් දිගු කරන්න.",
    ],
    "medium": [
      "කාබනික සහ කෘතිම පෝෂ්‍ය පදාර්ථ මිශ්‍රණයකින් පොහොර යෙදීම ප්‍රශස්ත කරන්න.",
      "අඛණ්ඩ වර්ධනයක් සහතික කිරීම සඳහා වාරිමාර්ග වාර ගණන සකසන්න.",
      "කොළ පුනර්ජනනය වැඩි දියුණු කිරීම සඳහා වර්ධන උත්තේජක (උදා: මුහුදු පැලෑටි සාරය) භාවිතා කරන්න.",
      "ශාක මත අධික ආතතිය වැළැක්වීම සඳහා පාලිත සෙවන හඳුන්වා දෙන්න.",
      "වඩා හොඳ පෝෂක රඳවා තබා ගැනීම සඳහා කොම්පෝස්ට් සහ වසුන් යෙදීමෙන් පසෙහි සෞඛ්‍යය වැඩි දියුණු කරන්න.",
    ],
    "law": [
      "නව රිකිලි දිරිමත් කිරීම සඳහා කප්පාදු කිරීමේ වාර ගණන වැඩි කරන්න.",
      "වේගවත් වර්ධනයක් පවත්වා ගැනීම සඳහා ඉහළ නයිට්‍රජන් යෙදවුම් සමඟ පොහොර යෙදීම ප්‍රශස්ත කරන්න.",
      "අඛණ්ඩ සජලනය සඳහා වාරිමාර්ග කාර්යක්ෂමතාව වැඩි කරන්න.",
      "ස්ථාවර නිෂ්පාදනය පවත්වා ගැනීම සඳහා අස්වනු නෙලීමේ කාල පරතරයන් අඩු කරන්න.",
      "අස්වැන්න අහිමි වීම වැළැක්වීම සඳහා පළිබෝධ සහ රෝග කළමනාකරණය වැඩි දියුණු කරන්න.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final recommendationGrowthList = getRecommendationList();
    // ignore: unused_local_variable
    bool hasContent =
        _capturedImagePath.isNotEmpty || recommendationGrowthList.isNotEmpty;

    // ignore: unused_local_variable
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate('growthTitle'),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _capturedImagePath.isNotEmpty ||
                            recommendationGrowthList.isNotEmpty
                        ? buildContent()
                        : buildInitialContent(),
                  ),
                ),
              ),
            ),
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
    );
  }

  // ignore: unused_element
  Widget _centeredLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: buildInitialContent(),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _contentLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buildContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    final recommendationGrowthList = getRecommendationList();
    return [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A71A5),
              Color(0xFF74B3CE),
            ],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GrowthAnalysisPage(),
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
            AppLocalizations.of(context)!.translate('viewAnalysis'),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      SizedBox(height: 20),
      Text(
        AppLocalizations.of(context)!.translate('leafcaptureimage'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(colorBlue),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      if (_analysisResult != "This is not a Tea Leaf." &&
          _analysisResult != "මෙය තේ කොළයක් නොවේ.")
        _buildRecommendationSection(
            recommendationGrowthList, "recommendedFertilizer"),
      SizedBox(height: 30),
      Divider(),
      SizedBox(height: 20),
      Leafcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 30),
      Text(
        AppLocalizations.of(context)!.translate('leafchooseimage'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(colorBlue),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorBlue),
          size: 60,
        ),
        onPressed: () => _chooseAndUploadImage(),
      ),
      SizedBox(height: 20),
    ];
  }

  List<Widget> buildInitialContent() {
    final recommendationGrowthList = getRecommendationList();
    return [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/growth3.png'),
            fit: BoxFit.cover,
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
              Color(0xFF2A71A5),
              Color(0xFF74B3CE),
            ],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GrowthAnalysisPage(),
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
            AppLocalizations.of(context)!.translate('viewAnalysis'),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      SizedBox(height: 20),
      Text(
        AppLocalizations.of(context)!.translate('leafcaptureimage'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(colorBlue),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      if (recommendationGrowthList.isNotEmpty)
        _buildRecommendationSection(
            recommendationGrowthList, "recommendedFertilizer"),
      SizedBox(height: 30),
      Divider(),
      SizedBox(height: 20),
      Leafcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 30),
      Text(
        AppLocalizations.of(context)!.translate('leafchooseimage'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(colorBlue),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorBlue),
          size: 60,
        ),
        onPressed: () => _chooseAndUploadImage(),
      ),
      SizedBox(height: 20),
    ];
  }

  Widget _buildResultContainer(String result) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(
      List<String> recommendationList, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            AppLocalizations.of(context)!.translate(name),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(colorBlue),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recommendationList.length,
          itemBuilder: (context, index) {
            return _buildRecommendationItem(
                recommendationList[index], index, name);
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
      String recommendation, int index, String name) {
    return Card(
      color: Colors.lightBlue[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: _buildRecommendationLeading(index),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.blue[800]),
        ),
        trailing: Icon(
            name == "recommendedFertilizer"
                ? Icons.local_florist
                : Icons.agriculture,
            color: Colors.blue[600]),
      ),
    );
  }

  Widget _buildRecommendationLeading(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
