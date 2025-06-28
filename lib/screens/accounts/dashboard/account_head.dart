import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/accountHeadDialog.dart';
import '../../../models/expense/account_head_model.dart';

class AccountHead extends StatefulWidget {
  const AccountHead({super.key});

  @override
  State<AccountHead> createState() => _AccountHeadState();
}

class _AccountHeadState extends State<AccountHead> {
  AccountHeadModel? accountList;

  bool result = true;
  bool isLoading = true;
  List<ListElement> filteredExpenses = [];
  final formKey = GlobalKey<FormState>();
  final TextEditingController category = TextEditingController();
  final TextEditingController search = TextEditingController();

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
    accountList = await HttpService.getAccountHead();
    if (accountList != null && accountList!.status == true) {
      filteredExpenses.addAll(accountList!.data.lists);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  filterExpense(String value) {
    setState(() {
      filteredExpenses = accountList!.data.lists
          .where((item) =>
              item.accountName.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
                    colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                      right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      const Text(
                        "Account Head",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const Spacer(), 
                      InkWell(
                        onTap: () {
                            showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const AddAccountHeadDialog(),
                                  );
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: isLoading == true
                ? LinearProgressIndicator(
                    color: Colors.blue.shade900,
                  )
                : accountList == null
                    ? noResultWidget(context, "No Result Found")
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16),
                              child: TextField(
                                controller: search,
                                autocorrect: false,
                                keyboardType: TextInputType.visiblePassword,
                                autofocus: true,
                                onChanged: (value) {
                                  filterExpense(value);
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  hintText: 'Search',
                                  prefixIcon: const Icon(Icons.search),
                                  fillColor: ColorConstant.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            filteredExpenses.isEmpty
                                ? noResultWidget(context, "No Result Found")
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredExpenses.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BankAccount(
                                                  accId: filteredExpenses[index]
                                                      .accountId,
                                                  accName:
                                                      filteredExpenses[index]
                                                          .accountName,
                                                ),
                                              ));
                                        },
                                        shape: const Border(
                                          bottom:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        leading: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey.shade300,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                                color: Colors.blue.shade900,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(
                                          filteredExpenses[index].accountName,
                                          style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "Balance: ${filteredExpenses[index].pendingAmount}",
                                          style: const TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
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
}
