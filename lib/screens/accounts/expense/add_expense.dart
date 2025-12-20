import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/accountHeadDialog.dart';
import 'package:login2/widgets/expenseCategoryDialog.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  var date = DateTime.now();
  List<AccountHead> accountHeads = [];
  List<AccountHead> filteredAccounts = [];
  bool result = true;
  List<ExpenseType> categories = [];
  List<ExpenseType> filteredCategories = [];
  ExpenseMasterData? expenseMasterData;
  CommonResponse? postResponse;
  String categoryId = "";
  String categoryName = "Tap to select";
  String fromAcId = "";
  String fromAcName = "Tap to select";
  String toAcId = "";
  String toAcName = "Tap to select";
  TextEditingController searchController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        result = true;
      });
    } else {
      setState(() {
        result = false;
      });
    }
    getDetails();
  }

  getDetails() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      setState(() {
        categories = expenseMasterData!.data.expenseType;
        filteredCategories = List.from(categories);
        accountHeads = expenseMasterData!.data.accountHead;
        filteredAccounts = List.from(accountHeads);
      });
      
      // Get shared preferences and update state
      final sharedAccountId = await Common.getSharedPref("accountId");
      final sharedAccountName = await Common.getSharedPref("accountName");
      
      setState(() {
        fromAcId = sharedAccountId;
        fromAcName = sharedAccountName;
      });
    } else {
      setState(() {});
    }
  }

  postExpense() async {
    postResponse = await HttpService.postExpense(
        categoryId,
        amountController.text,
        fromAcId,
        toAcId,
        date.toString(),
        remarkController.text);
    if (postResponse != null && postResponse!.status == true) {
      Common.toastMessaage(postResponse!.message, Colors.green);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      Common.toastMessaage(postResponse!.message, Colors.red);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // FIXED: Updated methods to properly update state
  void updateFromAccount(String id, String name) {
    setState(() {
      fromAcId = id;
      fromAcName = name;
    });
  }

  void updateToAccount(String id, String name) {
    setState(() {
      toAcId = id;
      toAcName = name;
    });
  }

  void updateCategory(String id, String name) {
    setState(() {
      categoryId = id;
      categoryName = name;
    });
  }

  // FIXED: Refresh account heads after adding new one
  void refreshAccountHeads() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      setState(() {
        accountHeads = expenseMasterData!.data.accountHead;
        filteredAccounts = List.from(accountHeads);
      });
    }
  }

  // FIXED: Refresh categories after adding new one
  void refreshCategories() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      setState(() {
        categories = expenseMasterData!.data.expenseType;
        filteredCategories = List.from(categories);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        "Add Expense",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date : ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: Center(
                      child: DateTimePicker(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        initialValue: date.toString(),
                        type: DateTimePickerType.date,
                        firstDate: DateTime(1995),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        validator: (value) {
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              date = DateTime.parse(value);
                            });
                          }
                        },
                        onSaved: (value) {
                          if (value!.isNotEmpty) {
                            date = value as DateTime;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("From"),
                  GestureDetector(
                    onTap: () {
                      _showAccountsDialog(context, "from");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: Text(
                                    fromAcName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Category"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showCategoryDialog(context);
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.35,
                                child: Text(
                                  categoryName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: categoryName == "Tap to select"
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _showCategoryDialog(context);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.green),
                                  onPressed: () async {
                                    final newCategory =
                                        await showDialog<String>(
                                      context: context,
                                      builder: (context) =>
                                          const AddCategoryDialog(),
                                    );

                                    if (newCategory != null &&
                                        newCategory.isNotEmpty) {
                                      final response =
                                          await HttpService.addCategoryExpense(
                                        newCategory: newCategory,
                                      );

                                      if (response != null &&
                                          response.status == true) {
                                        refreshCategories();
                                        Common.toastMessaage(
                                            "Category added successfully",
                                            Colors.green);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Amount"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          hintText: "Amount",
                          fillColor: Colors.grey[300],
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          labelStyle: const TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Head"),
                  GestureDetector(
                    onTap: () {
                      _showAccountsDialog(context, "to");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showAccountsDialog(context, "to");
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: Text(
                                    toAcName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: toAcName == "Tap to select"
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _showAccountsDialog(context, "to");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const AddAccountHeadDialog(),
                                      );

                                      if (result == true) {
                                        refreshAccountHeads();
                                        Common.toastMessaage(
                                            "Account head added successfully",
                                            Colors.green);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Remarks"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: remarkController,
                      maxLines: 2,
                      decoration: InputDecoration(
                          hintText: "Remarks",
                          fillColor: Colors.grey[300],
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          labelStyle: const TextStyle(color: Colors.black)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                      child: GestureDetector(
                        onTap: () {
                          if (fromAcId.isEmpty || fromAcId == "") {
                            Common.toastMessaage(
                                'Please select from account', Colors.red);
                          } else if (categoryId.isEmpty || categoryId == "") {
                            Common.toastMessaage(
                                'Please select category', Colors.red);
                          } else if (amountController.text.isEmpty) {
                            Common.toastMessaage(
                                'Please enter valid amount', Colors.red);
                          } else if (toAcId.isEmpty || toAcId == "") {
                            Common.toastMessaage(
                                'Please select to account', Colors.red);
                          } else {
                            if (context.mounted) {
                              Common.showProgressDialog(context, "Loading..");
                              postExpense();
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Submit',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Dialog methods that properly update parent state
  void _showAccountsDialog(BuildContext context, String type) async {
    final selectedAccount = await showDialog<AccountHead>(
      context: context,
      builder: (context) {
        return _AccountsDialog(
          accounts: accountHeads,
          searchController: TextEditingController(),
        );
      },
    );

    if (selectedAccount != null && mounted) {
      if (type == "from") {
        updateFromAccount(
            selectedAccount.accountId, selectedAccount.accountName);
      } else {
        updateToAccount(selectedAccount.accountId, selectedAccount.accountName);
      }
    }
  }

  void _showCategoryDialog(BuildContext context) async {
    final selectedCategory = await showDialog<ExpenseType>(
      context: context,
      builder: (context) {
        return _CategoryDialog(
          categories: categories,
          searchController: TextEditingController(),
        );
      },
    );

    if (selectedCategory != null && mounted) {
      updateCategory(selectedCategory.expCatId, selectedCategory.expCatName);
    }
  }
}


class _AccountsDialog extends StatefulWidget {
  final List<AccountHead> accounts;
  final TextEditingController searchController;

  const _AccountsDialog({
    required this.accounts,
    required this.searchController,
  });

  @override
  __AccountsDialogState createState() => __AccountsDialogState();
}

class __AccountsDialogState extends State<_AccountsDialog> {
  List<AccountHead> filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    filteredAccounts = List.from(widget.accounts);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
       title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Select Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 22,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.searchController,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                filteredAccounts = widget.accounts
                    .where((item) => item.accountName
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * .3,
            width: MediaQuery.of(context).size.width * .8,
            child: filteredAccounts.isEmpty
                ? const Center(
                    child: Text("No accounts found"),
                  )
                : ListView.builder(
                    itemCount: filteredAccounts.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context, filteredAccounts[index]);
                        },
                        title: Text(filteredAccounts[index].accountName),
                      );
                    },
                  ),
          )
        ],
      ),
     
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final List<ExpenseType> categories;
  final TextEditingController searchController;

  const _CategoryDialog({
    required this.categories,
    required this.searchController,
  });

  @override
  __CategoryDialogState createState() => __CategoryDialogState();
}

class __CategoryDialogState extends State<_CategoryDialog> {
  List<ExpenseType> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
     title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Select Category",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 22,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.searchController,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                filteredCategories = widget.categories
                    .where((item) => item.expCatName
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * .3,
            width: MediaQuery.of(context).size.width * .8,
            child: filteredCategories.isEmpty
                ? const Center(
                    child: Text("No categories found"),
                  )
                : ListView.builder(
                    itemCount: filteredCategories.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context, filteredCategories[index]);
                        },
                        title: Text(filteredCategories[index].expCatName),
                      );
                    },
                  ),
          )
        ],
      ),
     
    );
  }
}