import 'package:flutter/material.dart';


class MwFormLabel extends StatelessWidget {
  final String text;
  const MwFormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      )
    );
  }
}
