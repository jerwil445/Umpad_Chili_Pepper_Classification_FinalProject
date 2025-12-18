import 'package:flutter/material.dart';
import 'chili_pepper_data.dart';
import 'chili_pepper_detail.dart';
import 'package:google_fonts/google_fonts.dart';

class ChiliPepperClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chiliPeppers = getChiliPeppers();

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
            'Chili Pepper Classes',
            style: GoogleFonts.robotoSlab(
              fontSize: 22,
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
          foregroundColor: Colors.white,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: chiliPeppers.length,
          itemBuilder: (context, index) {
            final pepper = chiliPeppers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF755B53), Color(0xFF5D453F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    // Image container with enhanced styling
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.7),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          pepper.imagePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Return a placeholder widget if image fails to load
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[300],
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                    ),
                    // Decorative corner badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.orangeAccent,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  pepper.name,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDED0C6),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.7),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      pepper.description.length > 120
                          ? '${pepper.description.substring(0, 120)}...'
                          : pepper.description,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 13,
                        color: Colors.grey[300],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    // Decorative progress indicator for visual interest
                    Container(
                      height: 3,
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
                trailing: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 206, 17, 17),
                        Color.fromARGB(255, 230, 97, 9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChiliPepperDetailPage(pepper: pepper),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
