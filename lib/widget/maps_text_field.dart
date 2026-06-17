import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class MapsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool showError;

  const MapsTextField({
    super.key,
    required this.controller,
    this.hintText = 'Cari lokasi...',
    this.onChanged,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        showError ? CustomColor.danger : CustomColor.ocean900.withOpacity(0.20);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: bodyStyle.copyWith(fontSize: 14, color: CustomColor.ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: bodyStyle.copyWith(fontSize: 14, color: CustomColor.muted),
        filled: true,
        fillColor: CustomColor.paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CustomColor.coral500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CustomColor.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CustomColor.danger, width: 2),
        ),
      ),
    );
  }
}
