import 'package:flutter/material.dart';
import 'package:money_warden/theme/theme.dart';


class MwTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Icon? prefixIcon;
  final String? hintText;
  bool? enabled;

  MwTextField({
    super.key,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.onChanged,
    this.enabled
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MwColors>()!;

    return TextField(
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: colors.backgroundDark1, width: 1)
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: colors.backgroundDark1, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          prefixIcon: prefixIcon,
          hintStyle: TextStyle(
            color: colors.mutedText,
            overflow: TextOverflow.ellipsis
          ),
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: colors.backgroundDark1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
      ),
    );
  }
}
