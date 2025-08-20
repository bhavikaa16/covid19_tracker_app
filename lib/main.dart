import 'dart:io';

import 'package:covid_tracker/View/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  String apiKey;
  if (Platform.isAndroid) {
    apiKey = dotenv.env['ANDROID_API_KEY']!;
  } else if (Platform.isIOS) {
    apiKey = dotenv.env['IOS_API_KEY']!;
  } else {
    apiKey = dotenv.env['WEB_API_KEY']!;
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey, // Use the secure key from .env
      appId: DefaultFirebaseOptions.currentPlatform.appId,
      messagingSenderId: DefaultFirebaseOptions.currentPlatform.messagingSenderId,
      projectId: DefaultFirebaseOptions.currentPlatform.projectId,
      storageBucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
      iosBundleId: DefaultFirebaseOptions.currentPlatform.iosBundleId,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

