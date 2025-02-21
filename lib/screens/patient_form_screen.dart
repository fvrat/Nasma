// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'medical_data_screen.dart';

// class PatientFormScreen extends StatefulWidget {
//   final String userId;
//   final String firstName;
//   final String lastName;
//   final bool isDependent; // Check if the user is a dependent

//   const PatientFormScreen({
//     super.key,
//     required this.userId,
//     required this.firstName,
//     required this.lastName,
//     required this.isDependent, // New flag for dependents
//   });

//   @override
//   _PatientFormScreenState createState() => _PatientFormScreenState();
// }

// class _PatientFormScreenState extends State<PatientFormScreen> {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   final TextEditingController emergencyPhoneController =
//       TextEditingController();
//   String? selectedDoctorId;
//   List<Map<String, dynamic>> doctors = [];
//   bool isValid = false;
//   String? phoneError, doctorError;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//   }

//   void _fetchDoctors() async {
//     DatabaseEvent event = await _database.child("Doctors").once();
//     Map<dynamic, dynamic>? doctorData =
//         event.snapshot.value as Map<dynamic, dynamic>?;
//     if (doctorData != null) {
//       setState(() {
//         doctors = doctorData.entries.map((entry) {
//           return {
//             "id": entry.key,
//             "Fname": entry.value["Fname"],
//             "Lname": entry.value["Lname"],
//             "Hospital": entry.value["Hospital"],
//             "Speciality": entry.value["Speciality"],
//             "Degree": entry.value["Degree"],
//           };
//         }).toList();
//       });
//     }
//   }

//   void validateInputs() {
//     String phone = emergencyPhoneController.text.trim();
//     phoneError = phone.length == 10 &&
//             phone.startsWith("05") &&
//             RegExp(r'^[0-9]+$').hasMatch(phone)
//         ? null
//         : "Phone must be 10 digits & start with '05'";
//     doctorError = selectedDoctorId != null ? null : "Please select a doctor";

//     setState(() {
//       isValid = phoneError == null && doctorError == null;
//     });
//   }

//   void _savePatientData() async {
//     if (!isValid) return;

//     await _database.child("Patient").child(widget.userId).update({
//       "Patient_ID": widget.userId,
//       "Fname": widget.firstName,
//       "Lname": widget.lastName,
//       "EM_phone": int.tryParse(emergencyPhoneController.text.trim()) ?? 0,
//       "Doctor_ID": selectedDoctorId,
//       "Guardian_ID": widget.isDependent
//           ? widget.userId
//           : "", // Guardian ID is empty for normal patients
//       "Treatmentplan_ID": "", // Always empty
//     });

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MedicalDataScreen(userId: widget.userId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Information")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               enabled: false,
//               decoration: InputDecoration(labelText: "ID: ${widget.userId}"),
//             ),
//             TextField(
//               enabled: false,
//               decoration:
//                   InputDecoration(labelText: "First Name: ${widget.firstName}"),
//             ),
//             TextField(
//               enabled: false,
//               decoration:
//                   InputDecoration(labelText: "Last Name: ${widget.lastName}"),
//             ),
//             TextField(
//               controller: emergencyPhoneController,
//               keyboardType: TextInputType.number,
//               onChanged: (_) => validateInputs(),
//               decoration: InputDecoration(
//                 labelText: "Emergency Phone",
//                 errorText: phoneError,
//               ),
//             ),
//             const SizedBox(height: 20),
//             DropdownButtonFormField<String>(
//               value: selectedDoctorId,
//               hint: const Text("Select Doctor"),
//               items: doctors.map((doc) {
//                 return DropdownMenuItem<String>(
//                   value: doc["id"],
//                   child: Text(
//                     "${doc["Fname"]} ${doc["Lname"]} - ${doc["Hospital"]} | ${doc["Speciality"]} | ${doc["Degree"]}",
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDoctorId = value;
//                   validateInputs();
//                 });
//               },
//               decoration: InputDecoration(errorText: doctorError),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isValid ? _savePatientData : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isValid ? const Color(0xFF8699DA) : const Color(0xFFB1B1B1),
//               ),
//               child: const Text("Next"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'medical_data_screen.dart';

class PatientFormScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final bool isDependent; // Check if the user is a dependent

  const PatientFormScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.isDependent, // New flag for dependents
  });

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController emergencyPhoneController =
      TextEditingController();
  String? selectedDoctorId;
  List<Map<String, dynamic>> doctors = [];
  bool isValid = false;
  String? phoneError, doctorError;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() async {
    DatabaseEvent event = await _database.child("Doctor").once();
    Map<dynamic, dynamic>? doctorData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (doctorData != null) {
      setState(() {
        doctors = doctorData.entries.map((entry) {
          return {
            "id": entry.key, // Doctor ID
            "Fname": entry.value["Fname"] ?? "Unknown", // First Name
            "Lname": entry.value["Lname"] ?? "", // Last Name
            "Hospital":
                entry.value["Hospital"] ?? "Unknown Hospital", // Hospital
            "Speciality":
                entry.value["Speciality"] ?? "Unknown Speciality", // Speciality
            "Degree": entry.value["Degree"] ?? "No Degree", // Degree
          };
        }).toList();
      });
    }
  }

  void validateInputs() {
    String phone = emergencyPhoneController.text.trim();
    phoneError = phone.length == 10 &&
            phone.startsWith("05") &&
            RegExp(r'^[0-9]+$').hasMatch(phone)
        ? null
        : "Phone must be 10 digits & start with '05'";
    doctorError = selectedDoctorId != null ? null : "Please select a doctor";

    setState(() {
      isValid = phoneError == null && doctorError == null;
    });
  }

  void _savePatientData() async {
    if (!isValid) return;

    await _database.child("Patient").child(widget.userId).update({
      "Patient_ID": widget.userId,
      "Fname": widget.firstName,
      "Lname": widget.lastName,
      "EM_phone": int.tryParse(emergencyPhoneController.text.trim()) ?? 0,
      "Doctor_ID": selectedDoctorId, // Store doctor selection
      "Guardian_ID": widget.isDependent
          ? widget.userId
          : "", // Guardian ID is empty for normal patients
      "Treatmentplan_ID": "", // Always empty
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalDataScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Information")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              enabled: false,
              decoration: InputDecoration(labelText: "ID: ${widget.userId}"),
            ),
            TextField(
              enabled: false,
              decoration:
                  InputDecoration(labelText: "First Name: ${widget.firstName}"),
            ),
            TextField(
              enabled: false,
              decoration:
                  InputDecoration(labelText: "Last Name: ${widget.lastName}"),
            ),
            TextField(
              controller: emergencyPhoneController,
              keyboardType: TextInputType.number,
              onChanged: (_) => validateInputs(),
              decoration: InputDecoration(
                labelText: "Emergency Phone",
                errorText: phoneError,
              ),
            ),
            const SizedBox(height: 20),

            // Doctor Selection Dropdown
            DropdownButtonFormField<String>(
              value: selectedDoctorId,
              hint: const Text("Select Doctor"),
              items: doctors.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc["id"], // Store only doctor ID
                  child: Text(
                    "${doc["Fname"]} ${doc["Lname"]} - ${doc["Hospital"]} | ${doc["Speciality"]} | ${doc["Degree"]}",
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDoctorId = value;
                  validateInputs();
                });
              },
              decoration: InputDecoration(errorText: doctorError),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isValid ? _savePatientData : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isValid ? const Color(0xFF8699DA) : const Color(0xFFB1B1B1),
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
