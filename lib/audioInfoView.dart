import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loopplayer/iconToImage.dart';

class AudioInfoView extends StatefulWidget{
  final String fileName;
  final String trackName;
  final String albumName;
  final String albumArtistName;
  final Image albumArt;

  const AudioInfoView({super.key, required this.fileName, required this.trackName, required this.albumName, required this.albumArtistName, required this.albumArt});

  @override
  State<StatefulWidget> createState() {
    return _AudioInfoViewState();
  }
}

class _AudioInfoViewState extends State<AudioInfoView> {
  List<Widget> _info = [];
  List<Text> _texts = [];

  void _buildTexts() {
    // Si no hay trackName, mostramos solo el archivo
    setState(() {
      _info = [];
      if (widget.trackName.isEmpty) {
        _texts = [Text("Archivo: ${widget.fileName}")];
      } else {
        _texts = [
          Text("Cancion: ${widget.trackName}"),
          Text("Album: ${widget.albumName.isEmpty ? "No reconocido" : widget.albumName}"),
          Text("Artista: ${widget.albumArtistName.isEmpty ? "No reconocido" : widget.albumArtistName}"),
        ];
      }

      _info.add(widget.albumArt);
      _info.addAll(_texts);
    });
  }

  @override
  void didUpdateWidget(covariant AudioInfoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileName != widget.fileName ||
        oldWidget.trackName != widget.trackName ||
        oldWidget.albumName != widget.albumName ||
        oldWidget.albumArtistName != widget.albumArtistName) {
      _buildTexts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _info,
    );
  }
}