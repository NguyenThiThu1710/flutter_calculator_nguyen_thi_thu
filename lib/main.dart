import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';

  double? firstValue;
  String? mainOp;      // + or −
  String? pendingOp;   // × or ÷
  bool isNew = true;   // begin typing new number?

  // ========================
  //   CHECK OPERATOR
  // ========================
  bool isOperator(String t) {
    return ["+", "-", "−", "×", "÷"].contains(t);
  }

  bool isAddSub(String t) {
    return (t == "+" || t == "-" || t == "−");
  }

  bool isMulDiv(String t) {
    return (t == "×" || t == "÷");
  }

  // ========================
  //   INPUT NUMBER
  // ========================
  void _onNumber(String n) {
    setState(() {
      if (isNew) {
        _display = n;
        isNew = false;
      } else {
        if (_display == "0") {
          _display = n;
        } else {
          _display += n;
        }
      }
    });
  }

  // ========================
  //   DECIMAL
  // ========================
  void _decimal() {
    if (_display.contains(".")) return;
    setState(() {
      _display += ".";
      isNew = false;
    });
  }

  // ========================
  //   TOGGLE SIGN
  // ========================
  void _toggle() {
    if (_display == "0") return;

    setState(() {
      if (_display.startsWith("-")) {
        _display = _display.substring(1);
      } else {
        _display = "-$_display";
      }
    });
  }

  // ========================
  //   CLEAR
  // ========================
  void _clear() {
    setState(() {
      _display = "0";
      firstValue = null;
      mainOp = null;
      pendingOp = null;
      isNew = true;
    });
  }

  // ========================
  //   CE
  // ========================
  void _ce() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = "0";
        isNew = true;
      }
    });
  }

  // ========================
  //   PERCENT
  // ========================
  void _percent() {
    double v = double.tryParse(_display) ?? 0;
    setState(() {
      _display = (v / 100).toString();
      isNew = true;
    });
  }

  // ========================
  //   OPERATOR
  // ========================
  void _op(String op) {
    double v = double.tryParse(_display) ?? 0;

    // 🟥 CASE: first input is NEGATIVE number
    if (isNew && op == "−" && firstValue == null && mainOp == null) {
      _display = "-";
      isNew = false;
      return;
    }
    if (isNew && op == "-" && firstValue == null && mainOp == null) {
      _display = "-";
      isNew = false;
      return;
    }

    // =============================
    //   PRIORITY × and ÷ FIRST
    // =============================
    if (pendingOp != null && firstValue != null) {
      if (pendingOp == "×") {
        firstValue = firstValue! * v;
      } else if (pendingOp == "÷") {
        if (v == 0) {
          _display = "Error";
          isNew = true;
          return;
        }
        firstValue = firstValue! / v;
      }
      pendingOp = null;
    } else {
      if (firstValue == null) {
        firstValue = v;
      } else if (mainOp != null) {
        if (mainOp == "+") firstValue = firstValue! + v;
        if (mainOp == "-" || mainOp == "−") firstValue = firstValue! - v;
      }
    }

    // =============================
    //   UPDATE OPERATOR
    // =============================
    if (isMulDiv(op)) {
      pendingOp = op;
    } else if (isAddSub(op)) {
      mainOp = op;
    }

    isNew = true;
  }

  // ========================
  //   EQUAL
  // ========================
  void _equal() {
    double v = double.tryParse(_display) ?? 0;

    // HANDLE × ÷ FIRST
    if (pendingOp != null) {
      if (pendingOp == "×") {
        firstValue = (firstValue ?? 0) * v;
      } else if (pendingOp == "÷") {
        if (v == 0) {
          setState(() => _display = "Error");
          return;
        }
        firstValue = (firstValue ?? 0) / v;
      }
      pendingOp = null;
    } else {
      // HANDLE + -
      if (mainOp != null) {
        if (mainOp == "+") firstValue = firstValue! + v;
        if (mainOp == "-" || mainOp == "−") firstValue = firstValue! - v;
      } else {
        firstValue = v;
      }
    }

    setState(() {
      _display = firstValue.toString();
      mainOp = null;
      pendingOp = null;
      isNew = true;
    });
  }

  // ========================
  //   UI BELOW
  // ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272727),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(right: 20, bottom: 40),
                child: Text(
                  _display,
                  style: const TextStyle(color: Colors.white, fontSize: 48),
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(["C", "( )", "%", "÷"], [
                      const Color(0xFFEF5350),
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF394734),
                    ]),
                    const SizedBox(height: 10),

                    _row(["7", "8", "9", "×"], [
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF394734),
                    ]),
                    const SizedBox(height: 10),

                    _row(["4", "5", "6", "−"], [
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF394734),
                    ]),
                    const SizedBox(height: 10),

                    _row(["1", "2", "3", "+"], [
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF394734),
                    ]),
                    const SizedBox(height: 10),

                    _row(["CE", "0", ".", "="], [
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF333333),
                      const Color(0xFF076544),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> t, List<Color> c) {
    return Expanded(
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Center(child: _btn(t[i], c[i])),
          ),
        ),
      ),
    );
  }

  Widget _btn(String t, Color color) {
    return LayoutBuilder(builder: (context, box) {
      double s = box.maxHeight * 0.9;
      return GestureDetector(
        onTap: () => _press(t),
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(t,
                style: const TextStyle(fontSize: 26, color: Colors.white)),
          ),
        ),
      );
    });
  }

  void _press(String t) {
    if (t == "C") return _clear();
    if (t == "CE") return _ce();
    if (t == "+/-") return _toggle();
    if (t == "%") return _percent();
    if (t == ".") return _decimal();

    if (isOperator(t)) return _op(t);
    if (t == "=") return _equal();

    _onNumber(t);
  }
}
