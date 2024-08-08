import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:login2/screens/leadManagement/add_followup.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/BulkTransferLeadModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/bulkDeleteLeadModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/leadManagement/leadDetails.dart';
import '../../service/service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ignore: must_be_immutable
class ViewLeads extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? categoryName;
  String? staffName;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;
  int? page;
  int? pageSize;
  String? leadType;

  ViewLeads(this.token, this.editLead, this.deleteLead, this.cloudCall,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrollToIndex,
      this.page,
      this.pageSize,
      this.leadType,
      this.categoryName,
      this.staffName});

  @override
  State<ViewLeads> createState() => _ViewLeadsState();
}

class _ViewLeadsState extends State<ViewLeads> {
  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  bool? result = true;
  bool? result1 = true;
  DateTime? fromdate;
  DateTime? todate;
  var outputFormat = DateFormat('dd-MM-yyyy');
  dynamic status;
  dynamic staff;
  dynamic priority;
  dynamic transferStaff;
  bool? isCalled = true;
  List selectedIUsers = [];
  List selectedUserNumbers = [];
  bool searchField = false;
  final List<Color> _colors = [
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
  ];
  CommonConfigureModel? configure;
  bool isSort = true;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<Detail> items = [];
  int page = 1;
  int pageSize = 20;
  bool isLoading = false;
  String statusWise = '';
  String statusWiseId = '';
  String statusCatId = '';
  String type = '';
  String? branch;
  String roleId = '';
  String multiBranch = '';
  String phoneCallLogPermission = '';
  bool timeOut = false;
  List checkedResponseItems = [];
  List checkedresponseItemsName = [];
  List checkedCategoryItems = [];
  List checkedCategoryItemsName = [];
  List checkedPriorityItems = [];
  List checkedPriorityItemsName = [];
  List checkedAssignedStaffItems = [];
  List checkedAssignedStaffItemsName = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Set up animation controller
    if (widget.staff != null) {
      checkedAssignedStaffItems.add(widget.staff);
      checkedAssignedStaffItemsName.add(widget.staffName);
    }
    if (widget.category != null) {
      checkedCategoryItems.add(widget.category);
      checkedCategoryItemsName.add(widget.categoryName);
    }
    if (widget.page != null) {
      page = widget.page! - 1;
    }
    if (widget.pageSize != null) {
      pageSize = widget.pageSize!;
    }
    //print(widget.fromDate.toString());
    // fromdate = DateTime.parse(widget.fromDate.toString());
    // todate = DateTime.parse(widget.toDate.toString());
    status = widget.status == "0" ? null : widget.status;
    staff = widget.staff;
    if (isCalled == false) {
      isCalled = widget.isCalled!;
    }
    if (widget.pageName == "Followup Leads") {
      isCalled = false;
      fromdate = DateTime.now();
    } else if (widget.pageName == "Closed Leads" ||
        widget.pageName == "Total Called" ||
        widget.pageName == "Rejected Leads") {
      fromdate = DateTime.parse(widget.fromDate.toString());
      todate = DateTime.now();
    }
    getData('desc', true, status);
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.last.index ==
          items.length - 1) {
        if (items.length < viewLeads!.data.totalLeads) {
          getData('desc', false, status);
        }
      }
    });
  }

  void getData(sort, isFirst, status1) async {
    //print('scrollIndex1:${widget.scrollToIndex}');
    setState(() {
      timeOut = false;
    });
    try {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
        selectedIUsers.clear();
        selectedUserNumbers.clear();
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
        statusWise = await Common.getSharedPref("statusWise");
        roleId = await Common.getSharedPref("roleId");
        multiBranch = await Common.getSharedPref("multiBranch");
        setState(() {});
        if (statusWise == 'yes') {
          statusWiseId = await Common.getSharedPref("statusWisId");
          statusCatId = await Common.getSharedPref("statusCatId");
          type = await Common.getSharedPref("type");
          viewLeads = await HttpService.viewLeadsSts(
              widget.token,
              fromdate,
              todate,
              type,
              statusCatId,
              statusWiseId,
              sort,
              page,
              pageSize,
              isFirst,
              branch);
          if (viewLeads != null) {
            // fromdate = DateTime.parse(viewLeads!.data!.fromdate.toString());
            // todate = DateTime.parse(viewLeads!.data!.todate.toString());
            setState(() {});
          }
        } else {
          try {
            Map<String, dynamic> body = {
              "token": widget.token,
              if (fromdate != null) "fromDate": outputFormat.format(fromdate!),
              if (todate != null) "toDate": outputFormat.format(todate!),
              if (fromdate == null) "fromDate": "",
              if (todate == null) "toDate": "",
              "callResultId": status1 ?? "",
              //status1 == "-1" ? "" : status1,
              "leadCategoryId": checkedCategoryItems,
              "callResponseId": checkedResponseItems,
              "staffId": checkedAssignedStaffItems,
              "isCalled": isCalled,
              "priority": checkedPriorityItems,
              "sort": sort,
              "page": page,
              "pageSize": pageSize,
              "isFirst": isFirst,
              "leadType": widget.leadType ?? "",
              "branchId": branch ?? ""
            };
            log(body.toString());
            viewLeads = await HttpService.viewLeads(body);
          } catch (e) {
            log(e.toString());
          }
        }
        if (viewLeads != null) {
          //  if()   {fromdate = DateTime.parse(viewLeads!.data!.fromdate.toString());}
          //   if()  { todate = DateTime.parse(viewLeads!.data!.todate.toString());}
          setState(() {});
        }
        commonDetails = await HttpService.addLeadCommonData(widget.token);
        if (commonDetails != null) {
          setState(() {});
        }
        configure = await HttpService.configure(widget.token);
        setState(() {
          items.addAll(viewLeads!.data.details);
          page++;
          isLoading = false;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        timeOut = true;
      });
      log("error: $e");
    }
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        items.clear();
        page = 1;
        getData('desc', false, status);
        return;
      },
      child: result == true && timeOut == false
          ? Scaffold(
              backgroundColor: Colors.grey.shade200,
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
                        left: 10.0, top: 10.0, bottom: 10.0, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            searchField == true
                                ? TextFormField(
                                    onChanged: (value) {
                                      // viewLeads = viewLeads!.data!.
                                      //     .where((viewLeads) => viewLeads
                                      //         .toLowerCase()
                                      //         .contains(value.toLowerCase()))
                                      //     .toList();
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'search',
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(Icons.person,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : Text(
                                    widget.pageName.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          ],
                        ),
                        Row(
                          children: [
                            selectedIUsers.isNotEmpty
                                ? Row(
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Transfer'),
                                                      content:
                                                          FormField<String>(
                                                        builder:
                                                            (FormFieldState<
                                                                    String>
                                                                state) {
                                                          return Container(
                                                            height: 50,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.43,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade900,
                                                                    width: 0),
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            5))),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton<
                                                                      String>(
                                                                isExpanded:
                                                                    true,
                                                                hint:
                                                                    const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              20),
                                                                  child: Text(
                                                                      'Staff'),
                                                                ),
                                                                value:
                                                                    transferStaff,
                                                                items: commonDetails!
                                                                    .data
                                                                    .transferStaffs
                                                                    .map(
                                                                        (data) {
                                                                  return DropdownMenuItem(
                                                                    value: data
                                                                        .tranStaffId
                                                                        .toString(),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              20),
                                                                      child: Text(data
                                                                          .tranStaffName
                                                                          .toString()),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    (newValue1) {
                                                                  setState(() {
                                                                    transferStaff =
                                                                        newValue1;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'No')),
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              Common.showProgressDialog(
                                                                  context,
                                                                  "Loading..");
                                                              Map<String,
                                                                      dynamic>
                                                                  body = {
                                                                "token": widget
                                                                    .token,
                                                                'leadMasterIds':
                                                                    selectedIUsers,
                                                                'staffId':
                                                                    transferStaff
                                                              };
                                                              BulkTransferLeadModel
                                                                  bulkTransfer =
                                                                  await HttpService
                                                                      .bulkTransferLead(
                                                                          body);
                                                              if (bulkTransfer
                                                                      .data ==
                                                                  true) {
                                                                Common.toastMessaage(
                                                                    bulkTransfer
                                                                        .message,
                                                                    Colors
                                                                        .green);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                  page = 1;
                                                                  items.clear();
                                                                  getData(
                                                                      'desc',
                                                                      false,
                                                                      status);
                                                                }
                                                              } else {
                                                                Common.toastMessaage(
                                                                    bulkTransfer
                                                                        .message,
                                                                    Colors.red);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              }
                                                            },
                                                            child: const Text(
                                                                'Yes')),
                                                      ],
                                                    );
                                                  });
                                                });
                                          },
                                          child: const Icon(
                                            Icons.compare_arrows_rounded,
                                            color: Colors.white,
                                          )),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            if (widget.deleteLead == true) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Please Confirm'),
                                                      content: const Text(
                                                          'Are you sure to Delete Selected Leads?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'No')),
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              Map<String,
                                                                      dynamic>
                                                                  body = {
                                                                "token": widget
                                                                    .token,
                                                                'leadMasterIds':
                                                                    selectedIUsers,
                                                              };
                                                              BulkDeleteLeadModel
                                                                  deleteBulk =
                                                                  await HttpService
                                                                      .bulkDeleteLead(
                                                                          body);
                                                              if (deleteBulk
                                                                      .data ==
                                                                  true) {
                                                                Common.toastMessaage(
                                                                    deleteBulk
                                                                        .message,
                                                                    Colors
                                                                        .green);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  page = 1;
                                                                  items.clear();
                                                                  getData(
                                                                      'desc',
                                                                      false,
                                                                      status);
                                                                }
                                                              } else {
                                                                Common.toastMessaage(
                                                                    deleteBulk
                                                                        .message,
                                                                    Colors.red);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              }
                                                            },
                                                            child: const Text(
                                                                'Yes')),
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              Common.toastMessaage(
                                                  "You don't have permission to delete",
                                                  Colors.red);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ],
                                  )
                                : const SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              body: viewLeads != null && configure != null
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 10, top: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  fromdate == null || todate == null
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            const Text('Date from ',
                                                style: TextStyle(fontSize: 16)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(outputFormat.format(fromdate!),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(' to ',
                                                style: TextStyle(fontSize: 16)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(outputFormat.format(todate!),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      'Total Leads : ${viewLeads!.data.totalLeads}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  filtrationSheet(context);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: const Color(0xFFd5f5f4),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Image.asset(
                                          "assets/icons/filter.png",
                                          width: 20)),
                                ),
                              )
                            ],
                          ),
                        ),
                        viewLeads!.data.details.isNotEmpty
                            ? Expanded(
                                child: ScrollablePositionedList.builder(
                                  //reverse: true,
                                  initialScrollIndex:
                                      widget.scrollToIndex == null
                                          ? 0
                                          : widget.scrollToIndex!,
                                  //you can pass the desired index here//
                                  itemCount: items.length + (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == items.length) {
                                      // When reaching the end of the list, show a loader
                                      return _buildLoaderListItem();
                                    }
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
                                                Icons.call,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                " Call",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
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
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "Add Followup",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.right,
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
                                            DismissDirection.endToStart) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddFollowup(
                                                      widget.token,
                                                      widget.editLead,
                                                      widget.deleteLead,
                                                      widget.cloudCall,
                                                      items[index].callMasterId,
                                                      pageName: widget.pageName,
                                                      status: widget.status,
                                                      staff: widget.staff,
                                                      isCalled: widget.isCalled,
                                                      fromDate: widget.fromDate,
                                                      toDate: widget.toDate,
                                                      category: widget.category,
                                                      leadType: items[index]
                                                          .leadCategory,
                                                      leadTypeId: items[index]
                                                          .leadCategoryId,
                                                      leadSubType: items[index]
                                                          .leadSubCategory,
                                                      leadSubTypeId: items[
                                                              index]
                                                          .leadSubCategoryId,
                                                      priorityId:
                                                          items[index].priority,
                                                      priority: items[index]
                                                          .priorityName,
                                                      cost: items[index].cost,
                                                      address:
                                                          items[index].address,
                                                      leadType1:
                                                          widget.leadType,
                                                    )),
                                          ).then((value) {
                                            items.clear();
                                            page = 1;
                                            getData('desc', true, status);
                                          });
                                        } else {
                                          if (viewLeads!.data.callPermission ==
                                              false) {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext ctx) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Alert !!!'),
                                                    content: Text(viewLeads!
                                                        .data.warningMessage
                                                        .toString()),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Close')),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => LeadDetails(
                                                                      widget
                                                                          .token!,
                                                                      widget
                                                                          .editLead,
                                                                      widget
                                                                          .deleteLead,
                                                                      widget
                                                                          .cloudCall,
                                                                      viewLeads!
                                                                          .data
                                                                          .callLeadId
                                                                          .toString(),
                                                                      pageName: widget
                                                                          .pageName
                                                                          .toString(),
                                                                      status: widget
                                                                          .status,
                                                                      staff: widget
                                                                          .staff,
                                                                      isCalled:
                                                                          widget
                                                                              .isCalled,
                                                                      fromDate:
                                                                          widget
                                                                              .fromDate,
                                                                      toDate: widget
                                                                          .toDate,
                                                                      category:
                                                                          widget
                                                                              .category,
                                                                      scrollToIndex:
                                                                          index,
                                                                      page:
                                                                          page,
                                                                      pageSize:
                                                                          page *
                                                                              pageSize,
                                                                      leadType:
                                                                          widget
                                                                              .leadType)),
                                                            ).then((r) {
                                                              items.clear();
                                                              page = 1;
                                                              getData('desc',
                                                                  true, status);
                                                              // itemPositionsListener
                                                              //     .itemPositions
                                                              //     .addListener(
                                                              //         () {
                                                              //   if (itemPositionsListener
                                                              //           .itemPositions
                                                              //           .value
                                                              //           .last
                                                              //           .index ==
                                                              //       items.length -
                                                              //           1) {
                                                              //     if (items
                                                              //             .length <
                                                              //         viewLeads!
                                                              //             .data!
                                                              //             .totalLeads!) {
                                                              //       getData(
                                                              //           'desc',
                                                              //           true);
                                                              //     }
                                                              //   }
                                                              // });
                                                            });
                                                          },
                                                          child: const Text(
                                                              'followup')),
                                                    ],
                                                  );
                                                });
                                          } else {
                                            if (widget.cloudCall == true) {
                                              chooseCallDialog(context, index);
                                            } else {
                                              // String url =
                                              //     'tel:+${items[index].contactNumber1}';
                                              // await launchUrl(Uri.parse(url));
                                              Common.directCall(
                                                  items[index].contactNumber1);
                                            }
                                          }
                                        }
                                        return null;
                                      },
                                      child: InkWell(
                                          onLongPress: () {
                                            setState(() {
                                              items[index].isSelected =
                                                  !items[index].isSelected;
                                              if (items[index].isSelected ==
                                                  true) {
                                                selectedIUsers.add(
                                                    items[index].callMasterId);
                                                selectedUserNumbers.add(
                                                    items[index]
                                                        .contactNumber1);
                                              } else {
                                                selectedIUsers.remove(
                                                    items[index].callMasterId);
                                                selectedUserNumbers.remove(
                                                    items[index]
                                                        .contactNumber1);
                                              }
                                            });
                                          },
                                          onTap: () {
                                            selectedIUsers.isNotEmpty
                                                ? setState(() {
                                                    items[index].isSelected =
                                                        !items[index]
                                                            .isSelected!;
                                                    if (items[index]
                                                            .isSelected ==
                                                        true) {
                                                      selectedIUsers.add(
                                                          items[index]
                                                              .callMasterId);
                                                      selectedUserNumbers.add(
                                                          items[index]
                                                              .contactNumber1);
                                                    } else {
                                                      selectedIUsers.remove(
                                                          items[index]
                                                              .callMasterId);
                                                      selectedUserNumbers
                                                          .remove(items[index]
                                                              .contactNumber1);
                                                    }
                                                  })
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LeadDetails(
                                                                widget.token!,
                                                                widget.editLead,
                                                                widget
                                                                    .deleteLead,
                                                                widget
                                                                    .cloudCall,
                                                                items[index]
                                                                    .callMasterId
                                                                    .toString(),
                                                                pageName: widget
                                                                    .pageName
                                                                    .toString(),
                                                                status: widget
                                                                    .status,
                                                                staff: widget
                                                                    .staff,
                                                                isCalled: widget
                                                                    .isCalled,
                                                                fromDate: widget
                                                                    .fromDate,
                                                                toDate: widget
                                                                    .toDate,
                                                                category: widget
                                                                    .category,
                                                                scrollToIndex:
                                                                    index,
                                                                page: page,
                                                                pageSize: page *
                                                                    pageSize,
                                                                leadType: widget
                                                                    .leadType)),
                                                  ).then((r) {
                                                    items.clear();
                                                    page = 1;
                                                    getData(
                                                        'desc', true, status);
                                                    // itemPositionsListener
                                                    //     .itemPositions
                                                    //     .addListener(() {
                                                    //   if (itemPositionsListener
                                                    //           .itemPositions
                                                    //           .value
                                                    //           .last
                                                    //           .index ==
                                                    //       items.length - 1) {
                                                    //     if (items.length <
                                                    //         viewLeads!.data!
                                                    //             .totalLeads!) {
                                                    //       getData('desc', true);
                                                    //     }
                                                    //   }
                                                    // });
                                                  });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              decoration: BoxDecoration(
                                                color:
                                                    items[index].isSelected ==
                                                            false
                                                        ? Colors.white
                                                        : Colors.blue.shade100,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(2.0, 2.0),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 10,
                                                            left: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .88,
                                                            child: Stack(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    if (items[index]
                                                                            .priority ==
                                                                        '1')
                                                                      Container(
                                                                        width:
                                                                            10.0,
                                                                        height:
                                                                            10.0,
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.grey,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    if (items[index]
                                                                            .priority ==
                                                                        '2')
                                                                      Container(
                                                                        width:
                                                                            10.0,
                                                                        height:
                                                                            10.0,
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.green,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    if (items[index]
                                                                            .priority ==
                                                                        '3')
                                                                      Container(
                                                                        width:
                                                                            10.0,
                                                                        height:
                                                                            10.0,
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.red,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .46,
                                                                      child:
                                                                          Text(
                                                                        items[index]
                                                                            .clientName
                                                                            .toString(),
                                                                        // items.length.toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.pink.shade100,
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 2,
                                                                              bottom: 2),
                                                                          child:
                                                                              Text(
                                                                            items[index].leadCategory.toString(),
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.red,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            softWrap:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Visibility(
                                                                      visible: items[index].categoryCount.toString() !=
                                                                              "1" &&
                                                                          items[index].categoryCount.toString() !=
                                                                              "",
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                        decoration: const BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            shape: BoxShape.circle),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            items[index].categoryCount.toString(),
                                                                            // items.length.toString(),
                                                                            style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.68,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          items[index]
                                                                              .contactNumber1
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.black54,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 150,
                                                                              child: Text(
                                                                                'Assigned to : ${items[index].staffName}',
                                                                                style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(color: _colors[items[index].callResultId!], borderRadius: BorderRadius.circular(5)),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                                                                                child: Text(
                                                                                  items[index].callResult.toString(),
                                                                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        items[index].callResultId ==
                                                                                1
                                                                            ? Container(
                                                                                decoration: BoxDecoration(color: const Color(0xFFd5f5f4), borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Image.asset("assets/icons/calendar.png", width: 20),
                                                                                      const SizedBox(
                                                                                        width: 15,
                                                                                      ),
                                                                                      Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          const Text(
                                                                                            'Created Time',
                                                                                            style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 3,
                                                                                          ),
                                                                                          Text(
                                                                                            items[index].createdDate.toString(),
                                                                                            style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: const Color(0xFFd5f5f4), borderRadius: BorderRadius.circular(5)),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Image.asset("assets/icons/calendar.png", width: 20),
                                                                                          const SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          Column(
                                                                                            children: [
                                                                                              const Text(
                                                                                                'Called Date',
                                                                                                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                height: 3,
                                                                                              ),
                                                                                              Text(
                                                                                                items[index].isCalled == false ? '--' : items[index].calledDate.toString(),
                                                                                                style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: const Color(0xFFd5f5f4), borderRadius: BorderRadius.circular(5)),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Image.asset("assets/icons/calendar.png", width: 20),
                                                                                          const SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          Column(
                                                                                            children: [
                                                                                              const Text(
                                                                                                'Followup Date',
                                                                                                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                height: 3,
                                                                                              ),
                                                                                              Text(
                                                                                                items[index].scheduledDate.toString(),
                                                                                                style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                    maxHeight:
                                                                        60,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      minHeight:
                                                                          20,
                                                                      minWidth:
                                                                          20,
                                                                      maxHeight:
                                                                          50,
                                                                      maxWidth:
                                                                          50,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .white,
                                                                          width:
                                                                              0),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                            color: Colors
                                                                                .grey,
                                                                            blurRadius:
                                                                                5,
                                                                            offset:
                                                                                Offset(1, 1)),
                                                                      ],
                                                                      color: Colors
                                                                          .white,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: DecorationImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          image: NetworkImage(items[index]
                                                                              .profilePic
                                                                              .toString())),
                                                                      // image: AssetImage(
                                                                      //     'assets/images/img.jpeg')),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (viewLeads!
                                                                            .data
                                                                            .callPermission ==
                                                                        false) {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext ctx) {
                                                                            return AlertDialog(
                                                                              title: const Text('Alert !!!'),
                                                                              content: Text(viewLeads!.data.warningMessage.toString()),
                                                                              actions: [
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('Close')),
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) => LeadDetails(widget.token!, widget.editLead, widget.deleteLead, widget.cloudCall, viewLeads!.data.callLeadId.toString(), pageName: widget.pageName.toString(), status: widget.status, staff: widget.staff, isCalled: widget.isCalled, fromDate: widget.fromDate, toDate: widget.toDate, category: widget.category, scrollToIndex: index, page: page, pageSize: page * pageSize, leadType: widget.leadType)),
                                                                                      ).then((r) {
                                                                                        items.clear();
                                                                                        page = 1;
                                                                                        getData('desc', true, status);
                                                                                        // itemPositionsListener.itemPositions.addListener(() {
                                                                                        //   if (itemPositionsListener.itemPositions.value.last.index == items.length - 1) {
                                                                                        //     if (items.length < viewLeads!.data!.totalLeads!) {
                                                                                        //       getData('desc', true);
                                                                                        //     }
                                                                                        //   }
                                                                                        // });
                                                                                      });
                                                                                    },
                                                                                    child: const Text('followup')),
                                                                              ],
                                                                            );
                                                                          });
                                                                    } else {
                                                                      if (widget
                                                                              .cloudCall ==
                                                                          true) {
                                                                        chooseCallDialog(
                                                                            context,
                                                                            index);
                                                                      } else {
                                                                        // String
                                                                        // url =
                                                                        //     'tel:+${items[index].contactNumber1}';
                                                                        // await launchUrl(
                                                                        //     Uri.parse(url));
                                                                        Common.directCall(
                                                                            '+${items[index].contactNumber1}');
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 65,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.call,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Call',
                                                                              style: TextStyle(fontFamily: "MontserratMedium", fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    );
                                  },
                                  itemScrollController: itemScrollController,
                                  itemPositionsListener: itemPositionsListener,
                                ),
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.asset(
                                        "assets/icons/nodatafound.png",
                                      ),
                                    ),
                                    const Text(
                                      'Result Not Found',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Whoops... this information is \n not available for a moment',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Dashboard(widget.token)),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                          child: Text('Go Back',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ],
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(widget.token)),
                  );
                },
                child: Image.asset("assets/icons/menu.png",
                    width: 25), //icon inside button
              ),
              bottomNavigationBar: configure != null
                  ? BottomNavigation(
                      widget.token!,
                      configure!.data!.whatsappConfigured,
                      phoneCallLogPermission: phoneCallLogPermission,
                    )
                  : const SizedBox())
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
                    Text(
                      textAlign: TextAlign.center,
                      timeOut == true
                          ? "There seems to be a temporary issue !, \n Please retry to continue"
                          : 'No Network Found !',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        page = 1;
                        items.clear();
                        getData('desc', true, status);
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
              )),
    );
  }

  Future<Object?> filtrationSheet(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: IntrinsicHeight(
                child: Container(
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
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          //<-- SEE HERE
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'From Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: fromdate.toString(),
                                      type: DateTimePickerType.date,

                                      //controller: fromDate,
                                      firstDate: DateTime(1995),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                      // This will add one year from current date
                                      validator: (value) {
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            fromdate = DateTime.parse(value);
                                          });
                                        }
                                      },
                                      // We can also use onSaved
                                      onSaved: (value) {
                                        if (value!.isNotEmpty) {
                                          fromdate = DateTime.parse(value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          //<-- SEE HERE
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'To Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: todate.toString(),
                                      type: DateTimePickerType.date,

                                      //controller: fromDate,
                                      firstDate: DateTime(1995),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                      // This will add one year from current date
                                      validator: (value) {
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            todate = DateTime.parse(value);
                                          });
                                        }
                                      },
                                      // We can also use onSaved
                                      onSaved: (value) {
                                        if (value!.isNotEmpty) {
                                          todate = DateTime.parse(value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        multiBranch == 'true' && roleId == '2'
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 13),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Branch',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: FormField<String>(
                                        builder:
                                            (FormFieldState<String> state) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey.shade900,
                                                    width: 0),
                                                color: Colors.white,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5))),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                hint: const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: Text('Branch'),
                                                ),
                                                value: branch,
                                                items: commonDetails!
                                                    .data.branch
                                                    .map((data) {
                                                  return DropdownMenuItem(
                                                    value: data.branchId
                                                        .toString(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20),
                                                      child: Text(data
                                                          .branchName
                                                          .toString()),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue1) {
                                                  setState(() {
                                                    branch = newValue1;
                                                  });
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Visibility(
                          visible: widget.pageName == "Total Called",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 13,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  FormField<String>(
                                    builder: (FormFieldState<String> state) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade900,
                                                width: 0),
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              child: Text('Status'),
                                            ),
                                            value: status,
                                            items: commonDetails!
                                                .data.callResult
                                                .map((data) {
                                              return DropdownMenuItem(
                                                value: data.callResultId
                                                    .toString(),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Text(data.callResult
                                                      .toString()),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                status = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 13,
                            ),
                            const Text('Lead Category'),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Lead Category'),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .32,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .8,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: commonDetails!
                                                .data.leadCategory.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!
                                                        .data
                                                        .leadCategory[ind]
                                                        .leadCategory
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedCategoryItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .leadCategory[ind]
                                                            .leadCategoryId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedCategoryItems.add(
                                                          commonDetails!
                                                              .data
                                                              .leadCategory[ind]
                                                              .leadCategoryId
                                                              .toString());
                                                      checkedCategoryItemsName
                                                          .add(commonDetails!
                                                              .data
                                                              .leadCategory[ind]
                                                              .leadCategory
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedCategoryItems
                                                          .remove(commonDetails!
                                                              .data
                                                              .leadCategory[ind]
                                                              .leadCategoryId
                                                              .toString());
                                                      checkedCategoryItemsName
                                                          .remove(commonDetails!
                                                              .data
                                                              .leadCategory[ind]
                                                              .leadCategory
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  }
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: checkedCategoryItems.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Lead Category'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedCategoryItemsName.length,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0),
                                                            color: Colors.white,
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6))),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Text(
                                                                  checkedCategoryItemsName[
                                                                      i],
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Please Confirm'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure to Remove this Number?'),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedCategoryItemsName.remove(checkedCategoryItemsName[i]);
                                                                            checkedCategoryItems.remove(checkedCategoryItems[i]);
                                                                          });
                                                                          // if (checkedItemsName.length > 1) {
                                                                          //   setState(() {
                                                                          //     checkedItemsName.remove(checkedItemsName[i]);
                                                                          //     checkedItems.remove(checkedItems[i]);
                                                                          //   });
                                                                          // }
                                                                          // else {
                                                                          //   ScaffoldMessenger.of(context).showSnackBar(
                                                                          //     const SnackBar(
                                                                          //       content: Text('Minimum 1 Number required'),
                                                                          //       backgroundColor: Colors.redAccent,
                                                                          //       elevation: 10,
                                                                          //       behavior: SnackBarBehavior.floating,
                                                                          //       margin: EdgeInsets.all(10),
                                                                          //     ),
                                                                          //   );
                                                                          // }
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 30,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0),
                                                              color: Colors.grey
                                                                  .shade100,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6))),
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority'),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Priority'),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .23,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .8,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: commonDetails!
                                                .data.priority.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!.data
                                                        .priority[ind].priority
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedPriorityItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .priority[ind]
                                                            .priorityId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedPriorityItems.add(
                                                          commonDetails!
                                                              .data
                                                              .priority[ind]
                                                              .priorityId
                                                              .toString());
                                                      checkedPriorityItemsName
                                                          .add(commonDetails!
                                                              .data
                                                              .priority[ind]
                                                              .priority
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedPriorityItems
                                                          .remove(commonDetails!
                                                              .data
                                                              .priority[ind]
                                                              .priorityId
                                                              .toString());
                                                      checkedPriorityItemsName
                                                          .remove(commonDetails!
                                                              .data
                                                              .priority[ind]
                                                              .priority
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  }
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: checkedPriorityItems.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Priority'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedPriorityItemsName.length,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0),
                                                            color: Colors.white,
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6))),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Text(
                                                                  checkedPriorityItemsName[
                                                                      i],
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Please Confirm'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure to Remove this Number?'),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedPriorityItemsName.remove(checkedPriorityItemsName[i]);
                                                                            checkedPriorityItems.remove(checkedPriorityItems[i]);
                                                                          });

                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 30,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0),
                                                              color: Colors.grey
                                                                  .shade100,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6))),
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Assigned Staff'),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Assign Staff'),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .32,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .8,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: commonDetails!
                                                .data.staff.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!.data
                                                        .staff[ind].staffName
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedAssignedStaffItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .staff[ind]
                                                            .staffId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedAssignedStaffItems
                                                          .add(commonDetails!
                                                              .data
                                                              .staff[ind]
                                                              .staffId
                                                              .toString());
                                                      checkedAssignedStaffItemsName
                                                          .add(commonDetails!
                                                              .data
                                                              .staff[ind]
                                                              .staffName
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedAssignedStaffItems
                                                          .remove(commonDetails!
                                                              .data
                                                              .staff[ind]
                                                              .staffId
                                                              .toString());
                                                      checkedAssignedStaffItemsName
                                                          .remove(commonDetails!
                                                              .data
                                                              .staff[ind]
                                                              .staffName
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  }
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: checkedAssignedStaffItems.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Assigned Staff'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedAssignedStaffItemsName
                                                    .length,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0),
                                                            color: Colors.white,
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6))),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Text(
                                                                  checkedAssignedStaffItemsName[
                                                                      i],
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Please Confirm'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure to Remove this Number?'),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedAssignedStaffItemsName.remove(checkedAssignedStaffItemsName[i]);
                                                                            checkedAssignedStaffItems.remove(checkedAssignedStaffItems[i]);
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 30,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0),
                                                              color: Colors.grey
                                                                  .shade100,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6))),
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: widget.pageName == "Total Called",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 13,
                              ),
                              const Text('Call Response',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                              const SizedBox(
                                height: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          title: const Text('Call Response'),
                                          content: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .32,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .8,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: commonDetails!.data
                                                  .callResponseStatus.length,
                                              itemBuilder: (context, ind) {
                                                return CheckboxListTile(
                                                  title: SizedBox(
                                                    width: 200,
                                                    child: Text(
                                                      commonDetails!
                                                          .data
                                                          .callResponseStatus[
                                                              ind]
                                                          .callResponse
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  value: checkedResponseItems
                                                          .contains(commonDetails!
                                                              .data
                                                              .callResponseStatus[
                                                                  ind]
                                                              .callResponseId
                                                              .toString())
                                                      ? true
                                                      : false,
                                                  onChanged: (bool? value) {
                                                    if (value == true) {
                                                      setState(() {
                                                        checkedResponseItems
                                                            .add(commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponseId
                                                                .toString());
                                                        checkedresponseItemsName
                                                            .add(commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponse
                                                                .toString());

                                                        Navigator.pop(
                                                            context, true);
                                                      });
                                                    } else {
                                                      setState(() {
                                                        checkedResponseItems
                                                            .remove(commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponseId
                                                                .toString());
                                                        checkedresponseItemsName
                                                            .remove(commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponse
                                                                .toString());

                                                        Navigator.pop(
                                                            context, true);
                                                      });
                                                    }
                                                  },
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: checkedResponseItems.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15, bottom: 10),
                                          child: Text('Call Response'))
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(right: 40),
                                          child: SizedBox(
                                            height: 35,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  checkedresponseItemsName
                                                      .length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {});
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0),
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          6))),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  child: Text(
                                                                    checkedresponseItemsName[
                                                                        i],
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Please Confirm'),
                                                                    content:
                                                                        const Text(
                                                                            'Are you sure to Remove this Number?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('No')),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            setState(() {
                                                                              checkedresponseItemsName.remove(checkedresponseItemsName[i]);
                                                                              checkedResponseItems.remove(checkedResponseItems[i]);
                                                                            });
                                                                            // if (checkedItemsName.length > 1) {
                                                                            //   setState(() {
                                                                            //     checkedItemsName.remove(checkedItemsName[i]);
                                                                            //     checkedItems.remove(checkedItems[i]);
                                                                            //   });
                                                                            // }
                                                                            // else {
                                                                            //   ScaffoldMessenger.of(context).showSnackBar(
                                                                            //     const SnackBar(
                                                                            //       content: Text('Minimum 1 Number required'),
                                                                            //       backgroundColor: Colors.redAccent,
                                                                            //       elevation: 10,
                                                                            //       behavior: SnackBarBehavior.floating,
                                                                            //       margin: EdgeInsets.all(10),
                                                                            //     ),
                                                                            //   );
                                                                            // }
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('Yes')),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          child: Container(
                                                            height: 35,
                                                            width: 30,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 0),
                                                                color: Colors.grey
                                                                    .shade100,
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            6),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            6))),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                items.clear();
                                page = 1;
                                pageSize = 20;
                                getData('desc', true, status);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });
                            },
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
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

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Choose Call Type'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    Common.showProgressDialog(context, "Loading..");
                    CloudCallModel object1 = await HttpService.addCloudCall(
                        widget.token,
                        items[index].callMasterId.toString(),
                        items[index].contactNumber1);
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, Colors.green);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      Common.toastMessaage(object1.message, Colors.red);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(
                            Icons.cloud_circle_rounded,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Cloud Call',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    Common.directCall('+${items[index].contactNumber1}');
                  },
                  child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5)),
                            child: const Icon(
                              Icons.call,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text(
                            'Phone Call',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildLoaderListItem() {
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
}

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Text(label));
  }
}
