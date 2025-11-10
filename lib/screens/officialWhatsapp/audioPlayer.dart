import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final bool fromMe;
  final Duration duration;
  const AudioMessageWidget({
    Key? key,
    required this.audioUrl,
    this.fromMe = false,
    this.duration = const Duration(seconds: 0),
  }) : super(key: key);

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer _audioPlayer;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  Duration? _totalDuration;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.setUrl(widget.audioUrl).then((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: widget.fromMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: widget.fromMe ? const Radius.circular(18) : const Radius.circular(0),
            bottomRight: widget.fromMe ? const Radius.circular(0) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.blue),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_totalDuration != null && _totalDuration!.inMilliseconds > 0)
                        ? _currentPosition.inMilliseconds / _totalDuration!.inMilliseconds
                        : 0.0,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Audio message",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatDuration(_currentPosition),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
