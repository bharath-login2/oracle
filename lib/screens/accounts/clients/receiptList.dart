import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/screens/accounts/clients/editRecipt.dart';
import 'package:login2/screens/accounts/clients/viewReceipt.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/common.dart';
import '../../../models/clients/receiptDeleteModel.dart';
import '../../../models/clients/receiptListModel.dart';
import '../../../service/service.dart';
import '../../leadManagement/webview.dart';
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
  String headId = "";
  List<AccountHead> allAccountHeads = [];
  List<AccountHead> filteredHeads = [];
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    getData();
    getDetails();
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
  }

  getList() async {
    receiptList = await HttpService.receptList(widget.token, fDate.toString(),
        tDate.toString(), page, pageSize,headId, search.text, type);
    if (receiptList != null) {
      items.addAll(receiptList!.data.lists);
      page++;
    }
    setState(() {});
  }

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
                ),
              ),
            ),
            body: receiptList != null
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                /// 📅 From & To Date Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// From Date Picker
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final selected = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                1),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (selected != null) {
                                            fDate = DateFormat('dd-MM-yyyy')
                                                .format(selected);
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                fDate,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              const Icon(Icons.calendar_month,
                                                  color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// To Date Picker
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final selected = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (selected != null) {
                                            tDate = DateFormat('dd-MM-yyyy')
                                                .format(selected);
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                tDate,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              const Icon(Icons.calendar_month,
                                                  color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                /// 🔍 Search + Account Head + Submit Button
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Search Field
                                    Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: search,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: 'Search',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          prefixIcon: const Icon(Icons.search,
                                              color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    /// Account Head Selector
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                    
                                          GestureDetector(
                                            onTap: () async {
                                              await accountHeadDialog(context);
                                              setState(() {});
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      headName.isNotEmpty
                                                          ? headName
                                                          : "Select Account Head",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.grey),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    /// Submit Button
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            items.clear();
                                            page = 1;
                                            add = 1;
                                            getList();
                                          });
                                        },
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff2590cf),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "Submit",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, top: 5, bottom: 15),
                            child: receiptList!.data.lists.isNotEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .66,
                                    child: ScrollablePositionedList.builder(
                                      shrinkWrap: true,
                                      itemScrollController:
                                          itemScrollController,
                                      itemPositionsListener:
                                          itemPositionsListener,
                                      itemCount: items.length +
                                          (items.length + 15 == page * pageSize
                                              ? 1
                                              : 0),
                                      initialScrollIndex: 0,
                                      itemBuilder: (context, index) {
                                        if (index == items.length) {
                                          return buildLoaderListItem();
                                        } else {
                                          // return Padding(
                                          //   padding: const EdgeInsets.only(
                                          //       bottom: 10),
                                          //   child: Container(
                                          //     decoration: BoxDecoration(
                                          //         boxShadow: [
                                          //           BoxShadow(
                                          //             color: Colors.grey
                                          //                 .withOpacity(0.2),
                                          //             spreadRadius: 1,
                                          //             blurRadius: 1,
                                          //             offset:
                                          //                 const Offset(1, 1),
                                          //           )
                                          //         ],
                                          //         borderRadius:
                                          //             BorderRadius.circular(5),
                                          //         color: Colors.white),
                                          //     child: Padding(
                                          //       padding:
                                          //           const EdgeInsets.all(14.0),
                                          //       child: Column(
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment.start,
                                          //         children: [
                                          //           Row(
                                          //             mainAxisAlignment:
                                          //                 MainAxisAlignment
                                          //                     .spaceBetween,
                                          //             children: [
                                          //               SizedBox(
                                          //                 width: MediaQuery.of(
                                          //                             context)
                                          //                         .size
                                          //                         .width *
                                          //                     0.6,
                                          //                 child: InkWell(
                                          //                   onTap: () {
                                          //                     Navigator.push(
                                          //                       context,
                                          //                       MaterialPageRoute(
                                          //                           builder: (context) => ClientDetails(
                                          //                               widget
                                          //                                   .token,
                                          //                               items[index]
                                          //                                   .clientId
                                          //                                   .toString())),
                                          //                     ).then((_) {
                                          //                       items.clear();
                                          //                       page = 1;
                                          //                       add = 1;
                                          //                       getData();
                                          //                     });
                                          //                   },
                                          //                   child: Text(
                                          //                       items[index]
                                          //                           .customerName
                                          //                           .toString(),
                                          //                       overflow:
                                          //                           TextOverflow
                                          //                               .ellipsis,
                                          //                       style:
                                          //                           const TextStyle(
                                          //                         fontSize: 16,
                                          //                         fontWeight:
                                          //                             FontWeight
                                          //                                 .w600,
                                          //                       )),
                                          //                 ),
                                          //               ),
                                          //               Container(
                                          //                 decoration: BoxDecoration(
                                          //                     borderRadius:
                                          //                         BorderRadius
                                          //                             .circular(
                                          //                                 2),
                                          //                     color: const Color(
                                          //                         0xffe6fbec)),
                                          //                 child: Center(
                                          //                   child: Padding(
                                          //                     padding:
                                          //                         const EdgeInsets
                                          //                             .only(
                                          //                             left: 12,
                                          //                             right: 12,
                                          //                             top: 6,
                                          //                             bottom:
                                          //                                 6),
                                          //                     child: Text(
                                          //                         items[index]
                                          //                             .recieptAmount
                                          //                             .toString(),
                                          //                         style:
                                          //                             const TextStyle(
                                          //                           color: Colors
                                          //                               .green,
                                          //                           fontSize:
                                          //                               14,
                                          //                           fontWeight:
                                          //                               FontWeight
                                          //                                   .w600,
                                          //                         )),
                                          //                   ),
                                          //                 ),
                                          //               )
                                          //             ],
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 5,
                                          //           ),
                                          //           // Row(
                                          //           //   mainAxisAlignment:
                                          //           //       MainAxisAlignment
                                          //           //           .spaceBetween,
                                          //           //   children: [
                                          //           //     SizedBox(
                                          //           //       width: MediaQuery.of(
                                          //           //                   context)
                                          //           //               .size
                                          //           //               .width *
                                          //           //           0.6,
                                          //           //       child: Text(
                                          //           //         "Receipt No : ${items[index].receiptNumber}",
                                          //           //         overflow:
                                          //           //             TextOverflow
                                          //           //                 .ellipsis,
                                          //           //         style:
                                          //           //             const TextStyle(
                                          //           //           fontSize: 14,
                                          //           //           fontWeight:
                                          //           //               FontWeight
                                          //           //                   .w400,
                                          //           //         ),
                                          //           //       ),
                                          //           //     ),
                                          //           //   ],
                                          //           // ),
                                          //           // SizedBox(
                                          //           //   width:
                                          //           //       MediaQuery.of(context)
                                          //           //               .size
                                          //           //               .width *
                                          //           //           0.6,
                                          //           //   child: SizedBox(
                                          //           //     width: MediaQuery.of(
                                          //           //                 context)
                                          //           //             .size
                                          //           //             .width *
                                          //           //         0.41,
                                          //           //     child: Text(
                                          //           //       "Invoice No : ${items[index].invoiceNumber}",
                                          //           //       overflow: TextOverflow
                                          //           //           .ellipsis,
                                          //           //       style:
                                          //           //           const TextStyle(
                                          //           //         fontSize: 14,
                                          //           //         fontWeight:
                                          //           //             FontWeight.w400,
                                          //           //       ),
                                          //           //     ),
                                          //           //   ),
                                          //           // ),
                                          //           // const SizedBox(
                                          //           //   height: 5,
                                          //           // ),
                                          //           Row(
                                          //             mainAxisAlignment:
                                          //                 MainAxisAlignment
                                          //                     .start,
                                          //             children: [
                                          //               const Icon(
                                          //                 Icons.calendar_month,
                                          //                 color: Colors.grey,
                                          //                 size: 20,
                                          //               ),
                                          //               const SizedBox(
                                          //                 width: 8,
                                          //               ),
                                          //               Row(
                                          //                 mainAxisAlignment:
                                          //                     MainAxisAlignment
                                          //                         .spaceBetween,
                                          //                 children: [
                                          //                   SizedBox(
                                          //                     width: MediaQuery.of(
                                          //                                 context)
                                          //                             .size
                                          //                             .width *
                                          //                         0.6,
                                          //                     child: Text(
                                          //                         items[index]
                                          //                             .receiptDate,
                                          //                         maxLines: 1,
                                          //                         overflow:
                                          //                             TextOverflow
                                          //                                 .ellipsis,
                                          //                         style:
                                          //                             const TextStyle(
                                          //                           fontSize:
                                          //                               14,
                                          //                           fontWeight:
                                          //                               FontWeight
                                          //                                   .w400,
                                          //                         )),
                                          //                   ),
                                          //                 ],
                                          //               ),
                                          //               Transform.translate(
                                          //                 offset: Offset(-35,
                                          //                     0), // move 8 pixels left
                                          //                 child: Row(
                                          //                   children: [
                                          //                     SizedBox(
                                          //                       width: MediaQuery.of(
                                          //                                   context)
                                          //                               .size
                                          //                               .width *
                                          //                           0.6,
                                          //                       child: Text(
                                          //                         items[index]
                                          //                             .collectedStaff,
                                          //                         maxLines: 1,
                                          //                         overflow:
                                          //                             TextOverflow
                                          //                                 .ellipsis,
                                          //                         style:
                                          //                             const TextStyle(
                                          //                           fontSize:
                                          //                               11,
                                          //                           fontWeight:
                                          //                               FontWeight
                                          //                                   .w400,
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //               )
                                          //             ],
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 8,
                                          //           ),
                                          //           Row(
                                          //             mainAxisAlignment:
                                          //                 MainAxisAlignment
                                          //                     .spaceBetween,
                                          //             children: [
                                          //               Row(
                                          //                 children: [
                                          //                   Column(
                                          //                     crossAxisAlignment:
                                          //                         CrossAxisAlignment
                                          //                             .start,
                                          //                     children: [
                                          //                       const SizedBox(
                                          //                         height: 5,
                                          //                       ),
                                          //                       // Row(
                                          //                       //   children: [
                                          //                       //     const Icon(
                                          //                       //       Icons
                                          //                       //           .calendar_month,
                                          //                       //       color: Colors
                                          //                       //           .grey,
                                          //                       //       size: 20,
                                          //                       //     ),
                                          //                       //     const SizedBox(
                                          //                       //       width: 8,
                                          //                       //     ),
                                          //                       //     Text(
                                          //                       //         items[index]
                                          //                       //             .receiptDate
                                          //                       //             .toString(),
                                          //                       //         maxLines:
                                          //                       //             2,
                                          //                       //         overflow:
                                          //                       //             TextOverflow
                                          //                       //                 .ellipsis,
                                          //                       //         style:
                                          //                       //             const TextStyle(
                                          //                       //           fontSize:
                                          //                       //               14,
                                          //                       //           fontWeight:
                                          //                       //               FontWeight.w400,
                                          //                       //         )),
                                          //                       //   ],
                                          //                       // ),
                                          //                     ],
                                          //                   ),
                                          //                 ],
                                          //               ),
                                          //               Row(
                                          //                 children: [
                                          //                   InkWell(
                                          //                     onTap: () {
                                          //                       Navigator.push(
                                          //                         context,
                                          //                         MaterialPageRoute(
                                          //                             builder: (context) => ViewReceipt(
                                          //                                 widget
                                          //                                     .token,
                                          //                                 items[index]
                                          //                                     .id
                                          //                                     .toString(),
                                          //                                 items[index]
                                          //                                     .clientId
                                          //                                     .toString(),
                                          //                                 items[index]
                                          //                                     .receiptNumber
                                          //                                     .toString())),
                                          //                       );
                                          //                     },
                                          //                     child: Container(
                                          //                       decoration: BoxDecoration(
                                          //                           borderRadius:
                                          //                               BorderRadius
                                          //                                   .circular(
                                          //                                       2),
                                          //                           color: const Color(
                                          //                               0xffe9d9fd)),
                                          //                       child:
                                          //                           const Padding(
                                          //                         padding:
                                          //                             EdgeInsets
                                          //                                 .all(
                                          //                                     8.0),
                                          //                         child: Icon(
                                          //                             Icons
                                          //                                 .local_print_shop_outlined,
                                          //                             color: Color(
                                          //                                 0xff9747FF)),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   const SizedBox(
                                          //                     width: 10,
                                          //                   ),
                                          //                   InkWell(
                                          //                     onTap: () {
                                          //                       Navigator.push(
                                          //                         context,
                                          //                         MaterialPageRoute(
                                          //                             builder: (context) => EditReceipt(
                                          //                                 widget
                                          //                                     .token,
                                          //                                 items[index]
                                          //                                     .id
                                          //                                     .toString())),
                                          //                       ).then((_) {
                                          //                         items.clear();
                                          //                         page = 1;
                                          //                         add = 1;
                                          //                         getData();
                                          //                       });
                                          //                     },
                                          //                     child: Container(
                                          //                       decoration: BoxDecoration(
                                          //                           borderRadius:
                                          //                               BorderRadius
                                          //                                   .circular(
                                          //                                       2),
                                          //                           color: const Color(
                                          //                               0xffaedcf4)),
                                          //                       child:
                                          //                           const Padding(
                                          //                         padding:
                                          //                             EdgeInsets
                                          //                                 .all(
                                          //                                     8.0),
                                          //                         child: Icon(
                                          //                             Icons
                                          //                                 .mode_edit_outlined,
                                          //                             color: Colors
                                          //                                 .blue),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   const SizedBox(
                                          //                     width: 10,
                                          //                   ),
                                          //                   InkWell(
                                          //                     onTap: () {
                                          //                       showDialog(
                                          //                           context:
                                          //                               context,
                                          //                           builder:
                                          //                               (BuildContext
                                          //                                   context) {
                                          //                             return AlertDialog(
                                          //                               scrollable:
                                          //                                   true,
                                          //                               title: const Text(
                                          //                                   'Please Confirm'),
                                          //                               content:
                                          //                                   const Text('Are you sure to Delete?'),
                                          //                               actions: [
                                          //                                 TextButton(
                                          //                                     onPressed: () {
                                          //                                       Navigator.of(context).pop();
                                          //                                     },
                                          //                                     child: const Text('No')),
                                          //                                 TextButton(
                                          //                                     onPressed: () async {
                                          //                                       Common.showProgressDialog(context, "Loading..");
                                          //                                       ReceiptDeleteModel deleteReceipt = await HttpService.deleteReceipt(widget.token, items[index].id);
                                          //                                       if (deleteReceipt.data == true) {
                                          //                                         Common.toastMessaage(deleteReceipt.message, Colors.green);
                                          //                                         if (context.mounted) {
                                          //                                           getData();
                                          //                                           Navigator.pop(context);
                                          //                                           Navigator.pop(context);
                                          //                                         }
                                          //                                       } else {
                                          //                                         Common.toastMessaage(deleteReceipt.message, Colors.red);
                                          //                                         if (context.mounted) {
                                          //                                           Navigator.of(context).pop();
                                          //                                         }
                                          //                                       }
                                          //                                     },
                                          //                                     child: const Text('Yes')),
                                          //                               ],
                                          //                             );
                                          //                           });
                                          //                     },
                                          //                     child: Container(
                                          //                       decoration: BoxDecoration(
                                          //                           borderRadius:
                                          //                               BorderRadius
                                          //                                   .circular(
                                          //                                       2),
                                          //                           color: const Color(
                                          //                               0xfffcbcbc)),
                                          //                       child:
                                          //                           const Padding(
                                          //                         padding:
                                          //                             EdgeInsets
                                          //                                 .all(
                                          //                                     8.0),
                                          //                         child: Icon(
                                          //                             Icons
                                          //                                 .delete_outline,
                                          //                             color: Colors
                                          //                                 .red),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   const SizedBox(
                                          //                     width: 10,
                                          //                   ),
                                          //                   items[index].uploadedFile !=
                                          //                           ''
                                          //                       ? InkWell(
                                          //                           onTap: () {
                                          //                             Navigator
                                          //                                 .push(
                                          //                               context,
                                          //                               MaterialPageRoute(
                                          //                                   builder: (context) =>
                                          //                                       WebViewPage('image', items[index].uploadedFile.toString())),
                                          //                             );
                                          //                           },
                                          //                           child:
                                          //                               Container(
                                          //                             decoration: BoxDecoration(
                                          //                                 borderRadius: BorderRadius.circular(
                                          //                                     2),
                                          //                                 color: Colors
                                          //                                     .green
                                          //                                     .shade100),
                                          //                             child:
                                          //                                 const Padding(
                                          //                               padding:
                                          //                                   EdgeInsets.all(8.0),
                                          //                               child: Icon(
                                          //                                   Icons
                                          //                                       .screenshot,
                                          //                                   color:
                                          //                                       Colors.green),
                                          //                             ),
                                          //                           ),
                                          //                         )
                                          //                       : const SizedBox()
                                          //                 ],
                                          //               )
                                          //             ],
                                          //           )
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ),
                                          // );

                                          if (_isDetailedView) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewReceipt(
                                                            widget.token,
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
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                        spreadRadius: 0.5,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(1, 1),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 10.0),
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
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ClientDetails(
                                                                              widget.token,
                                                                              items[index].clientId.toString(),
                                                                            )),
                                                                  ).then((_) {
                                                                    items
                                                                        .clear();
                                                                    page = 1;
                                                                    add = 1;
                                                                    getData();
                                                                  });
                                                                },
                                                                child: Text(
                                                                  items[index]
                                                                      .customerName
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Row(children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2),
                                                                  color: const Color(
                                                                      0xffe6fbec),
                                                                ),
                                                                child: Text(
                                                                  items[index]
                                                                      .recieptAmount
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              PopupMenuButton<
                                                                  String>(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                onSelected:
                                                                    (value) {
                                                                  if (value ==
                                                                      'print') {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ViewReceipt(
                                                                                widget.token,
                                                                                items[index].id.toString(),
                                                                                items[index].clientId.toString(),
                                                                                items[index].receiptNumber.toString(),
                                                                              )),
                                                                    );
                                                                  } else if (value ==
                                                                      'edit') {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              EditReceipt(
                                                                                widget.token,
                                                                                items[index].id.toString(),
                                                                              )),
                                                                    ).then((_) {
                                                                      items
                                                                          .clear();
                                                                      page = 1;
                                                                      add = 1;
                                                                      getData();
                                                                    });
                                                                  } else if (value ==
                                                                      'delete') {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Please Confirm'),
                                                                          content:
                                                                              const Text('Are you sure to Delete?'),
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
                                                                  }
                                                                },
                                                                itemBuilder:
                                                                    (context) =>
                                                                        [
                                                                  const PopupMenuItem(
                                                                      value:
                                                                          'print',
                                                                      child: Text(
                                                                          'Print')),
                                                                  const PopupMenuItem(
                                                                      value:
                                                                          'edit',
                                                                      child: Text(
                                                                          'Edit')),
                                                                  const PopupMenuItem(
                                                                      value:
                                                                          'delete',
                                                                      child: Text(
                                                                          'Delete')),
                                                                ],
                                                                icon: const Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    size: 18),
                                                              ),
                                                            ]),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(children: [
                                                          Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              color:
                                                                  Colors.grey,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                              items[index]
                                                                  .receiptDate,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
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
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
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
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(1, 1),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      14.0),
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
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ClientDetails(
                                                                          widget
                                                                              .token,
                                                                          items[index]
                                                                              .clientId
                                                                              .toString())),
                                                                ).then((_) {
                                                                  items.clear();
                                                                  page = 1;
                                                                  add = 1;
                                                                  getData();
                                                                });
                                                              },
                                                              child: Text(
                                                                  items[index]
                                                                      .customerName
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  )),
                                                            ),
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2),
                                                                color: const Color(
                                                                    0xffe6fbec)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            12,
                                                                        top: 6,
                                                                        bottom:
                                                                            6),
                                                                child: Text(
                                                                    items[index]
                                                                        .recieptAmount
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    )),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
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
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
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
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Icon(
                                                            Icons.person,
                                                            color: Colors.grey,
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
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.6,
                                                                child: Text(
                                                                    "Collected by : ${items[index].collectedStaff} ",
                                                                    maxLines: 1,
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
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .calendar_month,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                          items[index]
                                                                              .receiptDate
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
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
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => ViewReceipt(
                                                                            widget.token,
                                                                            items[index].id.toString(),
                                                                            items[index].clientId.toString(),
                                                                            items[index].receiptNumber.toString())),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xffe9d9fd)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .local_print_shop_outlined,
                                                                        color: Color(
                                                                            0xff9747FF)),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => EditReceipt(
                                                                            widget.token,
                                                                            items[index].id.toString())),
                                                                  ).then((_) {
                                                                    items
                                                                        .clear();
                                                                    page = 1;
                                                                    add = 1;
                                                                    getData();
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xffaedcf4)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .mode_edit_outlined,
                                                                        color: Colors
                                                                            .blue),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              InkWell(
                                                                onTap: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          scrollable:
                                                                              true,
                                                                          title:
                                                                              const Text('Please Confirm'),
                                                                          content:
                                                                              const Text('Are you sure to Delete?'),
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
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xfffcbcbc)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .delete_outline,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              items[index].uploadedFile !=
                                                                      ''
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => WebViewPage('image', items[index].uploadedFile.toString())),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2),
                                                                            color: Colors.green.shade100),
                                                                        child:
                                                                            const Padding(
                                                                          padding:
                                                                              EdgeInsets.all(8.0),
                                                                          child: Icon(
                                                                              Icons.screenshot,
                                                                              color: Colors.green),
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
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                          )
                        ],
                      ),
                      items.isNotEmpty
                          ? Container(
                              height: 50.0,
                              color: Colors.grey.shade200,
                              child: Center(
                                  child: Text(
                                'Total : ${receiptList!.data.receiptSum}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                            )
                          : const SizedBox()
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
