import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* =========================
   APP ROOT WITH THEME
========================= */
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Calculator(
        isDark: isDark,
        onToggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
      ),
    );
  }
}

/* =========================
   CALCULATOR PAGE
========================= */
class Calculator extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const Calculator({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final TextEditingController num1Controller = TextEditingController();
  final TextEditingController num2Controller = TextEditingController();

  String result = "";

  void calculate(String operation) {
    double? a = double.tryParse(num1Controller.text);
    double? b = double.tryParse(num2Controller.text);

    if (a == null || b == null) {
      setState(() {
        result = "Please enter valid numbers";
      });
      return;
    }

    if (operation == "/" && b == 0) {
      setState(() {
        result = "Cannot divide by zero";
      });
      return;
    }

    setState(() {
      switch (operation) {
        case "+":
          result = "Result: ${a + b}";
          break;
        case "-":
          result = "Result: ${a - b}";
          break;
        case "*":
          result = "Result: ${a * b}";
          break;
        case "/":
          result = "Result: ${a / b}";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator App with Device"),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input 1
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter first number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Input 2
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter second number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => calculate("+"),
                  child: const Text("+"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("-"),
                  child: const Text("-"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("*"),
                  child: const Text("×"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("/"),
                  child: const Text("÷"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Result Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Text(
                  result.isEmpty
                      ? "Result will appear here"
                      : result,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
