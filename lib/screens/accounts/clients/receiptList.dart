import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/customerListModel.dart' as customer_list;
import 'package:login2/models/clients/receiptListAccountsModel.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/addInvoiceUpdated.dart';
import 'package:login2/screens/accounts/clients/editRecipt.dart';
import 'package:login2/screens/accounts/clients/viewReceipt.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/widgets/receiptListFilterWidget.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/common.dart';
import '../../../models/clients/receiptDeleteModel.dart';
import '../../../models/clients/receiptListModel.dart';
import '../../../service/service.dart';
import '../../leadManagement/webview.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart'
    as invoice_search;
import 'clientDetails.dart';

// ignore: must_be_immutable
class ReceiptList extends StatefulWidget {
  String token;
  String? fdate;
  String? tdate;
  String? type;
  ReceiptList(this.token, {super.key, this.fdate, this.tdate, this.type});

  @override
  State<ReceiptList> createState() => _ReceiptListState();
}

class _ReceiptListState extends State<ReceiptList> {
  String fDate = "From Date";
  String tDate = "To Date";
  String type = "";
  List<ListElement> items = [];
  ReceiptListModel? receiptList;
  ExpenseMasterData? expenseMasterData;
  ExpenseMasterData? expenseHeadData;
  bool result = true;
  TextEditingController search = TextEditingController();
  int page = 1;
  int add = 1;
  int pageSize = 15;
  bool _isDetailedView = true;
  String headName = "Select Head";
  bool _showFloatingOptions = false;
  Offset _floatingButtonPosition = Offset(16, 16);
  bool get isFiltered =>
      currentFilters.isNotEmpty ||
      (!_ignoreWidgetDates && (widget.fdate != null || widget.tdate != null));
  bool _ignoreWidgetDates = false;
  String headId = "";
  List<AccountHead> allAccountHeads = [];
  List<AccountHead> filteredHeads = [];
  Map<String, dynamic> currentFilters = {};
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final bool _useInitialDates = true;
  bool _showAccountTotals = false;
  List<ReceiptAccountData> accountTotals = [];
  bool _loadingAccountTotals = false;
  List<customer_list.Customer> customers = [];
  List<customer_list.Customer> filteredCustomers = [];
  String customerId = "";
  String customerName = "Choose Customer";
  List<invoice_search.Staff> staffs = [];
  List<invoice_search.Staff> filteredStaffs = [];
  String staffId = "";
  String staffName = "Choose Staff";
  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);

    type = widget.type ?? "0";
    if (widget.fdate != null && widget.tdate != null) {
      try {
        final fromDate = DateFormat('dd-MM-yyyy').parse(widget.fdate!);
        final toDate = DateFormat('dd-MM-yyyy').parse(widget.tdate!);
        fDate = widget.fdate!;
        tDate = widget.tdate!;
        currentFilters['created_from'] = fromDate.toIso8601String();
        currentFilters['created_to'] = toDate.toIso8601String();
      } catch (e) {
        print("Error parsing initial dates: $e");
      }
    }

    getData();
    getDetails();
    getList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFloatingButtonPosition();
    });
  }

  void _initializeFloatingButtonPosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _floatingButtonPosition = Offset(
        screenSize.width - 130,
        screenSize.height - 300,
      );
    });
  }

  void _onLoadMore() {
    if (items.length + 15 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index ==
            items.length - 1 &&
        page > add) {
      getList();
      add++;
    }
  }

  void _updateFloatingButtonPosition(Offset newPosition) {
    setState(() {
      _floatingButtonPosition = newPosition;
    });
  }

  void _initializeFilters(Map<String, dynamic>? filters) {
    if (filters == null) return;
    setState(() {
      currentFilters = Map.from(filters);
      if (filters['created_from'] != null) {
        try {
          final date = DateFormat('dd-MM-yyyy').parse(filters['created_from']);
          fDate = DateFormat('dd-MM-yyyy').format(date);
          currentFilters['created_from'] = date.toIso8601String();
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
      if (filters['created_to'] != null) {
        try {
          final date = DateFormat('dd-MM-yyyy').parse(filters['created_to']);
          tDate = DateFormat('dd-MM-yyyy').format(date);
          currentFilters['created_to'] = date.toIso8601String();
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    });
  }

  void _clearFilters() {
    setState(() {
      currentFilters.clear();
      fDate = "From Date";
      tDate = "To Date";
      headId = "";
      headName = "Select Head";
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

    // Helper function to validate and parse dates
    DateTime? parseAndValidateDate(String? dateString) {
      if (dateString == null) return null;
      try {
        final date = DateTime.parse(dateString);
        // Check if year is reasonable (between 2000 and 2100)
        if (date.year < 2000 || date.year > 2100) return null;
        return date;
      } catch (e) {
        return null;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final createdFrom =
                parseAndValidateDate(currentFilters['created_from']);
            final createdTo =
                parseAndValidateDate(currentFilters['created_to']);
            final fromDate = !_ignoreWidgetDates && createdFrom == null
                ? widget.fdate
                : createdFrom?.toIso8601String();
            final toDate = !_ignoreWidgetDates && createdTo == null
                ? widget.tdate
                : createdTo?.toIso8601String();

            final initialFilters = {
              if (fromDate != null) 'created_from': fromDate,
              if (toDate != null) 'created_to': toDate,
              ...currentFilters
                ..remove('created_from')
                ..remove('created_to'),
            };

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ReceiptListFilterWidget(
                  pageId: 2,
                  initialFilters: initialFilters,
                  onApplyFilters: (filters) {
                    setState(() {
                      currentFilters = Map.from(filters);
                      final from =
                          parseAndValidateDate(filters['created_from']);
                      final to = parseAndValidateDate(filters['created_to']);

                      fDate = from != null
                          ? DateFormat('dd-MM-yyyy').format(from)
                          : "From Date";
                      tDate = to != null
                          ? DateFormat('dd-MM-yyyy').format(to)
                          : "To Date";

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

  getDetails() async {
    expenseMasterData = await HttpService.expenseMasterData();
    if (expenseMasterData != null && expenseMasterData!.status == true) {
      allAccountHeads = expenseMasterData!.data.accountHead;
      filteredHeads.addAll(allAccountHeads);
      setState(() {});
    } else {
      setState(() {});
    }
  }

  getData() async {
    type = widget.type ?? "0";
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
    getCustomerList();
  }

  getCustomerList() async {
    try {
      customer_list.CustomerListModel? customerData =
          await HttpService.customerList(widget.token);
      if (customerData != null && customerData.status == true) {
        setState(() {
          customers = customerData.data ?? [];
          filteredCustomers = List.from(customers);
        });
      }
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  getList() async {
    String? fDateFilter;
    String? tDateFilter;

    if (!_ignoreWidgetDates) {
      fDateFilter = currentFilters['created_from'] ?? widget.fdate;
      tDateFilter = currentFilters['created_to'] ?? widget.tdate;
    } else {
      fDateFilter = currentFilters['created_from'];
      tDateFilter = currentFilters['created_to'];
    }

    List<String>? headIds = currentFilters['account_head_ids'];
    String headId =
        headIds != null && headIds.isNotEmpty ? headIds.join(',') : '';
    try {
      ReceiptListModel? newData = await HttpService.receptList(widget.token,
          fDateFilter, tDateFilter, page, pageSize, headId, search.text, type);
      _fetchAccountTotals(fDateFilter, tDateFilter, headId, search.text, type);
      if (newData != null) {
        setState(() {
          if (page == 1) {
            items = newData.data.lists;
          } else {
            items.addAll(newData.data.lists);
          }
          receiptList = newData;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _fetchAccountTotals(String? fDateFilter, String? tDateFilter,
      String headId, String searchKey, String type) async {
    setState(() {
      _loadingAccountTotals = true;
    });

    try {
      ReceiptListAccountsModel? accountData =
          await HttpService.receptListAccounts(
        widget.token,
        fDateFilter ?? "",
        tDateFilter ?? "",
        1,
        100,
        headId,
        searchKey,
        type,
      );

      if (accountData != null && accountData.status == true) {
        setState(() {
          accountTotals = accountData.data ?? [];
        });
      }
    } catch (e) {
      print("Error loading account totals: $e");
    } finally {
      setState(() {
        _loadingAccountTotals = false;
      });
    }
  }

  // getList() async {
  //   String? fDateFilter = currentFilters['created_from'];
  //   String? tDateFilter = currentFilters['created_to'];
  //   List<String>? headIds = currentFilters['account_head_ids'];
  //   if (fDateFilter == null && widget.fdate != null) {
  //     fDateFilter = widget.fdate;
  //   }
  //   if (tDateFilter == null && widget.tdate != null) {
  //     tDateFilter = widget.tdate;
  //   }
  //   String headId =
  //       headIds != null && headIds.isNotEmpty ? headIds.join(',') : '';
  //   try {
  //     ReceiptListModel? newData = await HttpService.receptList(
  //         widget.token,
  //         fDateFilter ?? "From Date",
  //         tDateFilter ?? "To Date",
  //         page,
  //         pageSize,
  //         headId,
  //         search.text,
  //         type);
  //     if (newData != null) {
  //       setState(() {
  //         if (page == 1) {
  //           items = newData.data.lists;
  //         } else {
  //           items.addAll(newData.data.lists);
  //         }
  //         receiptList = newData;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error loading data: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            'Receipt List',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                            ),
                            onPressed: _showFilters,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          IconButton(
                            icon: Icon(
                              _isDetailedView ? Icons.list : Icons.filter_list,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isDetailedView = !_isDetailedView;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: receiptList != null
                ? Column(
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
                          alignment: Alignment.bottomCenter,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.97,
                                      child: TextFormField(
                                        controller: search,
                                        onChanged: (val) {
                                          setState(() {
                                            page = 1;
                                            items.clear();
                                            getList();
                                          });
                                        },
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: 'Search by Customer Name',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          prefixIcon: const Icon(Icons.search,
                                              color: Colors.grey),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 12),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12, top: 5, bottom: 0),
                                    child: receiptList!.data.lists.isNotEmpty
                                        ? SizedBox(
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height *
                                            //     .76,
                                            child: ScrollablePositionedList
                                                .builder(
                                              padding:
                                                  EdgeInsets.only(bottom: 20),
                                              shrinkWrap: true,
                                              itemScrollController:
                                                  itemScrollController,
                                              itemPositionsListener:
                                                  itemPositionsListener,
                                              itemCount: items.length +
                                                  (items.length + 15 ==
                                                          page * pageSize
                                                      ? 1
                                                      : 0),
                                              initialScrollIndex: 0,
                                              itemBuilder: (context, index) {
                                                if (index == items.length) {
                                                  return buildLoaderListItem();
                                                } else {
                                                  if (_isDetailedView) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ViewReceipt(
                                                                        widget
                                                                            .token,
                                                                        items[index]
                                                                            .id
                                                                            .toString(),
                                                                        items[index]
                                                                            .clientId
                                                                            .toString(),
                                                                        items[index]
                                                                            .receiptNumber
                                                                            .toString(),
                                                                      )),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius:
                                                                    0.5,
                                                                blurRadius: 1,
                                                                offset:
                                                                    const Offset(
                                                                        1, 1),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors.white,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        10.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => ClientDetails(
                                                                                      widget.token,
                                                                                      items[index].clientId.toString(),
                                                                                    )),
                                                                          ).then(
                                                                              (_) {
                                                                            items.clear();
                                                                            page =
                                                                                1;
                                                                            add =
                                                                                1;
                                                                            getData();
                                                                          });
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          items[index]
                                                                              .customerName
                                                                              .toString(),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Row(
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: const Color(0xffe6fbec),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              items[index].recieptAmount.toString(),
                                                                              style: const TextStyle(
                                                                                color: Colors.green,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          PopupMenuButton<
                                                                              String>(
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            onSelected:
                                                                                (value) {
                                                                              if (value == 'print') {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => ViewReceipt(
                                                                                            widget.token,
                                                                                            items[index].id.toString(),
                                                                                            items[index].clientId.toString(),
                                                                                            items[index].receiptNumber.toString(),
                                                                                          )),
                                                                                );
                                                                              } else if (value == 'edit') {
                                                                                if (items[index].isVerified == "N") {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => EditReceipt(
                                                                                        widget.token,
                                                                                        items[index].id.toString(),
                                                                                      ),
                                                                                    ),
                                                                                  ).then((_) {
                                                                                    items.clear();
                                                                                    page = 1;
                                                                                    add = 1;
                                                                                    getData();
                                                                                  });
                                                                                } else {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text("Cannot Edit"),
                                                                                        content: const Text("This receipt is already verified and cannot be edited."),
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
                                                                              } else if (value == 'delete') {
                                                                                if (items[index].isVerified == "N") {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Please Confirm'),
                                                                                        content: const Text('Are you sure to Delete?'),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.pop(context),
                                                                                            child: const Text('No'),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () async {
                                                                                              Common.showProgressDialog(context, "Loading..");
                                                                                              ReceiptDeleteModel deleteReceipt = await HttpService.deleteReceipt(widget.token, items[index].id);
                                                                                              if (deleteReceipt.data == true) {
                                                                                                Common.toastMessaage(deleteReceipt.message, Colors.green);
                                                                                                if (context.mounted) {
                                                                                                  getData();
                                                                                                  Navigator.pop(context);
                                                                                                  Navigator.pop(context);
                                                                                                }
                                                                                              } else {
                                                                                                Common.toastMessaage(deleteReceipt.message, Colors.red);
                                                                                                if (context.mounted) {
                                                                                                  Navigator.pop(context);
                                                                                                }
                                                                                              }
                                                                                            },
                                                                                            child: const Text('Yes'),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                } else {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text("Cannot Edit"),
                                                                                        content: const Text("This receipt is already verified and cannot be edited."),
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
                                                                              }
                                                                            },
                                                                            itemBuilder: (context) =>
                                                                                [
                                                                              const PopupMenuItem(value: 'print', child: Text('Print')),
                                                                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                                                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                                            ],
                                                                            icon:
                                                                                const Icon(Icons.more_vert, size: 18),
                                                                          ),
                                                                        ]),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 16),
                                                                  const SizedBox(
                                                                      width: 6),
                                                                  Text(
                                                                      items[index]
                                                                          .receiptDate,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      )),
                                                                  const Spacer(),
                                                                  Flexible(
                                                                    child: Text(
                                                                      items[index]
                                                                          .collectedStaff,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .lock_clock,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 16),
                                                                  const SizedBox(
                                                                      width: 6),
                                                                  Text(
                                                                      items[index]
                                                                          .createdAt,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      )),
                                                                  const Spacer(),
                                                                  Flexible(
                                                                    child: Text(
                                                                      "Created By: ${items[index].collectedStaff}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 1,
                                                                blurRadius: 1,
                                                                offset:
                                                                    const Offset(
                                                                        1, 1),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color:
                                                                Colors.white),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(14.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => ClientDetails(widget.token, items[index].clientId.toString())),
                                                                        ).then(
                                                                            (_) {
                                                                          items
                                                                              .clear();
                                                                          page =
                                                                              1;
                                                                          add =
                                                                              1;
                                                                          getData();
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          items[index]
                                                                              .customerName
                                                                              .toString(),
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                2),
                                                                        color: const Color(
                                                                            0xffe6fbec)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                12,
                                                                            top:
                                                                                6,
                                                                            bottom:
                                                                                6),
                                                                        child: Text(
                                                                            items[index]
                                                                                .recieptAmount
                                                                                .toString(),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.green,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    child: Text(
                                                                      "Receipt No : ${items[index].receiptNumber}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.6,
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.41,
                                                                  child: Text(
                                                                    "Invoice No : ${items[index].invoiceNumber}",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .person,
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.6,
                                                                        child: Text(
                                                                            "Collected by : ${items[index].collectedStaff} ",
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const SizedBox(
                                                                              height: 5),
                                                                          Row(
                                                                            children: [
                                                                              const Icon(
                                                                                Icons.calendar_month,
                                                                                color: Colors.grey,
                                                                                size: 20,
                                                                              ),
                                                                              const SizedBox(width: 8),
                                                                              Text(items[index].receiptDate.toString(),
                                                                                  maxLines: 2,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  )),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ViewReceipt(widget.token, items[index].id.toString(), items[index].clientId.toString(), items[index].receiptNumber.toString())),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: const Color(0xffe9d9fd)),
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0),
                                                                            child:
                                                                                Icon(Icons.local_print_shop_outlined, color: Color(0xff9747FF)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (items[index].isVerified ==
                                                                              "N") {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => EditReceipt(
                                                                                  widget.token,
                                                                                  items[index].id.toString(),
                                                                                ),
                                                                              ),
                                                                            ).then((_) {
                                                                              items.clear();
                                                                              page = 1;
                                                                              add = 1;
                                                                              getData();
                                                                            });
                                                                          } else {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Cannot Edit"),
                                                                                  content: const Text("This receipt is already verified and cannot be edited."),
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
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: const Color(0xffaedcf4)),
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0),
                                                                            child:
                                                                                Icon(Icons.mode_edit_outlined, color: Colors.blue),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (items[index].isVerified ==
                                                                              "N") {
                                                                            showDialog(
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
                                                                                            Common.showProgressDialog(context, "Loading..");
                                                                                            ReceiptDeleteModel deleteReceipt = await HttpService.deleteReceipt(widget.token, items[index].id);
                                                                                            if (deleteReceipt.data == true) {
                                                                                              Common.toastMessaage(deleteReceipt.message, Colors.green);
                                                                                              if (context.mounted) {
                                                                                                getData();
                                                                                                Navigator.pop(context);
                                                                                                Navigator.pop(context);
                                                                                              }
                                                                                            } else {
                                                                                              Common.toastMessaage(deleteReceipt.message, Colors.red);
                                                                                              if (context.mounted) {
                                                                                                Navigator.of(context).pop();
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          child: const Text('Yes')),
                                                                                    ],
                                                                                  );
                                                                                });
                                                                          } else {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Cannot Edit"),
                                                                                  content: const Text("This receipt is already verified and cannot be deleted."),
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
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: const Color(0xfffcbcbc)),
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0),
                                                                            child:
                                                                                Icon(Icons.delete_outline, color: Colors.red),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      items[index].uploadedFile !=
                                                                              ''
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => WebViewPage('image', items[index].uploadedFile.toString())),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.green.shade100),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.screenshot, color: Colors.green),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : const SizedBox()
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );

                                                    // Helper Widget for Action Buttons
                                                  }
                                                }
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 180,
                                                  height: 180,
                                                  child: Image.asset(
                                                    "assets/icons/nodatafound.png",
                                                  ),
                                                ),
                                                const Text(
                                                  'No Data Found',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                )
                              ],
                            ),
                            // items.isNotEmpty
                            //     ? Container(
                            //         height: 36.0,
                            //         color: Colors.grey.shade200,
                            //         child: Center(
                            //             child: Text(
                            //           'Total : ${receiptList!.data.receiptSum}',
                            //           style: const TextStyle(
                            //               color: Colors.green,
                            //               fontSize: 18,
                            //               fontWeight: FontWeight.bold),
                            //         )),
                            //       )
                            //     : const SizedBox(),
                            items.isNotEmpty
                                ? Container(
                                    height: 56.0,
                                    color: Colors.grey.shade200,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Total : ${receiptList!.data.receiptSum}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (accountTotals.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _showAccountTotals =
                                                      !_showAccountTotals;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400),
                                                ),
                                                child: Icon(
                                                  _showAccountTotals
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons.keyboard_arrow_up,
                                                  color: Colors.grey.shade600,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),

                            if (_showAccountTotals && accountTotals.isNotEmpty)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Account Wise Receipts',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _showAccountTotals = false;
                                              });
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: _loadingAccountTotals
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : ListView.separated(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: accountTotals.length,
                                                separatorBuilder: (context,
                                                        index) =>
                                                    const Divider(height: 8),
                                                itemBuilder: (context, index) {
                                                  final account =
                                                      accountTotals[index];
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          account.accountName ??
                                                              'Unknown Account',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        "₹ ${account.totalReceipt ?? '0'}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(thickness: 1),
                                      Builder(
                                        builder: (context) {
                                          final double total =
                                              accountTotals.fold(
                                            0.0,
                                            (sum, item) =>
                                                sum +
                                                (double.tryParse(
                                                        item.totalReceipt ??
                                                            '0') ??
                                                    0),
                                          );
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total Receipt:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "₹ ${total.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            Positioned(
                              right:
                                  _floatingButtonPosition.dx == 0 ? 30 : null,
                              bottom:
                                  _floatingButtonPosition.dy == 0 ? 100 : null,
                              left: _floatingButtonPosition.dx != 0
                                  ? _floatingButtonPosition.dx
                                  : null,
                              top: _floatingButtonPosition.dy != 0
                                  ? _floatingButtonPosition.dy
                                  : null,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  final newPosition = Offset(
                                    _floatingButtonPosition.dx +
                                        details.delta.dx,
                                    _floatingButtonPosition.dy +
                                        details.delta.dy,
                                  );
                                  _updateFloatingButtonPosition(newPosition);
                                },
                                child: Column(
                                  children: [
                                    if (_showFloatingOptions) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: SizedBox(
                                                  width: 130,
                                                  child: FloatingActionButton
                                                      .extended(
                                                    heroTag: "simple_invoice",
                                                    onPressed: () {
                                                      setState(() {
                                                        _showFloatingOptions =
                                                            false;
                                                      });
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddInvoiceUpdated(
                                                            widget.token,
                                                            "",
                                                            "",
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    label: const Text(
                                                      'Sale',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.receipt,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: SizedBox(
                                                  width: 130,
                                                  child: FloatingActionButton
                                                      .extended(
                                                    heroTag: "complex_invoice",
                                                    onPressed: () {
                                                      setState(() {
                                                        _showFloatingOptions =
                                                            false;
                                                      });
                                                      addInvoiceDialog(context);
                                                    },
                                                    label: const Text(
                                                      'Invoice',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.description,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                    FloatingActionButton(
                                      heroTag: "main_floating_button",
                                      onPressed: () {
                                        setState(() {
                                          _showFloatingOptions =
                                              !_showFloatingOptions;
                                        });
                                      },
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: _showFloatingOptions
                                            ? Icon(Icons.close,
                                                color: Colors.white)
                                            : Icon(Icons.add,
                                                color: Colors.white),
                                      ),
                                      backgroundColor: _showFloatingOptions
                                          ? Colors.red
                                          : Color(0xFF2a86c9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ))
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

  Future<Object?> addInvoiceDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Customer  Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: search,
                                        autocorrect: false,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        autofocus: true,
                                        onChanged: (value) {
                                          setState(() {
                                            filteredCustomers = customers
                                                .where((item) => item.name!
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      child: ListView.builder(
                                        itemCount: filteredCustomers.length,
                                        physics: const ScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              onTap: () {
                                                customerName =
                                                    filteredCustomers[index]
                                                        .name!;
                                                customerId =
                                                    filteredCustomers[index]
                                                        .id!;
                                                search.clear();
                                                filteredCustomers =
                                                    List.from(customers);
                                                setState(() {});
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              title: Text(
                                                  filteredCustomers[index]
                                                      .name!));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      // onPressed: () {
                                      //   search.clear();
                                      //   filteredCustomers.addAll(customers);
                                      //   if (context.mounted) {
                                      //     Navigator.pop(context);
                                      //   }
                                      // },
                                      onPressed: () {
                                        search.clear();
                                        filteredCustomers =
                                            List.from(customers);
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
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    customerName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (customerId == '') {
                          Common.toastMessaage('Choose Client', Colors.red);
                        } else {
                          search.clear();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddInvoice(widget.token, customerId, "")),
                          ).then((_) {
                            getData();
                          });
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 25, right: 25),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<dynamic> accountHeadDialog(BuildContext context) {
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
                        filteredHeads = allAccountHeads
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
                    itemCount: filteredHeads.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            headName = filteredHeads[index].accountName;
                            headId = filteredHeads[index].accountId;
                            search.clear();
                            filteredHeads.clear();
                            filteredHeads.addAll(allAccountHeads);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredHeads[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    search.clear();
                    filteredHeads.clear();
                    filteredHeads.addAll(allAccountHeads);
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: bgColor,
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}
