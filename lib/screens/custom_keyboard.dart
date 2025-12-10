import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onTap;

  const CustomKeyboard({Key? key, required this.onTap}) : super(key: key);

  Widget _key(String label) {
    final isDel = label == "del";
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          height: 65,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isDel
                ? const Icon(Icons.backspace_outlined)
                : Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(children: [_key("1"), _key("2"), _key("3")]),
          Row(children: [_key("4"), _key("5"), _key("6")]),
          Row(children: [_key("7"), _key("8"), _key("9")]),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _key("0"),
              _key("del"),
            ],
          ),
        ],
      ),
    );
  }
}
