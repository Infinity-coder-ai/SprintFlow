import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates the SprintFlow launcher icon (rocket on brand background) at
/// assets/icon/app_icon.png. Run with:
///   flutter test test/app_icon_generator_test.dart
/// then:
///   dart run flutter_launcher_icons
void main() {
  test('generate launcher icon', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const double size = 1024.0;
    const ink = Color(0xFF061225);
    const purple = Color(0xFF6937FF);
    const purpleLight = Color(0xFF9A6BFF);
    const white = Color(0xFFF7F8FF);
    const orange = Color(0xFFFFB020);
    const red = Color(0xFFFF4F6D);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

    // Background.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = ink,
    );

    // Badge circle.
    canvas.drawCircle(center, 280, Paint()..color = purple);
    canvas.drawCircle(
      center,
      280,
      Paint()
        ..color = purpleLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Rocket (drawn upright, tilted for dynamism). Scaled to stay inside
    // the adaptive-icon safe zone.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.8);
    canvas.rotate(-0.55);

    // Flame.
    final flame =
        Path()
          ..moveTo(-48, 200)
          ..quadraticBezierTo(-44, 290, 0, 332)
          ..quadraticBezierTo(44, 290, 48, 200)
          ..close();
    canvas.drawPath(flame, Paint()..color = orange);
    final flameCore =
        Path()
          ..moveTo(-24, 208)
          ..quadraticBezierTo(-20, 262, 0, 288)
          ..quadraticBezierTo(20, 262, 24, 208)
          ..close();
    canvas.drawPath(flameCore, Paint()..color = white);

    // Fins.
    final finLeft =
        Path()
          ..moveTo(-86, 30)
          ..lineTo(-152, 212)
          ..lineTo(-86, 212)
          ..close();
    final finRight =
        Path()
          ..moveTo(86, 30)
          ..lineTo(152, 212)
          ..lineTo(86, 212)
          ..close();
    canvas.drawPath(finLeft, Paint()..color = red);
    canvas.drawPath(finRight, Paint()..color = red);

    // Body + nose cone.
    canvas.drawRRect(
      RRect.fromLTRBR(-88, -150, 88, 215, const Radius.circular(80)),
      Paint()..color = white,
    );
    final nose =
        Path()
          ..moveTo(-88, -150)
          ..quadraticBezierTo(-84, -252, 0, -296)
          ..quadraticBezierTo(84, -252, 88, -150)
          ..close();
    canvas.drawPath(nose, Paint()..color = white);

    // Window.
    canvas.drawCircle(const Offset(0, -60), 64, Paint()..color = purple);
    canvas.drawCircle(const Offset(0, -60), 46, Paint()..color = ink);

    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final outFile = File('assets/icon/app_icon.png');
    await outFile.writeAsBytes(bytes!.buffer.asUint8List());

    expect(outFile.existsSync(), isTrue);
    expect(await outFile.length(), greaterThan(10000));
  });
}
