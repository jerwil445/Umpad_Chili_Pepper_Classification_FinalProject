import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chili_pepper_data.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");
  int _totalScans = 0;
  String _mostFrequentChili = "None";
  bool _isLoading = true;
  String _favoriteChili = "Bird's Eye Chili";

  void _showChiliSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D1B18),
          title: Text(
            "Select Favorite Chili",
            style: GoogleFonts.robotoSlab(color: Colors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: getChiliPeppers().map((chili) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(chili.imagePath),
                  ),
                  title: Text(
                    chili.name,
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _favoriteChili = chili.name;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _editProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile picture editing coming soon!")),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final snapshot = await _dbRef.once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        int count = 0;
        Map<String, int> frequency = {};

        data.forEach((key, value) {
          if (value is Map) {
            count++;
            String className = value['className'] ?? 'Unknown';
            frequency[className] = (frequency[className] ?? 0) + 1;
          }
        });

        String topChili = "None";
        int maxCount = 0;

        frequency.forEach((key, value) {
          if (value > maxCount) {
            maxCount = value;
            topChili = key;
          }
        });

        if (mounted) {
          setState(() {
            _totalScans = count;
            _mostFrequentChili = topChili;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _totalScans = 0;
            _mostFrequentChili = "None";
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error fetching stats: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 27, 27), // Dark background
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.robotoSlab(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 55, 55),
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
        actions: [],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background Curve
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 206, 17, 17),
                        const Color.fromARGB(255, 230, 97, 9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                // Profile Card
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D1B18), // Dark card background
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE63946), Color(0xFFF77F00)],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _editProfilePicture,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: AssetImage('assets/profile/unnamed.jpg'),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _editProfilePicture,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Jerwil Umpad",
                                    style: GoogleFonts.robotoSlab(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "jerwil.umpad@example.com",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  //   decoration: BoxDecoration(
                                  //     color: Color(0xFFE63946).withOpacity(0.2),
                                  //     borderRadius: BorderRadius.circular(20),
                                  //   ),
                                  //   child: Text(
                                  //     "Spice Master",
                                  //     style: GoogleFonts.roboto(
                                  //       fontSize: 12,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Color(0xFFE63946),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80),

            // Statistics Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overview",
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Scans",
                          _isLoading ? "..." : "$_totalScans",
                          Icons.qr_code_scanner,
                          Color(0xFFE63946),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          "Top Scan",
                          _isLoading ? "..." : _mostFrequentChili,
                          Icons.local_fire_department,
                          Color(0xFFF77F00),
                          style: GoogleFonts.robotoSlab(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildWideStatCard(
                    "Favorite Chili",
                    _favoriteChili,
                    Icons.favorite,
                    Colors.redAccent,
                    onTap: _showChiliSelectionDialog,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Chili Classes List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chili Collection",
                        style: GoogleFonts.robotoSlab(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF2D1B18), // Dark card background
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: getChiliPeppers().asMap().entries.map((entry) {
                        int index = entry.key;
                        ChiliPepper pepper = entry.value;
                        var metadata = _getChiliMetadata(pepper.name);
                        return Column(
                          children: [
                            _buildClassItem(
                              pepper.name,
                              metadata['tag'],
                              metadata['color'],
                              pepper.imagePath,
                            ),
                            if (index != getChiliPeppers().length - 1) _buildDivider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {TextStyle? style}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2D1B18), // Dark card background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: style ?? GoogleFonts.robotoSlab(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2D1B18), // Dark card background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        value,
                        style: GoogleFonts.robotoSlab(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) Icon(Icons.edit, color: Colors.white24, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassItem(String name, String tag, Color tagColor, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (e, s) {},
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Map<String, dynamic> _getChiliMetadata(String name) {
    switch (name) {
      case 'Jalapeño':
        return {'tag': 'Mild Heat', 'color': Colors.green};
      case 'Habanero':
        return {'tag': 'Very Hot', 'color': Colors.orange};
      case 'Cayenne':
        return {'tag': 'Hot', 'color': Colors.redAccent};
      case 'Serrano':
        return {'tag': 'Hot', 'color': Colors.red};
      case 'Ghost Pepper':
        return {'tag': 'Extreme', 'color': Colors.red};
      case 'Carolina Reaper':
        return {'tag': 'Dangerous', 'color': Colors.purple};
      case 'Thai Chili':
        return {'tag': 'Very Hot', 'color': Colors.red};
      case 'Bird\'s Eye Chili':
        return {'tag': 'Very Hot', 'color': Colors.red};
      case 'Poblano':
        return {'tag': 'Mild', 'color': Colors.green};
      case 'Anaheim':
        return {'tag': 'Mild', 'color': Colors.green};
      default:
        return {'tag': 'Unknown', 'color': Colors.grey};
    }
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white10,
      indent: 86, // Align with text
      endIndent: 20,
    );
  }


}
