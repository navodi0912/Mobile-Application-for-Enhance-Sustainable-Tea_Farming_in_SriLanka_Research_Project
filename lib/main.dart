import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:harvest_pro/core/services/internet_provider.dart';
import 'package:harvest_pro/core/services/sign_in_provider.dart';
import 'package:harvest_pro/screen/common/auth/splash/splash_screen.dart';
import 'package:harvest_pro/screen/common/auth/signUp/sign_up_bloc.dart';
import 'package:harvest_pro/screen/common/loading_cubit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harvest_pro/shared/routes/routes.dart';
import 'package:harvest_pro/core/utils/app_localizations.dart';
import 'package:harvest_pro/core/services/firebase_options.dart';
import 'package:harvest_pro/screen/common/auth/authentication_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';

// Main entry point for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: 'lib/config/.env');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode') ?? 'en';
  runApp(MyApp(initialLocale: Locale(languageCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({Key? key, required this.initialLocale}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _error = false;
  late Locale _locale;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    initializeFlutterFire();
    initUniLinks();
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  void initializeFlutterFire() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } else {
        await Firebase.initializeApp();
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? languageCode = prefs.getString('languageCode') ?? 'en';
      _locale = Locale(languageCode);
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void initUniLinks() async {
    try {
      _sub = linkStream.listen((String? link) {
        if (link != null) {
          // Handle the link - parse it and navigate to the appropriate screen
          handleDeepLink(link);
        }
      }, onError: (err) {
        // Handle error
      });
    } on PlatformException {
      // Handle exception
    }
  }

  void handleDeepLink(String link) {
    // Parse the link and navigate to the appropriate screen
    // Example: https://www.yourdomain.com/open?param=value
    Uri uri = Uri.parse(link);
    if (uri.path == '/open') {
      // Navigate to the desired screen with necessary parameters
      Navigator.pushNamed(context, '/home', arguments: uri.queryParameters);
    }
    // Add more handling as needed
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return MaterialApp(
          home: Scaffold(
              body: Center(child: Text('Failed to initialise firebase!'))));
    }

    if (!_initialized) {
      return Container(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()));
    }

    // Wrapping with BlocProvider
    return BlocProvider<AuthenticationBloc>(
      create: (_) => AuthenticationBloc(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SignInProvider()),
          ChangeNotifierProvider(create: (_) => InternetProvider()),
          BlocProvider<LoadingCubit>(
            create: (context) => LoadingCubit(),
          ),
          BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: _locale,
            supportedLocales: [Locale('en'), Locale('si')],
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: SplashScreen.routeName,
            routes: routes,
          ),
        ),
      ),
    );
  }
}
