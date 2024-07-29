import 'package:flutter/material.dart';


class MwActionButton extends StatefulWidget {
  final Widget leading;
  final String text;
  final VoidCallback onTap;
  /// A custom role to give this button. Can be "default", "success", "warning", or "error".
  final String role;

  const MwActionButton({
    super.key,
    required this.leading,
    required this.text,
    required this.onTap,
    this.role = 'default'
  });

  @override
  State<MwActionButton> createState() => _MwActionButtonState();
}

class _MwActionButtonState extends State<MwActionButton> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.surfaceDim;
    Color textColor = Theme.of(context).colorScheme.onSurface;
    if (widget.role == 'error') {
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
    }

    return InkWell(
      onTap: widget.onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.inverseSurface, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.leading,
            const SizedBox(width: 10),
            Text(widget.text, style: TextStyle(color: textColor)),
          ],
        ),
      )
    );
  }
}
