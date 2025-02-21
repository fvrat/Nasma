import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? doctorId;
  List<Map<String, dynamic>> patients = [];
  String currentFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchDoctorPatients();
  }

  void _fetchDoctorPatients() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Fetch Doctor ID using email
    DatabaseEvent doctorEvent = await _database.child("Doctor").once();
    Map<dynamic, dynamic>? doctorData =
        doctorEvent.snapshot.value as Map<dynamic, dynamic>?;

    if (doctorData != null) {
      doctorData.forEach((key, value) {
        if (value["email"] == user.email) {
          setState(() {
            doctorId = key;
          });
        }
      });
    }

    if (doctorId == null) return;

    // Fetch Patients assigned to this doctor
    DatabaseEvent patientEvent = await _database.child("Patient").once();
    Map<dynamic, dynamic>? patientData =
        patientEvent.snapshot.value as Map<dynamic, dynamic>?;

    if (patientData != null) {
      List<Map<String, dynamic>> patientList = [];

      for (var entry in patientData.entries) {
        if (entry.value["Doctor_ID"] == doctorId) {
          String treatmentPlanId = entry.value["Treatmentplan_ID"] ?? "";

          // Fetch ACT Score & Approval Status from TreatmentPlan
          DatabaseEvent treatmentPlanEvent = await _database
              .child("TreatmentPlan")
              .child(treatmentPlanId)
              .once();
          Map<dynamic, dynamic>? treatmentPlanData =
              treatmentPlanEvent.snapshot.value as Map<dynamic, dynamic>?;

          int actScore = treatmentPlanData?["ACT"] ?? 0;
          bool isApproved = treatmentPlanData?["isApproved"] ?? false;

          patientList.add({
            "Fname": entry.value["Fname"] ?? "Unknown",
            "Lname": entry.value["Lname"] ?? "Unknown",
            "ACT": actScore,
            "Is_Approve": isApproved,
          });
        }
      }

      setState(() {
        patients = patientList;
        _applySorting();
      });
    }
  }

  void _applySorting() {
    if (currentFilter == "Need Approve") {
      patients.sort((a, b) => a["Is_Approve"] == false ? -1 : 1);
    } else if (currentFilter == "Status") {
      patients.sort((a, b) => a["ACT"].compareTo(b["ACT"]));
    } else {
      patients.sort((a, b) {
        String nameA = "${a["Fname"]} ${a["Lname"]}".toLowerCase();
        String nameB = "${b["Fname"]} ${b["Lname"]}".toLowerCase();
        return nameA.compareTo(nameB);
      });
    }
    setState(() {});
  }

  Color _getStatusColor(int actScore) {
    if (actScore >= 20) return Colors.green;
    if (actScore < 10) return Colors.red;
    return Colors.yellow;
  }

  Color _getTreatmentPlanColor(bool isApproved) {
    return isApproved ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 100,
          title: const Text(
            "Patient List",
            style: TextStyle(
              fontWeight: FontWeight.bold, // Make title bold
              fontSize: 30, // Adjust size if needed
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            // Sorting Bar - Styled According to Your Design
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: const Color(0xFF6676AA).withOpacity(0.09),
                borderRadius: BorderRadius.circular(1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton("All"),
                  _buildFilterButton("Need Approve"),
                  _buildFilterButton("Status"),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Table Header (Background #6676AA)
            Container(
              color: const Color(0xFF6676AA),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text("Name", style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text("Status",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("Treatment Plan",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),

            // Patient List
            Expanded(
              child: patients.isEmpty
                  ? const Center(child: Text("No patients found"))
                  : ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () {}, // Clickable for future interactions
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Name (Left)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${patient["Fname"]} ${patient["Lname"]}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                // ACT Status (Middle)
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildStatusIndicator(
                                          _getStatusColor(patient["ACT"])),
                                      const SizedBox(width: 5),
                                      Text(patient["ACT"].toString(),
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                // Treatment Plan (Right)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    patient["Is_Approve"]
                                        ? "Approved"
                                        : "Need Approve",
                                    style: TextStyle(
                                      color: _getTreatmentPlanColor(
                                          patient["Is_Approve"]),
                                      //fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          currentFilter = text;
          _applySorting();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: currentFilter == text
            ? const Color(0xFF6676AA)
            : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: currentFilter == text ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
