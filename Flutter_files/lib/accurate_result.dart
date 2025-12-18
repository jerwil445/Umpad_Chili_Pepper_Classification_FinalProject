import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class PredictionDetail {
  final String label;
  final double confidence;

  PredictionDetail({required this.label, required this.confidence});
}

class AccurateResultPage extends StatefulWidget {
  @override
  _AccurateResultPageState createState() => _AccurateResultPageState();
}

class _AccurateResultPageState extends State<AccurateResultPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");
  List<Map<dynamic, dynamic>> _predictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await _dbRef.orderByChild('timestamp').once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        List<Map<dynamic, dynamic>> predictionsList = [];
        data.forEach((key, value) {
          if (value is Map) {
            predictionsList.add({
              'id': value['id'] ?? '',
              'className': value['className'] ?? 'Unknown',
              'accuracy': value['accuracy'] ?? '0.0000',
              'timestamp': value['timestamp'] ?? 0,
              'allPredictions':
                  value['allPredictions'] ?? [], // Fetch all predictions
              'firebaseKey': key, // Store the Firebase key for deletion
            });
          }
        });

        // Sort by timestamp in descending order (newest first)
        predictionsList.sort(
          (a, b) => b['timestamp'].compareTo(a['timestamp']),
        );

        setState(() {
          _predictions = predictionsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $error')));
    }
  }

  // Function to delete a prediction
  Future<void> _deletePrediction(String firebaseKey, int index) async {
    try {
      await _dbRef.child(firebaseKey).remove();

      // Update the local list
      setState(() {
        _predictions.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction deleted successfully')),
      );
    } catch (error) {
      print('Error deleting prediction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting prediction: $error')),
      );
    }
  }

  // Function to confirm deletion
  void _confirmDelete(String firebaseKey, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this prediction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePrediction(firebaseKey, index);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Unknown';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // Function to get image path for a chili pepper class - copied from insert.dart
  String _getImagePath(String label) {
    // Normalize the label to match asset names
    String normalizedLabel = label.toLowerCase();

    if (normalizedLabel.contains('jalape') ||
        normalizedLabel.contains('jalapeno')) {
      return 'assets/images/Jalapeno.jpg';
    } else if (normalizedLabel.contains('habanero')) {
      return 'assets/images/Habanero.png';
    } else if (normalizedLabel.contains('cayenne')) {
      return 'assets/images/Cayenne.jpg';
    } else if (normalizedLabel.contains('serrano')) {
      return 'assets/images/Serrano.png';
    } else if (normalizedLabel.contains('ghost') ||
        normalizedLabel.contains('bhut')) {
      return 'assets/images/Ghost_Pepper.jpg';
    } else if (normalizedLabel.contains('carolina') ||
        normalizedLabel.contains('reaper')) {
      return 'assets/images/Carolina reaper.jpg';
    } else if (normalizedLabel.contains('thai')) {
      return 'assets/images/Thai Chili.png';
    } else if (normalizedLabel.contains('bird')) {
      return 'assets/images/Bird_s Eye Chili.jpg';
    } else if (normalizedLabel.contains('poblano')) {
      return 'assets/images/Poblano.png';
    } else if (normalizedLabel.contains('anaheim')) {
      return 'assets/images/Anaheim.png';
    } else {
      // Default image if no match found
      return 'assets/images/Jalapeno.jpg';
    }
  }

  String _getChiliPepperDescription(String className) {
    final chiliPeppers = [
      {
        'name': 'Jalapeño',
        'description':
            'Medium-sized chili pepper (2,500-8,000 SHU). Commonly eaten raw, pickled, or smoked. Popular in Mexican cuisine.',
      },
      {
        'name': 'Habanero',
        'description':
            'Very hot heart-shaped pepper (100,000-350,000 SHU). Comes in various colors. Popular in Caribbean and Central American dishes.',
      },
      {
        'name': 'Cayenne',
        'description':
            'Hot chili pepper (30,000-50,000 SHU). Often dried and ground into spice. Used to season spicy dishes.',
      },
      {
        'name': 'Serrano',
        'description':
            'Hot pepper hotter than jalapeño (10,000-23,000 SHU). Commonly consumed raw in Mexican salsas.',
      },
      {
        'name': 'Ghost Pepper',
        'description':
            'Extremely hot pepper (1,001,304 SHU). Holds former world record. Has a sweet-fruity taste that masks its heat.',
      },
      {
        'name': 'Carolina Reaper',
        'description':
            'World\'s hottest chili pepper (over 2 million SHU). Bumpy texture with sweet-fruity taste. Cross between Pakistani Naga and Red Habanero.',
      },
      {
        'name': 'Thai Chili',
        'description':
            'Small but very hot pepper (50,000-100,000 SHU). Essential in Southeast Asian cuisine. Used fresh in salsas and sauces.',
      },
      {
        'name': 'Poblano',
        'description':
            'Mild heart-shaped pepper (1,000-2,000 SHU). Often stuffed with cheese or meat. Becomes mulato pepper when dried.',
      },
      {
        'name': 'Anaheim',
        'description':
            'Mild chili pepper (500-2,500 SHU). Often used for stuffing. Popular in chile relleno and chili con carne.',
      },
      {
        'name': 'Bird’s Eye Chili',
        'description':
            'Small but fiery hot pepper (50,000-100,000 SHU). Resembles a bird\'s eye. Widely used in Thai and Vietnamese cuisine.',
      },
    ];

    // Find matching description
    for (var pepper in chiliPeppers) {
      String normalizedPepperName = pepper['name']!.replaceAll('’', '\'');
      String normalizedClassName = className.replaceAll('’', '\'');

      if (normalizedPepperName == normalizedClassName) {
        return pepper['description']!;
      }
    }

    // Handle case variations and partial matches
    for (var pepper in chiliPeppers) {
      String normalizedPepperName =
          pepper['name']!.replaceAll('’', '\'').toLowerCase();
      String normalizedClassName = className.replaceAll('’', '\'').toLowerCase();

      if (normalizedPepperName == normalizedClassName) {
        return pepper['description']!;
      }
      if (normalizedClassName.contains(normalizedPepperName) ||
          normalizedPepperName.contains(normalizedClassName)) {
        return pepper['description']!;
      }
    }

    return 'Description not available.';
  }

  // Function to build the detailed prediction breakdown dialog
  void _showPredictionDetails(Map<dynamic, dynamic> prediction) {
    // Extract all predictions
    List<PredictionDetail> allPreds = [];
    if (prediction['allPredictions'] is List) {
      for (var pred in prediction['allPredictions']) {
        if (pred is Map &&
            pred['label'] != null &&
            pred['confidence'] != null) {
          allPreds.add(
            PredictionDetail(
              label: pred['label'],
              confidence: pred['confidence'] is double
                  ? pred['confidence']
                  : double.tryParse(pred['confidence'].toString()) ?? 0.0,
            ),
          );
        }
      }
    }

    // Sort predictions by confidence (highest first)
    allPreds.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Calculate total confidence of displayed predictions
    double totalConfidence = allPreds.fold(
      0.0,
      (sum, pred) => sum + pred.confidence,
    );

    // Normalize predictions to ensure they sum to exactly 100%
    List<PredictionDetail> normalizedPredictions = [];
    double cumulativeSum = 0.0;

    for (int i = 0; i < allPreds.length; i++) {
      double normalizedConfidence;
      if (i == allPreds.length - 1) {
        // For the last item, use the remaining percentage to ensure total is exactly 100%
        normalizedConfidence = 1.0 - cumulativeSum;
      } else {
        // Normalize proportionally
        normalizedConfidence = allPreds[i].confidence / totalConfidence;
        cumulativeSum += normalizedConfidence;
      }

      normalizedPredictions.add(
        PredictionDetail(
          label: allPreds[i].label,
          confidence: normalizedConfidence,
        ),
      );
    }

    // Recalculate total confidence after normalization
    double normalizedTotalConfidence = normalizedPredictions.fold(
      0.0,
      (sum, pred) => sum + pred.confidence,
    );

    // Calculate remaining percentage for classes other than the top prediction
    double topPredictionConfidence = normalizedPredictions.isNotEmpty
        ? normalizedPredictions.first.confidence
        : 0.0;
    double remainingPercentage =
        normalizedTotalConfidence - topPredictionConfidence;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to take full height if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Color(0xFF2D1B18), // Darker, richer background
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prediction Analysis',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDED0C6),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white10, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Prediction Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Large Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24, width: 2),
                                image: DecorationImage(
                                  image: AssetImage(_getImagePath(prediction['className'])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Top Match',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    prediction['className'],
                                    style: GoogleFonts.robotoSlab(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: Colors.greenAccent),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '${(double.parse(prediction['accuracy']) * 100).toStringAsFixed(2)}% Accuracy',
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Description Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF3E2723).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book_rounded,
                                    color: Colors.orangeAccent, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  "About this Chili",
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDED0C6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              _getChiliPepperDescription(
                                  prediction['className']),
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detailed Breakdown',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDED0C6),
                            ),
                          ),
                          Text(
                            'Total: ${(normalizedTotalConfidence * 100).toStringAsFixed(2)}%',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // List of all predictions
                      ...normalizedPredictions.map((pred) {
                        bool isTop = normalizedPredictions.indexOf(pred) == 0;
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF3E2723).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: isTop ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
                          ),
                          child: Row(
                            children: [
                              // Small Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  _getImagePath(pred.label),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              
                              // Name and Bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pred.label,
                                            style: GoogleFonts.robotoSlab(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '${(pred.confidence * 100).toStringAsFixed(2)}%',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isTop ? Colors.orangeAccent : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pred.confidence,
                                        backgroundColor: Colors.black26,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isTop ? Colors.orange : Colors.grey,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Accuracy Result',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
      body: Container(
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _predictions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No prediction data available',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  return _buildPredictionCard(_predictions[index], index);
                },
              ),
      ),
    );
  }

  Widget _buildPredictionCard(Map<dynamic, dynamic> prediction, int index) {
    String imagePath = _getImagePath(prediction['className']);
    double accuracy = double.parse(prediction['accuracy']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPredictionDetails(prediction),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              prediction['className'],
                              style: GoogleFonts.robotoSlab(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Delete Button
                          InkWell(
                            onTap: () => _confirmDelete(prediction['firebaseKey'], index),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red[300],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatTimestamp(prediction['timestamp']),
                              style: GoogleFonts.robotoSlab(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Accuracy Indicator
                      Row(
                        children: [
                          Text(
                            'Accuracy:',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: accuracy,
                                backgroundColor: Colors.black26,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accuracy > 0.8 ? Colors.green : Colors.orange,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${(accuracy * 100).toStringAsFixed(2)}%',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accuracy > 0.8 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
