import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/screen/common/home/components/diseasePredict.dart';
import 'package:harvest_pro/screen/common/home/components/fertilizerPredict.dart';
import 'package:harvest_pro/screen/common/home/components/harvestPredict.dart';
import 'package:harvest_pro/screen/common/home/components/marketing_tips_widget.dart';
import 'package:harvest_pro/screen/common/home/components/qualityPredict.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // Access the Firebase user directly where context is valid
    // ignore: unused_local_variable
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate('welcome'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                "assets/images/smart-farm.png",
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.translate('enhanceyour'),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.green[800]),
                SizedBox(width: 10),
                Text(
                  '${AppLocalizations.of(context)!.translate('dailymarketingtips')}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]),
                ),
              ],
            ),
            Container(
              height: 140,
              child: MarketingTipsWidget(),
            ),
            SizedBox(height: 30),
            featureItem(
                AppLocalizations.of(context)!.translate('homeFertilizerTitle'),
                Icons.local_florist,
                FertilizerPredict()),
            featureItem(
                AppLocalizations.of(context)!.translate('homeQualityTitle'),
                Icons.trending_up,
                QualityPredict()),
            featureItem(
                AppLocalizations.of(context)!.translate('homeDiseaseTitle'),
                Icons.bug_report,
                DiseasePredict()),
            featureItem(
                AppLocalizations.of(context)!.translate('homeHarvestTitle'),
                Icons.grass,
                HarvestPredict()),
          ],
        ),
      ),
    );
  }

  Widget featureItem(String title, IconData icon, Widget child) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 50, color: const Color(colorPrimary)),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
