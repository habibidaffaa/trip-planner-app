import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';

class AppBarItineraryTitle extends StatelessWidget {
  final String title;
  AppBarItineraryTitle({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IterasiDisplay(
      title,
      style: const TextStyle(fontSize: 17),
      color: CustomColor.ocean900,
    );
  }
}
