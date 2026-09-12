import 'package:flutter/material.dart';

class PaymentScheduleScreen extends StatefulWidget {
  final String projectId;

  const PaymentScheduleScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Payment Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,

        // Back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        // Add button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                // TODO: Open Add Payment Schedule screen/dialog
              },
            ),
          ),
        ],

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primary,
                _primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
