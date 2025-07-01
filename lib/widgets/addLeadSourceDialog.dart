import 'package:flutter/material.dart';

class AddLeadSourceDialog extends StatefulWidget {
  final Function(String leadSource) onSubmit;

  const AddLeadSourceDialog({super.key, required this.onSubmit});

  @override
  State<AddLeadSourceDialog> createState() => _AddLeadSourceDialogState();
}

class _AddLeadSourceDialogState extends State<AddLeadSourceDialog> {
  final TextEditingController _leadSourceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Lead Source',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Lead Source', style: TextStyle(fontSize: 14))),
          const SizedBox(height: 8),
          TextField(
            controller: _leadSourceController,
            decoration: const InputDecoration(
              hintText: 'Enter Lead Source',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5AC7),
                      foregroundColor: const Color.fromARGB(255, 255, 252, 252),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
          onPressed: () {
            String leadSource = _leadSourceController.text.trim();
            if (leadSource.isNotEmpty) {
              widget.onSubmit(leadSource);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enter a valid lead source")),
              );
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
