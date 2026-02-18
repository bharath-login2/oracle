// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/bulk_remind.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/models/renewal/renewal_list.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_quick_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renew_custom_renewal.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_details.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup.dart';
import 'package:login2/screens/accounts/renewal_mannagement/view_history.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

import 'renew_quick_renewal.dart';

class RenewalList extends StatefulWidget {
  String custId;
  String title;
  String searchKey;
  String searchMonth;
  int renewed;
  RenewalList(
      {super.key,
      required this.custId,
      required this.title,
      required this.renewed,
      required this.searchKey,
      required this.searchMonth});

  @override
  State<RenewalList> createState() => _RenewalListState();
}

class _RenewalListState extends State<RenewalList> {
  final formKey = GlobalKey<FormState>();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController projectCost = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController customer = TextEditingController();
  TextEditingController renewalstatus = TextEditingController();
  TextEditingController recieverName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController expireIn = TextEditingController();
  TextEditingController search = TextEditingController();

  RenewalListModel? listResponse;
  HideModel? hideResponse;
  String clientId = "";
  bool isLoading = true;
  int page = 1;
  int add = 1;
  int pageSize = 10;
  String daysToExpire = "";
  List filteredNames = [];
  List selectedIds = [];
  List selectedNames = [];
  RenewalDetailslModel? detailsResponse;
  RenewalTemplateModel? template;
  PostReminderModel? postReminderRes;
  BulkRemindModel? bulkResponse;
  List products = [];
  List filteredProducts = [];
  String renClientId = "";
  List productName = [];
  double productCost = 0;
  List<ListElement> items = [];
  String fromDate = "";
  String toDate = "";
  bool isAllSelected = false;
  String multiBranch = "true";
  String? name = '';
  String? token = '';
  String? role = '';
  String? userId = '';
  String? phoneCallLogPermission = '';
  DateTime? selectedValue;
  String? selectedRenewalValue;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool _showSummaryDetails = true;
  double _summaryHeight = 60.0;
  double _expandedHeight = 280.0;

  void filterCustomers(
    String query,
  ) {
    filteredNames = detailsResponse!.data.customer
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getDetails() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      filteredNames = detailsResponse!.data.customer;
      filteredProducts = detailsResponse!.data.products;
    }
  }

  void _resetAndLoadList() {
    setState(() {
      page = 1;
      add = 1;
      items.clear();
    });
    getList();
  }

  hide(id) async {
    hideResponse = await HttpService.hideRenewal(id);
    if (hideResponse != null && hideResponse!.status == true) {
      Common.toastMessaage(hideResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(hideResponse!.message, Colors.red);
    }
  }

  void filterProducts(
    String query,
  ) {
    filteredProducts = detailsResponse!.data.products
        .where((map) =>
            map.productName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getRenewalReminderMessage(String renewalId, String contactId) async {
    template = await HttpService.getRenewalReminderMessage(renewalId);
    if (template != null && template!.status == true) {
      setState(() {
        Navigator.pop(context);
        reminderBottomSheet(renewalId, contactId);
      });
    } else {
      Common.toastMessaage(template!.message, Colors.red);
      Navigator.pop(context);
      setState(() {});
    }
  }

  postReminder(String renewalId, String contactNumber) async {
    postReminderRes = await HttpService.postReminder(
        renewalId,
        contactNumber,
        template!.data.templateType,
        template!.data.templateName,
        template!.data.templateId,
        template!.data.customerId,
        template!.data.message);
    if (postReminderRes != null && postReminderRes!.status == true) {
      Common.toastMessaage(postReminderRes!.message, Colors.green);
    } else {
      Common.toastMessaage(postReminderRes!.message, Colors.red);
    }
  }

  postBulkReminder() async {
    Common.showProgressDialog(context, "Loading..");
    bulkResponse = await HttpService.bulkReminder(selectedIds);
    if (bulkResponse != null) {
      Common.toastMessaage(bulkResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(bulkResponse!.message, Colors.red);
    }
    Navigator.pop(context);
    setState(() {
      selectedIds.clear();
      selectedNames.clear();
    });
  }

  getList() async {
    listResponse = await HttpService.renewalList(
        widget.custId,
        page,
        pageSize,
        clientId,
        fromDate,
        toDate,
        daysToExpire,
        widget.searchKey,
        widget.searchMonth,
        expireIn.text,
        search.text,
        selectedRenewalValue ?? "");
    if (listResponse != null && listResponse!.status == true) {
      // items = listResponse!.data.lists;
      items.addAll(listResponse!.data.lists);
      page++;
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateSummary() {
    if (listResponse != null &&
        listResponse!.data.count.isNotEmpty &&
        listResponse!.data.count[0] != null) {
      final apiCount = listResponse!.data.count[0];
      return {
        'totalCount': int.tryParse(apiCount.totalCount) ?? 0,
        'totalAmount': double.tryParse(apiCount.totalAmount) ?? 0,
        'renewedCount': int.tryParse(apiCount.renewed.total) ?? 0,
        'renewedAmount': double.tryParse(apiCount.renewed.amount) ?? 0,
        'expiredCount': int.tryParse(apiCount.expired.total) ?? 0,
        'expiredAmount': double.tryParse(apiCount.expired.amount) ?? 0,
        'pendingCount': int.tryParse(apiCount.pending.total) ?? 0,
        'pendingAmount': double.tryParse(apiCount.pending.amount) ?? 0,
      };
    } else {
      // Fallback to local calculation if API data is not available
      int totalCount = items.length;
      double totalAmount = 0;
      int renewedCount = 0;
      double renewedAmount = 0;
      int expiredCount = 0;
      double expiredAmount = 0;
      int pendingCount = 0;
      double pendingAmount = 0;

      for (var item in items) {
        double cost =
            double.tryParse(item.cost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        totalAmount += cost;

        if (item.isRenewed == true) {
          renewedCount++;
          renewedAmount += cost;
        } else if (item.isExpired == true) {
          expiredCount++;
          expiredAmount += cost;
        } else {
          pendingCount++;
          pendingAmount += cost;
        }
      }

      return {
        'totalCount': totalCount,
        'totalAmount': totalAmount,
        'renewedCount': renewedCount,
        'renewedAmount': renewedAmount,
        'expiredCount': expiredCount,
        'expiredAmount': expiredAmount,
        'pendingCount': pendingCount,
        'pendingAmount': pendingAmount,
      };
    }
  }

  @override
  void initState() {
    isLoading = true;
    getList();
    getDetails();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    super.initState();
  }

  void _onLoadMore() {
    if (items.length + 10 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getList();
      add++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = _calculateSummary();
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      selectedIds.isEmpty
                          ? InkWell(
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
                            )
                          : Checkbox(
                              fillColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              checkColor: Colors.blue,
                              value: isAllSelected,
                              onChanged: (value) {
                                setState(() {
                                  isAllSelected = value!;
                                  if (isAllSelected == true) {
                                    for (int i = 0; i < items.length; i++) {
                                      if (items[i].isRenewed == false) {
                                        if (selectedIds.contains(items[i].id)) {
                                        } else {
                                          selectedIds.add(items[i].id);
                                          selectedNames
                                              .add(items[i].clientName);
                                        }
                                      }
                                    }
                                  } else {
                                    selectedNames.clear();
                                    selectedIds.clear();
                                  }
                                });
                              }),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        selectedIds.isEmpty
                            ? widget.title
                            : "Tap to select all",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  selectedIds.isEmpty
                      ? InkWell(
                          onTap: () {
                            filtration(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            child: const Center(
                              child: Icon(
                                Icons.filter_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            bulkReminderSheet();
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.teal),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                    "assets/icons/whatsapp_white.png")),
                          ),
                        )
                ]),
          ),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: (() async {
            page = 1;
            add = 1;
            items.clear();
            getList();
          }),
          child: isLoading == true
              ? buildLoaderListItem()
              : items.isNotEmpty
                  ? SafeArea(
                      child: listResponse == null
                          ? const Center(
                              child: Text("Something Went Wrong"),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: TextFormField(
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          controller: search,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                            hintStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                            hintText: 'Search',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide
                                                  .none, // Set the border color to none
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // setState(() {
                                          //   isLoading == true;
                                          // });
                                          page = 1;
                                          add = 1;
                                          items.clear();
                                          getList();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.31,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: const Color(0xff2590cf)),
                                          child: const Center(
                                            child: Text("Submit",
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ScrollablePositionedList.builder(
                                      shrinkWrap: true,
                                      itemScrollController:
                                          itemScrollController,
                                      itemPositionsListener:
                                          itemPositionsListener,
                                      itemCount: items.length +
                                          (items.length + 10 == page * pageSize
                                              ? 1
                                              : 0),
                                      initialScrollIndex: 0,
                                      itemBuilder: (context, index) {
                                        if (index == items.length) {
                                          return buildLoaderListItem();
                                        } else {
                                          return Dismissible(
                                            key: const Key('0'),
                                            background: Container(
                                              color: Colors.green,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Icon(
                                                      Icons.restart_alt,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      " Renew",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            secondaryBackground: Container(
                                              color: Colors.blue,
                                              child: const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      " Add Followup",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            confirmDismiss: (direction) async {
                                              if (direction ==
                                                  DismissDirection.startToEnd) {
                                                if (items[index].renewalType ==
                                                    "quick") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RenewQuickRenewal(
                                                          id: items[index].id,
                                                        ),
                                                      )).then((_) {
                                                    page = 1;
                                                    add = 1;
                                                    items.clear();
                                                    getList();
                                                  });
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RenewCustomRenewal(
                                                          renId:
                                                              items[index].id,
                                                          renewalType:
                                                              items[index]
                                                                  .renewalType,
                                                        ),
                                                      )).then((_) {
                                                    page = 1;
                                                    add = 1;
                                                    items.clear();
                                                    getList();
                                                  });
                                                }
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RenewalFollowup(
                                                                items[index].id,
                                                                DateTime
                                                                    .now()))).then(
                                                    (_) {
                                                  page = 1;
                                                  add = 1;
                                                  items.clear();
                                                  getList();
                                                });
                                              }
                                              return null;
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (items[index].isRenewed ==
                                                      false) {
                                                    setState(() async {
                                                      if (selectedIds
                                                          .isNotEmpty) {
                                                        if (selectedIds
                                                            .contains(
                                                                items[index]
                                                                    .id)) {
                                                          selectedIds.remove(
                                                              items[index].id);
                                                          selectedNames.remove(
                                                              items[index]
                                                                  .clientName);
                                                        } else {
                                                          selectedIds.add(
                                                              items[index].id);
                                                          selectedNames.add(
                                                              items[index]
                                                                  .clientName);
                                                        }
                                                      } else {
                                                        if (selectedIds
                                                            .isEmpty) {
                                                          String token =
                                                              await Common
                                                                  .getSharedPref(
                                                                      "token");
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //       builder: (context) =>
                                                          //           ClientDetails(
                                                          //               token,
                                                          //               items[index]
                                                          //                   .clientId),
                                                          //     ))
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => CustomerDashboard(
                                                                  name: name!,
                                                                  token: token,
                                                                  userId:
                                                                      userId!,
                                                                  phoneCallLogPermission:
                                                                      phoneCallLogPermission,
                                                                  custId: items[
                                                                          index]
                                                                      .clientId),
                                                            ),
                                                          ).then((_) {
                                                            page = 1;
                                                            add = 1;
                                                            items.clear();
                                                            getList();
                                                          });
                                                        }
                                                        // Navigator.push(
                                                        //     context,
                                                        //     MaterialPageRoute(
                                                        //       builder: (context) =>
                                                        //           RenewalDetails(
                                                        //         id: items[index]
                                                        //             .id,
                                                        //       ),
                                                        //     )).then((_) {
                                                        //   page = 1;
                                                        //   add = 1;
                                                        //   items.clear();
                                                        //   getList();
                                                        // });
                                                      }
                                                    });
                                                    if ((items.length -
                                                            widget.renewed) ==
                                                        selectedIds.length) {
                                                      isAllSelected = true;
                                                    } else {
                                                      isAllSelected = false;
                                                    }
                                                  }
                                                },
                                                onLongPress: () {
                                                  setState(() {
                                                    if (items[index]
                                                            .isRenewed ==
                                                        false) {
                                                      if (selectedIds.contains(
                                                          items[index].id)) {
                                                        selectedIds.remove(
                                                            items[index].id);
                                                        selectedNames.remove(
                                                            items[index]
                                                                .clientName);
                                                      } else {
                                                        selectedIds.add(
                                                            items[index].id);
                                                        selectedNames.add(
                                                            items[index]
                                                                .clientName);
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: selectedIds.contains(
                                                            items[index].id)
                                                        ? Colors.blueGrey
                                                        : items[index]
                                                                    .isRenewed ==
                                                                true
                                                            ? Colors
                                                                .green.shade100
                                                                .withOpacity(.8)
                                                            : items[index]
                                                                        .isExpired ==
                                                                    true
                                                                ? Colors.red
                                                                    .shade100
                                                                    .withOpacity(
                                                                        .5)
                                                                : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    if (selectedIds
                                                                        .isEmpty) {
                                                                      String
                                                                          token =
                                                                          await Common.getSharedPref(
                                                                              "token");
                                                                      // Navigator.push(
                                                                      //     context,
                                                                      //     MaterialPageRoute(
                                                                      //       builder: (context) =>
                                                                      //           ClientDetails(token, items[index].clientId),
                                                                      //     ))
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => CustomerDashboard(
                                                                              name: name!,
                                                                              token: token,
                                                                              userId: userId!,
                                                                              phoneCallLogPermission: phoneCallLogPermission,
                                                                              custId: items[index].clientId),
                                                                        ),
                                                                      ).then(
                                                                          (_) {
                                                                        page =
                                                                            1;
                                                                        add = 1;
                                                                        items
                                                                            .clear();
                                                                        getList();
                                                                      });
                                                                    }
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            18,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .50,
                                                                        child:
                                                                            Text(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          " ${items[index].clientName}",
                                                                          style:
                                                                              const TextStyle(fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // const SizedBox(
                                                                //   height: 10,
                                                                // ),
                                                                // Row(
                                                                //   children: [
                                                                //     const Icon(
                                                                //       Icons
                                                                //           .phone,
                                                                //       size: 18,
                                                                //     ),
                                                                //     SizedBox(
                                                                //       width: MediaQuery.of(context)
                                                                //               .size
                                                                //               .width *
                                                                //           .50,
                                                                //       child:
                                                                //           Text(
                                                                //         overflow:
                                                                //             TextOverflow.ellipsis,
                                                                //         " ${items[index].contactNo}",
                                                                //         style: const TextStyle(
                                                                //             fontSize:
                                                                //                 14),
                                                                //       ),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      size: 18,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .50,
                                                                      child:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        " ${items[index].startDate} To ${items[index].endDate}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .shopping_basket,
                                                                      size: 18,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .50,
                                                                      child:
                                                                          Text(
                                                                        " ${items[index].products}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .currency_rupee,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      " ${items[index].cost}/-",
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                  color: items[index].isRenewed ==
                                                                          false
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .teal,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4.0,
                                                                        horizontal:
                                                                            8.0),
                                                                    child: Text(
                                                                      items[index].isRenewed ==
                                                                              true
                                                                          ? "Renewed"
                                                                          : items[index].isExpired == true
                                                                              ? "Expired"
                                                                              : "Not Renewed",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Container(
                                                                  color: Colors
                                                                      .yellow,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4.0,
                                                                        horizontal:
                                                                            8.0),
                                                                    child: Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      items[index]
                                                                          .remainingDays,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              54,
                                                                              43,
                                                                              43)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Visibility(
                                                                  visible:
                                                                      selectedIds
                                                                          .isEmpty,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Visibility(
                                                                        visible:
                                                                            items[index].isRenewed ==
                                                                                false,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            Common.showProgressDialog(context,
                                                                                "Loading..");
                                                                            getRenewalReminderMessage(items[index].id,
                                                                                items[index].contactNo);
                                                                            recieverName.text =
                                                                                items[index].clientName;
                                                                            contactNumber.text =
                                                                                items[index].contactNo;
                                                                            // setState(() {});
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.teal),
                                                                            child:
                                                                                Padding(padding: const EdgeInsets.all(8.0), child: Image.asset("assets/icons/whatsapp_white.png")),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Visibility(
                                                                        visible:
                                                                            items[index].isRenewed ==
                                                                                false,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (items[index].renewalType ==
                                                                                "quick") {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => RenewQuickRenewal(
                                                                                    id: items[index].id,
                                                                                  ),
                                                                                ),
                                                                              ).then((_) {
                                                                                page = 1;
                                                                                add = 1;
                                                                                items.clear();
                                                                                getList();
                                                                                Future.delayed(const Duration(milliseconds: 300), () {
                                                                                  if (itemScrollController.isAttached) {
                                                                                    itemScrollController.jumpTo(index: 0);
                                                                                  }
                                                                                });
                                                                              });
                                                                            } else {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => RenewCustomRenewal(
                                                                                    renId: items[index].id,
                                                                                    renewalType: items[index].renewalType,
                                                                                  ),
                                                                                ),
                                                                              ).then((_) {
                                                                                page = 1;
                                                                                add = 1;
                                                                                items.clear();
                                                                                getList();
                                                                                Future.delayed(const Duration(milliseconds: 300), () {
                                                                                  if (itemScrollController.isAttached) {
                                                                                    itemScrollController.jumpTo(index: 0);
                                                                                  }
                                                                                });
                                                                              });
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.green),
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.all(8.0),
                                                                              child: Icon(Icons.restart_alt, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // const SizedBox(
                                                                      //   width:
                                                                      //       10,
                                                                      // ),
                                                                      PopupMenuButton<
                                                                          String>(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                5),
                                                                        iconColor:
                                                                            Colors.black,
                                                                        color: Colors
                                                                            .white,
                                                                        onSelected:
                                                                            (value) {
                                                                          if (value ==
                                                                              "0") {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => RenewalFollowup(items[index].id, DateTime.now()))).then((_) {
                                                                              page = 1;
                                                                              add = 1;
                                                                              items.clear();
                                                                              getList();
                                                                            });
                                                                          } else if (value ==
                                                                              "1") {
                                                                            Common.showProgressDialog(context,
                                                                                "Loading..");
                                                                            getRenewalReminderMessage(items[index].id,
                                                                                items[index].contactNo);
                                                                            recieverName.text =
                                                                                items[index].clientName;
                                                                            contactNumber.text =
                                                                                items[index].contactNo;
                                                                          } else if (value ==
                                                                              "2") {
                                                                            if (items[index].renewalType ==
                                                                                "quick") {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => EditQuickRenewalScreen(
                                                                                            id: items[index].id,
                                                                                          ))).then((r) {
                                                                                getList();
                                                                              });
                                                                            } else {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => EditCustomRenewal(
                                                                                            renId: items[index].id,
                                                                                            renewalType: items[index].renewalType,
                                                                                          ))).then((_) {
                                                                                page = 1;
                                                                                add = 1;
                                                                                items.clear();
                                                                                getList();
                                                                              });
                                                                            }
                                                                          } else if (value ==
                                                                              "3") {
                                                                            if (items[index].renewalType ==
                                                                                "quick") {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => RenewQuickRenewal(
                                                                                      id: items[index].id,
                                                                                    ),
                                                                                  )).then((_) {
                                                                                page = 1;
                                                                                add = 1;
                                                                                items.clear();
                                                                                getList();
                                                                              });
                                                                            } else {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => RenewCustomRenewal(
                                                                                      renId: items[index].id,
                                                                                      renewalType: items[index].renewalType,
                                                                                    ),
                                                                                  )).then((_) {
                                                                                page = 1;
                                                                                add = 1;
                                                                                items.clear();
                                                                                getList();
                                                                              });
                                                                            }
                                                                          } else if (value ==
                                                                              "4") {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    scrollable: true,
                                                                                    title: const Text('Please Confirm'),
                                                                                    content: const Text('Are you sure to Hide?'),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: const Text('No')),
                                                                                      TextButton(
                                                                                          onPressed: () async {
                                                                                            Navigator.pop(context);
                                                                                            await hide(items[index].id);
                                                                                            page = 1;
                                                                                            add = 1;
                                                                                            items.clear();
                                                                                            getList();
                                                                                          },
                                                                                          child: const Text('Yes')),
                                                                                    ],
                                                                                  );
                                                                                });
                                                                          } else if (value ==
                                                                              "5") {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => ViewHistory(
                                                                                    id: items[index].id,
                                                                                    title: items[index].clientName,
                                                                                  ),
                                                                                ));
                                                                          }
                                                                        },
                                                                        itemBuilder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return [
                                                                            if (items[index].isRenewed ==
                                                                                false)
                                                                              const PopupMenuItem<String>(
                                                                                value: '0',
                                                                                child: Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.add,
                                                                                      color: Colors.green,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      'Add Followup',
                                                                                      style: TextStyle(color: Colors.green),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            if (items[index].isRenewed ==
                                                                                false)
                                                                              const PopupMenuItem<String>(
                                                                                value: '2',
                                                                                child: Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.edit,
                                                                                      color: Colors.blue,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      'Edit',
                                                                                      style: TextStyle(color: Colors.blue),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            const PopupMenuItem<String>(
                                                                              value: '4',
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.visibility_off,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    'Hide',
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const PopupMenuItem<String>(
                                                                              value: '5',
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.history,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    'Remind History',
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ];
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                // Summary Section
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: _showSummaryDetails
                                      ? _expandedHeight
                                      : _summaryHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: _summaryHeight,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(width: 40),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Count: ${summaryData['totalCount']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Text(
                                                  'Total: ₹ ${summaryData['totalAmount'].toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _showSummaryDetails =
                                                      !_showSummaryDetails;
                                                });
                                              },
                                              icon: Icon(
                                                _showSummaryDetails
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_up,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_showSummaryDetails) ...[
                                        Divider(
                                            height: 1,
                                            color: Colors.grey.shade300),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Category',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Count',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.grey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                          SizedBox(width: 55),
                                                          Text(
                                                            'Amount',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.grey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Divider(
                                                      height: 1,
                                                      color:
                                                          Colors.grey.shade300),
                                                  SizedBox(height: 10),

                                                  // Total Renewed
                                                  InkWell(
                                                    onTap: () {
                                                      // Filter to show only renewed items
                                                      print(
                                                          'Show renewed items');
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Renewed',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .green
                                                                      .shade700,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                child: Text(
                                                                  '${summaryData['renewedCount']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .green
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 30),
                                                              Container(
                                                                width: 80,
                                                                child: Text(
                                                                  '₹ ${summaryData['renewedAmount'].toStringAsFixed(0)}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .green
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),

                                                  // Total Expired
                                                  InkWell(
                                                    onTap: () {
                                                      // Filter to show only expired items
                                                      print(
                                                          'Show expired items');
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Expired',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .red
                                                                      .shade700,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                child: Text(
                                                                  '${summaryData['expiredCount']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 30),
                                                              Container(
                                                                width: 80,
                                                                child: Text(
                                                                  '₹ ${summaryData['expiredAmount'].toStringAsFixed(0)}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),

                                                  // Total Pending
                                                  InkWell(
                                                    onTap: () {
                                                      // Filter to show only pending items
                                                      print(
                                                          'Show pending items');
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .orange,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Pending',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade700,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                child: Text(
                                                                  '${summaryData['pendingCount']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .orange
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 30),
                                                              Container(
                                                                width: 80,
                                                                child: Text(
                                                                  '₹ ${summaryData['pendingAmount'].toStringAsFixed(0)}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .orange
                                                                        .shade700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Divider(
                                                      height: 1,
                                                      color:
                                                          Colors.grey.shade400),
                                                  SizedBox(height: 10),

                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Total',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .blue.shade700,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 50,
                                                              child: Text(
                                                                '${summaryData['totalCount']}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue
                                                                      .shade700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            SizedBox(width: 30),
                                                            Container(
                                                              width: 80,
                                                              child: Text(
                                                                '₹ ${summaryData['totalAmount'].toStringAsFixed(0)}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue
                                                                      .shade700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 150,
                              width: 150,
                              child:
                                  Image.asset("assets/icons/nodatafound.png")),
                          const Text("No Renewals")
                        ],
                      ),
                    )),
    );
  }

  Future<dynamic> filtration(BuildContext context) {
    int _selectedTab = 0;

    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildTabItem(
                                context,
                                'Date',
                                Icons.calendar_today,
                                0,
                                _selectedTab,
                                () => setState(() => _selectedTab = 0),
                              ),
                              _buildTabItem(
                                context,
                                'Customer',
                                Icons.person,
                                1,
                                _selectedTab,
                                () => setState(() => _selectedTab = 1),
                              ),
                              _buildTabItem(
                                context,
                                'Expiry Days',
                                Icons.timer,
                                2,
                                _selectedTab,
                                () => setState(() => _selectedTab = 2),
                              ),
                              _buildTabItem(
                                context,
                                'Status',
                                Icons.star_border_purple500_sharp,
                                3,
                                _selectedTab,
                                () => setState(() => _selectedTab = 3),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _buildRightPanel(_selectedTab, setState),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Expanded(
                        //   child: OutlinedButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         fromDate = "";
                        //         toDate = "";
                        //         customer.text = "";
                        //         clientId = "";
                        //         expireIn.text = "";
                        //         renewalstatus.text = "";
                        //         selectedRenewalValue = "";
                        //       });
                        //     },
                        //     style: OutlinedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(vertical: 12),
                        //       side: BorderSide(color: Colors.grey.shade300),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       'Clear All',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w500,
                        //         color: Colors.grey.shade700,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _resetAndLoadList();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3375e0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String title,
    IconData icon,
    int index,
    int selectedIndex,
    VoidCallback onTap,
  ) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        color: isSelected ? Colors.white : Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.blue : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(
      int selectedTab, void Function(void Function()) setState) {
    switch (selectedTab) {
      case 0:
        return _buildDateRangeSection(setState);
      case 1:
        return _buildCustomerSection(setState);
      case 2:
        return _buildExpiryDaysSection(setState);
      case 3:
        return _buildRenewalStatusSection(setState);
      default:
        return _buildDateRangeSection(setState);
    }
  }

  Widget _buildDateRangeSection(void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DateTimePicker(
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'Start date',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize:
                            11, // Reduced font size for selected date text
                        color: Colors.black87,
                      ), //
                      initialValue: fromDate,
                      type: DateTimePickerType.date,
                      firstDate: DateTime(1995),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            String formattedDate = DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(value));
                            fromDate = formattedDate;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'To Date',
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: Colors.grey.shade600,
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Container(
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.grey.shade300),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: DateTimePicker(
            //           decoration: const InputDecoration(
            //             contentPadding:
            //                 EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            //             border: InputBorder.none,
            //             hintText: 'End date',
            //             hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            //             suffixIcon: Icon(Icons.calendar_today,
            //                 size: 16, color: Colors.grey),
            //           ),
            //           initialValue: toDate,
            //           type: DateTimePickerType.date,
            //           firstDate: DateTime(1995),
            //           lastDate: DateTime.now().add(const Duration(days: 365)),
            //           onChanged: (value) {
            //             if (value.isNotEmpty) {
            //               setState(() {
            //                 String formattedDate = DateFormat('dd-MM-yyyy')
            //                     .format(DateTime.parse(value));
            //                 toDate = formattedDate;
            //               });
            //             }
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'From Date',
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: Colors.grey.shade600,
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Container(
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.grey.shade300),
            //           borderRadius: BorderRadius.circular(6),
            //         ),
            //         child: DateTimePicker(
            //           decoration: const InputDecoration(
            //             contentPadding:
            //                 EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            //             border: InputBorder.none,
            //             hintText: 'Start date',
            //             hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            //             suffixIcon: Icon(Icons.calendar_today,
            //                 size: 16, color: Colors.grey),
            //           ),
            //            style: const TextStyle(
            //               fontSize: 11, // Reduced font size for selected date text
            //               color: Colors.black87,
            //             ), //
            //           initialValue: fromDate,
            //           type: DateTimePickerType.date,
            //           firstDate: DateTime(1995),
            //           lastDate: DateTime.now().add(const Duration(days: 365)),
            //           onChanged: (value) {
            //             if (value.isNotEmpty) {
            //               setState(() {
            //                 String formattedDate = DateFormat('dd-MM-yyyy')
            //                     .format(DateTime.parse(value));
            //                 fromDate = formattedDate;
            //               });
            //             }
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DateTimePicker(
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'End date',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      initialValue: toDate,
                      type: DateTimePickerType.date,
                      firstDate: DateTime(1995),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            String formattedDate = DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(value));
                            toDate = formattedDate;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

// Customer Section - Updated
  Widget _buildCustomerSection(void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Customer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => dropDialog(context, "Customers"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    customer.text.isEmpty ? 'Select customer' : customer.text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          customer.text.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 20, // Smaller icon
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Expiry Days Section - Updated
  Widget _buildExpiryDaysSection(void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry in Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: expireIn,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Enter number of days',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRenewalStatusSection(void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renewal Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => renewalDropDialog(context, "Renewal Status", setState),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    renewalstatus.text.isEmpty
                        ? 'Select status'
                        : renewalstatus.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: renewalstatus.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Future<dynamic> filtration(BuildContext context) {
  //   return showModalBottomSheet(
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Padding(
  //           padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom),
  //           child: StatefulBuilder(
  //             builder: (context, setState) {
  //               return Container(
  //                 width: double.maxFinite,
  //                 clipBehavior: Clip.antiAlias,
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: const BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(16),
  //                     topRight: Radius.circular(16),
  //                   ),
  //                 ),
  //                 child: Material(
  //                   color: Colors.white,
  //                   child: SingleChildScrollView(
  //                     child: Column(
  //                       children: [
  //                         const SizedBox(height: 20),
  //                         const Text(
  //                           'Filtration',
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Column(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 const Text('From Date',
  //                                     style: TextStyle(
  //                                       fontSize: 15,
  //                                       fontWeight: FontWeight.w500,
  //                                     )),
  //                                 const SizedBox(
  //                                   height: 5,
  //                                 ),
  //                                 SizedBox(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.43,
  //                                   child: Center(
  //                                     child: DateTimePicker(
  //                                       decoration: InputDecoration(
  //                                           filled: true,
  //                                           //<-- SEE HERE
  //                                           fillColor: Colors.white,
  //                                           prefixIcon: const Icon(
  //                                             Icons.arrow_right,
  //                                             color: Colors.grey,
  //                                           ),
  //                                           counterText: "",
  //                                           hintText: 'From Date',
  //                                           isDense: true,
  //                                           border: OutlineInputBorder(
  //                                               borderSide: BorderSide(
  //                                                   color:
  //                                                       Colors.purple.shade100),
  //                                               borderRadius:
  //                                                   BorderRadius.circular(5))),
  //                                       initialValue: fromDate.toString(),
  //                                       type: DateTimePickerType.date,

  //                                       //controller: fromDate,
  //                                       firstDate: DateTime(1995),
  //                                       lastDate: DateTime.now()
  //                                           .add(const Duration(days: 365)),
  //                                       // This will add one year from current date
  //                                       validator: (value) {
  //                                         return null;
  //                                       },
  //                                       onChanged: (value) {
  //                                         if (value.isNotEmpty) {
  //                                           setState(() {
  //                                             String formattedDate = DateFormat(
  //                                                     'dd-MM-yyyy')
  //                                                 .format(
  //                                                     DateTime.parse(value));
  //                                             fromDate = formattedDate;
  //                                           });
  //                                         }
  //                                       },
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             Column(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 const Text('To Date',
  //                                     style: TextStyle(
  //                                       fontSize: 15,
  //                                       fontWeight: FontWeight.w500,
  //                                     )),
  //                                 const SizedBox(
  //                                   height: 5,
  //                                 ),
  //                                 SizedBox(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.43,
  //                                   child: Center(
  //                                     child: DateTimePicker(
  //                                       decoration: InputDecoration(
  //                                           filled: true,
  //                                           //<-- SEE HERE
  //                                           fillColor: Colors.white,
  //                                           prefixIcon: const Icon(
  //                                             Icons.arrow_right,
  //                                             color: Colors.grey,
  //                                           ),
  //                                           counterText: "",
  //                                           hintText: 'From Date',
  //                                           isDense: true,
  //                                           border: OutlineInputBorder(
  //                                               borderSide: BorderSide(
  //                                                   color:
  //                                                       Colors.purple.shade100),
  //                                               borderRadius:
  //                                                   BorderRadius.circular(5))),
  //                                       initialValue: toDate.toString(),
  //                                       type: DateTimePickerType.date,

  //                                       //controller: fromDate,
  //                                       firstDate: DateTime(1995),
  //                                       lastDate: DateTime.now()
  //                                           .add(const Duration(days: 365)),
  //                                       // This will add one year from current date
  //                                       validator: (value) {
  //                                         return null;
  //                                       },
  //                                       onChanged: (value) {
  //                                         if (value.isNotEmpty) {
  //                                           setState(() {
  //                                             String formattedDate = DateFormat(
  //                                                     'dd-MM-yyyy')
  //                                                 .format(
  //                                                     DateTime.parse(value));
  //                                             toDate = formattedDate;
  //                                           });
  //                                         }
  //                                       },
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 20.0),
  //                         TextFormField(
  //                           controller: customer,
  //                           readOnly: true,
  //                           onTap: (() {
  //                             dropDialog(context, "Customers");
  //                           }),
  //                           decoration: const InputDecoration(
  //                             labelText: 'Customer',
  //                             prefixIcon:
  //                                 Icon(Icons.person, color: Colors.black),
  //                             border: OutlineInputBorder(),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(color: Colors.black),
  //                             ),
  //                             labelStyle: TextStyle(color: Colors.black),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20.0),
  //                         TextFormField(
  //                           keyboardType: TextInputType.number,
  //                           controller: expireIn,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Expiry in Days',
  //                             prefixIcon: Icon(Icons.calendar_today,
  //                                 color: Colors.black),
  //                             border: OutlineInputBorder(),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(color: Colors.black),
  //                             ),
  //                             labelStyle: TextStyle(color: Colors.black),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20.0),
  //                         TextFormField(
  //                           controller: renewalstatus,
  //                           readOnly: true,
  //                           onTap: (() {
  //                             renewalDropDialog(context, "Renewal Status");
  //                           }),
  //                           decoration: const InputDecoration(
  //                             labelText: 'Renewal Status',
  //                             prefixIcon: Icon(
  //                                 Icons.star_border_purple500_sharp,
  //                                 color: Colors.black),
  //                             border: OutlineInputBorder(),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(color: Colors.black),
  //                             ),
  //                             labelStyle: TextStyle(color: Colors.black),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 30.0),
  //                         Container(
  //                           height: 40,
  //                           width: double.maxFinite,
  //                           decoration: const BoxDecoration(
  //                             color: Color(0xFF3375e0),
  //                             borderRadius:
  //                                 BorderRadius.all(Radius.circular(8)),
  //                           ),
  //                           child: RawMaterialButton(
  //                             onPressed: () {
  //                               items.clear();
  //                               page = 1;
  //                               add = 1;
  //                               getList();
  //                               Navigator.pop(context);
  //                             },
  //                             child: const Text(
  //                               "Continue",
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         );
  //       });
  // }

  Future<dynamic> dropDialog(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          if (title == "Customers") {
                            setState(() {
                              filterCustomers(value);
                            });
                          } else {
                            setState(() {
                              filterProducts(value);
                            });
                          }
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "Customers"
                        ? filteredNames.length
                        : filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          if (title == "Customers") {
                            customer.text = filteredNames[index].name;
                            clientId = filteredNames[index].id;
                          } else {
                            if (productName.contains(
                                filteredProducts[index].productName)) {
                            } else {
                              products.add(ProductId(
                                prdId: filteredProducts[index].id,
                                prdCost: filteredProducts[index].totalAmount,
                                prdQty: "1",
                                prdName: filteredProducts[index].productName,
                              ));
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            productCost = 0;

                            for (int i = 0; i < products.length; i++) {
                              productCost += double.parse(products[i].prdCost);
                            }
                            projectCost.text = (productCost).toString();
                          }
                          Navigator.pop(context);
                          setState(() {});
                          filterCustomers("");
                          filterProducts("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            title == "Customers"
                                ? filteredNames[index].name.toString()
                                : filteredProducts[index]
                                    .productName
                                    .toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  Future<void> renewalDropDialog(BuildContext context, String title,
      void Function(void Function()) setState) async {
    final Map<String, String> options = {
      "1": "Renewed",
      "2": "Not Renewed",
      "3": "Expired",
    };

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                trailing: selectedRenewalValue == entry.key
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    renewalstatus.text = entry.value;
                    selectedRenewalValue = entry.key;
                  });
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  reminderBottomSheet(String id, String contactNo) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Send Reminder",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: recieverName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please EnterName";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: contactNumber,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Contact Number";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Contact No',
                              prefixIcon: Icon(Icons.phone, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 4.0, bottom: 4.0),
                          child: Text("Reminder Message"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(template!.data.message),
                          ),
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
                              Navigator.pop(context);
                              await postReminder(id, contactNo);
                            },
                            child: const Text("Send Reminder",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
      },
    );
  }

  bulkReminderSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Send Reminder To",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedNames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: Text(
                                      selectedNames[index],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIds
                                              .remove(selectedIds[index]);
                                          selectedNames
                                              .remove(selectedNames[index]);
                                        });
                                      },
                                      child: const Icon(Icons.close))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
                          Navigator.pop(context);
                          postBulkReminder();
                        },
                        child: const Text("Send Reminder",
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // selectMediumDialog(int index, isBulk) {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: StatefulBuilder(builder: (context, setState) {
  //             return Column(
  //               children: [
  //                 const Text(
  //                   "Select Medium",
  //                   style: TextStyle(
  //                       fontSize: 20,
  //                       fontStyle: FontStyle.normal,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //                 Padding(
  //                   padding:
  //                       const EdgeInsets.only(top: 25, bottom: 10, left: 10),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         selectedMedium,
  //                         style: const TextStyle(
  //                             fontSize: 20, fontStyle: FontStyle.normal),
  //                       ),
  //                       PopupMenuButton<String>(
  //                         icon: const Icon(Icons.arrow_drop_down),
  //                         iconColor: Colors.black,
  //                         color: Colors.white,
  //                         onSelected: (value) {
  //                           if (value == "1") {
  //                             selectedMedium = "Official";
  //                           } else {
  //                             selectedMedium = "Un Official";
  //                           }
  //                           setState(() {});
  //                         },
  //                         itemBuilder: (BuildContext context) {
  //                           return [
  //                             const PopupMenuItem<String>(
  //                               value: '1',
  //                               child: Text('Official'),
  //                             ),
  //                             const PopupMenuItem<String>(
  //                               value: '2',
  //                               child: Text('Un Official'),
  //                             ),
  //                           ];
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text(
  //                   "Cancel",
  //                   style: TextStyle(color: Colors.black),
  //                 )),
  //             ElevatedButton(
  //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
  //                 onPressed: () {
  //                   if (selectedMedium != "select medium") {
  //                     Navigator.pop(context);
  //                     if (isBulk == false) {
  //                       Common.showProgressDialog(context, "Loading..");
  //                       getRenewalReminderMessage(
  //                           items[index].id, items[index].contactNo);
  //                       recieverName.text = items[index].clientName;
  //                       contactNumber.text = items[index].contactNo;
  //                     } else {
  //                       bulkReminderSheet();
  //                     }
  //                   } else {}
  //                 },
  //                 child: const Text(
  //                   "Done",
  //                   style: TextStyle(color: Colors.white),
  //                 )),
  //           ],
  //         );
  //       });
  // }
}

Widget buildLoaderListItem() {
  return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ));
}
