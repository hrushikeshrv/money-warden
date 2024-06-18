import 'package:flutter/material.dart';


class PillContainer extends StatelessWidget {
  final Widget child;
  final Color color;

  const PillContainer({
    super.key,
    required this.child,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
        color: color,
      ),
      child: child,
    );
  }
}
