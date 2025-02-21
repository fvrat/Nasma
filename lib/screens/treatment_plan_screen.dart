import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final String patientId;

  const TreatmentPlanScreen({super.key, required this.patientId});

  @override
  _TreatmentPlanScreenState createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  TextEditingController medicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  List<TimeOfDay> selectedTimes = [];

  bool isLoading = false;
  bool showMore = false;
  String patientName = "John Doe"; // Simulated data
  int age = 30;
  int actScore = 18;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
    // Simulated Treatment Data
    medicationController.text = "Budesonide/Formoterol (ICS/LABA)";
    dosageController.text = "1 inhalation twice daily";
  }

  bool isButtonEnabled() {
    return medicationController.text.isNotEmpty &&
        dosageController.text.isNotEmpty &&
        selectedTimes.isNotEmpty;
  }

  Future<void> approveAndSend() async {
    if (!isButtonEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields before approving.")),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Approval"),
        content: Text(
            "Are you sure you want to approve and send this treatment plan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              scheduleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "Treatment Plan Approved & Notifications Scheduled!")),
              );
            },
            child: Text("Approve & Send"),
          ),
        ],
      ),
    );
  }

  void scheduleNotifications() {
    for (int i = 0; i < selectedTimes.length; i++) {
      final DateTime now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTimes[i].hour,
        selectedTimes[i].minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      NotificationService.scheduleNotification(
        id: i,
        title: "Medication Reminder",
        body:
            "It's time to take your ${medicationController.text} (${dosageController.text}).",
        scheduledTime: scheduledTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildEditableFields(),
                    const Spacer(),
                    _buildApproveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: showMore ? 320 : 260,
      decoration: BoxDecoration(
        color: Color(0xFF6676AA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "TREATMENT PLAN RECOMMENDATION",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
          InkWell(
            onTap: () {
              setState(() {
                showMore = !showMore;
              });
            },
            child: Text(
              showMore ? "Show Less" : "Show More",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.greenAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showMore)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Additional patient details:\n- Weight: 70kg\n- Height: 170cm\n- Known allergies: None",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
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
    return Column(
      children: [
        for (int i = 0; i < selectedTimes.length; i++)
          ListTile(
            title: Text("Intake Time: ${selectedTimes[i].format(context)}"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  selectedTimes.removeAt(i);
                });
              },
            ),
          ),
        ListTile(
          title: Text("Add Intake Time"),
          trailing: Icon(Icons.add),
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: 8, minute: 0),
            );
            if (pickedTime != null) {
              setState(() {
                selectedTimes.add(pickedTime);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildApproveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: isButtonEnabled() ? approveAndSend : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isButtonEnabled() ? Color(0xFF6676AA) : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
          ),
          child: Text(
            "APPROVE & SEND",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
