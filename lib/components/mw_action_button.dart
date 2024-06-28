import 'package:flutter/material.dart';


class MwActionButton extends StatefulWidget {
  final Widget leading;
  final String text;
  final VoidCallback onTap;

  const MwActionButton({super.key, required this.leading, required this.text, required this.onTap});

  @override
  State<MwActionButton> createState() => _MwActionButtonState();
}

class _MwActionButtonState extends State<MwActionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.inverseSurface, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.leading,
              const SizedBox(width: 10),
              Text(widget.text),
            ],
          )
        ),
      ),
    );
  }
}
