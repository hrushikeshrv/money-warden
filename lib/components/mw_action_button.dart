import 'package:flutter/material.dart';


class MwActionButton extends StatefulWidget {
  final Widget leading;
  final String text;
  final VoidCallback onTap;
  /// A custom role to give this button. Can be "default", "success", "warning", or "error".
  final String role;
  bool enabled = true;

  MwActionButton({
    super.key,
    required this.leading,
    required this.text,
    required this.onTap,
    this.role = 'default',
    this.enabled = true
  });

  @override
  State<MwActionButton> createState() => _MwActionButtonState();
}

class _MwActionButtonState extends State<MwActionButton> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.surfaceDim;
    Color textColor = Theme.of(context).colorScheme.onSurface;
    Color enabledBorderColor = Theme.of(context).colorScheme.inverseSurface;
    if (widget.role == 'error') {
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
    }
    if (widget.role == 'warning') {
      backgroundColor = const Color(0xFFF5F4BA);
      enabledBorderColor = const Color(0xFF756A10);
    }

    return InkWell(
      onTap: () {
        if (!widget.enabled) return;
        widget.onTap();
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: widget.enabled ?
              Border.all(color: enabledBorderColor, width: 2)
            : Border.all(color: Theme.of(context).colorScheme.surfaceDim),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.leading,
            const SizedBox(width: 8),
            Text(widget.text, style: TextStyle(color: textColor), textAlign: TextAlign.center,),
          ],
        ),
      )
    );
  }
}
