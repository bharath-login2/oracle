import 'package:flutter/material.dart';

class _CompactFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CompactFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,  // Reduced from default button height
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,  // Slightly smaller text
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ),
      ),
    );
  }
}