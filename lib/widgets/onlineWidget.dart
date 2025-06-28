import 'package:flutter/material.dart';

Widget _buildStatusChip(String status) {
  Color bgColor;
  String label;

  switch (status.toLowerCase()) {
    case "started":
      bgColor = Colors.green;
      label = "Online";
      break;
    case "ended":
      bgColor = Colors.red;
      label = "Offline";
      break;
    default:
      bgColor = Colors.grey;
      label = "Not Started";
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.1),
      border: Border.all(color: bgColor),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: bgColor, fontWeight: FontWeight.w500),
    ),
  );
}
