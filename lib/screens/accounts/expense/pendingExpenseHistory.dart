import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/expenseTypeModel.dart';
import 'package:login2/models/lead_management/pendingListModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/AddPendingExpenseForm.dart';
import 'package:login2/models/expense/account_head_model.dart';

class PendingExpenseHistoryPage extends StatefulWidget {
  const PendingExpenseHistoryPage({super.key});
  @override
  State<PendingExpenseHistoryPage> createState() =>
      _PendingExpenseHistoryPageState();
}

class _PendingExpenseHistoryPageState extends State<PendingExpenseHistoryPage> {
  List<PendingListElement> _pendingExpenses = [];
  bool _isLoading = true;
  List<ListElement> staffList = [];
  List<ExpenseTypeElement> expenseTypes = [];
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _fetchPendingExpenses();
    _loadStaffs();
    _loadExpenseTypes();
  }
  Future<void> _fetchPendingExpenses() async {
    setState(() => _isLoading = true);
    final response = await HttpService.get_pending_list();
    if (response != null && response.status == true) {
      setState(() {
        _pendingExpenses = response.data.pendingList;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to fetch expenses"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getAccountHead();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data.lists;
      });
    }
  }

  Future<void> _loadExpenseTypes() async {
    final response = await HttpService.get_expense_type();
    if (response != null && response.status == true) {
      setState(() {
        expenseTypes = response.data.expenseType;
      });
    }
  }

  void _editExpense(PendingListElement expense) {
    final TextEditingController amountController =
        TextEditingController(text: expense.amount?.toString() ?? "");
    final TextEditingController dateController = TextEditingController(
      text: expense.expenseDate.isNotEmpty
          ? expense.expenseDate
          : DateFormat("dd-MM-yyyy").format(DateTime.now()),
    );
    String? accountHead = expense.accountNameId;
    String? expenseType = expense.expenseTypeId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Update Pending Expense",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Account Head",
                        border: OutlineInputBorder(),
                      ),
                      value: staffList.any(
                              (account) => account.accountId == accountHead)
                          ? accountHead
                          : null,
                      isExpanded: true,
                      items: staffList.map((account) {
                        return DropdownMenuItem(
                          value: account.accountId,
                          child: Text(account.accountName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => accountHead = val),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: expenseType,
                      decoration: const InputDecoration(
                        labelText: "Expense Type",
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: expenseTypes.map((etype) {
                        return DropdownMenuItem(
                          value: etype.expCatId,
                          child: Text(etype.expCatName),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setStateDialog(() => expenseType = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Expense Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: expense.expenseDate.isNotEmpty
                              ? DateFormat("dd-MM-yyyy")
                                  .parse(expense.expenseDate)
                              : DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            dateController.text =
                                DateFormat("dd-MM-yyyy").format(picked);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedData = {
                      "id": expense.id,
                      "account_head": accountHead,
                      "expense_type": expenseType,
                      "amount": amountController.text,
                      "expense_date": dateController.text,
                    };

                    final response =
                        await HttpService.editPendingHistory(updatedData);

                    if (!mounted) return;
                    Navigator.pop(context);
                    if (response != null && response.status == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ ${response.message}"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _fetchPendingExpenses();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "❌ ${response?.message ?? "Failed to update expense"}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteExpense(PendingListElement expense) async {
    final response =
        await HttpService.deletePendingHistory(expense.id.toString());

    if (response != null && response.status == true) {
      setState(() {
        _pendingExpenses.removeWhere((e) => e.id == expense.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("✅ ${response.message ?? "Expense deleted successfully"}"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to delete expense"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _selectedDate == null
        ? _pendingExpenses
        : _pendingExpenses.where((expense) {
            try {
              final expenseDate =
                  DateFormat("dd-MM-yyyy").parse(expense.expenseDate);
              return expenseDate.year == _selectedDate!.year &&
                  expenseDate.month == _selectedDate!.month &&
                  expenseDate.day == _selectedDate!.day;
            } catch (_) {
              return true;
            }
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pending Expense",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Filter by Date",
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "refresh") {
                _fetchPendingExpenses();
              } else if (value == "add") {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AddPendingExpenseForm(),
                        ),
                      ),
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => const [
              //PopupMenuItem(value: "refresh", child: Text("🔄 Refresh")),
              PopupMenuItem(value: "add", child: Text("Add Pending Expense")),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchPendingExpenses();
              },
              child: filteredExpenses.isEmpty
                  ? const Center(
                      child: Text(
                        "No pending expenses found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 255, 255, 255),
                                  Colors.white
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          expense.accountName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 137, 178, 216),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "₹${expense.amount}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(expense.expenseType),
                                        backgroundColor: const Color.fromARGB(
                                            255, 190, 218, 231),
                                      ),
                                      Text(
                                        expense.expenseDate,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "👤 Created By: ${expense.createdBy}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            //  fontStyle: FontStyle.italic,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.15),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              tooltip: "Edit",
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue, size: 18),
                                              onPressed: () =>
                                                  _editExpense(expense),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 247, 235, 235),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red
                                                      .withOpacity(0.15),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              tooltip: "Delete",
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 18),
                                              onPressed: () =>
                                                  _deleteExpense(expense),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),

                                  //  const Divider(height: 20),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     ElevatedButton.icon(
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: Colors.blue,
                                  //         foregroundColor: Colors.white,
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(8),
                                  //         ),
                                  //       ),
                                  //       icon: const Icon(Icons.edit, size: 18),
                                  //       label: const Text("Edit"),
                                  //       onPressed: () => _editExpense(expense),
                                  //     ),
                                  //     const SizedBox(width: 10),
                                  //     ElevatedButton.icon(
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: Colors.red,
                                  //         foregroundColor: Colors.white,
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(8),
                                  //         ),
                                  //       ),
                                  //       icon: const Icon(Icons.delete, size: 18),
                                  //       label: const Text("Delete"),
                                  //       onPressed: () => _deleteExpense(expense),
                                  //     ),
                                  //   ],
                                  // )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
