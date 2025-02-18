import 'package:flutter/material.dart';
import 'screens/homepage.dart'; // Assuming HomeScreen is in homepage.dart
import 'screens/DashBoard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nasma App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HealthDashboard(), // Load HomeScreen as the home page
    );
  }
}
