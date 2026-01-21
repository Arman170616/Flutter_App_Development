import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

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
        expression
            .replaceAll('×', '*')
            .replaceAll('÷', '/'),
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
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                      ),
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

            // Buttons
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
