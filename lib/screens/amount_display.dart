import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;
  final bool keyboardVisible;
  final VoidCallback onToggle;

  const AmountDisplay({
    Key? key,
    required this.amount,
    required this.keyboardVisible,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Enter Amount",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "\$",
                style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: keyboardVisible ? 70 : 65,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(keyboardVisible ? 1 : 0.6),
                ),
                child: Text(amount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
