import 'package:flutter/material.dart';
import 'chili_pepper_data.dart';
import 'package:google_fonts/google_fonts.dart';

class ChiliPepperDetailPage extends StatelessWidget {
  final ChiliPepper pepper;

  const ChiliPepperDetailPage({Key? key, required this.pepper})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 59, 25, 11), // Dark background color
            Color(0xFF251B1B), // Slightly lighter shade
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            pepper.name,
            style: GoogleFonts.robotoSlab(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDED0C6),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 206, 17, 17),
                  const Color.fromARGB(255, 230, 97, 9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pepper Image with enhanced styling and decorative elements
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF755B53), Color(0xFF5D453F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        pepper.imagePath,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Return a placeholder widget if image fails to load
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 50, color: Colors.red),
                                SizedBox(height: 10),
                                Text(
                                  'Failed to load image',
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Decorative corner elements
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Pepper Name with enhanced styling and decorative divider
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF755B53), Color(0xFF5D453F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pepper.name,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDED0C6),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Decorative divider
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.orange.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Description Section with enhanced styling
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF755B53), Color(0xFF5D453F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Title with icon
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFDED0C6),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Description',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDED0C6),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Description Text with better formatting
                    Text(
                      pepper.description,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),

              // Additional spacing at the bottom
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
