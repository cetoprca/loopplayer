import 'package:flutter/material.dart';

enum Directions{
  FORWARD,
  BACKWARD
}

class BottomControls extends StatelessWidget{
  final VoidCallback togglePlayer;
  final VoidCallback toggleLoop;
  final Function(Directions) movePosition;
  final VoidCallback replayPlayer;

  final loopActive;
  final playerPlaying;

  const BottomControls(
      {super.key,
        required this.togglePlayer,
        required this.toggleLoop,
        required this.movePosition,
        required this.replayPlayer,
        required this.loopActive,
        required this.playerPlaying}
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton( // Mover hacia atras
            iconSize: 48,
            icon: Icon(Icons.fast_rewind_sharp),
            onPressed: () => movePosition(Directions.BACKWARD)
        ),
        IconButton( // Activar / desactivar bucle
          iconSize: 48,
            icon: Icon(loopActive ? Icons.repeat_one : Icons.repeat),
            onPressed: toggleLoop
        ),
        IconButton( // Activar / desactivar reproducir
            iconSize: 48,
            icon: Icon(playerPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: togglePlayer
        ),
        IconButton(
            iconSize: 48,
            icon: Icon(Icons.replay),
            onPressed: replayPlayer
        ),
        IconButton(
            iconSize: 48,
            icon: Icon(Icons.fast_forward_sharp),
            onPressed: () => movePosition(Directions.FORWARD)
        ),
      ],
    );
  }

}