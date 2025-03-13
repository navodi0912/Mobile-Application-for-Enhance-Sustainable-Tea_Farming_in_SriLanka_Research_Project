import 'dart:convert';
import 'dart:ui';
import 'package:harvest_pro/core/services/firebase_function_services.dart';
import 'package:harvest_pro/screen/function_1/fertilizerAnalysis/fertilizerAnalysis.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/screen/function_1/predictFertilizer/components/leafcapture.dart';
import 'package:harvest_pro/screen/function_1/predictFertilizer/components/imagebox.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

// A StatefulWidget for Fertilizer and chemical prediction in Tea plants.
class Fertilizer extends StatefulWidget {
  @override
  _FertilizerState createState() => _FertilizerState();
}

// The state class for Leaf, managing the Fertilizer and chemical prediction
class _FertilizerState extends State<Fertilizer> {
  // Various member variables and methods...
  String _capturedImagePath = '';
  String _analysisResult = '';
  Color textColor = Colors.black;
  List<String> recommendationFertilizerList = [];
  List<String> recommendationUsageList = [];
  final user = FirebaseAuth.instance.currentUser!;
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];
  String _currentDiseaseClass = '';

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

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

// Called when an image is captured, handles image analysis.
  void _onImageCaptured(String path) async {
    setState(() {
      _capturedImagePath = path;
    });
    var result = await _uploadImage(path);
    _processResult(result);
  }

// Uploads an image to a server endpoint for Fertilizer and chemical prediction.
  Future<Map<String, dynamic>> _uploadImage(String imagePath) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$mlIP:8000/Function01/Fertilizer'),
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

// Processes the result from the image analysis and updates the UI.
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
        //_analysisResult = "This is not a Tea Leaf.";
        _analysisResult = AppLocalizations.of(context)!.translate('notTeaLeaf');
        _currentDiseaseClass = '';
      } else {
        _analysisResult =
            '${AppLocalizations.of(context)!.translate('LeafClass')} $leafClass\n'
            '${AppLocalizations.of(context)!.translate('DiseaseClass')} $diseaseClass';
        await _firestoreService.storeFertilizerPrediction(
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

  List<String> getRecommendationFertilizerList() {
    if (_currentDiseaseClass.isEmpty) {
      return [];
    }
    return _getRecommendationsForFertilizer(_currentDiseaseClass);
  }

  List<String> getRecommendationUsageList() {
    if (_currentDiseaseClass.isEmpty) {
      return [];
    }
    return _getRecommendationsForUsage(_currentDiseaseClass);
  }

  Future<void> _chooseAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _onImageCaptured(image.path);
    }
  }

  List<String> _getRecommendationsForUsage(String diseaseClass) {
    Locale currentLocale = Localizations.localeOf(context);
    Map<String, List<String>> recommendations =
        currentLocale.languageCode == 'si'
            ? recommendationsForUsageSi
            : recommendationsForUsageEn;

    // Use 'Other' as a default key for conditions not explicitly handled
    return recommendations[diseaseClass] ??
        ["No specific recommendations available for this condition."];
  }

  Map<String, List<String>> recommendationsForUsageEn = {
    "sulfur": [
      "Morning (8:00 AM - 10:00 AM): Apply gypsum at 25–50 kg per hectare to improve sulfur levels.",
      "Afternoon (1:00 PM - 3:00 PM): Mix ammonium sulfate into irrigation water for faster absorption.",
      "Evening (5:00 PM - 6:00 PM): Observe plant recovery and plan a follow-up application if needed.",
    ],
    "nitrogen": [
      "Morning (7:00 AM - 9:00 AM): Apply urea or ammonium nitrate at 50 kg per hectare through soil broadcasting.",
      "Midday (11:00 AM - 1:00 PM): Irrigate the field lightly to help nutrient absorption.",
      "Evening (4:00 PM - 6:00 PM): Spray a foliar solution (2% urea) on the leaves for quick nitrogen absorption.",
    ],
    "manganese": [
      "Morning (8:00 AM - 10:00 AM): Spray a foliar solution of 0.1–0.5% manganese sulfate on leaves.",
      "Afternoon (2:00 PM - 4:00 PM): Apply manganese sulfate to soil at a rate of 5–10 kg per hectare for long-term improvement.",
      "Evening (6:00 PM - 7:00 PM): Monitor plant symptoms and adjust the next application if necessary.",
    ],
  };

  Map<String, List<String>> recommendationsForUsageSi = {
    "sulfur": [
      "උදෑසන (පෙ.ව. 8:00 - පෙ.ව. 10:00): සල්ෆර් මට්ටම වැඩි දියුණු කිරීම සඳහා හෙක්ටයාරයකට කිලෝග්‍රෑම් 25–50 බැගින් ජිප්සම් යොදන්න.",
      "දහවල් (ප.ව. 1:00 - ප.ව. 3:00): වේගවත් අවශෝෂණය සඳහා වාරිමාර්ග ජලයට ඇමෝනියම් සල්ෆේට් මිශ්‍ර කරන්න",
      "සවස (ප.ව. 5:00 - ප.ව. 6:00): ශාක ප්‍රතිසාධනය නිරීක්ෂණය කර අවශ්‍ය නම් පසු විපරම් යෙදීමක් සැලසුම් කරන්න",
    ],
    "nitrogen": [
      "උදෑසන (පෙ.ව. 7:00 - පෙ.ව. 9:00): පස විසුරුවා හැරීම හරහා හෙක්ටයාරයකට කිලෝග්‍රෑම් 50 බැගින් යූරියා හෝ ඇමෝනියම් නයිට්රේට් යොදන්න",
      "දහවල් (පෙ.ව. 11:00 - ප.ව. 1:00): පෝෂක අවශෝෂණයට උපකාර කිරීම සඳහා ක්ෂේත්‍රයට සැහැල්ලුවෙන් ජලය සපයන්න.",
      "සවස (ප.ව. 4:00 - ප.ව. 6:00): ඉක්මන් නයිට්‍රජන් අවශෝෂණය සඳහා කොළ මත පත්‍ර ද්‍රාවණයක් (2% යූරියා) ඉසින්න.",
    ],
    "manganese": [
      "උදෑසන (පෙ.ව. 8:00 - පෙ.ව. 10:00): කොළ මත 0.1–0.5% මැංගනීස් සල්ෆේට් පත්‍ර ද්‍රාවණයක් ඉසින්න.",
      "දහවල් (ප.ව. 2:00 - ප.ව. 4:00): දිගුකාලීන දියුණුව සඳහා හෙක්ටයාරයකට කිලෝග්‍රෑම් 5–10 බැගින් පසට මැංගනීස් සල්ෆේට් යොදන්න.",
      "සවස (ප.ව. 6:00 - ප.ව. 7:00): ශාක රෝග ලක්ෂණ නිරීක්ෂණය කර අවශ්‍ය නම් ඊළඟ යෙදුම සකස් කරන්න.",
    ],
  };

  List<String> _getRecommendationsForFertilizer(String diseaseClass) {
    Locale currentLocale = Localizations.localeOf(context);
    Map<String, List<String>> recommendations =
        currentLocale.languageCode == 'si'
            ? recommendationsForFertilizerSi
            : recommendationsForFertilizerEn;

    // Use 'Other' as a default key for conditions not explicitly handled
    return recommendations[diseaseClass] ??
        ["No specific recommendations available for this condition."];
  }

  Map<String, List<String>> recommendationsForFertilizerEn = {
    "sulfur": [
      "Gypsum (Calcium Sulfate)",
      "Ammonium Sulfate (21-0-0-24S)",
      "Elemental Sulfur",
    ],
    "nitrogen": [
      "Urea (46-0-0)",
      "Ammonium Nitrate (34-0-0)",
      "Organic Compost",
    ],
    "manganese": [
      "Manganese Sulfate (MnSO₄)",
      "Chelated Manganese (Mn-EDTA)",
    ],
  };

  Map<String, List<String>> recommendationsForFertilizerSi = {
    "sulfur": [
      "ජිප්සම් (කැල්සියම් සල්ෆේට්)",
      "ඇමෝනියම් සල්ෆේට් (21-0-0-24S)",
      "මූලද්‍රව්‍ය සල්ෆර්",
    ],
    "nitrogen": [
      "යූරියා (46-0-0)",
      "ඇමෝනියම් නයිට්‍රේට් (34-0-0)",
      "කාබනික කොම්පෝස්ට්",
    ],
    "manganese": [
      "මැංගනීස් සල්ෆේට් (MnSO₄)",
      "චීලේටඩ් මැංගනීස් (Mn-EDTA)",
    ],
  };

  // Builds the main UI of the Leaf screen.
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final recommendationFertilizerList = getRecommendationFertilizerList();
    final recommendationUsageList = getRecommendationUsageList();
    // ignore: unused_local_variable
    bool hasContent =
        _capturedImagePath.isNotEmpty || recommendationUsageList.isNotEmpty;
    // Access the Firebase user directly where context is valid
    // ignore: unused_local_variable
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate('fertilizerTitle'),
      ),
      body: Container(
        color: Colors.lightGreen[50],
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
                            recommendationUsageList.isNotEmpty
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
          // Wrap the Column with Center
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align items to the start vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center items horizontally
            children: buildContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    // ignore: unused_local_variable
    final recommendationFertilizerList = getRecommendationFertilizerList();
    final recommendationUsageList = getRecommendationUsageList();
    // Return the list of widgets that make up the content of the page
    return [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF66BB6A),
            ],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FertilizerAnalysisPage(),
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
          color: const Color(colorPrimary),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      SizedBox(height: 10),
      if (_analysisResult != "This is not a Tea Leaf." &&
          _analysisResult != "මෙය තේ කොළයක් නොවේ.")
        _buildRecommendationSection(
            recommendationFertilizerList, "recommendedFertilizer"),
      if (_analysisResult != "This is not a Tea Leaf." &&
          _analysisResult != "මෙය තේ කොළයක් නොවේ.")
        _buildRecommendationSection(recommendationUsageList, "fertilizerUsage"),
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
          color: const Color(colorPrimary),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorPrimary),
          size: 60,
        ),
        onPressed: () => _chooseAndUploadImage(),
      ),
      SizedBox(height: 20),
    ];
  }

  List<Widget> buildInitialContent() {
    // ignore: unused_local_variable
    final recommendationFertilizerList = getRecommendationFertilizerList();
    final recommendationUsageList = getRecommendationUsageList();
    return [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fertilizer.png'),
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
              Color(0xFF1B5E20),
              Color(0xFF66BB6A),
            ],
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FertilizerAnalysisPage(),
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
          color: const Color(colorPrimary),
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      if (recommendationFertilizerList.isNotEmpty)
        _buildRecommendationSection(
            recommendationFertilizerList, "recommendedFertilizer"),
      if (recommendationUsageList.isNotEmpty)
        _buildRecommendationSection(recommendationUsageList, "fertilizerUsage"),
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
          color: const Color(colorPrimary),
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.image,
          color: const Color(colorPrimary),
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
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
              color: const Color(colorPrimary),
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
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: _buildRecommendationLeading(index),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.green[800]),
        ),
        trailing: Icon(
            name == "recommendedFertilizer"
                ? Icons.local_florist
                : Icons.agriculture,
            color: Colors.green[600]),
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
