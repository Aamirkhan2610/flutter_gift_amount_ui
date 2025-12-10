import 'package:flutter/material.dart';

class NoteDisplay extends StatelessWidget {
  final String note;

  const NoteDisplay({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (note.isEmpty) return const SizedBox(height: 40);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        "Note: $note",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}
