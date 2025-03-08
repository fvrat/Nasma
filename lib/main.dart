import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/treatment_plan_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treatment Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomeScreen(),
      routes: {
        '/treatmentPlan': (context) => TreatmentPlanScreen(
            patientId: '12345'), // Replace with dynamic patient ID.
        '/dashboard': (context) =>
            DashboardScreen(), // Create this screen or replace with your own.
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/treatmentPlan');
          },
          child: Text('Go to Treatment Plan'),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Text('Dashboard content here'),
      ),
    );
  }
}
