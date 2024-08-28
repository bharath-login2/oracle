// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/screens/accounts/clients/invoiceList.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/accounts/expense/expense_list.dart';

class AccountsDashboard extends StatefulWidget {
  String token;

  AccountsDashboard({super.key, required this.token});
  @override
  State<AccountsDashboard> createState() => _AccountsDashboardState();
}

class _AccountsDashboardState extends State<AccountsDashboard> {
  List list = [
    "Expense",
    "Invoices",
    "Pending invoices",
    "Receipts",
  ];
  List colorList = [
    const Color(0xFFddd8f5),
    const Color(0xFFf0ebef),
    const Color(0xFFd7e9f4),
    const Color(0xFFf5e6d7),
    const Color(0xFFdbe4e8),
    const Color(0xFFf3d6d5),
    const Color(0xFFe0f0c8),
    const Color(0xFFf3e8d3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  ),
                  child: Column(
                    children: [
                      // Container(
                      //   height: MediaQuery.of(context).size.height * .2,
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12),
                      //       image: DecorationImage(
                      //           image: AssetImage("assets/main/logo.png"))),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Account Management",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 5.0,
                                color: Colors.grey,
                              ),
                            ]),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .95,
                        height: MediaQuery.of(context).size.height * .2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 3),
                            itemBuilder: (context, i) {
                              return InkWell(
                                onTap: () {
                                  if (list[i] == "Expense") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ExpenseList(),
                                        ));
                                  } else if (list[i] == "Invoices") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InvoiceList(
                                              widget.token.toString())),
                                    );
                                  } else if (list[i] == "Pending invoices") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PendingInvoice(
                                              widget.token.toString())),
                                    );
                                  } else if (list[i] == "Receipts") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReceiptList(
                                              widget.token.toString())),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf0ebef),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      list[i],
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                height: MediaQuery.of(context).size.height * .67,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.5),
                  children: [
                    gridItem(
                        "BANK ACCOUNT", "1000.00", Colors.green, colorList[0]),
                    gridItem(
                        "PENDING EXPENSE", "1000.00", Colors.red, colorList[1]),
                    gridItem(
                        "TODAYS INCOME", "1000.00", Colors.black, colorList[2]),
                    gridItem("TODAYS EXPENSE", "1000.00", Colors.black,
                        colorList[3]),
                    gridItem("THIS MONTH INCOME", "1000.00", Colors.black,
                        colorList[4]),
                    gridItem("THIS MONTH EXPENSE", "1000.00", Colors.black,
                        colorList[5]),
                    gridItem("PENDING INVOICE", "1000.00", Colors.black,
                        colorList[6]),
                    gridItem("ADVANCE AMOUNT", "1000.00", Colors.green,
                        colorList[7]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 25.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0ebef),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Income",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            Row(
                              children: [
                                Text(
                                  "14-05-2000",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                ),
                                Text(
                                  "14-05-2020",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      progressItem("Customer", "350.00", 35),
                      progressItem("Renewal", "600.00", 60),
                      progressItem("Installment", "50.00", 5),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 25.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0ebef),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Expense",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            Row(
                              children: [
                                Text(
                                  "14-05-2000",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                ),
                                Text(
                                  "14-05-2020",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      progressItem("Staff", "350.00", 35),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding progressItem(String name, String amount, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26.0, left: 20.0, right: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                amount,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.grey,
            value: value / 100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Container gridItem(
      String name, String value, Color amountColor, Color backGround) {
    return Container(
      decoration: BoxDecoration(
        color: backGround,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 13),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: TextStyle(
                color: amountColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
