import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  double height = 170; // cm
  double weight = 65; // kg
  double bmi = 0;
  String status = "";

  List<Map<String, dynamic>> bmiHistory = [];

// Load history
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('bmi_history');

    if (data != null) {
      setState(() {
        bmiHistory = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

// Save history
  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bmi_history', jsonEncode(bmiHistory));
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }



  void calculateBMI() {
    setState(() {
      double h = height / 100;
      bmi = weight / (h * h);

      if (bmi < 18.5) {
        status = "Underweight";
      } else if (bmi < 25) {
        status = "Normal";
      } else if (bmi < 30) {
        status = "Overweight";
      } else {
        status = "Obese";
      }

      // Save history
      bmiHistory.insert(0, {
        "bmi": bmi.toStringAsFixed(2),
        "status": status,
        "height": height.toStringAsFixed(0),
        "weight": weight.toStringAsFixed(0),
        "time": DateTime.now().toString(),
      });

      saveHistory();
    });
  }


  Color getStatusColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Height Slider
              bmiCard(
                title: "Height (cm)",
                value: height.toStringAsFixed(0),
                child: Slider(
                  value: height,
                  min: 100,
                  max: 220,
                  divisions: 120,
                  label: height.toStringAsFixed(0),
                  onChanged: (val) => setState(() => height = val),
                ),
              ),

              const SizedBox(height: 20),

              // Weight Slider
              bmiCard(
                title: "Weight (kg)",
                value: weight.toStringAsFixed(0),
                child: Slider(
                  value: weight,
                  min: 30,
                  max: 150,
                  divisions: 120,
                  label: weight.toStringAsFixed(0),
                  onChanged: (val) => setState(() => weight = val),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: calculateBMI,
                child: const Text(
                  "Calculate BMI",
                  style: TextStyle(fontSize: 20),
                ),
              ),

              const SizedBox(height: 30),

              if (bmi > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bmi.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(),
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 22,
                          color: getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bmiCard({
    required String title,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
