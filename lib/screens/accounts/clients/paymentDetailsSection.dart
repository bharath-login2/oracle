import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';

class PaymentDetailsSection extends StatefulWidget {
  final List<String> paymentStatusList;
  final List<String> paymentMethods;
  final Function(String)? onPaymentStatusChanged;
  final Function(String)? onPaymentMethodChanged;

  const PaymentDetailsSection({
    super.key,
    required this.paymentStatusList,
    required this.paymentMethods,
    this.onPaymentStatusChanged,
    this.onPaymentMethodChanged,
  });

  @override
  State<PaymentDetailsSection> createState() => _PaymentDetailsSectionState();
}

class _PaymentDetailsSectionState extends State<PaymentDetailsSection> {
  String? paymentStatus;
  String? paymentMethod;
  String? collectedBy;
  String? paidDate;
  TextEditingController paidAmount = TextEditingController();
  Color paidColor = Colors.black;

  String staffName = "Select Account Head";
  List<String> targetGroupNames = [];
  List<String> targetGroups = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 25),

          // 🔹 Pay Status
          _buildFormRow(
            "Pay Status * :",
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: paymentStatus,
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text('Status'),
                  ),
                  items: widget.paymentStatusList.map((data) {
                    return DropdownMenuItem(
                      value: data,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(data, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      paymentStatus = newValue;
                      widget.onPaymentStatusChanged?.call(newValue ?? '');
                      if (paymentStatus == "Paid") {
                        paidAmount.text = "0"; // Example logic
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Paid Amount (Only visible if paid/partial)
          if (paymentStatus != null && paymentStatus != "Unpaid")
            _buildFormRow(
              "Paid Amount * :",
              TextFormField(
                controller: paidAmount,
                readOnly: paymentStatus == "Paid",
                style: TextStyle(color: paidColor),
                onChanged: (val) {
                  if (double.tryParse(val) == null) {
                    paidColor = Colors.red;
                  } else {
                    paidColor = Colors.black;
                  }
                  setState(() {});
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // 🔹 Payment Method (only if paid or partial)
          Visibility(
            visible: paymentStatus == "Paid" || paymentStatus == "Partial",
            child: Column(
              children: [
                _buildFormRow(
                  "Payment Method * :",
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: paymentMethod,
                        hint: const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text('Select Method'),
                        ),
                        items: widget.paymentMethods.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(m),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => paymentMethod = newValue);
                          widget.onPaymentMethodChanged?.call(newValue ?? '');
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Account Head
                _buildFormRow(
                  "Account Head * :",
                  GestureDetector(
                    onTap: () => _showDialog(context, "Select Account Head"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              staffName,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Target Group
                _buildFormRow(
                  "Target Group :",
                  GestureDetector(
                    onTap: () => _showDialog(context, "Select Target Group"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: targetGroupNames.isEmpty
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Target Group'),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: targetGroupNames
                                  .map((name) => Chip(
                                        label: Text(name),
                                        backgroundColor: Colors.white,
                                        deleteIconColor: Colors.red,
                                        onDeleted: () {
                                          setState(() {
                                            targetGroupNames.remove(name);
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Collected By
          _buildFormRow(
            "Collected By :",
            DropdownButtonFormField<String>(
              value: collectedBy,
              hint: const Text('Select Staff'),
              items: ['Staff 1', 'Staff 2', 'Staff 3'].map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => collectedBy = v),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Paid Date
          _buildFormRow(
            "Paid Date :",
            DateTimePicker(
              type: DateTimePickerType.date,
              dateMask: 'yyyy-MM-dd',
              initialValue: paidDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) => setState(() => paidDate = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  void _showDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text("Custom dialog content goes here"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
  }
}
