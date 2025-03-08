import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:firebase_database/firebase_database.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final String patientId;

  const TreatmentPlanScreen({super.key, required this.patientId});

  @override
  _TreatmentPlanScreenState createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  TextEditingController medicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  List<TimeOfDay> intakeTimes = [];

  bool isLoading = false;
  String patientName = "Furat Alfarsi";
  int age = 30;
  int actScore = 18;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    medicationController.text = "Budesonide/Formoterol (ICS/LABA)";
    dosageController.text = "1 inhalation twice daily";
    NotificationService.initialize();
    fetchTreatmentPlan();
  }

  void _addIntakeTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        intakeTimes.add(pickedTime);
      });
    }
  }

  void _removeIntakeTime(int index) {
    setState(() {
      intakeTimes.removeAt(index);
    });
  }

  Future<void> _approveTreatmentPlan() async {
    await NotificationService.cancelAllNotifications();

    for (int i = 0; i < intakeTimes.length; i++) {
      await NotificationService.scheduleDailyNotification(
        id: i,
        title: "Medication Reminder",
        body:
            "Time to take ${medicationController.text} - ${dosageController.text}",
        timeOfDay: intakeTimes[i],
      );
    }

    await _saveTreatmentPlanToFirebase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Treatment Plan Approved & Reminders Set!")),
    );
  }

  Future<void> _saveTreatmentPlanToFirebase() async {
    final treatmentPlanData = {
      'ACT': actScore,
      'dosage': dosageController.text,
      'name': medicationController.text,
      'intakeTimes': intakeTimes.map((time) => time.format(context)).toList(),
      'isApproved': true,
      'stepNum': '1',
    };

    await _databaseRef
        .child('TreatmentPlans')
        .child(widget.patientId)
        .set(treatmentPlanData);
  }

  Future<void> fetchTreatmentPlan() async {
    setState(() {
      isLoading = true;
    });

    DataSnapshot snapshot = await _databaseRef
        .child('TreatmentPlans')
        .child(widget.patientId)
        .get();

    if (snapshot.snapshot.exists) {
      var data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        medicationController.text = data['name'];
        dosageController.text = data['dosage'];
        actScore = data['ACT'];
        intakeTimes = (data['intakeTimes'] as List<dynamic>).map((time) {
          var parts = time.split(' ');
          return TimeOfDay(
              hour: int.parse(parts[0].split(':')[0]),
              minute: int.parse(parts[0].split(':')[1]));
        }).toList();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildEditableFields(),
                  const Spacer(),
                  _buildApproveButton(),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Color(0xFF6676AA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Image.asset("assets/star.png", width: 40, height: 40),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TREATMENT PLAN RECOMMENDATION",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Name: $patientName\nAge: $age\nACT Score = $actScore",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                child: Text(
                  "Show More",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTextField("Medication", medicationController),
          _buildTextField("Dosage per day", dosageController),
          _buildTimePicker(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add Intake Time",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Wrap(
            spacing: 10,
            children: [
              ...List.generate(
                intakeTimes.length,
                (index) => Chip(
                  label: Text(intakeTimes[index].format(context)),
                  onDeleted: () => _removeIntakeTime(index),
                ),
              ),
              ElevatedButton(
                onPressed: _addIntakeTime,
                child: Text('Add Time'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApproveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _approveTreatmentPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color(0xFF4CAF50), // Corrected 'primary' to 'backgroundColor'
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          textStyle: TextStyle(fontSize: 16),
        ),
        child: Text("Approve Treatment Plan"),
      ),
    );
  }
}

extension on DataSnapshot {
  get snapshot => null;
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Daily medication reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode:
          AndroidScheduleMode.exact, // Set the schedule mode to 'exact'
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
