import 'package:flutter/material.dart';
import 'package:login2/models/expense/customerListModel.dart';

import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/service/service.dart';

class AddAccountHeadDialog extends StatefulWidget {
  const AddAccountHeadDialog({super.key});

  @override
  State<AddAccountHeadDialog> createState() => _AddAccountHeadDialogState();
}

class _AddAccountHeadDialogState extends State<AddAccountHeadDialog> {
  String accountType = "Staff";
  String openingBalanceType = 'Advance';
  bool markImportant = false;
  List<Staff> staffList = [];
  List<CustomerExp> customerList = [];

  String? selectedStaffId;
  String? selectedCustomerId;

  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController openingBalanceController =
      TextEditingController();

  InputDecoration _inputDecoration(String label) => InputDecoration(
        hintText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await HttpService.getStaffs();
    if (response != null && response.status == true) {
      staffList = response.data;
    }

    final customerResponse = await HttpService.getCustomers();
    if (customerResponse != null) {
      if (customerResponse.status == true) {
        customerList = customerResponse.data ?? [];
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    accountNameController.dispose();
    personNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    purposeController.dispose();
    remarkController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Account Head",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Account Type *",
                style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 10,
              children: ["Staff", "Customer", "Other", "Bank"].map((type) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: type,
                      groupValue: accountType,
                      onChanged: (val) {
                        setState(() {
                          accountType = val!;
                        });
                      },
                    ),
                    Text(type),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            _buildDynamicFields(accountType),
            const SizedBox(height: 20),
            const Text("Opening Balance is",
                style: TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: "Advance",
                      groupValue: openingBalanceType,
                      visualDensity: const VisualDensity(horizontal: -4),
                      onChanged: (val) =>
                          setState(() => openingBalanceType = val!),
                    ),
                    const Text("Advance Amount"),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: "Pending",
                      groupValue: openingBalanceType,
                      visualDensity: const VisualDensity(horizontal: -4),
                      onChanged: (val) =>
                          setState(() => openingBalanceType = val!),
                    ),
                    const Text("Pending Amount"),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: markImportant,
                  onChanged: (val) => setState(() => markImportant = val!),
                ),
                const Text("Mark as important"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final response = await HttpService.addAccountHead(
                      accountType: accountType,
                      accountName: accountNameController.text.trim(),
                      personName: personNameController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                      email: emailController.text.trim(),
                      purpose: purposeController.text.trim(),
                      remark: remarkController.text.trim(),
                      openingBalance: openingBalanceController.text.trim(),
                      openingBalanceType:
                          openingBalanceType == 'Advance' ? 'debit' : 'credit',
                      isImportant: markImportant,
                    );
                    if (response != null && response.status == true) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to add account head"),
                        ),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFields(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Account Name *",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: accountNameController,
          decoration: _inputDecoration("Account name"),
        ),
        const SizedBox(height: 10),
        if (type == "Staff") ...[
          const Text("Select Staff *",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedStaffId,
            decoration: _inputDecoration("Select Staff"),
            items: staffList
                .map((staff) => DropdownMenuItem<String>(
                      value: staff.id,
                      child: Text(staff.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStaffId = value;
                personNameController.text =
                    staffList.firstWhere((staff) => staff.id == value).name;
              });
            },
          ),
        ] else if (type == "Customer") ...[
          const Text("Select Customer *",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedCustomerId,
            decoration: _inputDecoration("Select Customer"),
            items: customerList
                .map((cust) => DropdownMenuItem<String>(
                      value: cust.id,
                      child: Text(cust.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCustomerId = value;
                personNameController.text =
                    customerList.firstWhere((cust) => cust.id == value).name;
              });
            },
          ),
        ] else ...[
          const Text("Person Name",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: personNameController,
            decoration: _inputDecoration("Person name"),
          ),
          const SizedBox(height: 10),
          const Text("Phone No", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: phoneController,
            decoration: _inputDecoration("Phone Number"),
          ),
          const SizedBox(height: 10),
          const Text("Address", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: addressController,
            decoration: _inputDecoration("Address"),
          ),
          const SizedBox(height: 10),
          const Text("Email ID", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            decoration: _inputDecoration("Email"),
          ),
          const SizedBox(height: 10),
          const Text("Purpose", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: purposeController,
            decoration: _inputDecoration("Purpose"),
          ),
          const SizedBox(height: 10),
          const Text("Remark", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: remarkController,
            decoration: _inputDecoration("Remark"),
          ),
        ],
        const SizedBox(height: 10),
        const Text("Opening Balance",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: openingBalanceController,
          decoration: _inputDecoration("Opening Balance"),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
