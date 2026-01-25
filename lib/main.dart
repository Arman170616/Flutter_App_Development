import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// ================= HOME SCREEN (Calculator + BMI + Age Switch) =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    CalculatorScreen(),
    BmiScreen(),
    AgeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Calculator",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: "BMI",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
            label: "Age",
          ),
        ],
      ),
    );
  }
}

// ================= CALCULATOR APP =================

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';

  void onTap(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
      } else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == '=') {
        calculate();
      } else {
        expression += value;
      }
    });
  }

  void calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(
        expression.replaceAll('×', '*').replaceAll('÷', '/'),
      );
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();
    } catch (e) {
      result = 'Error';
    }
  }

  Widget btn(String text,
      {Color bg = const Color(0xFF3A3A3A),
        Color fg = Colors.white,
        int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.all(22),
          ),
          onPressed: () => onTap(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: fg),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expression,
                      style: const TextStyle(fontSize: 28, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(children: [
                  btn('AC', bg: Colors.grey, fg: Colors.black),
                  btn('⌫', bg: Colors.grey, fg: Colors.black),
                  btn('%', bg: Colors.grey, fg: Colors.black),
                  btn('÷', bg: Colors.orange),
                ]),
                Row(children: [
                  btn('7'),
                  btn('8'),
                  btn('9'),
                  btn('×', bg: Colors.orange),
                ]),
                Row(children: [
                  btn('4'),
                  btn('5'),
                  btn('6'),
                  btn('-', bg: Colors.orange),
                ]),
                Row(children: [
                  btn('1'),
                  btn('2'),
                  btn('3'),
                  btn('+', bg: Colors.orange),
                ]),
                Row(children: [
                  btn('0', flex: 2),
                  btn('.'),
                  btn('=', bg: Colors.orange),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= BMI APP + HISTORY =================

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  double height = 170;
  double weight = 65;
  double bmi = 0;
  String status = "";

  List<Map<String, dynamic>> bmiHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('bmi_history');
    if (data != null) {
      setState(() {
        bmiHistory = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bmi_history', jsonEncode(bmiHistory));
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

      bmiHistory.insert(0, {
        "bmi": bmi.toStringAsFixed(2),
        "status": status,
        "height": height.toStringAsFixed(0),
        "weight": weight.toStringAsFixed(0),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            sliderCard("Height (cm)", height, 100, 220,
                    (v) => setState(() => height = v)),
            const SizedBox(height: 20),
            sliderCard("Weight (kg)", weight, 30, 150,
                    (v) => setState(() => weight = v)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: calculateBMI,
              child:
              const Text("Calculate BMI", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            if (bmi > 0)
              Text(
                "BMI: ${bmi.toStringAsFixed(2)} ($status)",
                style: TextStyle(
                  fontSize: 28,
                  color: getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: bmiHistory.length,
                itemBuilder: (context, index) {
                  final item = bmiHistory[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "BMI: ${item['bmi']} | ${item['status']} | H:${item['height']} W:${item['weight']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderCard(String title, double value, double min, double max,
      Function(double) onChange) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value.toStringAsFixed(0),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}

// ================= AGE CALCULATOR =================

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  DateTime? birthDate;
  String ageResult = "";

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => birthDate = date);
      calculateAge();
    }
  }

  void calculateAge() {
    if (birthDate == null) return;

    final today = DateTime.now();
    int years = today.year - birthDate!.year;
    int months = today.month - birthDate!.month;
    int days = today.day - birthDate!.day;

    if (days < 0) {
      months--;
      days += 30;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      ageResult = "$years Years, $months Months, $days Days";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Age Calculator"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: pickDate,
              child: const Text("Select Birth Date"),
            ),
            const SizedBox(height: 20),
            if (birthDate != null)
              Text(
                "DOB: ${birthDate!.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 20),
            if (ageResult.isNotEmpty)
              Text(
                ageResult,
                style: const TextStyle(fontSize: 28, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
