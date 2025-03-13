import 'package:flutter/material.dart';
import 'dart:io';

class ImageBox extends StatelessWidget {
  final String imagePath;
  const ImageBox({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 450;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return SizedBox(
      width: 341 * fem,
      height: 225 * fem,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * fem),
        child: imagePath.isNotEmpty
            ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/imageGreen.jpg',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
