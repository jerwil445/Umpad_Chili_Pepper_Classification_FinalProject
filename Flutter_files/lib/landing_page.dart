import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chili_pepper_test/insert.dart'; // Import HomePage

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/background_image/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Full-screen semi-transparent overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          // Content overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Content container
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // App Logo or Icon
                    // Container(
                    //   padding: EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.2),
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Icon(
                    //     Icons.local_fire_department,
                    //     size: 100,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // SizedBox(height: 30),

                    // App Logo with direct shadow on image layer
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10,
                      ),
                      child: Stack(
                        children: [
                          PhysicalModel(
                            color: const Color.fromARGB(0, 255, 255, 255),
                            elevation: 8,
                            shadowColor: const Color.fromARGB(
                              255,
                              8,
                              8,
                              8,
                            ).withOpacity(0.2),
                            child: Image.asset(
                              'assets/background_image/Chili_5.png',
                              width: 480,

                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            bottom: 25,
                            left: 85,
                            right: 0,
                            child: Text(
                              ' P         E         P         P         E         R',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // App Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Identify chili pepper varieties with AI-powered image recognition',
                        style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Get Started Button with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 206, 17, 17),
                      const Color.fromARGB(255, 230, 97, 9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Add transition when navigating to HomePage
                    _navigateWithTransition(context, HomePage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Features
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildFeatureItem(Icons.camera_alt, 'Snap & Identify'),
                    SizedBox(height: 15),
                    _buildFeatureItem(Icons.science, 'AI-Powered Recognition'),
                    SizedBox(height: 15),
                    _buildFeatureItem(Icons.info, 'Detailed Information'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  // Helper method to navigate with transition
  void _navigateWithTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
