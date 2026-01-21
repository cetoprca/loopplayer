import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loopplayer/audioInfoView.dart';
import 'package:loopplayer/bottomControls.dart';
import 'package:loopplayer/iconToImage.dart';
import 'package:loopplayer/sliders.dart';
import 'package:logger/src/log_level.dart';

import 'package:audiotags/audiotags.dart';

void main() {
  runApp(LoopPlayer());
}

class LoopPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioPlayerExplorer(),
    );
  }
}

class AudioPlayerExplorer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AudioPlayerExplorerState();
  }
}

class _AudioPlayerExplorerState extends State<AudioPlayerExplorer> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer(logLevel: Level.off);
  bool _isPlaying = false;
  bool _loopActive = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Duration _start = Duration.zero;
  Duration _end = Duration.zero;

  bool _endInitialized = false;

  String? _currentFilePath;

  String? _fileName;
  String? _trackName;
  String? _albumName;
  String? _albumArtistName;
  Image? _albumArt;

  late Image placeholder;
  @override
  void initState() {
    super.initState();
    _openPlayer();
  }

  Future<void> _openPlayer() async {
    await _player.openPlayer();
    _player.setSubscriptionDuration(Duration(milliseconds: 100));

    placeholder = Image.memory(await iconToImageBytes(Icons.music_note, 48, Colors.grey),
      width: 100,
      height: 100,);

    _player.onProgress!.listen((event) {
      setState(() {
        _position = event.position;
        _duration = event.duration ?? Duration.zero;

        if(!_endInitialized){
          setState(() {
            _end = _duration;
            _endInitialized = true;
          });
        }

        // Detener o loop al llegar a _end
        if (_position >= _end) {
          if (_loopActive) {
            _player.seekToPlayer(_start);
          } else {
            _player.stopPlayer();
            _isPlaying = false;
          }
        }
      });
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _currentFilePath = result.files.single.path;
        _position = Duration.zero;
        _duration = Duration.zero;
        _start = Duration.zero;
        _end = Duration.zero;
        _endInitialized = false;
        _loadAudioMetadata(result);
      });
      _startPlayer();
    }
  }

  Future<void> _loadAudioMetadata(FilePickerResult result) async{
    Tag? tag = await AudioTags.read(result.files.single.path!);
    _fileName = result.files.single.name;
    _trackName = tag?.title ?? "";
    _albumName = tag?.album ?? "";
    _albumArtistName = tag?.albumArtist ?? "";
    if(tag != null && tag.pictures.isNotEmpty){
      _albumArt = Image.memory(tag.pictures.first.bytes, width: 100, height: 100,);
    }else{
      _albumArt = placeholder;
    }
  }

  Future<void> _startPlayer() async {
    if (_currentFilePath == null) return;

    await _player.startPlayer(
      fromURI: _currentFilePath!,
      whenFinished: () {
        if (_loopActive) {
          _player.seekToPlayer(_start);
        } else {
          setState(() => _isPlaying = false);
        }
      },
    );

    // Mover al inicio seleccionado
    await _player.seekToPlayer(_start);

    setState(() => _isPlaying = true);
  }

  Future<void> _pausePlayer() async {
    await _player.pausePlayer();
    setState(() => _isPlaying = false);
  }

  Future<void> _stopPlayer() async {
    await _player.stopPlayer();
    setState(() => _isPlaying = false);
  }

  Future<void> _seekPlayer(Duration position) async {
    await _player.seekToPlayer(position);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _movePosition(Directions direction) async {
    if(direction == Directions.FORWARD) {
      _player.seekToPlayer(_position + Duration(seconds: 1));
    }else{
      _player.seekToPlayer(_position + Duration(seconds: -1));
    }
  }

  Future<void> _resumePlayer() async{
    if(_player.isPaused){
      _player.resumePlayer();
      setState(() {
        _isPlaying = true;
      });
    }else if(_player.isStopped){
      _startPlayer();
    }
  }

  Future<void> _restartPlayer() async => _player.seekToPlayer(Duration(seconds: 0));
  Future<void> _togglePlayer() async => _isPlaying ? _pausePlayer() : _resumePlayer();
  Future<void> _toggleLoop() async => setState(() => _loopActive = !_loopActive);

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reproductor de Audio'), backgroundColor: Colors.orange,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Seleccionar archivo'),
              onPressed: _pickFile,
            ),
            SizedBox(height: 10),

            AudioInfoView(
              fileName: _fileName ?? "",
              trackName: _trackName ?? "",
              albumName: _albumName ?? "",
              albumArtistName: _albumArtistName?? "",
              albumArt: _albumArt ?? placeholder
            ),

            SizedBox(height: 20),

            // Slider de posición
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds
                  .toDouble()
                  .clamp(0.0, _duration.inSeconds.toDouble()),
              onChanged: (value) => _seekPlayer(Duration(seconds: value.toInt())),
            ),

            // Duración
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),

            SizedBox(height: 20),
            // Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: Icon(Icons.replay_10),
                  onPressed: () {
                    final newPos = _position - Duration(seconds: 10);
                    _seekPlayer(newPos > Duration.zero ? newPos : Duration.zero);
                  },
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _pausePlayer();
                    } else {
                      _startPlayer();
                    }
                  },
                ),
                IconButton(
                  iconSize: 48,
                  icon: Icon(Icons.forward_10),
                  onPressed: () {
                    final newPos = _position + Duration(seconds: 10);
                    _seekPlayer(newPos < _duration ? newPos : _duration);
                  },
                ),
              ],
            ),
            StartEndSliders(      // Sliders para el control de cuando empieza y termina el audio
                start: _start,
                end: _end,
                duration: _duration,
                format: _formatDuration,
                onStartChanged: (v) => (setState((){
                  if(_end > v){
                    _start = v;
                  }else{
                    _start = _end - Duration(seconds: 1);
                  }

                  if(_position < _start){
                    _startPlayer();
                  }
                })),
                onEndChanged: (v) => (setState((){
                  if(v > _start){
                    _end = v;
                  }else{
                    _end = _start + Duration(seconds: 1);
                  }

                  if(_position > _end){
                    _startPlayer();
                  }
                })),
            ),
            Expanded(
                child: Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: BottomControls(
                      togglePlayer: _togglePlayer,
                      toggleLoop: _toggleLoop,
                      movePosition: _movePosition,
                      replayPlayer: _restartPlayer,
                      loopActive: _loopActive,
                      playerPlaying: _isPlaying
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

