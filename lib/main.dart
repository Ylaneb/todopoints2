import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';   // already there
import 'screens/home_screen.dart'; // ← import your screen
import 'package:firebase_core/firebase_core.dart';


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
    final pixelText = GoogleFonts.pressStart2pTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.greenAccent,
      displayColor: Colors.greenAccent,
    );

    return MaterialApp(
      title: 'ToDoPoints2',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: pixelText,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 24,
            color: Colors.greenAccent,
          ),
        ),
      ),
      home: const HomeScreen(),  // ← use your HomeScreen here
    );
  }
}
