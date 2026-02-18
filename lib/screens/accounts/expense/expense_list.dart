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
import 'package:login2/screens/accounts/expense/pendingExpenseHistory.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/AddPendingExpenseForm.dart';
import 'package:login2/widgets/expenseListFilterWidget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ExpenseList extends StatefulWidget {
  final String? fdate;
  final String? tdate;
  final String? status;
  final String? catId;
  final String? catName;

  const ExpenseList({
    super.key,
    this.fdate,
    this.tdate,
    this.status,
    this.catId,
    this.catName,
  });

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  ExpenseListModel? expenseList;
  ExpenseMasterData? expenseMasterData;
  CommonResponse? deleteResponse;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final TextEditingController search = TextEditingController();

  int page = 1;
  int pageSize = 20;
  List<Expense> items = [];
  String categoryId = "";
  String categoryName = "Tap to select";
  String staffId = "";
  String staffName = "Tap to select";
  String fDate = "Tap to select";
  String tDate = "Tap to select";
  String headName = "Tap to select";
  String headId = "";
  int add = 1;
  List<StaffList> staffs = [];
  List<StaffList> filteredStaffs = [];
  bool result = true;
  List<ExpenseType> categories = [];
  List<ExpenseType> filteredCategories = [];
  List<AccountHead> allAccountHeads = [];
  List<AccountHead> filteredHeads = [];
  bool _isDetailedView = true;
  Map<String, dynamic> currentFilters = {};
  bool _ignoreWidgetDates = false;

  bool get isFiltered =>
      currentFilters.isNotEmpty ||
      (!_ignoreWidgetDates &&
          (widget.fdate != null ||
              widget.tdate != null ||
              widget.catId != null));

  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);

    if (widget.fdate != null && widget.tdate != null) {
      currentFilters['created_from'] = widget.fdate;
      currentFilters['created_to'] = widget.tdate;
      fDate = widget.fdate!;
      tDate = widget.tdate!;
    }
    if (widget.catId != null) {
      currentFilters['category_ids'] = [widget.catId!];
      categoryId = widget.catId!;
      categoryName = widget.catName ?? "Tap to select";
    }

    getData();
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_onLoadMore);
    super.dispose();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getList();
      add++;
    }
  }

  void _clearFilters() {
    setState(() {
      currentFilters.clear();
      fDate = "Tap to select";
      tDate = "Tap to select";
      categoryId = "";
      categoryName = "Tap to select";
      headId = "";
      headName = "Tap to select";
      staffId = "";
      staffName = "Tap to select";
      search.clear();
      page = 1;
      items.clear();
      _ignoreWidgetDates = true;
    });
    getList();
  }

  void _showFilters() {
    setState(() {
      _ignoreWidgetDates = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ExpenseListFilterWidget(
                  pageId: 2,
                  initialFilters: currentFilters,
                  onApplyFilters: (filters) {
                    setState(() {
                      currentFilters = Map.from(filters);
                      if (filters['created_from'] != null) {
                        fDate = DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(filters['created_from']));
                      } else {
                        fDate = "Tap to select";
                      }
                      if (filters['created_to'] != null) {
                        tDate = DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(filters['created_to']));
                      } else {
                        tDate = "Tap to select";
                      }
                      if (filters['category_ids']?.isNotEmpty ?? false) {
                        categoryId = filters['category_ids'].first;
                        var category = categories.firstWhere(
                          (c) => c.expCatId == categoryId,
                          orElse: () => ExpenseType(
                              expCatId: "", expCatName: "Tap to select"),
                        );
                        categoryName = category.expCatName;
                      } else {
                        categoryId = "";
                        categoryName = "Tap to select";
                      }
                      page = 1;
                      items.clear();
                    });
                    getList();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getData() async {
    categoryId = widget.catId ?? "";
    categoryName = widget.catName ?? "Tap to select";

    final connectivityResult = await Connectivity().checkConnectivity();
    // setState(() {
    //   result = connectivityResult == ConnectivityResult.mobile ||
    //       connectivityResult == ConnectivityResult.wifi;
    // });
    setState(() {
      result = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    });

    if (result) {
      await Future.wait([getList(), getDetails()]);
    }
  }

  Future<void> getList() async {
    String? fDateFilter;
    String? tDateFilter;

    if (!_ignoreWidgetDates) {
      fDateFilter = currentFilters['created_from'] ?? widget.fdate;
      tDateFilter = currentFilters['created_to'] ?? widget.tdate;
    }

    List<String> categoryIds = currentFilters['category_ids'] ?? [];
    List<String> fromHeadIds = currentFilters['from_account_head_ids'] ?? [];
    List<String> toHeadIds = currentFilters['to_account_head_ids'] ?? [];
    List<String> staffIds = currentFilters['created_by_ids'] ?? [];

    String categoryId = categoryIds.join(',');
    String headId = [...fromHeadIds, ...toHeadIds].join(',');
    String staffId = staffIds.join(',');
    String fromHeadIdStr = fromHeadIds.join(',');
    String toHeadIdStr = toHeadIds.join(',');

    try {
      ExpenseListModel? newData = await HttpService.expenseList(
        fDateFilter,
        tDateFilter,
        page,
        pageSize,
        categoryId,
        headId,
        staffId,
        fromHeadIdStr,
        toHeadIdStr,
        search.text,
      );

      if (newData != null && newData.status == true) {
        setState(() {
          if (page == 1) {
            items = newData.data.lists;
          } else {
            items.addAll(newData.data.lists);
          }
          expenseList = newData;
          page++;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> getDetails() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      setState(() {
        categories = expenseMasterData!.data.expenseType;
        filteredCategories = List.from(categories);
        staffs = expenseMasterData!.data.staffList;
        filteredStaffs = List.from(staffs);
        allAccountHeads = expenseMasterData!.data.accountHead;
        filteredHeads = List.from(allAccountHeads);
      });
    }
  }

  Future<void> deleteExpense(String expId) async {
    deleteResponse = await HttpService.deleteExpense(expId);
    if (deleteResponse != null && deleteResponse!.status == true) {
      Common.toastMessaage(deleteResponse!.message, Colors.green);
      setState(() {
        add = 1;
        page = 1;
        items.clear();
      });
      getList();
    } else {
      Common.toastMessaage(
          deleteResponse?.message ?? "Failed to delete", Colors.red);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return result
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
                    colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
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
                            "Expense",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isDetailedView ? Icons.list : Icons.filter_list,
                              color: Colors.white,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _isDetailedView = !_isDetailedView;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.filter_alt,
                                color: Colors.white),
                            onPressed: _showFilters,
                          ),
                          // PopupMenuButton<String>(
                          //   icon: const Icon(Icons.more_vert,
                          //       color: Colors.white),
                          //   iconSize: 22,
                          //   padding: EdgeInsets.zero,
                          //   constraints: const BoxConstraints(),
                          //   color: Colors.white,
                          //   onSelected: (value) {
                          //     if (value == "0") {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => const AddExpense()),
                          //       ).then((_) {
                          //         setState(() {
                          //           page = 1;
                          //           add = 1;
                          //           items.clear();
                          //         });
                          //         getList();
                          //       });
                          //     } else if (value == "1") {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) =>
                          //                 const ExpenseCategories()),
                          //       ).then((_) => getDetails());
                          //     }
                          //   },
                          //   itemBuilder: (context) => const [
                          //     PopupMenuItem(
                          //         value: '0', child: Text('Add Expense')),
                          //     PopupMenuItem(
                          //         value: '1', child: Text('Expense Category')),
                          //         PopupMenuItem(
                          //         value: '2', child: Text('Add Expense History')),
                          //   ],
                          // ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.white,
                            onSelected: (value) {
                              if (value == "0") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddExpense()),
                                ).then((_) {
                                  setState(() {
                                    page = 1;
                                    add = 1;
                                    items.clear();
                                  });
                                  getList();
                                });
                              } else if (value == "1") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ExpenseCategories()),
                                ).then((_) => getDetails());
                              } else if (value == "2") {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SizedBox(
                                        width: 400,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: AddPendingExpenseForm(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else if (value == "3") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PendingExpenseHistoryPage(),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: '0', child: Text('Add Expense')),
                              PopupMenuItem(
                                  value: '1', child: Text('Expense Category')),
                              // PopupMenuItem(
                              //     value: '2',
                              //     child: Text('Add Pending History')),
                              PopupMenuItem(
                                  value: '3', child: Text('Pending Expense')),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (isFiltered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.orange.shade50,
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Filters applied',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              add = 1;
                              page = 1;
                              items.clear();
                            });
                            await getList();
                          },
                          child: ScrollablePositionedList.builder(
                            padding: const EdgeInsets.only(bottom: 60),
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            itemCount: items.length +
                                (items.length + 20 == page * pageSize ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == items.length) {
                                return buildLoaderListItem();
                              }
                              return _buildListItem(index);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 50.0,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: expenseList != null
                                  ? Text(
                                      'Total Expense : ${expenseList!.data.totalAmount}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpense()),
                ).then((_) {
                  setState(() {
                    page = 1;
                    add = 1;
                    items.clear();
                  });
                  getList();
                });
              },
              child: const Icon(Icons.add),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: getData,
                    child: Container(
                      width: 120,
                      height: 35,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildListItem(int index) {
    final item = items[index];
    return _isDetailedView
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseHistory(
                    expId: item.cmpnyExId,
                    fromAccPerson: item.fromAccountPerson,
                    toAccPerson: item.toAccountPerson,
                    data: item,
                  ),
                ),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(blurRadius: 0.95, color: Colors.black12)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.expCatName,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${DateFormat('dd-MM-yyyy').format(item.trnDate)}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.fromAccountPerson} ➜ ${item.toAccountPerson}",
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee, size: 16),
                              Text(
                                " ${item.amount}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (item.isVerified == "N") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditExpense(data: item),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        page = 1;
                                        add = 1;
                                        items.clear();
                                      });
                                      getList();
                                    });
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Cannot Edit"),
                                          content: const Text(
                                              "This expense is already verified and cannot be edited."),
                                          actions: [
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.blue,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (item.isVerified == "N") {
                                    deleteDialog(context, item.cmpnyExId);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Cannot Edit"),
                                          content: const Text(
                                              "This expense is already verified and cannot be deleted."),
                                          actions: [
                                            TextButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.red,
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(
                bottom: 8.0, top: 8.0, left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseHistory(
                    expId: item.cmpnyExId,
                    fromAccPerson: item.fromAccountPerson,
                    toAccPerson: item.toAccountPerson,
                    data: item,
                  ),
                ),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 0.95, color: Colors.black12)
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
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
                        child: Text((index + 1).toString()),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .7,
                              child: Text(
                                item.expCatName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .7,
                              child: Text(
                                "Created by: ${item.staffName}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Date: ${DateFormat('dd-MM-yyyy').format(item.trnDate)}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text(
                                "${item.fromAccountPerson} ➜ ${item.toAccountPerson}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text(
                                "Remarks: ${item.remarks}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee, size: 20),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: Text(
                                    " ${item.amount} /-",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
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
                            onTap: () {
                              if (item.isVerified == "N") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditExpense(data: item),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    page = 1;
                                    add = 1;
                                    items.clear();
                                  });
                                  getList();
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Cannot Edit"),
                                      content: const Text(
                                          "This expense is already verified and cannot be edited."),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blue,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // GestureDetector(
                          //   // onTap: () => deleteDialog(context, item.cmpnyExId),

                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(2),
                          //       color: Colors.red,
                          //     ),
                          //     child: const Padding(
                          //       padding: EdgeInsets.all(5.0),
                          //       child: Icon(Icons.delete, color: Colors.white),
                          //     ),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () {
                              if (item.isVerified == "N") {
                                deleteDialog(context, item.cmpnyExId);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Cannot Edit"),
                                      content: const Text(
                                          "This expense is already verified and cannot be deleted."),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.red,
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget buildLoaderListItem() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> deleteDialog(BuildContext context, String expId) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please Confirm'),
        content: const Text('Are you sure to Delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteExpense(expId);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
