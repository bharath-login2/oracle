import 'package:flutter/material.dart';

class ExpenseIncomePage extends StatelessWidget {
  const ExpenseIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense / Income")),
      body: const Center(child: Text("Expense / Income Chart here")),
    );
  }
}

