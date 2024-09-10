// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/exp_list.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';

class EditExpense extends StatefulWidget {
  Expense data;
  EditExpense({super.key, required this.data});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  var date;
  List<AccountHead> accountHeads = [];
  List<AccountHead> filteredAccounts = [];
  bool result = true;
  List<ExpenseType> categories = [];
  List<ExpenseType> filteredCategories = [];
  ExpenseMasterData? expenseMasterData;
  ExpensePostModel? updateResponse;
  String expId = "";
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
    expId = widget.data.cmpnyExId;
    date = DateTime.parse(widget.data.trnDate.toString());
    fromAcId = widget.data.fromAccount;
    toAcId = widget.data.tothePerson;
    fromAcName = widget.data.fromAccountPerson;
    toAcName = widget.data.toAccountPerson;
    categoryId = widget.data.expCatid;
    categoryName = widget.data.expCatName;
    amountController.text = widget.data.amount;
    remarkController.text = widget.data.remarks;
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
    // getDetailsById();
    getMasterData();
  }

  // getDetailsById() async {
  //   expenseMasterData = await HttpService.expenseMasterData();
  //   if (expenseMasterData != null && expenseMasterData!.status == true) {
  //     categories = expenseMasterData!.data.expenseType;
  //     filteredCategories.addAll(categories);
  //     accountHeads = expenseMasterData!.data.accountHead;
  //     filteredAccounts.addAll(accountHeads);
  //     setState(() {});
  //   } else {
  //     setState(() {});
  //   }
  // }

  getMasterData() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      categories = expenseMasterData!.data.expenseType;
      filteredCategories.addAll(categories);
      accountHeads = expenseMasterData!.data.accountHead;
      filteredAccounts.addAll(accountHeads);
      setState(() {});
    } else {
      setState(() {});
    }
  }

  updateExpense() async {
    updateResponse = await HttpService.updateExpense(
        expId,
        categoryId,
        amountController.text,
        fromAcId,
        toAcId,
        date.toString(),
        remarkController.text);
    if (updateResponse != null && updateResponse!.status == true) {
      Common.toastMessaage(updateResponse!.message, Colors.green);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      Common.toastMessaage(updateResponse!.message, Colors.red);
      if (mounted) {
        Navigator.pop(context);
      }
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
                        "Edit Expense",
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
                        // This will add one year from current date
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
                        // We can also use onSaved
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
                      accountsDialog(context, "from");
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
                  GestureDetector(
                    onTap: () {
                      categoryDialog(context);
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
                                    categoryName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
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
                          //prefixIcon: Icon(myIcon, color: prefixIconColor),
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
                  const Text("Person/Company"),
                  GestureDetector(
                    onTap: () {
                      accountsDialog(context, "to");
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
                                    toAcName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
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
                          //prefixIcon: Icon(myIcon, color: prefixIconColor),
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
                          if (fromAcId == "") {
                            Common.toastMessaage(
                                'Please select from account', Colors.red);
                          } else if (categoryId == "") {
                            Common.toastMessaage(
                                ' Please select category', Colors.red);
                          } else if (amountController.text == "") {
                            Common.toastMessaage(
                                ' Please enter valid amount', Colors.red);
                          } else if (toAcId == "") {
                            Common.toastMessaage(
                                'Please select to account', Colors.red);
                          } else {
                            if (context.mounted) {
                              Common.showProgressDialog(context, "Loading..");
                              updateExpense();
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

  Future<dynamic> accountsDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredAccounts = accountHeads
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredAccounts.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            if (type == "from") {
                              fromAcName = filteredAccounts[index].accountName;
                              fromAcId = filteredAccounts[index].accountId;
                            } else {
                              toAcName = filteredAccounts[index].accountName;
                              toAcId = filteredAccounts[index].accountId;
                            }
                            searchController.clear();
                            filteredAccounts.clear();
                            filteredAccounts.addAll(accountHeads);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredAccounts[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    searchController.clear();
                    filteredAccounts.clear();
                    filteredAccounts.addAll(accountHeads);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> categoryDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredCategories = categories
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredCategories.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            categoryName = filteredCategories[index].expCatName;
                            categoryId = filteredCategories[index].expCatId;
                            searchController.clear();
                            filteredCategories.clear();
                            filteredCategories.addAll(categories);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredCategories[index].expCatName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    searchController.clear();
                    filteredCategories.clear();
                    filteredCategories.addAll(categories);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }
}
