import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/exp_category_list.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  ExpenseCategoryList? expenseCategories;
  CommonResponse? response;

  bool result = true;
  bool isLoading = true;
  final formKey = GlobalKey<FormState>();
  final TextEditingController category = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
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
    getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    expenseCategories = await HttpService.expenseCategoryList();
    if (expenseCategories != null && expenseCategories!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  addCategory(String cat) async {
    response = await HttpService.addExpenseCategory(cat);
    if (response != null && response!.status == true) {
      Common.toastMessaage(response!.message, Colors.green);
      getList();
    } else {
      Common.toastMessaage(response!.message, Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  updateCategory(String catId, String cat) async {
    response = await HttpService.updateExpenseCategory(cat, catId);
    if (response != null && response!.status == true) {
      Common.toastMessaage(response!.message, Colors.green);
      getList();
    } else {
      Common.toastMessaage(response!.message, Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  deleteCategory(String catId) async {
    response = await HttpService.deleteExpenseCategory(catId);
    if (response != null && response!.status == true) {
      Common.toastMessaage(response!.message, Colors.green);
      getList();
    } else {
      Common.toastMessaage(response!.message, Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                              "Expense Categories",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        IconButton(
                            color: Colors.white,
                            onPressed: () {
                              categoryBottomsheet("Add Category", "", "");
                            },
                            icon: const Icon(Icons.add))
                      ]),
                ),
              ),
            ),
            body: isLoading == true
                ? LinearProgressIndicator(
                    color: Colors.blue.shade900,
                  )
                : expenseCategories == null
                    ? const Center(
                        child: Text(
                          "Something went wrong !",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenseCategories!.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            shape: const Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              expenseCategories!.data[index].typeName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            // subtitle:  Text(
                            //   "Createdby: ${expenseList!.data[index].typeName}",
                            //   style: TextStyle(
                            //       color: Colors.teal,
                            //       fontWeight: FontWeight.normal),
                            // ),
                            trailing: SizedBox(
                              width: MediaQuery.of(context).size.width * .17,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      categoryBottomsheet(
                                          "Edit Category",
                                          expenseCategories!
                                              .data[index].typeName,
                                          expenseCategories!.data[index].typeId
                                              .toString());
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      deleteDialog(
                                          context,
                                          expenseCategories!.data[index].typeId
                                              .toString());
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  categoryBottomsheet(String title, String cat, String catId) {
    category.text = cat;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
                key: formKey,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == "") {
                            return "Enter category name";
                          }
                          return null;
                        },
                        controller: category,
                        decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon:
                                Icon(Icons.category, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3375e0),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: RawMaterialButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (title == "Add Category") {
                                addCategory(category.text);
                              } else {
                                updateCategory(catId, category.text);
                              }
                            }
                          },
                          child: const Text("Submit",
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  Future<dynamic> deleteDialog(BuildContext context, String catId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    deleteCategory(catId);
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }
}
