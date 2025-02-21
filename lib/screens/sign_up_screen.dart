import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'sign_up_next_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isIdValid = false;
  bool isFirstNameValid = false;
  bool isLastNameValid = false;
  bool isPhoneValid = false;

  bool emailSent = false; // Track if verification email is sent

  void _validateFields() {
    setState(() {
      isEmailValid = emailController.text.trim().isNotEmpty;
      isPasswordValid = passwordController.text.trim().isNotEmpty;
      isIdValid = RegExp(r'^\d+$').hasMatch(idController.text.trim());
      isFirstNameValid =
          RegExp(r'^[a-zA-Z]+$').hasMatch(firstNameController.text.trim());
      isLastNameValid =
          RegExp(r'^[a-zA-Z]+$').hasMatch(lastNameController.text.trim());
      isPhoneValid = RegExp(r'^05\d{8}$').hasMatch(phoneController.text.trim());
    });
  }

  bool get isFormValid =>
      isEmailValid &&
      isPasswordValid &&
      isIdValid &&
      isFirstNameValid &&
      isLastNameValid &&
      isPhoneValid;

  void _signUp() async {
    if (!isFormValid) return; // Prevent signing up if form is invalid

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification(); // ✅ Send verification email
        await _auth
            .signOut(); // ✅ Log user out immediately to prevent unverified login

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Verification email sent! Check your inbox.")),
        );

        setState(() {
          emailSent = true; // ✅ Update UI to show "Verification Sent" message
        });

        String userId = idController.text.trim();

        await _database.child("users").child(userId).set({
          "email": emailController.text.trim(),
          "id": userId,
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "phone": int.tryParse(phoneController.text.trim()) ?? 0,
          "emailVerified": false, // ✅ Track verification status
        });

        _showVerificationDialog(userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showVerificationDialog(String userId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without verification
      builder: (context) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: const Text(
            "A verification email has been sent. Please check your inbox and verify your account."),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser
                  ?.reload(); // ✅ Refresh user data
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null && user.emailVerified) {
                print("✅ Email is verified!");

                // Update database to mark email as verified
                await _database.child("users").child(userId).update({
                  "emailVerified": true,
                });

                // Navigate to next screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpNextScreen(
                      userId: userId,
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("❌ Email not verified yet! Try again.")),
                );
              }
            },
            child: const Text("I've Verified My Email"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser
                  ?.sendEmailVerification(); // ✅ Resend verification email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("✅ Verification email sent again!")),
              );
            },
            child: const Text("Resend Email"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SIGN UP",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Nunito",
              ),
            ),
            const SizedBox(height: 10),

            // Email Field
            TextField(
              controller: emailController,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "Email",
                errorText: isEmailValid ? null : "Email cannot be empty",
              ),
            ),

            // Password Field (Hidden Input)
            TextField(
              controller: passwordController,
              obscureText: true,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "Password",
                errorText: isPasswordValid ? null : "Password cannot be empty",
              ),
            ),

            // ID Field
            TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "ID",
                errorText: isIdValid ? null : "ID must be numbers only",
              ),
            ),

            // First Name Field
            TextField(
              controller: firstNameController,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "First Name",
                errorText: isFirstNameValid
                    ? null
                    : "First name must contain only letters",
              ),
            ),

            // Last Name Field
            TextField(
              controller: lastNameController,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "Last Name",
                errorText: isLastNameValid
                    ? null
                    : "Last name must contain only letters",
              ),
            ),

            // Phone Number Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateFields(),
              decoration: InputDecoration(
                labelText: "Phone Number",
                errorText: isPhoneValid
                    ? null
                    : "Phone must be 10 digits & start with '05'",
              ),
            ),

            const SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: isFormValid ? _signUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? const Color(0xFF8699DA) // Enabled (Valid)
                    : const Color(0xFFB1B1B1), // Disabled (Invalid)
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Nunito",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
