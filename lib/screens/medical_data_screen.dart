import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'finish_screen.dart';

class MedicalDataScreen extends StatefulWidget {
  final String userId;

  const MedicalDataScreen({super.key, required this.userId});

  @override
  _MedicalDataScreenState createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String? selectedGender;
  bool? isPregnant;
  bool? hasAllergy;
  DateTime? selectedDate;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  bool isValid = false;

  // Calculate BMI
  double calculateBMI() {
    double weight = double.tryParse(weightController.text.trim()) ?? 0;
    double height = double.tryParse(heightController.text.trim()) ?? 0;
    if (weight > 0 && height > 0) {
      return weight / pow(height / 100, 2);
    }
    return 0;
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        validateInputs();
      });
    }
  }

  void validateInputs() {
    bool weightValid = weightController.text.isNotEmpty &&
        RegExp(r'^[0-9]+$').hasMatch(weightController.text.trim());
    bool heightValid = heightController.text.isNotEmpty &&
        RegExp(r'^[0-9]+$').hasMatch(heightController.text.trim());
    bool genderValid = selectedGender != null;
    bool dateValid = selectedDate != null;

    setState(() {
      isValid = weightValid && heightValid && genderValid && dateValid;
    });
  }

  void _saveMedicalData() async {
    if (!isValid) return;

    double bmi = calculateBMI();

    await _database.child("Patient").child(widget.userId).update({
      "Gender": selectedGender,
      "Is_pregnant": isPregnant ?? false,
      "Has_allergy": hasAllergy ?? false,
      "Date_of_birth": selectedDate != null
          ? DateFormat("dd/MM/yyyy").format(selectedDate!)
          : "",
      "Weight": int.tryParse(weightController.text.trim()) ?? 0,
      "Height": int.tryParse(heightController.text.trim()) ?? 0,
      "BMI": bmi.toStringAsFixed(2), // Store calculated BMI
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FinishScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical Data")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
                "To optimize your experience, we need some medical data.",
                textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // Gender Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Gender: "),
                Radio<String>(
                  value: "Female",
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() {
                    selectedGender = value;
                    validateInputs();
                  }),
                ),
                const Text("Female"),
                Radio<String>(
                  value: "Male",
                  groupValue: selectedGender,
                  onChanged: (value) => setState(() {
                    selectedGender = value;
                    validateInputs();
                  }),
                ),
                const Text("Male"),
              ],
            ),

            // Pregnancy Status (Only if Female)
            if (selectedGender == "Female")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Are you pregnant? "),
                  Radio<bool>(
                    value: true,
                    groupValue: isPregnant,
                    onChanged: (value) => setState(() {
                      isPregnant = value;
                      validateInputs();
                    }),
                  ),
                  const Text("Yes"),
                  Radio<bool>(
                    value: false,
                    groupValue: isPregnant,
                    onChanged: (value) => setState(() {
                      isPregnant = value;
                      validateInputs();
                    }),
                  ),
                  const Text("No"),
                ],
              ),

            // Allergy Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Do you have allergies? "),
                Radio<bool>(
                  value: true,
                  groupValue: hasAllergy,
                  onChanged: (value) => setState(() {
                    hasAllergy = value;
                    validateInputs();
                  }),
                ),
                const Text("Yes"),
                Radio<bool>(
                  value: false,
                  groupValue: hasAllergy,
                  onChanged: (value) => setState(() {
                    hasAllergy = value;
                    validateInputs();
                  }),
                ),
                const Text("No"),
              ],
            ),

            // Date of Birth - Calendar Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Birthday",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat("dd/MM/yyyy").format(selectedDate!)
                      : "Select a date",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Weight
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => validateInputs(),
              decoration: const InputDecoration(labelText: "Weight (kg)"),
            ),

            // Height
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => validateInputs(),
              decoration: const InputDecoration(labelText: "Height (cm)"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isValid ? _saveMedicalData : null,
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
