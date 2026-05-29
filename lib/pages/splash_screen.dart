import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';

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
      backgroundColor: CustomColor.ocean900,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: _ShoreLinePainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IterasiMono(
                  'est. 2026 · jakarta',
                  style: const TextStyle(fontSize: 10, letterSpacing: 2.4),
                  color: CustomColor.coral300,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CustomPaint(painter: _CompassPainter()),
                ),
                const SizedBox(height: 32),
                RichText(
                  text: TextSpan(
                    style: displayStyle.copyWith(
                      fontSize: 88,
                      color: CustomColor.paper,
                      height: 0.85,
                    ),
                    children: const [
                      TextSpan(text: 'iterasi'),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: CustomColor.coral400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Perjalanan, dirancang dengan tangan.',
                  style: displayStyle.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    color: CustomColor.paper.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: IterasiMono(
                'v 2.0 · raja ampat build',
                style: const TextStyle(fontSize: 10),
                color: CustomColor.paper.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..color = CustomColor.sand300.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - (radius - 8)),
      Paint()
        ..color = CustomColor.coral500
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(center.dx - (radius - 8), center.dy),
      Offset(center.dx + (radius - 8), center.dy),
      Paint()
        ..color = CustomColor.ocean300.withOpacity(0.75)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 4, Paint()..color = CustomColor.paper);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShoreLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.3,
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = CustomColor.ocean800
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
