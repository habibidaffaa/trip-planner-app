import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class IterasiDisplay extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;

  const IterasiDisplay(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: displayStyle.merge(style).copyWith(color: color),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

class IterasiBody extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  const IterasiBody(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: bodyStyle.merge(style).copyWith(color: color),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      textAlign: textAlign,
    );
  }
}

class IterasiMono extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;

  const IterasiMono(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: monoStyle.merge(style).copyWith(color: color),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

class IterasiKicker extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;

  const IterasiKicker(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: monoStyle
          .copyWith(
            fontSize: 11,
            letterSpacing: 0.22 * 11,
            color: color ?? CustomColor.muted,
          )
          .merge(style),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}
