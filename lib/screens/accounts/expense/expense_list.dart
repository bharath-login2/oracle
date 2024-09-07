// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/exp_list.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/accounts/expense/add_expense.dart';
import 'package:login2/screens/accounts/expense/edit_expense.dart';
import 'package:login2/screens/accounts/expense/expense_categories.dart';
import 'package:login2/screens/accounts/expense/expense_history.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../renewal_mannagement/renewal_list.dart';

class ExpenseList extends StatefulWidget {
  String? fdate;
  String? tdate;
  ExpenseList({super.key, this.fdate, this.tdate});
  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  ExpenseListModel? expenseList;
  ExpenseMasterData? expenseMasterData;
  ExpensePostModel? deleteResponse;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int page = 1;
  int pageSize = 20;
  List<Expense> items = [];
  String categoryId = "";
  String categoryName = "Tap to select";
  String staffId = "";
  String staffName = "Tap to select";
  String fDate = "Tap to select";
  String tDate = "Tap to select";
  int add = 1;
  List<StaffList> staffs = [];
  List<StaffList> filteredStaffs = [];
  bool result = true;
  List<ExpenseType> categories = [];
  List<ExpenseType> filteredCategories = [];
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
  }

  getData() async {
    if (widget.fdate != null && widget.tdate != null) {
      fDate = widget.fdate!;
      tDate = widget.tdate!;
    }
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
    getDetails();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getList();
      add++;
    }
  }

  getList() async {
    expenseList = await HttpService.expenseList(
        fDate, tDate, page, pageSize, categoryId, staffId);
    if (expenseList != null && expenseList!.status == true) {
      items.addAll(expenseList!.data);
      page++;
      setState(() {});
    } else {
      setState(() {});
    }
  }

  getDetails() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      filteredCategories.clear();
      filteredStaffs.clear();
      categories = expenseMasterData!.data.expenseType;
      filteredCategories.addAll(categories);
      staffs = expenseMasterData!.data.staffList;
      filteredStaffs.addAll(staffs);
      setState(() {});
    } else {
      setState(() {});
    }
  }

  deleteExpense(String expId) async {
    deleteResponse = await HttpService.deleteExpense(expId);
    if (deleteResponse != null && deleteResponse!.status == true) {
      Common.toastMessaage(deleteResponse!.message, Colors.green);
      add = 1;
      page = 1;
      items.clear();
      getList();
    } else {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
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
                              "Expense",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          iconColor: Colors.white,
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == "0") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddExpense(),
                                  )).then((_) {
                                page = 1;
                                add = 1;
                                items.clear();
                                getList();
                              });
                            } else if (value == "1") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExpenseCategories(),
                                  )).then((_) {
                                getDetails();
                              });
                            } else if (value == "2") {
                              filtrationSheet(context);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: '0',
                                child: Text('Add Expense'),
                              ),
                              const PopupMenuItem<String>(
                                value: '1',
                                child: Text('Expense Category'),
                              ),
                              const PopupMenuItem<String>(
                                value: '2',
                                child: Text('Filter'),
                              ),
                            ];
                          },
                        ),
                      ]),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                add = 1;
                page = 1;
                items.clear();
                getList();
              },
              child: ScrollablePositionedList.builder(
                  shrinkWrap: true,
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemCount: items.length +
                      (items.length + 20 == page * pageSize ? 1 : 0),
                  initialScrollIndex: 0,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return buildLoaderListItem();
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, top: 8.0, left: 8.0, right: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 0.95,
                                  color: Colors.black12,
                                )
                              ],
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(),
                                    )),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .7,
                                        child: Text(
                                          "${items[index].fromAccountPerson} ➜ ${items[index].toAccountPerson}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .7,
                                        child: Text(
                                          "Created by: ${items[index].staffName}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Date: ${DateFormat('dd-MM-yyyy').format(items[index].trnDate)}",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text(
                                          "Category: ${items[index].expCatName}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text(
                                          "Remarks: ${items[index].remarks}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.currency_rupee,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .45,
                                            child: Text(
                                              " ${items[index].amount} /-",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditExpense(
                                                data: items[index],
                                              ),
                                            )).then((_) {
                                          page = 1;
                                          add = 1;
                                          items.clear();
                                          getList();
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.blue),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.edit,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        deleteDialog(
                                            context, items[index].cmpnyExId);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.red),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ExpenseHistory(
                                                expId: items[index].cmpnyExId,
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.teal),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(
                                            Icons.history,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExpense(),
                    )).then((_) {
                  page = 1;
                  add = 1;
                  items.clear();
                  getList();
                });
              },
              child: const Icon(Icons.add),
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

  Future<dynamic> filtrationSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Material(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Filtration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("From Date"),
                                GestureDetector(
                                  onTap: () async {
                                    final selctedDatetimetemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(DateTime.now().year,
                                          DateTime.now().month, 1),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    fDate = DateFormat('dd-MM-yyyy')
                                        .format(selctedDatetimetemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            fDate,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("To Date"),
                                GestureDetector(
                                  onTap: () async {
                                    final toDateSelectTemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    tDate = DateFormat('dd-MM-yyyy')
                                        .format(toDateSelectTemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            tDate,
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Staff"),
                            GestureDetector(
                              onTap: () {
                                staffDialog(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                            staffName,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ],
                                  ),
                                )),
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                            categoryName,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ],
                                  ),
                                )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            items.clear();
                            page = 1;
                            add = 1;
                            await getList();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xff2590cf)),
                            child: const Center(
                              child: Text("Filter",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<dynamic> staffDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: search,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredStaffs = staffs
                            .where((item) => item.staffName
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
                    itemCount: filteredStaffs.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            staffName = filteredStaffs[index].staffName;
                            staffId = filteredStaffs[index].userId;
                            search.clear();
                            filteredStaffs.clear();
                            filteredStaffs.addAll(staffs);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaffs[index].staffName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    search.clear();
                    filteredStaffs.clear();
                    filteredStaffs.addAll(staffs);
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
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: search,
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
                            search.clear();
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
                    search.clear();
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

  Future<dynamic> deleteDialog(BuildContext context, String expId) {
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
                    deleteExpense(expId);
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
