import 'dart:convert';
import 'dart:ui';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/screen/function_3/diseaseAnalysis/diseaseAnalysis.dart';
import 'package:harvest_pro/screen/function_3/diseaseIdentification/components/imagebox.dart';
import 'package:harvest_pro/screen/function_3/diseaseIdentification/components/leafcapture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

class DiseaseIdentification extends StatefulWidget {
  const DiseaseIdentification({super.key});

  @override
  _DiseaseIdentificationState createState() => _DiseaseIdentificationState();
}

class _DiseaseIdentificationState extends State<DiseaseIdentification> {
  String _capturedImagePath = '';
  String _analysisResult = '';
  Color textColor = Colors.black;
  List<String> remediesList = [];
  List<String> recommendationList = [];
  final user = FirebaseAuth.instance.currentUser!;
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _currentDiseaseClass = '';

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

    if (_currentDiseaseClass.isNotEmpty) {
      if (_analysisResult.isNotEmpty &&
          _analysisResult != "This is not a Tea Leaf." &&
          !_analysisResult.contains('error')) {
        final parts = _analysisResult.split('\n');
        if (parts.length == 2) {
          final leafClassPart = parts[0].split(' ').last;

          _analysisResult =
              '${AppLocalizations.of(context)!.translate('LeafClass')} $leafClassPart\n'
              '${AppLocalizations.of(context)!.translate('DiseaseClass')} $_currentDiseaseClass';
        }
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
        Uri.parse('http://$mlIP:8000/Function03/disease'),
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
      _currentDiseaseClass = '';
    } else {
      String leafClass = result['leaf_cls'][0] ?? 'Unknown leaf class';
      String diseaseClass = result['disease_cls'][0] ?? 'Unknown disease class';

      if (leafClass == "Other 06") {
        _analysisResult = AppLocalizations.of(context)!.translate('notTeaLeaf');
        _currentDiseaseClass = '';
      } else {
        _analysisResult =
            '${AppLocalizations.of(context)!.translate('LeafClass')} : $leafClass\n'
            '${AppLocalizations.of(context)!.translate('DiseaseClass')} : $diseaseClass';

        await _firestoreService.storeDiseasePrediction(
            diseaseClass: diseaseClass);

        _currentDiseaseClass = diseaseClass;
      }

      textColor = Colors.red;
    }
    setState(() {
      _isLoading = false;
    });
    setState(() {});
  }

  List<String> getRemediesList() {
    if (_currentDiseaseClass.isEmpty) {
      return [];
    }
    return _getRemedies(_currentDiseaseClass);
  }

  List<String> getRecommendationsList() {
    if (_currentDiseaseClass.isEmpty) {
      return [];
    }
    return _getRecommendations(_currentDiseaseClass);
  }

  Future<void> _chooseAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _onImageCaptured(image.path);
    }
  }

  List<String> _getRemedies(String diseaseClass) {
    Locale currentLocale = Localizations.localeOf(context);
    Map<String, List<String>> recommendations =
        currentLocale.languageCode == 'si' ? remediesSi : remediesEn;

    return recommendations[diseaseClass] ??
        ["No specific recommendations available for this condition."];
  }

  Map<String, List<String>> remediesEn = {
    "Healthy": [
      "Maintain proper fertilization and irrigation.",
    ],
    "Blister - Stage 01": [
      "Apply neem oil or copper-based fungicides.",
    ],
    "Blister - Stage 02": [
      "Use stronger fungicides (e.g., Mancozeb or Chlorothalonil).",
    ],
    "Mite - Stage 01": [
      "Spray sulfur-based miticides or neem oil.",
    ],
    "Mite - Stage 02": [
      " Apply acaricides (e.g., Abamectin or Spiromesifen).",
    ],
    "Rust - Stage 01": [
      "Apply fungicides like copper sulfate or sulfur dust.",
    ],
    "Rust - Stage 02": [
      "Use systemic fungicides (e.g., Propiconazole or Tebuconazole).",
    ],
  };

  Map<String, List<String>> remediesSi = {
    "Healthy": [
      "නිසි පොහොර යෙදීම සහ වාරිමාර්ග පවත්වා ගන්න.",
    ],
    "Blister - Stage 01": [
      "නෙම් තෙල් හෝ තඹ පාදක දිලීර නාශක යොදන්න.",
    ],
    "Blister - Stage 02": [
      "ශක්තිමත් දිලීර නාශක භාවිතා කරන්න (උදා: මැන්කොසෙබ් හෝ ක්ලෝරොතලෝනිල්).",
    ],
    "Mite - Stage 01": [
      "සල්ෆර් පාදක මයිටිසයිඩ් හෝ නීම් තෙල් ඉසින්න.",
    ],
    "Mite - Stage 02": [
      "ඇකරයිසයිඩ් යොදන්න (උදා: ඇබමෙක්ටින් හෝ ස්පිරෝමසිෆෙන්).",
    ],
    "Rust - Stage 01": [
      "තඹ සල්ෆේට් හෝ සල්ෆර් දූවිලි වැනි දිලීර නාශක යොදන්න.",
    ],
    "Rust - Stage 02": [
      "පද්ධතිමය දිලීර නාශක භාවිතා කරන්න (උදා: ප්‍රොපිකොනසෝල් හෝ ටෙබුකොනසෝල්).",
    ],
  };

  List<String> _getRecommendations(String diseaseClass) {
    Locale currentLocale = Localizations.localeOf(context);
    Map<String, List<String>> recommendations =
        currentLocale.languageCode == 'si'
            ? recommendationsSi
            : recommendationsEn;

    return recommendations[diseaseClass] ??
        ["No specific recommendations available for this condition."];
  }

  Map<String, List<String>> recommendationsEn = {
    "Healthy": [
      "Continue regular monitoring and preventive spraying of organic fungicides.",
    ],
    "Blister - Stage 01": [
      "Prune affected leaves and ensure good air circulation.",
    ],
    "Blister - Stage 02": [
      " Remove severely infected plants to prevent spread.",
    ],
    "Mite - Stage 01": [
      " Increase humidity to disrupt mite reproduction.",
    ],
    "Mite - Stage 02": [
      " Introduce predatory mites (Phytoseiulus persimilis) as biological control.",
    ],
    "Rust - Stage 01": [
      "Avoid excessive nitrogen fertilization, which can increase rust susceptibility.",
    ],
    "Rust - Stage 02": [
      "Implement crop rotation and remove infected debris to prevent reinfection.",
    ],
  };

  Map<String, List<String>> recommendationsSi = {
    "Healthy": [
      "කාබනික දිලීර නාශක නිතිපතා අධීක්ෂණය සහ වැළැක්වීමේ ඉසීම දිගටම කරගෙන යන්න.",
    ],
    "Blister - Stage 01": [
      "බලපෑමට ලක් වූ කොළ කප්පාදු කර හොඳ වායු සංසරණයක් සහතික කරන්න.",
    ],
    "Blister - Stage 02": [
      " පැතිරීම වැළැක්වීම සඳහා දැඩි ලෙස ආසාදිත ශාක ඉවත් කරන්න.",
    ],
    "Mite - Stage 01": [
      " මයිටා ප්‍රජනනයට බාධා කිරීම සඳහා ආර්ද්‍රතාවය වැඩි කරන්න.",
    ],
    "Mite - Stage 02": [
      " ජීව විද්‍යාත්මක පාලනයක් ලෙස කොල්ලකාරී මයිටාවන් (ෆයිටොසියුලස් පර්සිමිලිස්) හඳුන්වා දෙන්න.",
    ],
    "Rust - Stage 01": [
      "අධික නයිට්‍රජන් පොහොර යෙදීමෙන් වළකින්න, එය මලකඩ වලට ගොදුරු වීමේ හැකියාව වැඩි කළ හැකිය.",
    ],
    "Rust - Stage 02": [
      "නැවත ආසාදනය වීම වැළැක්වීම සඳහා බෝග භ්‍රමණය ක්‍රියාත්මක කර ආසාදිත සුන්බුන් ඉවත් කරන්න.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final remediesList = getRemediesList();
    // ignore: unused_local_variable
    final recommendationList = getRecommendationsList();
    // ignore: unused_local_variable
    bool hasContent = _capturedImagePath.isNotEmpty || remediesList.isNotEmpty;
    // ignore: unused_local_variable
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate('diseaseTitle'),
      ),
      body: Container(
        color: Colors.purple[50],
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        _capturedImagePath.isNotEmpty || remediesList.isNotEmpty
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
    final remediesList = getRemediesList();
    final recommendationList = getRecommendationsList();
    return [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseAnalysisPage(),
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
          color: const Color(colorPurple),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      SizedBox(height: 10),
      if (_analysisResult != "This is not a Tea Leaf." &&
          _analysisResult != "මෙය තේ කොළයක් නොවේ.")
        _buildRecommendationSection(remediesList, "diseaseRemedies"),
      if (_analysisResult != "This is not a Tea Leaf." &&
          _analysisResult != "මෙය තේ කොළයක් නොවේ.")
        _buildRecommendationSection(
            recommendationList, "diseaseRecommendations"),
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
          color: const Color(colorPurple),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorPurple),
          size: 60,
        ),
        onPressed: () => _chooseAndUploadImage(),
      ),
      SizedBox(height: 20),
    ];
  }

  List<Widget> buildInitialContent() {
    final remediesList = getRemediesList();
    final recommendationList = getRecommendationsList();
    return [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/disease.png'),
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
            colors: [Color(0xFF4A148C), Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseAnalysisPage(),
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
          color: const Color(colorPurple),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      if (remediesList.isNotEmpty)
        _buildRecommendationSection(remediesList, "diseaseRemedies"),
      if (recommendationList.isNotEmpty)
        _buildRecommendationSection(
            recommendationList, "diseaseRecommendations"),
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
          color: const Color(colorPurple),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorPurple),
          size: 60,
        ),
        onPressed: () => _chooseAndUploadImage(),
      ),
      SizedBox(height: 20),
    ];
  }

  // Builds a container widget to display the analysis result.
  Widget _buildResultContainer(String result) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
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

  // Builds a section to display recommendations.
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
              color: const Color(colorPurple),
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

  // Builds a widget for each recommendation item.
  Widget _buildRecommendationItem(
      String recommendation, int index, String name) {
    return Card(
      color: Colors.purple[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: _buildRecommendationLeading(index),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.purple[800]),
        ),
        trailing: Icon(
            name == "diseaseRemedies" ? Icons.local_florist : Icons.agriculture,
            color: Colors.purple[600]),
      ),
    );
  }

  // Builds a leading widget for the recommendation items.
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
