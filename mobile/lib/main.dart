import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app_tossecontrol',
      theme: ThemeData(
        primaryColor: kMedicalBlue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: kClinicalWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kMedicalBlue,
          primary: kMedicalBlue,
          secondary: kMedicalGreen,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: kTextColor,
          displayColor: kTextColor,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundWhite,
          elevation: 0,
          foregroundColor: kTextColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kMedicalBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
