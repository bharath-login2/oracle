import 'package:flutter/material.dart';

class WorkProgressPage extends StatelessWidget {
  const WorkProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Work Progress")),
      body: const Center(child: Text("Work Progress Chart here")),
    );
  }
}
