import 'package:flutter/material.dart';
import 'dart:async';

class TimeDifferenceWidget extends StatefulWidget {
  final String createdAt; 

  const TimeDifferenceWidget({super.key, required this.createdAt});

  @override
  _TimeDifferenceWidgetState createState() => _TimeDifferenceWidgetState();
}

class _TimeDifferenceWidgetState extends State<TimeDifferenceWidget> {
  late Timer _timer;
  late Duration _timeDifference;
  late DateTime _createdAt;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _createdAt = DateTime.parse(widget.createdAt); // Parse the passed created_at value
    _currentTime = DateTime.now();
    _timeDifference = _currentTime.difference(_createdAt);

    // Start a timer that updates every second
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimeDifference);
  }

  void _updateTimeDifference(Timer timer) {
    setState(() {
      _currentTime = DateTime.now();
      _timeDifference = _currentTime.difference(_createdAt);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeString = "${_timeDifference.inHours}h ${_timeDifference.inMinutes % 60}m ${_timeDifference.inSeconds % 60}s";

    return Text(
      "Time since creation: $timeString",
      style: TextStyle(fontSize: 24),
    );
  }
}
