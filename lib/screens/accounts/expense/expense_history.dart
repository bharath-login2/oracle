import 'package:flutter/material.dart';
import 'package:login2/models/expense/exp_history.dart';
import 'package:login2/service/service.dart';

class ExpenseHistory extends StatefulWidget {
  String expId;
  ExpenseHistory({super.key, required this.expId});

  @override
  State<ExpenseHistory> createState() => _ExpenseHistoryState();
}

class _ExpenseHistoryState extends State<ExpenseHistory> {
  bool isLoading = true;
  ExpensehistoryModel? history;

  getList() async {
    setState(() {
      isLoading = true;
    });
    history = await HttpService.expenseHistory(widget.expId);
    if (history != null && history!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
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
                        "Expense History",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: isLoading == true
          ? LinearProgressIndicator(
              color: Colors.blue.shade900,
            )
          : history == null
              ? const Center(
                  child: Text(
                    "Something went wrong !",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,top: 16.0,bottom: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*.28,
                                  child: const Text(
                                    "Category: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                Text(
                                 history!.data.category,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*.28,
                                  child: const Text(
                                    "Amount: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                Text(
                                  history!.data.amount,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*.28,
                                  child: const Text(
                                    "Expense Date: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                 Text(
                                  history!.data.expenseDate,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        itemCount: history!.data.history.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                leading:  CircleAvatar(
                                    backgroundColor:index==0? Colors.teal:Colors.blue,
                                    child: Icon(
                                   index==0? Icons.receipt:  Icons.edit,
                                      color: Colors.white,
                                    )),
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 4, left: 8, right: 8),
                                  child: Text(
                                    history!.data.history[index].staffName,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16.0, top: 4, left: 8, right: 8),
                                  child: Text(
                                    history!.data.history[index].logData,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                trailing: Text(history!.data.history[index].createdAt),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
