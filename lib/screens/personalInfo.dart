import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'footer.dart';
import 'personalInfo.dart';
import 'homepage.dart';
import 'connect_patch_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String patientId;
  final String previousPage; // ✅ Track where the user came from

  PersonalInfoScreen({required this.patientId, required this.previousPage});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late String patientId; // Store the patientId footer
  int _selectedIndex = 2; // Profile tab is selected footer

  final Map<String, TextEditingController> controllers = {
    "Fname": TextEditingController(),
    "Lname": TextEditingController(),
    "EM_phone": TextEditingController(),
    "Gender": TextEditingController(),
    "Weight": TextEditingController(),
    "Height": TextEditingController(),
    "Date_of_birth": TextEditingController(),
    "Is_pregnant": TextEditingController(),
    "Has_allergies": TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    patientId = widget.patientId; // Get patientId from HomeScreen
    fetchUserData();
  }

  // ✅ Function to handle back navigation may we need to add all pages
  void _handleBackNavigation() {
    if (widget.previousPage == "home") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (widget.previousPage == "dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConnectPatchScreen()),
      );
    } else {
      Navigator.pop(
          context); // Default behavior if the previous page is unknown
    }
  }
  //-----------------------------------------------

  Future<void> fetchUserData() async {
    try {
      DatabaseEvent patientEvent =
          await _database.child("Patient").child(patientId).once();
      if (patientEvent.snapshot.exists) {
        Map<dynamic, dynamic>? patientData =
            patientEvent.snapshot.value as Map<dynamic, dynamic>?;
        if (patientData != null) {
          setState(() {
            controllers.forEach((key, controller) {
              controller.text = patientData[key]?.toString() ?? "";
            });
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ConnectPatchScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalInfoScreen(
                  patientId: patientId, previousPage: "personal_info"),
            ),
          );
          break;
      }
    }
  }

//------------------------------------Front-end----------------------------------
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color.fromARGB(255, 102, 118, 170), // Highlight color
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 102, 118, 170),
            ),
            dialogBackgroundColor:
                Colors.white, // Calendar inside background white
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controllers["Date_of_birth"]!.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  String getProfileImage() {
    if (controllers["Gender"]!.text.toLowerCase() == "male") {
      return 'assets/man.png';
    } else if (controllers["Gender"]!.text.toLowerCase() == "female") {
      return 'assets/woman.png';
    }
    return 'assets/user.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBackNavigation, // ✅ Use dynamic navigation
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Color.fromARGB(255, 254, 255, 255), // Profile circle color
              ),
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(getProfileImage()),
              ),
            ),

            SizedBox(height: 10),
            Text(
              "${controllers["Fname"]!.text} ${controllers["Lname"]!.text}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Patient ID (Non-editable)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextFormField(
                initialValue: patientId,
                decoration: InputDecoration(
                  labelText: "Patient ID",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                readOnly: true,
              ),
            ),
            // Other Fields
            ...controllers.entries.map((entry) {
              bool isDateField = entry.key == "Date_of_birth";

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key.replaceAll('_', ' '),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: isDateField
                        ? IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          )
                        : null,
                  ),
                  readOnly: isDateField,
                  onTap: isDateField ? () => _selectDate(context) : null,
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 102, 118, 170), // Button color
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Changes",
                  style:
                      TextStyle(color: Colors.white), // Ensure text is visible
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        selectedIndex: _selectedIndex,
        onItemTapped: (index, _) =>
            _onItemTapped(index), // Pass navigation handler
        patientId: patientId, // ✅ Ensure the correct patient ID is passed
      ),
    );
  }
}
