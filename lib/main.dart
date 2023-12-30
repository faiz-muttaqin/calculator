import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class CalculatorController {
  String _displayValue = '0';
  double _operand1 = 0;
  String _operator = '';
  bool _isNewInput = true;

  String get displayValue => _displayValue;

  void onDigitPressed(String digit) {
    if (_isNewInput) {
      _displayValue = digit;
      _isNewInput = false;
    } else {
      _displayValue += digit;
    }
  }

  void onOperatorPressed(String operator) {
    if (!_isNewInput) {
      RegExp regex = RegExp(r'[0-9]$');
      if (regex.hasMatch(_displayValue)) {
        _displayValue += operator;
      } else {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1) + operator;
      }
    }
  }

  void onDotPressed() {
    if (!_isNewInput) {
      // Check if the last character is a number or dot
      RegExp regex = RegExp(r'[0-9.]$');
      if (regex.hasMatch(_displayValue)) {
        // Check if the last number already contains a dot
        RegExp dotRegex = RegExp(r'\.([0-9]*)$');
        if (!dotRegex.hasMatch(_displayValue)) {
          // If no dot is present, add a dot
          _displayValue += ".";
        }
      }
    }
  }

  void onEqualsPressed() {
    if (!_isNewInput) {
      // Parse the expression and get a list of tokens
      List<String> tokens = parseExpression(_displayValue);

      // Perform calculations based on the order of operations
      double result = calculate(tokens);

      // Format the result as a string and remove trailing zeros
      _displayValue = result.toString().replaceAll(RegExp(r'\.0*$'), '');

      // If the result is an integer, remove the decimal point
      _displayValue = _displayValue.endsWith('.') ? _displayValue.substring(0, _displayValue.length - 1) : _displayValue;
    }
  }

  List<String> parseExpression(String expression) {
    List<String> tokens = [];
    String currentToken = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];

      // Check if the character is an operator
      if ('+-×/'.contains(char)) {
        // Save the current token and operator
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken);
          currentToken = '';
        }
        tokens.add(char);
      } else {
        // Append the character to the current token
        currentToken += char;
      }
    }

    // Add the last token if not empty
    if (currentToken.isNotEmpty) {
      tokens.add(currentToken);
    }

    return tokens;
  }

  double calculate(List<String> tokens) {
    // Perform calculations based on the order of operations
    for (String operator in ['×', '/']) {
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i] == operator) {
          double operand1 = double.parse(tokens[i - 1]);
          double operand2 = double.parse(tokens[i + 1]);
          double result = operator == '×' ? operand1 * operand2 : operand1 / operand2;

          // Replace the operator and operands with the result
          tokens[i - 1] = result.toString();
          tokens.removeRange(i, i + 2);

          // Adjust the index to account for the removed elements
          i--;
        }
      }
    }

    // Perform addition and subtraction
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String operator = tokens[i];
      double operand = double.parse(tokens[i + 1]);
      result = operator == '+' ? result + operand : result - operand;
    }

    return result;
  }

  void onBackspacePressed() {
    if (_displayValue.length > 1) {
      _displayValue = _displayValue.substring(0, _displayValue.length - 1);
    } else {
      _displayValue = '0';
    }
  }
  void onClearPressed() {
    _displayValue = '0';
    _operand1 = 0;
    _operator = '';
    _isNewInput = true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(controller: CalculatorController()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CalculatorController controller;

  const MyHomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _number = "0";
  void _updateNumber() {
    setState(() {
      _number = widget.controller.displayValue;;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Calculate the screen's aspect ratio
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenAspectRatio = screenWidth / screenHeight;

    // Set a desired aspect ratio for the children
    double desiredChildAspectRatio = 16 / 25; // Change this to your desired aspect ratio

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight/5,
            color: Theme.of(context).primaryColor,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _number,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(0),
              shrinkWrap: false,
              childAspectRatio: screenAspectRatio / desiredChildAspectRatio,
              crossAxisCount: 4,
              children: <Widget>[
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: 'C',
                  onTap: () {
                    widget.controller.onClearPressed();
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '+/-',
                  onTap: () {
                    widget.controller.onOperatorPressed('+/-');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '%',
                  onTap: () {
                    widget.controller.onOperatorPressed('%');
                    _updateNumber();
                  },
                ),
                CalculatorButton.Icon(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  text: 'Backspace',
                  icon: Icons.backspace,
                  onTap: () {
                    widget.controller.onBackspacePressed();
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '7',
                  onTap: () {
                    widget.controller.onDigitPressed('7');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '8',
                  onTap: () {
                    widget.controller.onDigitPressed('8');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '9',
                  onTap: () {
                    widget.controller.onDigitPressed('9');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  text: '/',
                  onTap: () {
                    widget.controller.onOperatorPressed('/');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '4',
                  onTap: () {
                    widget.controller.onDigitPressed('4');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '5',
                  onTap: () {
                    widget.controller.onDigitPressed('5');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '6',
                  onTap: () {
                    widget.controller.onDigitPressed('6');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  text: '×',
                  onTap: () {
                    widget.controller.onOperatorPressed('×');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '1',
                  onTap: () {
                    widget.controller.onDigitPressed('1');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '2',
                  onTap: () {
                    widget.controller.onDigitPressed('2');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '3',
                  onTap: () {
                    widget.controller.onDigitPressed('3');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  text: '-',
                  onTap: () {
                    widget.controller.onOperatorPressed('-');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '0',
                  onTap: () {
                    widget.controller.onDigitPressed('0');
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '.',
                  onTap: () {
                    widget.controller.onDotPressed();
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  text: '=',
                  onTap: () {
                    widget.controller.onEqualsPressed();
                    _updateNumber();
                  },
                ),
                CalculatorButton(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  text: '+',
                  onTap: () {
                    widget.controller.onOperatorPressed('+');
                    _updateNumber();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateUI() {
    if (mounted) {
      setState(() {});
    }
  }
}

class CalculatorButton extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final String text;
  IconData? icon;
  final Function() onTap;

  CalculatorButton({super.key,
  required this.backgroundColor,
  required this.foregroundColor,
  required this.text,
  required this.onTap,
  });

  CalculatorButton.Icon({super.key,
  required this.backgroundColor,
  required this.foregroundColor,
  required this.icon,
  required this.text,
  required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        child: Center(
          child: icon == null
              ? Text(
            text,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: foregroundColor),
          )
              : Icon(
            icon,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}