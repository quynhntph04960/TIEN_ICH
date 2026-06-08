import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  String _result = "0";
  String _error = "";

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  double? _toNumber(String raw) {
    return double.tryParse(raw.trim());
  }

  void _calculate(String operation) {
    final first = _toNumber(_firstController.text);
    final second = _toNumber(_secondController.text);

    if (first == null || second == null) {
      setState(() {
        _error = "Vui lòng nhập 2 số hợp lệ.";
      });
      return;
    }

    double value = 0;
    if (operation == "+") {
      value = first + second;
    } else if (operation == "-") {
      value = first - second;
    } else if (operation == "x") {
      value = first * second;
    } else if (operation == "/") {
      if (second == 0) {
        setState(() {
          _error = "Không thể chia cho 0.";
        });
        return;
      }
      value = first / second;
    }

    setState(() {
      _error = "";
      _result = value.toStringAsFixed(
        value == value.truncateToDouble() ? 0 : 4,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Máy tính")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Nhập 2 số cho phép tính",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _firstController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Số thứ nhất",
              prefixIcon: Icon(Icons.looks_one_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secondController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Số thứ hai",
              prefixIcon: Icon(Icons.looks_two_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OpButton(label: "+", onTap: () => _calculate("+")),
              _OpButton(label: "-", onTap: () => _calculate("-")),
              _OpButton(label: "x", onTap: () => _calculate("x")),
              _OpButton(label: "/", onTap: () => _calculate("/")),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kết quả",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _result,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpButton extends StatelessWidget {
  const _OpButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
