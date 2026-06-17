import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class IterasiChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? borderColor;

  const IterasiChip._({
    required this.label,
    required this.bg,
    required this.fg,
    this.borderColor,
  });

  factory IterasiChip.filled({
    required String label,
    Color? bg,
    Color? fg,
  }) =>
      IterasiChip._(
        label: label,
        bg: bg ?? CustomColor.ocean900,
        fg: fg ?? CustomColor.paper,
      );

  factory IterasiChip.outline({required String label}) => IterasiChip._(
        label: label,
        bg: Colors.transparent,
        fg: CustomColor.ocean900,
        borderColor: CustomColor.ocean900.withOpacity(0.25),
      );

  factory IterasiChip.coral({required String label}) => IterasiChip._(
        label: label,
        bg: CustomColor.coral500,
        fg: CustomColor.paper,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Text(
        label,
        style: bodyStyle.copyWith(
          fontSize: 12,
          fontWeight: medium,
          color: fg,
        ),
      ),
    );
  }
}
