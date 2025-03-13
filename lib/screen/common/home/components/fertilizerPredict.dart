import 'package:flutter/material.dart';
import 'package:harvest_pro/screen/function_1/predictFertilizerSeparate/fertilizerSeparate.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';

class FertilizerPredict extends StatelessWidget {
  FertilizerPredict({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue,
            Colors.green,
          ],
        ),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => FertilizerSeparate()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: Size(double.infinity, 10),
        ),
        child: Text(
          AppLocalizations.of(context)!.translate('fertilizerTitle'),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
