import 'package:flutter/material.dart';
import 'package:login2/models/expense/exp_history.dart';
import 'package:login2/models/expense/exp_list.dart';
import 'package:login2/screens/accounts/expense/edit_expense.dart';
import 'package:login2/service/service.dart';

class ExpenseHistory extends StatefulWidget {
  String expId;
  String fromAccPerson;
  String toAccPerson;
  final Expense data;

  ExpenseHistory(
      {super.key,
      required this.expId,
      required this.fromAccPerson,
      required this.toAccPerson,
      required this.data});

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
    print("Expense title: ${widget.data}");
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Back icon and Title
                Row(
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
                      "Expense History",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditExpense(data: widget.data),
                          ),
                        );

                        getList();
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () {
                        deleteDialog(context, widget.expId);
                      },
                    ),
                  ],
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
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 16.0, bottom: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .28,
                                  child: const Text(
                                    "Category: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                Text(
                                  history!.data.category,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .28,
                                  child: const Text(
                                    "Amount: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                Text(
                                  history!.data.amount,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .28,
                                  child: const Text(
                                    "Expense Date: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                Text(
                                  history!.data.expenseDate,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .28,
                                  child: const Text(
                                    "Remark: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                Text(
                                  history!.data.remark,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
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
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                // leading:  ,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                              backgroundColor: index == 0
                                                  ? Colors.teal
                                                  : Colors.blue,
                                              child: Icon(
                                                index == 0
                                                    ? Icons.receipt
                                                    : Icons.edit,
                                                color: Colors.white,
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Text(
                                              history!.data.history[index]
                                                  .staffName,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          history!
                                              .data.history[index].createdTime,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          history!
                                              .data.history[index].createdAt,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, top: 2, left: 8, right: 8),
                                  child: Text(
                                    history!.data.history[index].logData,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                // trailing: ,
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
  void deleteDialog(BuildContext context, String expId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete this expense?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); 
            bool deleted = await HttpService.deleteExpense(expId);
            if (deleted && mounted) {
              Navigator.pop(context); 
              
            }
          },
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}

}
