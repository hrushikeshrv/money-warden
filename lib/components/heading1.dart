import 'package:flutter/material.dart';


class Heading1 extends StatelessWidget {
  final String text;
  const Heading1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Text(text, style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold
      )),
    );
  }
}
