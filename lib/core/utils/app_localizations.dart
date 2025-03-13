import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'currency': 'LKR.',
      'profile': 'Profile',
      'appinfo': 'App Info',
      'userinfo': 'User Info',
      'name': 'Name',
      'email': 'Email',
      'age': 'Age',
      'gender': 'Gender',
      'address': 'Address',
      'signout': 'Signout',
      //

      //
      'currentlanguge': 'Current Language',
      'enterage': 'Add your age',
      'enteremail': 'Add your email',
      'entergender': 'Add your gender',
      'enteraddress': 'Add your address',
      //
      'diseasetitle': 'Disease Analysis',
      'diseasecaptureimage':
          'Capture or choose image of the cucumber using below buttons!',
      'diseasechooseimage': 'Choose a Image',
      'diseasefollowthese': 'Follow these recommendations for better harvest.',
      'DiseaseClass': 'Disease Class:',
      'LeafClass': 'Leaf Class:',
      //
      'leaftitle': 'Leaf Disease Analysis',

      //Common
      'leafchooseimage': 'Choose a Image',
      'leafcaptureimage':
          'Capture or choose image of the Tea leaf using the buttons below!',
      "notTeaLeaf": "This is not a Tea Leaf.",
      'viewAnalysis': 'View Analysis',
      'dailymarketingtips': 'Your Daily Marketing Tips!',
      'selectDate': 'Select a Date:',
      'date': 'Date',
      'date:': 'Date',
      'count': 'Count',
      'percentage': 'Percentage',

      //Home
      'welcome': 'Welcome!',
      'enhanceyour': 'Enhance Your Tea Farming with AI',

      //Home/Marketing Tips
      'marketingTip1':
          "Ensure well-drained, slightly acidic soil (pH 4.5–6) with rich organic matter for optimal root development and nutrient absorption.",
      'marketingTip2':
          "Regular pruning and shade management improve leaf quality, control plant height, and promote new shoot growth.",
      'marketingTip3':
          "Pluck the top two leaves and a bud every 7–14 days to ensure high-quality tea while allowing the plant to regenerate efficiently.",
      'marketingTip4':
          "Consistent rainfall or irrigation is essential, but excess water should be avoided to prevent root rot and fungal diseases.",
      'marketingTip5':
          "Implement natural pest control methods, use organic fertilizers, and monitor for common threats like tea mosquito bugs and fungal infections.",

      //Function 1
      'recommendedFertilizer': 'Here are some recommended fertilizers.',
      'fertilizerUsage': 'How to Use Fertilizer.',
      'notaTeaLeaf': 'This is not a Tea leaf.',
      'fertilizerTitle': 'Fertilizer Prediction',
      'homeFertilizerTitle': 'Fertilizer and Chemical Prediction',

      //Function 1 Analysis
      'fertilizerAnalysis': 'Fertilizer Analysis',
      'diseaseChart': 'Disease Analysis Chart',
      'selectDateDisease': 'Please select a date to view disease counts.',
      'fertilizerCount': 'Fertilizer Count',

      //Function 2
      'growthTitle': 'Growth Quality',
      'growthClass': 'Growth Quality',
      'percentageClass': 'Percentage',
      'homeQualityTitle': 'Growth Quality Prediction',

      //Function 2 Analysis
      'growthAnalysis': 'Growth Analysis',
      'growthChart': 'Growth Analysis Chart',
      'selectDateGrowth': 'Please select a date to view growth counts.',
      'growthCount': 'Growth Count',

      //Function 2 Part 2
      'harvestTittle': 'Harvest Prediction',
      'homeHarvestTitle': 'Tea Leaf Harvest Prediction',
      'TeaHarvestTittle': 'Tea Harvest Prediction',
      'captureImages': 'Capture at least 10 different tea leaf images',
      'capturedImages': 'images captured',
      'noImages': 'No images captured yet',
      'pleaseCaptureImages': 'Please capture at least 10 tea leaf images',
      'submit': 'Submit',
      'imagesAnalysis': 'Images For Analysis',
      'predictionCompleted': 'Prediction Complete',
      'predictedHarvest': 'Predicted Tea Leaf Harvest',
      'tenDays': '10 Days',
      'oneMonth': '1 Month',
      'growthDistribution': 'Growth Distribution',
      'highQuality': 'High Quality',
      'mediumQuality': 'Medium Quality',
      'lowQuality': 'Low Quality',
      'totalImages': 'Total Images:',
      'backToImages': 'Back to images',
      'viewHistory': 'View History',

      //Function 2 Part 2 Analysis
      'harvestAnalysis': 'Harvest Analysis',
      'harvestChart': 'Harvest Analysis Chart',
      'selectDateHarvest': 'Please select a date to view Harvest counts.',
      'harvestPrediction': 'harvestPrediction Count',
      'quantity': 'Quantity(kg)',
      'noData': 'No data available for the selected date.',
      'highQualityLeaves': 'High Quality Leaves',
      'mediumQualityLeaves': 'Medium Quality Leaves',
      'lowQualityLeaves': 'Low Quality Leaves',

      //Function 3
      'diseaseRemedies': 'Here are some Remedies',
      'diseaseRecommendations': 'Here are some recommendations',
      'diseaseTitle': 'Diseases Identification',
      'homeDiseaseTitle': 'Diseases Identification from Tea Leaves',

      //Function 3 Analysis
      'diseaseAnalysis': 'Disease Analysis',
      'diseaseCount': 'Disease Count',
    },
    'si': {
      'currency': 'රු.',
      'profile': 'පැතිකඩ',
      'appinfo': 'යෙදුම් තොරතුරු',
      'userinfo': 'පරිශීලක තොරතුරු',
      'name': 'නම',
      'email': 'විද්යුත් තැපෑල',
      'age': 'වයස',
      'gender': 'ස්ත්රී පුරුෂ භාවය',
      'address': 'ලිපිනය',
      'signout': 'වරන්න',
      //

//
      'currentlanguge': 'වත්මන් භාෂාව',
      'enterage': 'වයස ඇතුළත් කරන්න',
      'enteremail': 'විද්‍යුත් තැපෑල ඇතුලත් කරන්න',
      'entergender': 'ස්ත්‍රී පුරුෂ භාවය ඇතුලත් කරන්න',
      'enteraddress': 'ලිපිනය ඇතුලත් කරන්න',
      //
      'diseasetitle': 'රෝග විශ්ලේෂණය',
      'diseasecaptureimage':
          'පහත ස්කෑන් බොත්තම භාවිතයෙන් පිපිඤ්ඤා වල රූපය ග්‍රහණය කර ගන්න හෝ තෝරන්න!',
      'diseasechooseimage': 'රූපයක් තෝරන්න',
      'diseasefollowthese':
          'වඩා හොඳ අස්වැන්නක් සඳහා මෙම නිර්දේශ අනුගමනය කරන්න.',
      'DiseaseClass': 'රෝග පන්තිය:',
      'LeafClass': 'කොළ පන්තිය:',
      //
      'leaftitle': 'රෝග විශ්ලේෂණය',

      //Common

      'leafchooseimage': 'රූපයක් තෝරන්න',
      'leafcaptureimage':
          'පහත ස්කෑන් බොත්තම භාවිතයෙන් තේ පත්‍රයේ පින්තූරයක් ගන්න හෝ තෝරන්න!',
      "notTeaLeaf": "මෙය තේ කොළයක් නොවේ.",
      'viewAnalysis': 'විශ්ලේෂණය බලන්න',
      'dailymarketingtips': 'ඔබේ දෛනික අලෙවිකරණ ඉඟි!',
      'selectDate': 'දිනයක් තෝරන්න:',
      'date': 'දිනය',
      'date:': 'දිනය:',
      'count': 'ගණන',
      'percentage': 'ප්‍රතිශතය',

      //Home
      'welcome': 'සාදරයෙන් පිළිගනිමු!',
      'enhanceyour': 'AI සමඟින් ඔබේ තේ වගාව වැඩි දියුණු කරන්න',

      //Home/Marketing Tips
      'marketingTip1':
          "ප්‍රශස්ත මූල වර්ධනය සහ පෝෂක අවශෝෂණය සඳහා හොඳින් ජලය බැස යන, තරමක් ආම්ලික පස (pH අගය 4.5–6) පොහොසත් කාබනික ද්‍රව්‍ය වලින් සමන්විත බව සහතික කර ගන්න.",
      'marketingTip2':
          "නිතිපතා කප්පාදු කිරීම සහ සෙවන කළමනාකරණය කොළවල ගුණාත්මකභාවය වැඩි දියුණු කරයි, ශාක උස පාලනය කරයි, සහ නව අංකුර වර්ධනය ප්‍රවර්ධනය කරයි",
      'marketingTip3':
          "ශාකය කාර්යක්ෂමව පුනර්ජනනය වීමට ඉඩ සලසමින් උසස් තත්ත්වයේ තේ සහතික කිරීම සඳහා සෑම දින 7-14 කට වරක් ඉහළ කොළ දෙක සහ අංකුරයක් නෙළා ගන්න.",
      'marketingTip4':
          "නිරන්තර වර්ෂාපතනය හෝ වාරිමාර්ග අත්‍යවශ්‍ය වේ, නමුත් මුල් කුණුවීම සහ දිලීර රෝග වැළැක්වීම සඳහා අතිරික්ත ජලය වළක්වා ගත යුතුය.",
      'marketingTip5':
          "ස්වාභාවික පළිබෝධ පාලන ක්‍රම ක්‍රියාත්මක කිරීම, කාබනික පොහොර භාවිතා කිරීම සහ තේ මදුරු දෝෂ සහ දිලීර ආසාදන වැනි පොදු තර්ජන නිරීක්ෂණය කිරීම.",

      //Function 1
      'recommendedFertilizer': 'නිර්දේශිත පොහොර කිහිපයක් මෙන්න',
      'fertilizerUsage': 'පොහොර භාවිතා කරන ආකාරය.',
      'notaTeaLeaf': 'මේක තේ කොළයක් නෙවෙයි.',
      'fertilizerTitle': 'පොහොර පුරෝකථනය',
      'homeFertilizerTitle': 'පොහොර සහ රසායනික පුරෝකථනය',

      //Function 1 Analysis
      'fertilizerAnalysis': 'පොහොර විශ්ලේෂණය',
      'fertilizerCount': 'පොහොර ගණන',
      'diseaseChart': 'රෝග විශ්ලේෂණ සටහන',
      'selectDateDisease': 'රෝග ගණන බැලීමට දිනයක් තෝරන්න.',

      //Function 2
      'growthTitle': 'වර්ධන ගුණාත්මකභාවය',
      'growthClass': 'වර්ධන ගුණාත්මකභාවය',
      'percentageClass': 'ප්‍රතිශතය',
      'homeQualityTitle': 'වර්ධන ගුණාත්මක පුරෝකථනය',

      //Function 2 Analysis
      'growthAnalysis': 'වර්ධන විශ්ලේෂණය',
      'growthChart': 'වර්ධන විශ්ලේෂණ සටහන',
      'selectDateGrowth': 'වර්ධන ගණන් බැලීමට කරුණාකර දිනයක් තෝරන්න.',
      'growthCount': 'වර්ධන ගණන',

      //Function 2 Part 2
      'harvestTittle': 'අස්වැන්න පුරෝකථනය',
      'TeaHarvestTittle': 'තේ අස්වැන්න පුරෝකථනය',
      'homeHarvestTitle': 'තේ කොළ අස්වැන්න පුරෝකථනය',
      'captureImages': 'අවම වශයෙන් විවිධ තේ දළු රූප 10ක්වත් ග්‍රහණය කරගන්න',
      'capturedImages': 'ලබාගත් රූප',
      'noImages': 'තවම රූප ලබාගෙන නැත',
      'pleaseCaptureImages':
          'කරුණාකර අවම වශයෙන් තේ දළු රූප 10ක් ග්‍රහණය කරගන්න',
      'submit': '',
      'imagesAnalysis': 'විශ්ලේෂණය සඳහා රූප',
      'predictionCompleted': 'පුරෝකථනය සම්පූර්ණයි',
      'predictedHarvest': 'පුරෝකථනය කළ තේ දළු අස්වැන්න',
      'tenDays': 'දින 10',
      'oneMonth': 'මාස 1',
      'growthDistribution': 'වර්ධන ව්‍යාප්තිය',
      'highQuality': 'ඉහළ ගුණාත්මකභාවය',
      'mediumQuality': 'මධ්‍යම ගුණාත්මකභාවය',
      'lowQuality': 'අඩු ගුණාත්මකභාවය',
      'totalImages': 'මුළු රූප:',
      'backToImages': 'ආපසු රූප වෙත',
      'viewHistory': 'ඉතිහාසය බලන්න',

      //Function 2 Part 2 Analysis
      'harvestAnalysis': 'අස්වැන්න විශ්ලේෂණය',
      'harvestChart': 'අස්වැන්න විශ්ලේෂණ ප්‍රස්ථාරය',
      'selectDateHarvest': 'අස්වැන්න ගණන් බැලීමට කරුණාකර දිනයක් තෝරන්න.',
      'harvestPrediction': 'අස්වැන්න පුරෝකථනය ගණන',
      'quantity': 'ප්‍රමාණය(කිලෝග්‍රෑම්)',
      'noData': 'තෝරාගත් දිනය සඳහා දත්ත නොමැත.',
      'highQualityLeaves': 'ඉහළ ගුණාත්මක කොළ',
      'mediumQualityLeaves': 'මධ්‍යම ගුණාත්මක කොළ',
      'lowQualityLeaves': 'අඩු ගුණාත්මක කොළ',

      //Function 3
      'diseaseRemedies': 'මේ සදහා ප්‍රතිකාර කිහිපයක්',
      'diseaseRecommendations': 'මේ සදහා නිර්දේශ කිහිපයක්',
      'diseaseTitle': 'රෝග හඳුනා ගැනීම',
      'homeDiseaseTitle': 'තේ කොළ වලින් රෝග හඳුනා ගැනීම',

      //Function 3 Analysis
      'diseaseAnalysis': 'රෝග විශ්ලේෂණය',
      'diseaseCount': 'රෝග ගණන',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 'Key not found';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'si'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
