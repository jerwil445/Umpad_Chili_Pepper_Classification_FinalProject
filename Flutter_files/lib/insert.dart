import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:camera/camera.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:chili_pepper_test/profile_page.dart';
import 'package:chili_pepper_test/accurate_result.dart';
import 'package:chili_pepper_test/graph_page.dart';
import 'package:chili_pepper_test/graph_page.dart';
import 'package:chili_pepper_test/chili_pepper_classes.dart';
import 'package:flutter/services.dart'; // For rootBundle

// Define a class to hold prediction data
class PredictionData {
  final String label;
  final double confidence;

  PredictionData({required this.label, required this.confidence});
}

// Function to get description for a chili pepper class
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
      'name':
          'Bird’s Eye Chili', // Changed from Bird\'s Eye Chili to match the labels.txt file exactly
      'description':
          'Small but fiery hot pepper (50,000-100,000 SHU). Resembles a bird\'s eye. Widely used in Thai and Vietnamese cuisine.',
    },
  ];

  // Find matching description
  for (var pepper in chiliPeppers) {
    // Normalize names by replacing smart quotes with standard quotes for comparison
    String normalizedPepperName = pepper['name']!.replaceAll('’', '\'');
    String normalizedClassName = className.replaceAll('’', '\'');

    if (normalizedPepperName == normalizedClassName) {
      return pepper['description']!;
    }
  }

  // Handle case variations and partial matches
  for (var pepper in chiliPeppers) {
    String normalizedPepperName = pepper['name']!.replaceAll('’', '\'').toLowerCase();
    String normalizedClassName = className.replaceAll('’', '\'').toLowerCase();

    if (normalizedPepperName == normalizedClassName) {
      return pepper['description']!;
    }
    // Handle truncated names from labels.txt (e.g., "Ghost Pepper (Bhut..." -> "Ghost Pepper")
    if (normalizedClassName.contains(normalizedPepperName) ||
        normalizedPepperName.contains(normalizedClassName)) {
      return pepper['description']!;
    }
  }

  return 'Description not available.';
}

// Custom StyleHook to apply Google Fonts
class CustomStyleHook extends StyleHook {
  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return GoogleFonts.robotoSlab(
      textStyle: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  double get activeIconSize => 25.0;

  @override
  double get iconSize => 20.0;

  @override
  double get activeIconMargin => 5.0;
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final dbRef = FirebaseDatabase.instance.ref("predictions");
  File? _image;
  String _sampleImagePath = '';
  String _predictionResult = '';
  double _accuracy = 0.0;
  DateTime _predictionTime =
      DateTime.now(); // Add this line to store the prediction time
  bool _isLoading = false;
  bool _isCameraActive = false;
  bool _hasShownWelcomePopup =
      false; // Flag to track if welcome popup has been shown
  List<String> _labels = [];
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  List<PredictionData> _allPredictions = []; // Store all predictions

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
    // Show welcome popup when the page first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownWelcomePopup) {
        _showWelcomePopup();
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(_cameras[0], ResolutionPreset.medium);
        await _controller!.initialize();
        // Add setState to update UI after initialization
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/tflite/model_unquant.tflite",
        labels: "assets/tflite/labels.txt",
      );

      // Load labels separately to display them properly
      String labelsData = await DefaultAssetBundle.of(
        context,
      ).loadString("assets/tflite/labels.txt");
      setState(() {
        _labels = labelsData.split('\n')..removeWhere((label) => label.isEmpty);
      });
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _sampleImagePath = ''; // Reset sample image path
          _isLoading = true;
        });
        _predictImage(_image!);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Method to predict from asset image (Real Prediction)
  Future<void> _predictFromAsset(String imagePath) async {
    try {
      // Stop camera if it's active
      if (_isCameraActive && _controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      // Set the UI state to show loading and display the asset image
      setState(() {
        _image = null; // Clear any existing file image
        _sampleImagePath = imagePath; // Set the sample image path
        _isLoading = true;
        _isCameraActive = false; // Ensure camera is marked as inactive
      });

      // Load the asset image data
      final byteData = await rootBundle.load(imagePath);
      
      // Create a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Write the asset data to the temporary file
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      // Run the actual prediction on the temporary file
      await _predictImage(tempFile);

      // Wait a brief moment for the UI to update
      await Future.delayed(Duration(milliseconds: 300));

      // Automatically show the details modal after prediction
      if (_predictionResult.isNotEmpty && _predictionResult != 'Not a Chili Pepper') {
        _showChiliDetailsModal();
      }

    } catch (e) {
      print("Error predicting from asset: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error predicting from asset: $e')),
      );
    }
  }

  // Method to reset prediction and show the grid again
  void _resetPrediction() {
    setState(() {
      _image = null;
      _sampleImagePath = '';
      _predictionResult = '';
      _accuracy = 0.0;
      _allPredictions = [];
      _isLoading = false;
    });
  }

  // Method to build chili class card for grid layout
  // Each card displays an image and a detailed description of the chili pepper class
  Widget _buildChiliClassCard(String name, String imagePath) {
    // Map for scientific names
    final Map<String, String> scientificNames = {
      'Jalapeño': 'Capsicum annuum',
      'Habanero': 'Capsicum chinense',
      'Cayenne': 'Capsicum annuum',
      'Serrano': 'Capsicum annuum',
      'Ghost Pepper': 'Capsicum chinense',
      'Carolina Reaper': 'Capsicum chinense',
      'Thai Chili': 'Capsicum annuum',
      'Poblano': 'Capsicum annuum',
      'Anaheim': 'Capsicum annuum',
      'Bird\'s Eye Chili': 'Capsicum frutescens',
    };

    // Map for heat levels
    final Map<String, String> heatLevels = {
      'Jalapeño': 'MEDIUM',
      'Habanero': 'VERY HOT',
      'Cayenne': 'HOT',
      'Serrano': 'HOT',
      'Ghost Pepper': 'EXTREME',
      'Carolina Reaper': 'EXTREME',
      'Thai Chili': 'VERY HOT',
      'Poblano': 'MILD',
      'Anaheim': 'MILD',
      'Bird\'s Eye Chili': 'VERY HOT',
    };

    String scientificName = scientificNames[name] ?? 'Capsicum sp.';
    String heatLevel = heatLevels[name] ?? 'MEDIUM';

    return GestureDetector(
      onTap: () {
        // Show modal directly without prediction
        _showChiliInfoModal(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Chili Image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.broken_image, color: Colors.white54),
                );
              },
            ),
            
            // Dark gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            
            // Content overlay
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              top: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heat Level Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHeatColor(heatLevel).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          heatLevel,
                          style: GoogleFonts.roboto(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Chili Name
                  Text(
                    name,
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Scientific Name
                  Text(
                    scientificName,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _predictImage(File image) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 20, // Increase number of results to capture all classes
        threshold:
            0.0001, // Very low threshold to capture even tiny confidence values
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // Get the highest confidence prediction
        var highest = recognitions[0];
        String className = highest['label'];
        double confidence = highest['confidence'];

        // Store all predictions
        List<PredictionData> allPreds = [];
        for (var recognition in recognitions) {
          // Only add predictions with valid labels and confidence values
          if (recognition['label'] != null &&
              recognition['confidence'] != null) {
            allPreds.add(
              PredictionData(
                label: recognition['label'],
                confidence: recognition['confidence'] is double
                    ? recognition['confidence']
                    : double.tryParse(recognition['confidence'].toString()) ??
                          0.0,
              ),
            );
          }
        }

        // STRICT MODE: Check if confidence is high enough to be considered a valid chili pepper
        // Threshold set to 20% (0.20) to allow accurate breakdown even for lower confidence
        if (confidence < 0.20) {
          setState(() {
            _predictionResult = 'Not a Chili Pepper';
            _accuracy = confidence;
            _allPredictions = allPreds;
            _isLoading = false;
            _predictionTime = DateTime.now(); // Store the timestamp
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Very low confidence (${(confidence * 100).toStringAsFixed(1)}%). This does not look like a known chili pepper.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // Do NOT save to Firebase for invalid/uncertain predictions
        } else {
          setState(() {
            _predictionResult = className;
            _accuracy = confidence;
            _allPredictions = allPreds;
            _isLoading = false;
            _predictionTime = DateTime.now(); // Store the timestamp
          });

          // Save to Firebase only if it's a valid prediction
          await _saveToFirebase(className, confidence);
        }
      } else {
        setState(() {
          _predictionResult = 'No prediction';
          _accuracy = 0.0;
          _allPredictions = [];
          _isLoading = false;
          _predictionTime = DateTime.now(); // Store the timestamp
        });
      }
    } catch (e) {
      print("Error predicting image: $e");
      setState(() {
        _predictionResult = 'Error occurred';
        _accuracy = 0.0;
        _allPredictions = [];
        _isLoading = false;
        _predictionTime = DateTime.now(); // Store the timestamp
      });
    }
  }

  Future<void> _saveToFirebase(String className, double accuracy) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final id = Random().nextInt(100000);

      // Convert all predictions to a map format for Firebase
      List<Map<String, dynamic>> predictionsForFirebase = [];
      for (var pred in _allPredictions) {
        predictionsForFirebase.add({
          'label': pred.label,
          'confidence': pred.confidence,
        });
      }

      await dbRef.push().set({
        "id": id,
        "className": className,
        "accuracy": accuracy.toStringAsFixed(4),
        "timestamp": timestamp,
        "allPredictions": predictionsForFirebase, // Store all predictions
      });

      print("Data saved to Firebase successfully");
    } catch (e) {
      print("Error saving to Firebase: $e");
    }
  }

  String getImagePath(String label) {
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

  // Function to build the detailed prediction breakdown
  Widget _buildPredictionBreakdown() {
    if (_allPredictions.isEmpty) return Container();

    // Sort predictions by confidence (highest first)
    List<PredictionData> sortedPredictions = List.from(_allPredictions);
    sortedPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Calculate total confidence of displayed predictions
    double totalConfidence = sortedPredictions.fold(
      0.0,
      (sum, pred) => sum + pred.confidence,
    );

    // Normalize predictions to ensure they sum to exactly 100%
    List<PredictionData> normalizedPredictions = [];
    double cumulativeSum = 0.0;

    for (int i = 0; i < sortedPredictions.length; i++) {
      double normalizedConfidence;
      if (i == sortedPredictions.length - 1) {
        // For the last item, use the remaining percentage to ensure total is exactly 100%
        normalizedConfidence = 1.0 - cumulativeSum;
      } else {
        // Normalize proportionally
        normalizedConfidence =
            sortedPredictions[i].confidence / totalConfidence;
        cumulativeSum += normalizedConfidence;
      }

      normalizedPredictions.add(
        PredictionData(
          label: sortedPredictions[i].label,
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
    double topPredictionConfidence = normalizedPredictions.first.confidence;
    double remainingPercentage =
        normalizedTotalConfidence - topPredictionConfidence;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2D1B18),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy Breakdown',
            style: GoogleFonts.robotoSlab(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDED0C6),
            ),
          ),
          SizedBox(height: 20),
          ...normalizedPredictions.map((pred) {
            bool isTop = normalizedPredictions.indexOf(pred) == 0;
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(getImagePath(pred.label)),
                        fit: BoxFit.cover,
                      ),
                      border: isTop ? Border.all(color: Colors.orangeAccent, width: 2) : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pred.label,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                                color: isTop ? Colors.white : Colors.white70,
                              ),
                            ),
                            Text(
                              '${(pred.confidence * 100).toStringAsFixed(2)}%',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isTop ? Colors.orangeAccent : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pred.confidence,
                            backgroundColor: Colors.black12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTop ? Colors.orangeAccent : Colors.grey.withOpacity(0.3),
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
        ],
      ),
    );
  }
  
  
  // Method to show chili info modal without prediction (for browsing only)
  void _showChiliInfoModal(String chiliName) {
    // Get chili-specific data
    Map<String, dynamic> chiliData = _getChiliData(chiliName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildChiliModal(chiliName, chiliData);
      },
    );
  }

  // Method to show detailed chili pepper information in a smooth modal
  void _showChiliDetailsModal() {
    if (_predictionResult.isEmpty || _predictionResult == 'Not a Chili Pepper') return;

    // Get chili-specific data
    Map<String, dynamic> chiliData = _getChiliData(_predictionResult);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildChiliModal(_predictionResult, chiliData);
      },
    );
  }

  // Build the chili modal widget
  Widget _buildChiliModal(String chiliName, Map<String, dynamic> chiliData) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Top Bar with back button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Chili Image with overlaid text
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF2D2D2D),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Chili Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            getImagePath(chiliName),
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        // Dark gradient overlay for text readability
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.9),
                              ],
                              stops: [0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                        
                        // Content overlay
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          top: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Heat Level Badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getHeatColor(chiliData['heatLevel']).withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      chiliData['heatLevel'].toUpperCase(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              Spacer(),
                              
                              // Chili Name
                              Text(
                                chiliName,
                                style: GoogleFonts.robotoSlab(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              
                              SizedBox(height: 6),
                              
                              // Scientific Name
                              Text(
                                chiliData['scientificName'],
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Scoville Heat Scale Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF251816), // Dark brownish background
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Icon + Title + SHU Value
                        Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SCOVILLE SCALE',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1,
                              ),
                            ),
                            Spacer(),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: chiliData['shuRange'].toString().replaceAll(' Range', ''),
                                    style: GoogleFonts.robotoSlab(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' SHU',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Progress Bar
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF1F2933), // Dark track color
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: chiliData['heatPosition'] < 0.1 ? 0.1 : chiliData['heatPosition'],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  colors: [Colors.orangeAccent, Colors.deepOrange, Colors.red],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Bottom Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeatLabel('MILD', chiliData['heatLevel'] == 'Mild'),
                            _buildHeatLabel('HOT', ['Medium', 'Hot'].contains(chiliData['heatLevel'])),
                            _buildHeatLabel('VERY HOT', chiliData['heatLevel'] == 'Very Hot'),
                            _buildHeatLabel('SUPER', ['Extreme', 'Super'].contains(chiliData['heatLevel'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Color Variants
                  if (chiliData['colors'] != null && chiliData['colors'].isNotEmpty) ...[
                    Row(
                      children: [
                        ...chiliData['colors'].map<Widget>((colorData) {
                          return Container(
                            margin: EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.local_fire_department,
                                      color: colorData['color'],
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  colorData['name'],
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                  
                  // About Section
                  Text(
                    'About',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    _getChiliPepperDescription(chiliName),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Read more',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Flavor & Culinary Use
                  Text(
                    'Flavor & Culinary Use',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chiliData['flavorTags'].map<Widget>((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Culinary Uses
                  ...chiliData['uses'].map<Widget>((use) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(use['icon'], color: Colors.orangeAccent, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  use['title'],
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  use['description'],
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 24),
                  
                  // Nutrition Highlight
                  Text(
                    'Nutrition Highlight',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.eco, color: Colors.green, size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chiliData['nutritionTitle'],
                                style: GoogleFonts.robotoSlab(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                chiliData['nutritionDescription'],
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  

                  
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Helper method to get heat color
  Color _getHeatColor(String heatLevel) {
    switch (heatLevel.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hot':
        return Colors.deepOrange;
      case 'very hot':
        return Colors.red;
      case 'extreme':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  // Helper method to get comprehensive chili data
  Map<String, dynamic> _getChiliData(String chiliName) {
    final chiliDatabase = {
      'Jalapeño': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Medium',
        'shuRange': '2,500-8,000 Range',
        'heatPosition': 0.15,
        'shuPeak': '5k',
        'colors': [
          {'name': 'Green', 'color': Colors.green},
          {'name': 'Red', 'color': Colors.red},
        ],
        'flavorTags': ['Grassy', 'Bright', 'Vegetal', 'Fresh'],
        'uses': [
          {
            'icon': Icons.restaurant,
            'title': 'Salsas & Dips',
            'description': 'Primary ingredient for fresh salsas.',
          },
          {
            'icon': Icons.local_pizza,
            'title': 'Toppings',
            'description': 'Popular on pizzas and nachos.',
          },
        ],
        'nutritionTitle': 'High in Vitamin C',
        'nutritionDescription': 'One pepper provides over 100% of daily value.',
      },
      'Habanero': {
        'scientificName': 'Capsicum chinense',
        'heatLevel': 'Very Hot',
        'shuRange': '100k-350k Range',
        'heatPosition': 0.65,
        'shuPeak': '350k',
        'colors': [
          {'name': 'Orange', 'color': Colors.orange},
          {'name': 'Red', 'color': Colors.red},
          {'name': 'Yellow', 'color': Colors.yellow},
        ],
        'flavorTags': ['Fruity', 'Citrusy', 'Floral', 'Smoky'],
        'uses': [
          {
            'icon': Icons.soup_kitchen,
            'title': 'Hot Sauces & Salsas',
            'description': 'Primary ingredient for extreme heat.',
          },
          {
            'icon': Icons.local_drink,
            'title': 'Spicy Infusions',
            'description': 'Great for tequilas and oils.',
          },
        ],
        'nutritionTitle': 'High in Vitamin C',
        'nutritionDescription': 'One pepper provides over 100% of daily value.',
      },
      'Cayenne': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Hot',
        'shuRange': '30k-50k Range',
        'heatPosition': 0.35,
        'shuPeak': '50k',
        'colors': [
          {'name': 'Red', 'color': Colors.red},
        ],
        'flavorTags': ['Earthy', 'Smoky', 'Pungent', 'Sharp'],
        'uses': [
          {
            'icon': Icons.blender,
            'title': 'Spice Powder',
            'description': 'Dried and ground for seasoning.',
          },
          {
            'icon': Icons.medical_services,
            'title': 'Health Benefits',
            'description': 'Used in traditional medicine.',
          },
        ],
        'nutritionTitle': 'Rich in Capsaicin',
        'nutritionDescription': 'Boosts metabolism and circulation.',
      },
      'Serrano': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Hot',
        'shuRange': '10k-23k Range',
        'heatPosition': 0.25,
        'shuPeak': '23k',
        'colors': [
          {'name': 'Green', 'color': Colors.green},
          {'name': 'Red', 'color': Colors.red},
        ],
        'flavorTags': ['Crisp', 'Bright', 'Grassy', 'Clean'],
        'uses': [
          {
            'icon': Icons.restaurant_menu,
            'title': 'Fresh Salsas',
            'description': 'Commonly consumed raw in Mexican salsas.',
          },
          {
            'icon': Icons.local_dining,
            'title': 'Garnish',
            'description': 'Sliced fresh on tacos and dishes.',
          },
        ],
        'nutritionTitle': 'High in Vitamin A',
        'nutritionDescription': 'Supports eye health and immunity.',
      },
      'Ghost Pepper': {
        'scientificName': 'Capsicum chinense × frutescens',
        'heatLevel': 'Extreme',
        'shuRange': '1M+ Range',
        'heatPosition': 0.85,
        'shuPeak': '1M',
        'colors': [
          {'name': 'Red', 'color': Colors.red},
          {'name': 'Orange', 'color': Colors.orange},
        ],
        'flavorTags': ['Fruity', 'Sweet', 'Smoky', 'Intense'],
        'uses': [
          {
            'icon': Icons.warning,
            'title': 'Extreme Hot Sauces',
            'description': 'Use with extreme caution.',
          },
          {
            'icon': Icons.science,
            'title': 'Pepper Spray',
            'description': 'Used in defense products.',
          },
        ],
        'nutritionTitle': 'Extreme Capsaicin',
        'nutritionDescription': 'Handle with care - can cause burns.',
      },
      'Carolina Reaper': {
        'scientificName': 'Capsicum chinense',
        'heatLevel': 'Extreme',
        'shuRange': '2M+ Range',
        'heatPosition': 0.95,
        'shuPeak': '2.2M',
        'colors': [
          {'name': 'Red', 'color': Colors.red},
        ],
        'flavorTags': ['Sweet', 'Fruity', 'Cinnamon', 'Deadly'],
        'uses': [
          {
            'icon': Icons.dangerous,
            'title': 'Challenge Foods',
            'description': 'World\'s hottest pepper challenges.',
          },
          {
            'icon': Icons.science,
            'title': 'Extract Production',
            'description': 'Used for capsaicin extraction.',
          },
        ],
        'nutritionTitle': 'World Record Heat',
        'nutritionDescription': 'Guinness World Record holder.',
      },
      'Thai Chili': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Very Hot',
        'shuRange': '50k-100k Range',
        'heatPosition': 0.55,
        'shuPeak': '100k',
        'colors': [
          {'name': 'Red', 'color': Colors.red},
          {'name': 'Green', 'color': Colors.green},
        ],
        'flavorTags': ['Bright', 'Clean', 'Pungent', 'Sharp'],
        'uses': [
          {
            'icon': Icons.ramen_dining,
            'title': 'Asian Cuisine',
            'description': 'Essential in Thai and Vietnamese dishes.',
          },
          {
            'icon': Icons.local_fire_department,
            'title': 'Chili Paste',
            'description': 'Base for many Asian sauces.',
          },
        ],
        'nutritionTitle': 'High in Antioxidants',
        'nutritionDescription': 'Supports immune system health.',
      },
      'Poblano': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Mild',
        'shuRange': '1k-2k Range',
        'heatPosition': 0.05,
        'shuPeak': '2k',
        'colors': [
          {'name': 'Green', 'color': Colors.green},
          {'name': 'Red', 'color': Colors.red},
        ],
        'flavorTags': ['Earthy', 'Rich', 'Mild', 'Smoky'],
        'uses': [
          {
            'icon': Icons.fastfood,
            'title': 'Chile Rellenos',
            'description': 'Stuffed with cheese or meat.',
          },
          {
            'icon': Icons.soup_kitchen,
            'title': 'Mole Sauce',
            'description': 'Key ingredient in traditional mole.',
          },
        ],
        'nutritionTitle': 'Rich in Fiber',
        'nutritionDescription': 'Supports digestive health.',
      },
      'Anaheim': {
        'scientificName': 'Capsicum annuum',
        'heatLevel': 'Mild',
        'shuRange': '500-2.5k Range',
        'heatPosition': 0.03,
        'shuPeak': '2.5k',
        'colors': [
          {'name': 'Green', 'color': Colors.green},
        ],
        'flavorTags': ['Mild', 'Sweet', 'Peppery', 'Fresh'],
        'uses': [
          {
            'icon': Icons.restaurant,
            'title': 'Stuffing',
            'description': 'Popular for chile relleno.',
          },
          {
            'icon': Icons.local_pizza,
            'title': 'Roasting',
            'description': 'Delicious when roasted.',
          },
        ],
        'nutritionTitle': 'Low Calorie',
        'nutritionDescription': 'Great for weight management.',
      },
      'Bird\'s Eye Chili': {
        'scientificName': 'Capsicum frutescens',
        'heatLevel': 'Very Hot',
        'shuRange': '50k-100k Range',
        'heatPosition': 0.55,
        'shuPeak': '100k',
        'colors': [
          {'name': 'Red', 'color': Colors.red},
          {'name': 'Green', 'color': Colors.green},
        ],
        'flavorTags': ['Intense', 'Sharp', 'Clean', 'Bright'],
        'uses': [
          {
            'icon': Icons.restaurant_menu,
            'title': 'Southeast Asian Dishes',
            'description': 'Widely used in Thai and Vietnamese cuisine.',
          },
          {
            'icon': Icons.local_fire_department,
            'title': 'Chili Oil',
            'description': 'Base for spicy condiments.',
          },
        ],
        'nutritionTitle': 'High in Vitamin C',
        'nutritionDescription': 'Boosts immune system.',
      },
    };

    return chiliDatabase[chiliName] ?? {
      'scientificName': 'Capsicum sp.',
      'heatLevel': 'Medium',
      'shuRange': 'Unknown',
      'heatPosition': 0.5,
      'shuPeak': 'N/A',
      'colors': [],
      'flavorTags': ['Spicy'],
      'uses': [],
      'nutritionTitle': 'Nutritious',
      'nutritionDescription': 'Contains vitamins and minerals.',
    };
  }

  // Helper method to get chili pepper description
  String _getChiliPepperDescription(String chiliName) {
    final descriptions = {
      'Jalapeño': 'The Jalapeño is a medium-sized chili pepper pod type cultivar of the species Capsicum annuum. A mature jalapeño chili is 5–10 cm long and hangs down with a round, firm, smooth flesh of 25–38 mm wide.',
      'Habanero': 'The Habanero is a hot variety of chili pepper. Unripe habaneros are green, and they color as they mature. The most common color variants are orange and red, but the fruit may also be white, brown, yellow, green, or purple.',
      'Cayenne': 'The Cayenne pepper is a type of Capsicum annuum. It is usually a moderately hot chili pepper used to flavor dishes. Cayenne peppers are a group of tapering, 10 to 25 cm long, generally skinny, mostly red-colored peppers.',
      'Serrano': 'The Serrano pepper is a type of chili pepper that originated in the mountainous regions of the Mexican states of Puebla and Hidalgo. The name of the pepper is a reference to the mountains (sierras) of these regions.',
      'Ghost Pepper': 'The Ghost Pepper, also known as Bhut Jolokia, is an interspecific hybrid chili pepper cultivated in Northeast India. It is a hybrid of Capsicum chinense and Capsicum frutescens and is one of the hottest peppers in the world.',
      'Carolina Reaper': 'The Carolina Reaper is a cultivar of the Capsicum chinense plant. Developed by South Carolina breeder Ed Currie, the pepper is red and gnarled, with a bumpy texture and a small pointed tail.',
      'Thai Chili': 'Thai chili, also known as Bird\'s Eye Chili, is a chili pepper, a variety from the species Capsicum annuum, native to Mexico. Cultivated across Southeast Asia, it is used extensively in many Asian cuisines.',
      'Bird\'s Eye Chili': 'Bird\'s Eye Chili is a small, hot chili pepper used in Southeast Asian cuisine. It is known for its sharp heat and is often used in curries, salads, and stir-fries.',
      'Poblano': 'The Poblano is a mild chili pepper originating in the state of Puebla, Mexico. Dried, it is called ancho or chili ancho, from the Spanish word ancho ("wide").',
      'Anaheim': 'The Anaheim pepper is a mild variety of the New Mexico chile. It is named after Anaheim, California, where Emilio Ortega brought the seeds in the early 1900s.',
    };

    return descriptions[chiliName] ?? 'A spicy chili pepper variety known for its unique flavor and heat profile. Popular in various cuisines around the world.';
  }

  // Helper method to build heat scale labels
  Widget _buildHeatLabel(String label, bool isActive) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
        color: isActive ? Colors.deepOrange : Colors.white38,
        letterSpacing: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 37, 27, 27), // Dark background color
            Color.fromARGB(255, 37, 27, 27),
            // Slightly lighter shade
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        appBar: AppBar(
          title: Text(
            "Chili Pepper Classifier",
            style: GoogleFonts.robotoSlab(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor: const Color.fromARGB(255, 240, 55, 55),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 206, 17, 17),
                  const Color.fromARGB(255, 230, 97, 9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.white),
              onPressed: _showWelcomePopup, // Reuse the existing popup method
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Enhanced DrawerHeader with custom height
                Container(
                  height: 150, // Custom height for the drawer header
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE63946), // Hot Red
                        Color(0xFFF77F00), // Spicy Orange
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container(
                        //   padding: EdgeInsets.all(8),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.2),
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: Icon(
                        //     Icons.local_fire_department,
                        //     size: 40,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        // SizedBox(height: 12),
                        Text(
                          "Chili Pepper Classifier",
                          style: GoogleFonts.robotoSlab(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // SizedBox(height: 8),
                        Text(
                          "AI-Powered Identification",
                          style: GoogleFonts.robotoSlab(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE63946), width: 2),
                      color: Color(
                        0xFFE63946,
                      ).withOpacity(0.5), // Hot Red background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: Color(0xFFE63946),
                    ),
                  ),
                  title: Text(
                    'History Accuracy Result',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to the accurate result page
                    _navigateWithTransition(context, AccurateResultPage());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFF77F00), width: 2),
                      color: Color(
                        0xFFF77F00,
                      ).withOpacity(0.5), // Spicy Orange background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.show_chart,
                      color: Color(0xFFF77F00),
                    ),
                  ),
                  title: Text(
                    'Graph',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to the graph page
                    _navigateWithTransition(context, GraphPage());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(151, 32, 199, 54),
                        width: 2,
                      ),
                      color: Color.fromARGB(
                        151,
                        32,
                        199,
                        54,
                      ).withOpacity(0.5), // Fresh Green background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.category, color: Colors.green),
                  ),
                  title: Text(
                    'Chili pepper classes',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to the chili pepper classes page
                    _navigateWithTransition(context, ChiliPepperClassesPage());
                  },
                ),
              ],
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
          child: SingleChildScrollView(
            // Make the entire body scrollable
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome section with instructions - hidden when image is selected or camera is active
                  // if (!_isCameraActive && _image == null)
                  //   Container(
                  //     padding: EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[100],
                  //       borderRadius: BorderRadius.circular(12),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey.withOpacity(0.2),
                  //           spreadRadius: 1,
                  //           blurRadius: 5,
                  //           offset: Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Welcome to Chili Pepper Classifier!',
                  //           style: GoogleFonts.robotoSlab(
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.bold,
                  //             color: Color(0xFFE63946),
                  //           ),
                  //         ),
                  //         SizedBox(height: 8),
                  //         Text(
                  //           'Identify chili pepper varieties with AI-powered image recognition.',
                  //           style: GoogleFonts.robotoSlab(
                  //             fontSize: 14,
                  //             color: Colors.grey[700],
                  //           ),
                  //         ),
                  //         SizedBox(height: 12),
                  //         Text(
                  //           'How to use:',
                  //           style: GoogleFonts.robotoSlab(
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.grey[800],
                  //           ),
                  //         ),
                  //         SizedBox(height: 4),
                  //         _buildInstructionItem(
                  //           1,
                  //           'Use the camera button below to take a photo of a chili pepper',
                  //         ),
                  //         _buildInstructionItem(
                  //           2,
                  //           'Or use the gallery button to select an existing image',
                  //         ),
                  //         _buildInstructionItem(
                  //           3,
                  //           'The AI will analyze the image and provide a prediction',
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  if (!_isCameraActive && _image == null) SizedBox(height: 20),

                  // Camera/Image container with enhanced initial state
                  DottedBorder(
                    color: Colors.orange,
                    strokeWidth: 1,
                    dashPattern: [5, 5], // Adjust the pattern as needed
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    child: Container(
                      height: 350,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Camera preview content (behind corner lines)
                            if (_isLoading)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 10),
                                    Text(
                                      'Analyzing image...',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            else if (_image != null)
                              // Show user-selected image first (from gallery/camera)
                              Image.file(_image!, fit: BoxFit.cover)
                            else if (_sampleImagePath.isNotEmpty)
                              // Show sample image when chili class card is tapped
                              Image.asset(_sampleImagePath, fit: BoxFit.cover)
                            else if (_isCameraActive &&
                                _controller != null &&
                                _controller!.value.isInitialized)
                              // Camera preview - only show if no image is selected
                              CameraPreview(_controller!)
                            else
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.5,
                                            ),
                                            spreadRadius: 10,
                                            blurRadius: 20,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.photo_camera,
                                        size: 40,
                                        color: const Color.fromARGB(
                                          255,
                                          202,
                                          201,
                                          201,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No image selected',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 20,
                                        color: Color(0xFFDED0C6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Take a photo or select from gallery',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            // Curved corner lines with gap from dotted border (always visible, in front of camera)
                            // Top-left corner arc
                            Positioned(
                              top: 5,
                              left: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                ),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                      left: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Top-right corner arc
                            Positioned(
                              top: 5,
                              right: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                ),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                      right: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-left corner arc
                            Positioned(
                              bottom: 5,
                              left: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                ),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                      left: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-right corner arc
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                ),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                      right: BorderSide(
                                        color: Colors.orange,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Class Images Section - Grid Layout (2 columns)
                  // Displays sample images of all chili pepper classes that the ML model can recognize
                  // Each image card is clickable to simulate a prediction for that specific chili type
                  if (_allPredictions.isEmpty) ...[
                    SizedBox(height: 20),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Chili Pepper Classes',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDED0C6),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Grid layout for 2 columns
                          Container(
                            height: 280, // Height for horizontal scrolling cards
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(bottom: 20),
                              children: [
                                // Jalapeño
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Jalapeño',
                                    'assets/images/Jalapeno.jpg',
                                  ),
                                ),
                                // Habanero
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Habanero',
                                    'assets/images/Habanero.png',
                                  ),
                                ),
                                // Cayenne
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Cayenne',
                                    'assets/images/Cayenne.jpg',
                                  ),
                                ),
                                // Serrano
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Serrano',
                                    'assets/images/Serrano.png',
                                  ),
                                ),
                                // Ghost Pepper
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Ghost Pepper',
                                    'assets/images/Ghost_Pepper.jpg',
                                  ),
                                ),
                                // Carolina Reaper
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Carolina Reaper',
                                    'assets/images/Carolina reaper.jpg',
                                  ),
                                ),
                                // Thai Chili
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Thai Chili',
                                    'assets/images/Thai Chili.png',
                                  ),
                                ),
                                // Poblano
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Poblano',
                                    'assets/images/Poblano.png',
                                  ),
                                ),
                                // Anaheim
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Anaheim',
                                    'assets/images/Anaheim.png',
                                  ),
                                ),
                                // Bird's Eye Chili
                                Container(
                                  width: 180,
                                  margin: EdgeInsets.only(right: 12),
                                  child: _buildChiliClassCard(
                                    'Bird\'s Eye Chili',
                                    'assets/images/Bird_s Eye Chili.jpg',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 5),

                  // Enhanced Prediction Result Card - Only show for user-selected images
                  if (_predictionResult.isNotEmpty && !_isCameraActive && _sampleImagePath.isEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      width: 320,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header with Icon and Title
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  "Analysis Result",
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.cloud_done, size: 12, color: Colors.greenAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        "SAVED",
                                        style: GoogleFonts.roboto(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Main Content
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Identified as",
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: Colors.white54,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _predictionResult,
                                        style: GoogleFonts.robotoSlab(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: _predictionResult ==
                                                  'Not a Chili Pepper'
                                              ? Colors.redAccent
                                              : Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 14, color: Colors.white38),
                                          SizedBox(width: 6),
                                          Text(
                                            _predictionTime
                                                .toLocal()
                                                .toString()
                                                .split('.')
                                                .first,
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Confidence Indicator
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                      width: 4,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${(_allPredictions.isNotEmpty ? _allPredictions[0].confidence * 100 : 0).toStringAsFixed(2)}%",
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orangeAccent,
                                          ),
                                        ),
                                        Text(
                                          "Accuracy",
                                          style: GoogleFonts.roboto(
                                            fontSize: 10,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 5),
                  // Show the predicted class above the prediction breakdown
                  // Knowledge Card (Description) - Only show for user-selected images, not sample images
                  if (_allPredictions.isNotEmpty &&
                      _predictionResult != 'Not a Chili Pepper' &&
                      _sampleImagePath.isEmpty) // Hide for sample images
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
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
                              Icon(Icons.menu_book_rounded, color: Colors.orangeAccent, size: 20),
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
                            _getChiliPepperDescription(_predictionResult),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 8),
                  // Add the prediction breakdown section - Only show for user-selected images
                  if (_allPredictions.isNotEmpty &&
                      _predictionResult != 'Not a Chili Pepper' &&
                      _sampleImagePath.isEmpty) ...[ // Hide for sample images
                    _buildPredictionBreakdown(),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _resetPrediction,
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          'Scan Another',
                          style: GoogleFonts.robotoSlab(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE63946),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: StyleProvider(
          style: CustomStyleHook(),
          child: ConvexAppBar(
            style: TabStyle
                .fixedCircle, // Changed from react to fixedCircle for less curve
            height: 40, // Reduced height for less padding
            curveSize: 60, // Reduced curve size
            backgroundColor: const Color.fromARGB(255, 255, 254, 254),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 206, 17, 17),
                const Color.fromARGB(255, 230, 97, 9),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            items: [
              TabItem(
                icon: Icon(
                  Icons.image,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                title: 'Gallery',
              ),
              TabItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCameraActive ? Icons.camera : Icons.camera_alt,
                    color: _isCameraActive
                        ? Colors.green
                        : const Color.fromARGB(
                            255,
                            240,
                            55,
                            55,
                          ), // Red color to match theme
                    size: 20,
                  ),
                ),
                title: _isCameraActive ? 'Capture' : 'Camera',
              ),
              TabItem(
                icon: Icon(Icons.person, color: Colors.white),
                title: 'Profile',
              ),
            ],
            initialActiveIndex: 1,
            onTap: (int i) {
              switch (i) {
                case 0: // Gallery
                  // Close camera if active
                  if (_isCameraActive) {
                    _toggleCamera();
                  }
                  _pickImage();
                  break;
                case 1: // Camera
                  if (_isCameraActive) {
                    _captureImage();
                  } else {
                    _toggleCamera();
                  }
                  break;
                case 2: // Profile
                  // Close camera if active
                  if (_isCameraActive) {
                    _toggleCamera();
                  }
                  // Navigate to ProfilePage and clear image when returning
                  _navigateWithTransition(context, ProfilePage()).then((_) {
                    // Reset image when returning from profile
                    if (mounted) {
                      setState(() {
                        _image = null;
                        _sampleImagePath = '';
                        _predictionResult = '';
                        _allPredictions = [];
                      });
                    }
                  });
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build instruction items
  Widget _buildInstructionItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFFE63946),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.robotoSlab(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.robotoSlab(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show welcome popup when the page first loads
  void _showWelcomePopup() {
    setState(() {
      _hasShownWelcomePopup = true; // Mark popup as shown
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Welcome to Chili Pepper Classifier!',
            style: GoogleFonts.robotoSlab(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE63946), // Red color to match theme
            ),
            textAlign: TextAlign.center,
          ),
          titleTextStyle: GoogleFonts.robotoSlab(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFFE63946), // Red color to match theme
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Identify chili pepper varieties with AI-powered image recognition.',
                  style: GoogleFonts.robotoSlab(color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'How to use:',
                  style: GoogleFonts.robotoSlab(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                _buildInstructionItem(
                  1,
                  'Use the camera button to take a photo of a chili pepper',
                ),
                _buildInstructionItem(
                  2,
                  'Or use the gallery button to select an existing image',
                ),
                _buildInstructionItem(
                  3,
                  'The AI will analyze the image and provide a prediction',
                ),
                _buildInstructionItem(
                  4,
                  'View detailed results and historical data in the other tabs',
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                    0xFFE63946,
                  ), // Red background color to match theme
                  foregroundColor: Colors.white, // White text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Okay'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to navigate with transition
  Future<void> _navigateWithTransition(
    BuildContext context,
    Widget page,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  // Method to toggle camera on/off
  Future<void> _toggleCamera() async {
    if (_isCameraActive) {
      // Closing camera
      // Dispose the controller first
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (e) {
          print("Error stopping camera: $e");
        } finally {
          _controller = null;
        }

        setState(() {
          _isCameraActive = false;
          _sampleImagePath = ''; // Reset sample image path
        });
      }
    } else {
      // Opening camera
      if (_cameras.isEmpty) {
        // If cameras haven't been initialized yet, initialize them
        await _initializeCamera();
      }

      if (_cameras.isNotEmpty) {
        try {
          // Dispose any existing controller
          if (_controller != null) {
            await _controller!.dispose();
          }

          // Create new controller
          _controller = CameraController(_cameras[0], ResolutionPreset.medium);
          await _controller!.initialize();

          setState(() {
            _isCameraActive = true;
            _sampleImagePath = ''; // Reset sample image path
            _image = null; // Clear captured image
            _predictionResult = ''; // Clear prediction
            _allPredictions = []; // Clear predictions
          });
        } catch (e) {
          print("Error starting camera: $e");

          // Make sure to clean up controller on error
          if (_controller != null) {
            _controller = null;
          }

          setState(() {
            _isCameraActive = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error starting camera: $e')));
        }
      }
    }
  }

  // Method to capture image from camera
  Future<void> _captureImage() async {
    // Check if controller is still valid before using it
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        // Take the picture first
        final XFile file = await _controller!.takePicture();

        // Set state immediately to indicate we're processing
        setState(() {
          _image = File(file.path);
          _sampleImagePath = ''; // Reset sample image path
          _isCameraActive = false;
          _isLoading = true;
        });

        // Now dispose the controller after taking the picture
        await _controller!.dispose();
        _controller = null;

        // Process the image
        await _predictImage(_image!);
      } catch (e) {
        print("Error capturing image: $e");

        // Make sure to dispose controller even if there's an error
        if (_controller != null) {
          await _controller!.dispose();
          _controller = null;
        }

        setState(() {
          _isLoading = false;
          _isCameraActive = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    } else {
      // Controller is not valid, show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera not initialized')));

      setState(() {
        _isCameraActive = false;
      });
    }
  }
}
