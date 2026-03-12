import 'package:flutter/material.dart';
import 'package:money_warden/theme/theme.dart';

class MwPillButton extends StatefulWidget {
  final Widget child;
  bool enabled = true;
  final VoidCallback onTap;
  final Color? backgroundColor;
  MwPillButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.enabled=true
  });

  @override
  State<MwPillButton> createState() => _MwPillButtonState();
}

class _MwPillButtonState extends State<MwPillButton> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MwColors>()!;
    return InkWell(
      onTap: () {
        if (!widget.enabled) return;
        widget.onTap();
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colors.backgroundDark1,
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.child
      )
    );
  }
}
