import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/service/service.dart';

class Branches extends StatefulWidget {
  const Branches({super.key});

  @override
  State<Branches> createState() => _BranchesState();
}

class _BranchesState extends State<Branches> {
  BranchListModel? branches;
  CommonResponse? commonResponse;
  bool result = true;
  bool isLoading = true;
  final formKey = GlobalKey<FormState>();
  String token = "";
  final TextEditingController branchController = TextEditingController();

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
    token = await Common.getSharedPref("token");
    branches = await HttpService.getBranchList(token);
    if (branches != null && branches!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  addBranch(String branch) async {
    commonResponse = await HttpService.postBranch(branch);
    if (commonResponse != null && commonResponse!.status == true) {
      Common.toastMessaage(commonResponse!.message, Colors.green);
      getList();
    } else {
      Common.toastMessaage(commonResponse!.message, Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  updateBranch(String branchId, String branch) async {
    commonResponse = await HttpService.updateBranch(branch, branchId);
    if (commonResponse != null && commonResponse!.status == true) {
      Common.toastMessaage(commonResponse!.message, Colors.green);
      getList();
    } else {
      Common.toastMessaage(commonResponse!.message, Colors.red);
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
                              "Branches",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        IconButton(
                            color: Colors.white,
                            onPressed: () {
                              branchBottomsheet("Add Branch", "", "");
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
                : branches == null
                    ? const Center(
                        child: Text(
                          "Something went wrong !",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: branches!.data!.length,
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
                              branches!.data![index].branchName!,
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
                            trailing: InkWell(
                              onTap: () {
                                branchBottomsheet(
                                    "Edit Branch",
                                    branches!.data![index].branchName!,
                                    branches!.data![index].branchId.toString());
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.blue,
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

  branchBottomsheet(String title, String branch, String branchId) {
    branchController.text = branch;
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
                            return "Enter branch name";
                          }
                          return null;
                        },
                        controller: branchController,
                        decoration: const InputDecoration(
                            labelText: 'Branch *',
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
                              if (title == "Add Branch") {
                                addBranch(branchController.text);
                              } else {
                                updateBranch(branchId, branchController.text);
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
}
