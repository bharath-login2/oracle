import 'package:flutter/material.dart';

class AccountSection extends StatefulWidget {
  final String title;
  final TextEditingController openingBalanceController;
  final TextEditingController dateController;
  final bool showCheckbox;
  const AccountSection({
    super.key,
    required this.title,
    required this.openingBalanceController,
    required this.dateController,
    this.showCheckbox = true,
  });

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  bool isChecked = false;
  String balanceType = "advance";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Checkbox(
                  //   value: isChecked,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       isChecked = value ?? false;
                  //     });
                  //   },
                  // ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              const Text(
                "Date",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),

          // Input Fields Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.openingBalanceController,
                  decoration: const InputDecoration(
                    labelText: "Opening Balance",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      widget.dateController.text =
                          "${date.day}-${date.month}-${date.year}";
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Radio buttons
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  dense: true,
                  title: const Text("Advance Amount"),
                  value: "advance",
                  groupValue: balanceType,
                  onChanged: (value) {
                    setState(() => balanceType = value!);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  dense: true,
                  title: const Text("Pending Amount"),
                  value: "pending",
                  groupValue: balanceType,
                  onChanged: (value) {
                    setState(() => balanceType = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
