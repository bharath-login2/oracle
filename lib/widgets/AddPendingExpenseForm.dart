import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/models/lead_management/expenseTypeModel.dart';
import 'package:login2/service/service.dart';

class AddPendingExpenseForm extends StatefulWidget {
  const AddPendingExpenseForm({Key? key}) : super(key: key);

  @override
  State<AddPendingExpenseForm> createState() => _AddPendingExpenseFormState();
}

class _AddPendingExpenseFormState extends State<AddPendingExpenseForm> {
  String selectedOption = "existing"; // existing or new
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // New account head controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  String? selectedHead;
  String? selectedExpenseType;
  List<ListElement> staffList = [];
  List<ExpenseTypeElement> expenseTypes = [];
  bool isLoadingExpenseTypes = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());

    Common.getSharedPref("userId").then((id) {
      setState(() {
        userId = id ?? "";
      });
      _loadStaffs();
    });

    _loadExpenseTypes();
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getAccountHead();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data.lists;
        if (selectedHead == null &&
            staffList.any((staff) => staff.accountId == userId)) {
          selectedHead = userId;
        }
      });
    }
  }

  Future<void> _loadExpenseTypes() async {
    final response = await HttpService.get_expense_type();
    if (response != null && response.status == true) {
      setState(() {
        expenseTypes = response.data.expenseType;
        isLoadingExpenseTypes = false;
      });
    } else {
      setState(() {
        isLoadingExpenseTypes = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    Map<String, dynamic> data;

    if (selectedOption == "existing") {
      data = {
        "type": "existing",
        "account_head_id": selectedHead,
        "expense_type": selectedExpenseType,
        "amount": amountController.text,
        "expense_date": dateController.text,
      };
    } else {
      data = {
        "type": "new",
        "name": nameController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "email": emailController.text,
        "purpose": purposeController.text,
        "remark": remarkController.text,
        "expense_type": selectedExpenseType,
        "amount": amountController.text,
        "expense_date": dateController.text,
      };
    }

    try {
      var response = await HttpService.pendingExpenseMasterData(data);

      if (response != null && response.status == true) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.message ?? "Something went wrong"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: $e")),
        );
      }
    }
  }

  Future<T?> _showSearchDialog<T>({
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
  }) async {
    String searchText = '';
    List<T> filteredList = List.from(items);

    return showDialog<T>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 550,
              child: Column(
                children: [
                
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          searchText = val.toLowerCase();
                          filteredList = items
                              .where((e) => itemLabel(e).toLowerCase().contains(searchText))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(child: Text("No results found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredList.length,
                            //separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: Colors.grey.shade100,
                                title: Text(itemLabel(item), style: const TextStyle(fontSize: 16)),
                                onTap: () {
                                  Navigator.pop(context, item);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Pending Expense",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
         
          const SizedBox(height: 5),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Existing Account Head"),
                          value: "existing",
                          groupValue: selectedOption,
                          onChanged: (val) => setState(() => selectedOption = val!),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("New Account Head"),
                          value: "new",
                          groupValue: selectedOption,
                          onChanged: (val) => setState(() => selectedOption = val!),
                        ),
                      ),
                    ],
                  ),
                  if (selectedOption == "existing") ...[
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedHead != null
                            ? staffList
                                .firstWhere(
                                  (e) => e.accountId == selectedHead,
                                  orElse: () =>
                                      ListElement(accountId: '', accountName: '', pendingAmount: '0'),
                                )
                                .accountName
                            : "",
                      ),
                      decoration: _inputDecoration("Account Head")
                          .copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
                      onTap: () async {
                        final selected = await _showSearchDialog<ListElement>(
                          title: "Account Head",
                          items: staffList,
                          itemLabel: (e) => e.accountName,
                        );
                        if (selected != null) {
                          setState(() {
                            selectedHead = selected.accountId;
                          });
                        }
                      },
                    ),
                  ],
                  if (selectedOption == "new") ...[
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration("Person Name")),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration("Phone No")),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: addressController,
                        decoration: _inputDecoration("Address")),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration("Email Id")),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: purposeController,
                        decoration: _inputDecoration("Purpose")),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: remarkController,
                        decoration: _inputDecoration("Remark")),
                  ],
                  const SizedBox(height: 10),
                  isLoadingExpenseTypes
                      ? const Center(child: CircularProgressIndicator())
                      : TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: selectedExpenseType != null
                                ? expenseTypes
                                    .firstWhere(
                                        (e) => e.expCatId == selectedExpenseType,
                                        orElse: () => ExpenseTypeElement(expCatId: '', expCatName: ''))
                                    .expCatName
                                : "",
                          ),
                          decoration: _inputDecoration("Expense Type")
                              .copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
                          onTap: () async {
                            final selected = await _showSearchDialog<ExpenseTypeElement>(
                              title: "Expense Type",
                              items: expenseTypes,
                              itemLabel: (e) => e.expCatName,
                            );
                            if (selected != null) {
                              setState(() {
                                selectedExpenseType = selected.expCatId;
                              });
                            }
                          },
                        ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Amount"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: _inputDecoration("Expense Date")
                        .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dateController.text =
                              DateFormat("dd-MM-yyyy").format(picked);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Submit"),
                onPressed: _handleSubmit,
              ),
            ],
          )
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
