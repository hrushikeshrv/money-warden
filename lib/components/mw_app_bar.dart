import 'package:flutter/material.dart';

class MwAppBar extends StatelessWidget {
  final String text;
  final String assetImagePath;

  const MwAppBar({super.key, required this.text, required this.assetImagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Image.asset(assetImagePath, height: 45,),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
