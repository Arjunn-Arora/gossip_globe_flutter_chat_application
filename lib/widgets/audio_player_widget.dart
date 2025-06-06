import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key, required this.audioUrl});

  final String audioUrl;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else if (state == PlayerState.paused) {
        setState(() {
          isPlaying = false;
        });
      } else if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          position = const Duration();
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    super.initState();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(":");
  }

  void seekToPosition(double seconds) async {
    final newPosition = Duration(seconds: seconds.toInt());
    await audioPlayer.seek(newPosition);
    await audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.orangeAccent,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: IconButton(
                onPressed: () async {
                  if (!isPlaying) {
                    await audioPlayer.play(UrlSource(widget.audioUrl));
                  } else {
                    audioPlayer.pause();
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                )),
          ),
        ),
        Expanded(
          child: Slider.adaptive(
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            min: 0.0,
            onChanged: seekToPosition,
          ),
        ),
        Text(
          formatTime(duration - position),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
