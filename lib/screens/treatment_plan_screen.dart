import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TreatmentPlanScreen extends StatelessWidget {
  const TreatmentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController treatmentController = TextEditingController(
        text:
            "Controller: 1 inhalation of Budesonide/\nFormoterol (ICS/LABA) twice daily.\n\nReliever: Same inhaler (ICS/Formoterol)\nas needed for symptoms.");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child:
                        Image.asset("assets/star.png", width: 40, height: 40),
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
                        "Name: Furat Alfarsi\nAge: 23\nACT Score = 16",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Show more",
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
            ),

            const SizedBox(height: 20),

            // Editable Treatment Plan Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: treatmentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter treatment plan...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black87),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Image.asset("assets/editpen.png",
                          width: 24, height: 24),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Approve & Send Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        "Updated Treatment Plan: ${treatmentController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6676AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40),
                  ),
                  child: Text(
                    "APPROVE & SEND",
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
