import 'package:flutter/material.dart';
import 'screens/data_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner App',
      // Specify Dark Theme for the entire app
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        // Define Dark Theme settings
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white, // For title text color
        ),
        cardTheme: CardTheme(
          color: Colors.blueGrey[800],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Default icon color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent), // For TextButton color
        ),
      ),
      home: const DataListScreen(), // Set DataListScreen as the home screen
    );
  }
}
