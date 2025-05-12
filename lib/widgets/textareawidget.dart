import 'package:flutter/material.dart';

class ResizableTextField extends StatefulWidget {
  final TextEditingController controller;

  const ResizableTextField({super.key, required this.controller});

  @override
  _ResizableTextFieldState createState() => _ResizableTextFieldState();
}

class _ResizableTextFieldState extends State<ResizableTextField> {
  double _height = 100; // initial height

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: TextField(
            controller: widget.controller,
            maxLines: null, // allow unlimited lines
            expands: false,
            decoration: const InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _height += details.delta.dy;
              if (_height < 50) _height = 50; // prevent too small
            });
          },
          child: Container(
            height: 10,
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.drag_handle, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
