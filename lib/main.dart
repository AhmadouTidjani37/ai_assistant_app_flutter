import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iut_assistant/firebase_options.dart';
import 'package:iut_assistant/screen/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DJANI GPT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:Color.fromARGB(255, 1, 35, 87)),
        useMaterial3: true,
      ),
      home: splashScreen(),
    );
  }
}
