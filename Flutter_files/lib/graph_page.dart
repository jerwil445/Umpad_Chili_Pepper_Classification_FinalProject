import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true;
  Map<String, int> _classFrequency = {};
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loadLabels();
    _fetchData();
  }

  Future<void> _loadLabels() async {
    try {
      // Load labels from assets
      String labelsData = await DefaultAssetBundle.of(
        context,
      ).loadString("assets/tflite/labels.txt");
      List<String> labelsList = labelsData.split('\n')
        ..removeWhere((label) => label.isEmpty);

      // For the graph page, we want to use the full label names as they are
      // Don't process them by splitting on spaces since some labels contain spaces
      _labels = List<String>.from(labelsList);
    } catch (e) {
      print("Error loading labels: $e");
      // Empty list instead of fallback labels
      _labels = [];
    }
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await _dbRef.orderByChild('timestamp').once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        List<Map<String, dynamic>> predictionsList = [];
        data.forEach((key, value) {
          if (value is Map) {
            predictionsList.add({
              'id': value['id'] ?? '',
              'className': value['className'] ?? 'Unknown',
              'accuracy': value['accuracy'] ?? '0.0000',
              'timestamp': value['timestamp'] ?? 0,
            });
          }
        });

        // Sort by timestamp in descending order (newest first)
        predictionsList.sort(
          (a, b) => b['timestamp'].compareTo(a['timestamp']),
        );

        setState(() {
          _predictions = predictionsList;
          _calculateClassFrequency();
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

  void _calculateClassFrequency() {
    Map<String, int> frequency = {};

    // Only count occurrences of each class that actually appear in predictions
    // Don't initialize with zero counts from labels
    for (var prediction in _predictions) {
      String className = prediction['className'];
      // Don't process the className by splitting spaces since some labels contain spaces
      // Just use the className as is
      frequency[className] = (frequency[className] ?? 0) + 1;
    }

    // No need to remove zero counts since we never added them

    setState(() {
      _classFrequency = frequency;
    });
  }

  List<FlSpot> _generateSpots() {
    List<FlSpot> spots = [];
    int index = 0;

    _classFrequency.forEach((className, count) {
      spots.add(FlSpot(index.toDouble(), count.toDouble()));
      index++;
    });

    return spots;
  }

  List<String> _getXAxisLabels() {
    List<String> labels = [];
    _classFrequency.forEach((className, count) {
      labels.add(className);
    });
    return labels;
  }

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
        backgroundColor:
            Colors.transparent, // Make scaffold background transparent
        appBar: AppBar(
          title: Text(
            'Prediction Frequency Graph',
            style: GoogleFonts.robotoSlab(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDED0C6),
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
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: _fetchData),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _predictions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No prediction data available',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: Text('Refresh Data'),
                    ),
                  ],
                ),
              )
            : _buildChart(),
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalScans = _predictions.length;
    String topChili = "None";
    int maxCount = 0;

    _classFrequency.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        topChili = key;
      }
    });

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Total Scans",
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    totalScans.toString(),
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Top Chili",
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    topChili,
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 18, // Slightly smaller to fit names
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_classFrequency.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: GoogleFonts.robotoSlab(fontSize: 18),
        ),
      );
    }

    List<FlSpot> spots = _generateSpots();
    List<String> xAxisLabels = _getXAxisLabels();

    // Calculate max Y value and determine appropriate interval
    double maxYValue = _classFrequency.values.fold<double>(
      0,
      (max, value) => value > max ? value.toDouble() : max,
    );

    // Determine y-axis interval based on max value
    int yInterval = 1;
    if (maxYValue > 10) {
      yInterval = (maxYValue / 5).ceil(); // Show approximately 5 labels
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            Text(
              'Prediction Trends',
              style: GoogleFonts.robotoSlab(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDED0C6),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Frequency of each chili pepper class',
              style: GoogleFonts.robotoSlab(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            // Line chart
            Container(
              height: 350,
              padding: EdgeInsets.only(right: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white10,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white10,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: 1, // Show all labels
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < xAxisLabels.length) {
                            String className = xAxisLabels[index];
                            // Truncate long names for display
                            String displayName = className.length > 10
                                ? className.substring(0, 10) + '..'
                                : className;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -math.pi / 4, // Slant the text
                                child: Text(
                                  displayName,
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFDED0C6),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: yInterval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white10),
                  ),
                  minX: 0,
                  maxX: (_classFrequency.length - 1).toDouble(),
                  minY: 0,
                  maxY: (maxYValue * 1.2) + 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true, // Smooth curve
                      curveSmoothness: 0.35,
                      color: const Color(0xFFE63946),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFFF77F00),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE63946).withOpacity(0.3),
                            const Color(0xFFE63946).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.grey[800]!,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final index = flSpot.x.toInt();
                          if (index >= 0 && index < xAxisLabels.length) {
                            return LineTooltipItem(
                              '${xAxisLabels[index]}\n',
                              GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${flSpot.y.toInt()} scans',
                                  style: GoogleFonts.roboto(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    // Convert entries to a list and sort by frequency (descending)
    var sortedEntries = _classFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(Icons.list, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Class Breakdown (Ranked)',
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDED0C6),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Organize class names on the left and frequencies on the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sortedEntries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Class name on the left
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Frequency on the right
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '${entry.value} scans',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
