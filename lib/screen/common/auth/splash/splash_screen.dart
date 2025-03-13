import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:harvest_pro/screen/common/auth/launcherScreen/launcher_screen.dart';
import 'package:provider/provider.dart';
import 'package:harvest_pro/core/services/sign_in_provider.dart';
import 'package:harvest_pro/core/utils/next_screen.dart';
import '../../nav/nav.dart';

// create a new widget called SplashScreen
class SplashScreen extends StatefulWidget {
  // give the SplashScreen a route name
  static String routeName = '/splash';
  // create a constructor for the SplashScreen
  const SplashScreen({Key? key}) : super(key: key);

  // create a new stateful widget called _SplashScreenState
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// create a new stateful widget called _SplashScreenState
class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    // read the SignInProvider
    final spm = context.read<SignInProvider>();
    super.initState();
    // create a timer of 2 seconds
    Timer(const Duration(seconds: 5), () {
      // if the user is not signed in
      spm.isSignedIn == false
          // go to the LoginScreen
          ? nextScreen(context, const LauncherScreen())
          // if the user is signed in
          : nextScreen(context, const Nav());
    });
  }

  @override
  Widget build(BuildContext context) {
    // return a Scaffold with a SafeArea as a child
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_splash.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/plant.png',
                fit: BoxFit.fill,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
