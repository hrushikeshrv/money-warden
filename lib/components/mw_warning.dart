import 'package:flutter/material.dart';


class MwWarning extends StatelessWidget {
  final List<Widget> children;

  const MwWarning({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFFFF9AE),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_rounded, color: Color(0xFFBAAB06)),
              SizedBox(width: 5),
              Text('Warning', style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    );
  }
}
