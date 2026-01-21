import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<Uint8List> iconToImageBytes(IconData icon, double size, Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  // Creamos un TextSpan con el IconData
  final textSpan = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(
      fontSize: size,
      fontFamily: icon.fontFamily,
      color: color,
    ),
  );

  textPainter.text = textSpan;
  textPainter.layout();
  textPainter.paint(canvas, Offset.zero);

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> pictureToBytes(ui.Picture picture, int width, int height) async {
  // Convertir Picture a Image
  final img = await picture.toImage(width, height);
  // Convertir Image a bytes PNG
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}