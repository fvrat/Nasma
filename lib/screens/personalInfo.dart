import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String patientId = "1"; // Default Patient ID

  // Controllers for user data
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController pregnantController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController smokerController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  String? isPregnant = 'false'; // True/False menu for pregnancy
  String? isAllergic = 'false'; // True/False menu for allergies
  String? isSmoker = 'false'; // True/False menu for smoker
  String? selectedDate; // For storing the birth date

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Fetch patient data
      DatabaseEvent patientEvent =
          await _database.child("Patient").child(patientId).once();
      DatabaseEvent historyEvent = await _database
          .child("Medical_history")
          .orderByChild("patient_ID")
          .equalTo(patientId)
          .once();

      // Fetch Patient Data
      if (patientEvent.snapshot.exists) {
        Map<dynamic, dynamic>? patientData =
            patientEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (patientData != null) {
          setState(() {
            firstNameController.text = patientData['Fname'] ?? "";
            lastNameController.text = patientData['Lname'] ?? "";
            emergencyController.text = patientData['EM_phone'] ?? "";
          });
        }
      }

      // Fetch Medical History Data
      if (historyEvent.snapshot.exists) {
        Map<dynamic, dynamic>? historyData =
            (historyEvent.snapshot.value as Map<dynamic, dynamic>?)
                ?.values
                .first;

        if (historyData != null) {
          setState(() {
            genderController.text = historyData['Gender'] ?? "";
            isPregnant = historyData['Is_pragnent'] ? 'true' : 'false';
            isAllergic = historyData['Has_allergies'] ? 'true' : 'false';
            isSmoker = historyData['Are_you_smoker'] ? 'true' : 'false';
            String birthDate = historyData['Date_of_birth'] ?? "";
            weightController.text = historyData['Weight'].toString();
            heightController.text = historyData['Height'].toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> updateUserData() async {
    try {
      // Update Patient table (First Name, Last Name, Emergency Number)
      await _database.child("Patient").child(patientId).update({
        'Fname': firstNameController.text,
        'Lname': lastNameController.text,
        'EM_phone': emergencyController.text,
      });

      // Update Medical_history table (other fields)
      DatabaseEvent historyEvent = await _database
          .child("Medical_history")
          .orderByChild("patient_ID")
          .equalTo(patientId)
          .once();

      if (historyEvent.snapshot.exists) {
        String key = historyEvent.snapshot.children.first.key!;

        await _database.child("Medical_history").child(key).update({
          'Gender': genderController.text,
          'Is_pragnent': isPregnant == 'true',
          'Has_allergies': isAllergic == 'true',
          'Are_you_smoker': isSmoker == 'true',
          'Date_of_birth': int.tryParse(birthdayController.text) ?? 0,
          'Weight': int.tryParse(weightController.text) ?? 0,
          'Height': int.tryParse(heightController.text) ?? 0,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      print("Error updating data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  // Function to select a birth date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        birthdayController.text = selectedDate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personal Info",
          style: TextStyle(color: Color.fromARGB(255, 16, 16, 16)),
        ),
        backgroundColor: Colors.white, // Set background color to white
      ),
      backgroundColor: Colors.white, // Set page background to white
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: TextEditingController(text: patientId),
                decoration: InputDecoration(
                  labelText: "ID",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                readOnly: true, // ID is Read-Only
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: emergencyController,
                decoration: InputDecoration(
                  labelText: "Emergency Number",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: genderController,
                decoration: InputDecoration(
                  labelText: "Gender",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: birthdayController,
                decoration: InputDecoration(
                  labelText: "Birthday",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: "Weight",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              TextFormField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: "Height",
                  filled: true,
                  fillColor: Colors.white, // White background for field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 12), // Added space between fields
              // True/False question (Pregnancy)
              Row(
                children: [
                  Text("Are you pregnant?"),
                  Radio<String>(
                    value: 'true',
                    groupValue: isPregnant,
                    onChanged: (value) {
                      setState(() {
                        isPregnant = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'false',
                    groupValue: isPregnant,
                    onChanged: (value) {
                      setState(() {
                        isPregnant = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 12), // Added space between fields
              // True/False question (Allergies)
              Row(
                children: [
                  Text("Do you have any allergies?"),
                  Radio<String>(
                    value: 'true',
                    groupValue: isAllergic,
                    onChanged: (value) {
                      setState(() {
                        isAllergic = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'false',
                    groupValue: isAllergic,
                    onChanged: (value) {
                      setState(() {
                        isAllergic = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 12), // Added space between fields
              // True/False question (Smoker)
              Row(
                children: [
                  Text("Are you a smoker?"),
                  Radio<String>(
                    value: 'true',
                    groupValue: isSmoker,
                    onChanged: (value) {
                      setState(() {
                        isSmoker = value;
                      });
                    },
                  ),
                  Text('Yes'),
                  Radio<String>(
                    value: 'false',
                    groupValue: isSmoker,
                    onChanged: (value) {
                      setState(() {
                        isSmoker = value;
                      });
                    },
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 12), // Added space between fields
              // Birth date picker

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 45, 96, 137), // Blue background for button
                  foregroundColor: Colors.white, // White text color
                ),
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
