import 'package:flutter/material.dart';

class StartEndSliders extends StatelessWidget{
  final Duration start;
  final Duration end;
  final Duration duration;
  final String Function(Duration) format;
  final ValueChanged<Duration> onStartChanged;
  final ValueChanged<Duration> onEndChanged;

  const StartEndSliders({
    required this.start,
    required this.end,
    required this.duration,
    required this.format,
    required this.onStartChanged,
    required this.onEndChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StartSlider(start: start, duration: duration, format: format, onStartChanged: onStartChanged),
        EndSlider(end: end, duration: duration, format: format, onEndChanged: onEndChanged)
      ],
    );
  }

}

class EndSlider extends StatelessWidget{
  final Duration end;
  final Duration duration;
  final String Function(Duration) format;
  final ValueChanged<Duration> onEndChanged;

  const EndSlider({
    required this.end,
    required this.duration,
    required this.format,
    required this.onEndChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("End:"),
        Expanded(
          child: Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: end.inSeconds
                .toDouble()
                .clamp(0.0, duration.inSeconds.toDouble()),
            onChanged: (v) => onEndChanged(Duration(seconds: v.toInt())),
          ),
        ),
        Text(format(end)),
      ],
    );
  }
}

class StartSlider extends StatelessWidget{
  final Duration start;
  final Duration duration;
  final String Function(Duration) format;
  final ValueChanged<Duration> onStartChanged;

  const StartSlider({
    required this.start,
    required this.duration,
    required this.format,
    required this.onStartChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Start:"),
        Expanded(
          child: Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: start.inSeconds
                  .toDouble()
                  .clamp(0.0, duration.inSeconds.toDouble()),
              onChanged: (v) => onStartChanged(Duration(seconds: v.toInt()))
          ),
        ),
        Text(format(start)),
      ],
    );
  }
}
