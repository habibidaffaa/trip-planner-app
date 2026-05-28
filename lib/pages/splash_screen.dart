import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:iterasi1/resource/theme.dart';

import 'itinerary_list.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pushReplacementNamed(context, ItineraryList.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.softOffWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.asset(
                'assets/images/AppLogo.png',
                fit: BoxFit.contain,
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trip Planner',
              style: headingTextStyle.copyWith(
                fontSize: 40,
                fontWeight: bold,
                letterSpacing: -2.0,
                color: CustomColor.boardroomNavy,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: CustomColor.lilacAccent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Your Personal Itinerary Assistant',
                    textStyle: primaryTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                      color: CustomColor.boardroomNavy,
                    ),
                    speed: const Duration(milliseconds: 40),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
