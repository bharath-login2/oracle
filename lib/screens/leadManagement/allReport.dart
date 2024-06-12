// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/addFollowup.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/deleteLeadModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../service/service.dart';
import 'dashboard.dart';
import 'leadDetails.dart';

class AllReport extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String? pageName;
  int? page;
  int? pageSize;
  List? checkedCategoryItems;
  List? checkedCategoryItemsName;
  List? checkedCallResultItems;
  List? checkedCallResultItemsName;
  List? checkedPriorityItems;
  List? checkedPriorityItemsName;
  List? checkedAssignedStaffItems;
  List? checkedAssignedStaffItemsName;
  List? checkedCreatedStaffItems;
  List? checkedCreatedStaffItemsName;
  AllReport(this.token, this.editLead, this.deleteLead, this.cloudCall,
      {this.pageName,
      this.page,
      this.pageSize,
      this.checkedCategoryItems,
      this.checkedCategoryItemsName,
      this.checkedCallResultItems,
      this.checkedCallResultItemsName,
      this.checkedPriorityItems,
      this.checkedPriorityItemsName,
      this.checkedAssignedStaffItems,
      this.checkedAssignedStaffItemsName,
      this.checkedCreatedStaffItems,
      this.checkedCreatedStaffItemsName,
      Key? key})
      : super(key: key);

  @override
  State<AllReport> createState() => _AllReportState();
}

class _AllReportState extends State<AllReport> {
  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  bool? result = true;
  bool? result1 = true;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  bool? isCalled = true;
  List selectedIUsers = [];
  List selectedUserNumbers = [];
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
  List<dynamic> items = [];
  int page = 1;
  int pageSize = 20;
  bool isLoading = false;
  List checkedCategoryItems = [];
  List checkedCategoryItemsName = [];
  List checkedCallResultItems = [];
  List checkedCallResultItemsName = [];
  List checkedPriorityItems = [];
  List checkedPriorityItemsName = [];
  List checkedAssignedStaffItems = [];
  List checkedAssignedStaffItemsName = [];
  List checkedCreatedStaffItems = [];
  List checkedCreatedStaffItemsName = [];
  List checkedLeadSource = [];
  List checkedLeadSourceName = [];
  String? branch;
  String roleId = '';
  String multiBranch = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.last.index ==
          items.length - 1) {
        if (items.length < viewLeads!.data.totalLeads) {
          getData();
        }
      }
    });
  }

  void getData() async {
    //print('scrollIndex1:${widget.scrollToIndex}');

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
      // if (widget.page != null) {
      //   page = widget.page! - 1;
      // }
      // else if (widget.pageSize != null) {
      //   pageSize = widget.pageSize!;
      // }
      // else  if (widget.checkedCategoryItems != null) {checkedCategoryItems=widget.checkedCategoryItems!;}
      // else if(widget.checkedCategoryItemsName != null){ checkedCategoryItemsName=widget.checkedCategoryItemsName!;}
      // else if(widget.checkedCallResultItems!=null){  checkedCallResultItems=widget.checkedCallResultItems!;}
      // else if(widget.checkedCallResultItemsName!=null){  checkedCallResultItemsName=widget.checkedCallResultItemsName!;}
      // else if(widget.checkedPriorityItems!=null){  checkedPriorityItems=widget.checkedPriorityItems!;}
      // else if(widget.checkedPriorityItemsName!=null){  checkedPriorityItemsName=widget.checkedPriorityItemsName!;}
      // else if(widget.checkedAssignedStaffItems!=null){  checkedAssignedStaffItems=widget.checkedAssignedStaffItems!;}
      // else if(widget.checkedAssignedStaffItemsName!=null){  checkedAssignedStaffItemsName=widget.checkedAssignedStaffItemsName!;}
      // else if(widget.checkedCreatedStaffItems!=null){  checkedCreatedStaffItems=widget.checkedCreatedStaffItems!;}
      // else if(widget.checkedCreatedStaffItemsName!=null){  checkedCreatedStaffItemsName=widget.checkedCreatedStaffItemsName!;}
      //setState(() {});
      roleId = await Common.getSharedPref("roleId");
      multiBranch = await Common.getSharedPref("multiBranch");
      Map<String, dynamic> body = {
        "token": widget.token,
        "fromDate": outputFormat.format(fromdate),
        "toDate": outputFormat.format(todate),
        "page": page,
        "pageSize": pageSize,
        "callResultId": checkedCallResultItems,
        "leadCategoryId": checkedCategoryItems,
        "priority": checkedPriorityItems,
        "staffId": checkedAssignedStaffItems,
        "createdBy": checkedCreatedStaffItems,
        "branchId": branch,
        "lead_source_id": checkedLeadSource
      };
      //print(body);
      viewLeads = await HttpService.allViewLeads(body);
      if (viewLeads != null) {
        setState(() {});
      }

      commonDetails = await HttpService.addLeadCommonData(widget.token);
      if (commonDetails != null) {
        setState(() {});
      }
      configure = await HttpService.configure(widget.token);
      setState(() {
        items.addAll(viewLeads!.data.details as Iterable);
        page++;
        isLoading = false;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard(widget.token)),
                          );
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
                        'All Report',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: viewLeads != null && configure != null
            ? Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 10, top: 15),
                    child: Row(
                      children: [
                        const Text('Date from ',
                            style: TextStyle(fontSize: 16)),
                        Text(outputFormat.format(fromdate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text(' to ', style: TextStyle(fontSize: 16)),
                        Text(outputFormat.format(todate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          width: 15,
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
                                child: Image.asset("assets/icons/filter.png",
                                    width: 20)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text('Total Leads : ${viewLeads!.data.totalLeads}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  viewLeads!.data.details.isNotEmpty
                      ? Expanded(
                          child: ScrollablePositionedList.builder(
                            //reverse: true,
                            initialScrollIndex: 0,
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
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                          builder: (context) => AddFollowup(
                                                widget.token,
                                                widget.editLead,
                                                widget.deleteLead,
                                                widget.cloudCall,
                                                items[index].callMasterId,
                                                pageName: widget.pageName,
                                                leadType:
                                                    items[index].leadCategory,
                                                leadTypeId:
                                                    items[index].leadCategoryId,
                                                leadSubType: items[index]
                                                    .leadSubCategory,
                                                leadSubTypeId: items[index]
                                                    .leadSubCategoryId,
                                                priorityId:
                                                    items[index].priority,
                                                priority:
                                                    items[index].priorityName,
                                                cost: items[index].cost,
                                                address: items[index].address,
                                              )),
                                    ).then((value) {
                                      items.clear();
                                      page = 1;
                                      getData();
                                    });
                                    // showDialog(
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return AlertDialog(
                                    //         scrollable: true,
                                    //         title: const Text('Please Confirm'),
                                    //         content: const Text(
                                    //             'Are you sure to Delete?'),
                                    //         actions: [
                                    //           // The "Yes" button
                                    //           TextButton(
                                    //               onPressed: () async {
                                    //                 DeleteLeadModel delete =
                                    //                     await HttpService
                                    //                         .deleteLead(
                                    //                             widget.token,
                                    //                             items[index]
                                    //                                 .callMasterId);
                                    //                 if (delete.data == true) {
                                    //                   Common.toastMessaage(
                                    //                       delete.message,
                                    //                       Colors.green);
                                    //                   if (context.mounted) {
                                    //                     Navigator.push(
                                    //                       context,
                                    //                       MaterialPageRoute(
                                    //                           builder:
                                    //                               (context) =>
                                    //                                   AllReport(
                                    //                                     widget
                                    //                                         .token!,
                                    //                                     widget
                                    //                                         .editLead,
                                    //                                     widget
                                    //                                         .deleteLead,
                                    //                                     widget
                                    //                                         .cloudCall,
                                    //                                     pageName:
                                    //                                         widget.pageName,
                                    //                                   )),
                                    //                     );
                                    //                   }
                                    //                 } else {
                                    //                   Common.toastMessaage(
                                    //                       delete.message,
                                    //                       Colors.red);
                                    //                   if (context.mounted) {
                                    //                     Navigator.of(context)
                                    //                         .pop();
                                    //                   }
                                    //                 }
                                    //               },
                                    //               child: const Text('Yes')),
                                    //           TextButton(
                                    //               onPressed: () {
                                    //                 Navigator.of(context).pop();
                                    //               },
                                    //               child: const Text('No'))
                                    //         ],
                                    //       );
                                    //     });
                                  } else {
                                    if (widget.cloudCall == false) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              title: const Text('Alert !!!'),
                                              content: Text(""),
                                              actions: [
                                                // The "Yes" button
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Close')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    LeadDetails(
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
                                                                          .details[
                                                                              index]
                                                                          .callMasterId
                                                                          .toString(),
                                                                      pageName:
                                                                          widget
                                                                              .pageName,
                                                                      page:
                                                                          page,
                                                                      pageSize:
                                                                          page *
                                                                              pageSize,
                                                                      fromDate:
                                                                          fromdate
                                                                              .toString(),
                                                                      toDate: todate
                                                                          .toString(),
                                                                    )),
                                                      ).then((r) {
                                                        items.clear();
                                                        page = 1;
                                                        getData();
                                                      });
                                                    },
                                                    child:
                                                        const Text('followup')),
                                              ],
                                            );
                                          });
                                    } else {
                                      if (widget.cloudCall == true) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: const Text(
                                                    'Choose Call Type'),
                                                content: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        Common
                                                            .showProgressDialog(
                                                                context,
                                                                "Loading..");
                                                        CloudCallModel object1 =
                                                            await HttpService
                                                                .addCloudCall(
                                                                    widget
                                                                        .token,
                                                                    items[index]
                                                                        .callMasterId,
                                                                    items[index]
                                                                        .contactNumber1);
                                                        if (object1.data ==
                                                            true) {
                                                          if (context.mounted) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AllReport(
                                                                            widget.token!,
                                                                            widget.editLead,
                                                                            widget.deleteLead,
                                                                            widget.cloudCall,
                                                                            pageName:
                                                                                widget.pageName,
                                                                          )),
                                                            );
                                                          }
                                                        } else {
                                                          Common.toastMessaage(
                                                              object1.message,
                                                              Colors.red);
                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
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
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              child: const Icon(
                                                                Icons
                                                                    .cloud_circle_rounded,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            const Text(
                                                              'Cloud Call',
                                                              style: TextStyle(
                                                                  fontSize: 18),
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
                                                        // String url =
                                                        //     'tel:${'+${items[index].contactNumber1}'}';
                                                        // await launchUrl(Uri.parse(url));
                                                        bool? res =
                                                            await FlutterPhoneDirectCaller
                                                                .callNumber(
                                                                    '+${items[index].contactNumber1}');
                                                      },
                                                      child: SizedBox(
                                                          height: 50,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 30,
                                                                width: 30,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    const Icon(
                                                                  Icons.call,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              const Text(
                                                                'Phone Call',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      } else {
                                        String url =
                                            'tel:+${items[index].contactNumber1}';
                                        await launchUrl(Uri.parse(url));
                                      }
                                    }
                                  }
                                  return null;
                                },
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LeadDetails(
                                                  widget.token!,
                                                  widget.editLead,
                                                  widget.deleteLead,
                                                  widget.cloudCall,
                                                  items[index]
                                                      .callMasterId
                                                      .toString(),
                                                  pageName: widget.pageName,
                                                  page: page,
                                                  pageSize: page * pageSize,
                                                  fromDate: fromdate.toString(),
                                                  toDate: todate.toString(),
                                                )),
                                      ).then((r) {
                                        items.clear();
                                        page = 1;
                                        getData();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        decoration: BoxDecoration(
                                          color:
                                              items[index].isSelected == false
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
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 10, left: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .89,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              if (items[index]
                                                                      .priority ==
                                                                  '1')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (items[index]
                                                                      .priority ==
                                                                  '2')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (items[index]
                                                                      .priority ==
                                                                  '3')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 170,
                                                                child: Text(
                                                                  items[index]
                                                                      .clientName
                                                                      .toString(),
                                                                  // items.length.toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .pink
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: 5,
                                                                        right:
                                                                            5,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                    child: Text(
                                                                      items[index]
                                                                          .leadCategory
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Visibility(
                                                            visible: items[
                                                                        index]
                                                                    .categoryCount
                                                                    .toString() !=
                                                                "1",
                                                            child: Container(
                                                              height: 20,
                                                              width: 20,
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Center(
                                                                child: Text(
                                                                  items[index]
                                                                      .categoryCount
                                                                      .toString(),
                                                                  // items.length.toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),
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
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Column(
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
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Text(
                                                                          'Assigned to : ${items[index].staffName}',
                                                                          style: const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.black54,
                                                                              fontWeight: FontWeight.w500),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                _colors[items[index].callResultId!],
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
                                                                            items[index].callResult.toString(),
                                                                            style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  items[index].callResultId ==
                                                                          1
                                                                      ? Container(
                                                                          decoration: BoxDecoration(
                                                                              color: const Color(0xFFd5f5f4),
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 5,
                                                                                right: 5,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            child:
                                                                                Row(
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
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
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
                                                              maxHeight: 60,
                                                            ),
                                                            child: Container(
                                                              constraints:
                                                                  const BoxConstraints(
                                                                minHeight: 20,
                                                                minWidth: 20,
                                                                maxHeight: 50,
                                                                maxWidth: 50,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 0),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey,
                                                                      blurRadius:
                                                                          5,
                                                                      offset:
                                                                          Offset(
                                                                              1,
                                                                              1)),
                                                                ],
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: NetworkImage(items[
                                                                            index]
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
                                                            onTap: () async {
                                                              if (widget
                                                                      .cloudCall ==
                                                                  false) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            ctx) {
                                                                      return AlertDialog(
                                                                        title: const Text(
                                                                            'Alert !!!'),
                                                                        content:
                                                                            Text(""),
                                                                        actions: [
                                                                          // The "Yes" button
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('Close')),
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => LeadDetails(
                                                                                            widget.token!,
                                                                                            widget.editLead,
                                                                                            widget.deleteLead,
                                                                                            widget.cloudCall,
                                                                                            viewLeads!.data.details[index].callMasterId.toString(),
                                                                                            pageName: widget.pageName,
                                                                                            page: page,
                                                                                            pageSize: page * pageSize,
                                                                                            fromDate: fromdate.toString(),
                                                                                            toDate: todate.toString(),
                                                                                          )),
                                                                                ).then((r) {
                                                                                  items.clear();
                                                                                  page = 1;
                                                                                  getData();
                                                                                  itemPositionsListener.itemPositions.addListener(() {
                                                                                    if (itemPositionsListener.itemPositions.value.last.index == items.length - 1) {
                                                                                      if (items.length < viewLeads!.data.totalLeads) {
                                                                                        getData();
                                                                                      }
                                                                                    }
                                                                                  });
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
                                                                              const Text('Choose Call Type'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  Common.showProgressDialog(context, "Loading..");
                                                                                  CloudCallModel object1 = await HttpService.addCloudCall(widget.token, items[index].callMasterId, items[index].contactNumber1);
                                                                                  if (object1.data == true) {
                                                                                    if (context.mounted) {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => AllReport(
                                                                                                  widget.token!,
                                                                                                  widget.editLead,
                                                                                                  widget.deleteLead,
                                                                                                  widget.cloudCall,
                                                                                                  pageName: widget.pageName,
                                                                                                )),
                                                                                      );
                                                                                    }
                                                                                  } else {
                                                                                    Common.toastMessaage(object1.message, Colors.red);
                                                                                    if (context.mounted) {
                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: SizedBox(
                                                                                  height: 50,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        height: 30,
                                                                                        width: 30,
                                                                                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
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
                                                                                  // String url =
                                                                                  //     'tel:${'+${items[index].contactNumber1}'}';
                                                                                  // await launchUrl(Uri.parse(url));
                                                                                  bool? res = await FlutterPhoneDirectCaller.callNumber('+${items[index].contactNumber1}');
                                                                                },
                                                                                child: SizedBox(
                                                                                    height: 50,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 30,
                                                                                          width: 30,
                                                                                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
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
                                                                } else {
                                                                  String url =
                                                                      'tel:+${items[index].contactNumber1}';
                                                                  await launchUrl(
                                                                      Uri.parse(
                                                                          url));
                                                                }
                                                              }
                                                            },
                                                            child: Container(
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child:
                                                                  const Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .call,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 15,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text('Call',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                "MontserratMedium",
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
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
                          height: MediaQuery.of(context).size.height * 0.6,
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
                                    fontSize: 20, fontWeight: FontWeight.bold),
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
                                      MediaQuery.of(context).size.width * 0.4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
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
                child:
                    Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
              ),
      ),
    );
  }

  Future<dynamic> filtrationSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
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
                                          hintText: 'From Date',
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
                        const SizedBox(
                          height: 13,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                                                    // The "Yes" button
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
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                            const Text('Call Result'),
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
                                        title: const Text('Call Result'),
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
                                                .data.callResult.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!
                                                        .data
                                                        .callResult[ind]
                                                        .callResult
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedCallResultItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .callResult[ind]
                                                            .callResultId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedCallResultItems
                                                          .add(commonDetails!
                                                              .data
                                                              .callResult[ind]
                                                              .callResultId
                                                              .toString());
                                                      checkedCallResultItemsName
                                                          .add(commonDetails!
                                                              .data
                                                              .callResult[ind]
                                                              .callResult
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedCallResultItems
                                                          .remove(commonDetails!
                                                              .data
                                                              .callResult[ind]
                                                              .callResultId
                                                              .toString());
                                                      checkedCallResultItemsName
                                                          .remove(commonDetails!
                                                              .data
                                                              .callResult[ind]
                                                              .callResult
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
                                child: checkedCallResultItems.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Call Result'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedCallResultItemsName
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
                                                                  checkedCallResultItemsName[
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
                                                                    // The "Yes" button
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedCallResultItemsName.remove(checkedCallResultItemsName[i]);
                                                                            checkedCallResultItems.remove(checkedCallResultItems[i]);
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                                              .32,
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
                                                                    // The "Yes" button
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
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                                                                    // The "Yes" button
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
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                            const Text('Created By'),
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
                                        title: const Text('Created By'),
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
                                                .data.transferStaffs.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!
                                                        .data
                                                        .transferStaffs[ind]
                                                        .tranStaffName
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedCreatedStaffItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .transferStaffs[ind]
                                                            .tranStaffId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedCreatedStaffItems
                                                          .add(commonDetails!
                                                              .data
                                                              .transferStaffs[
                                                                  ind]
                                                              .tranStaffId
                                                              .toString());
                                                      checkedCreatedStaffItemsName
                                                          .add(commonDetails!
                                                              .data
                                                              .transferStaffs[
                                                                  ind]
                                                              .tranStaffName
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedCreatedStaffItems
                                                          .remove(commonDetails!
                                                              .data
                                                              .transferStaffs[
                                                                  ind]
                                                              .tranStaffId
                                                              .toString());
                                                      checkedCreatedStaffItemsName
                                                          .remove(commonDetails!
                                                              .data
                                                              .transferStaffs[
                                                                  ind]
                                                              .tranStaffName
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
                                child: checkedCreatedStaffItems.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Created By'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedCreatedStaffItemsName
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
                                                                  checkedCreatedStaffItemsName[
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
                                                                    // The "Yes" button
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedCreatedStaffItemsName.remove(checkedCreatedStaffItemsName[i]);
                                                                            checkedCreatedStaffItems.remove(checkedCreatedStaffItems[i]);
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                            const Text('Lead Source'),
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
                                        title: const Text('Lead Source'),
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
                                                .data.leadSource.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!
                                                        .data
                                                        .leadSource[ind]
                                                        .leadSource
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedCallResultItems
                                                        .contains(commonDetails!
                                                            .data
                                                            .leadSource[ind]
                                                            .leadSourceId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedLeadSource.add(
                                                          commonDetails!
                                                              .data
                                                              .leadSource[ind]
                                                              .leadSourceId
                                                              .toString());
                                                      checkedLeadSourceName.add(
                                                          commonDetails!
                                                              .data
                                                              .leadSource[ind]
                                                              .leadSource
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedLeadSource.remove(
                                                          commonDetails!
                                                              .data
                                                              .leadSource[ind]
                                                              .leadSource
                                                              .toString());
                                                      checkedLeadSourceName
                                                          .remove(commonDetails!
                                                              .data
                                                              .leadSource[ind]
                                                              .leadSourceId
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
                                child: checkedLeadSource.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 10),
                                        child: Text('Lead Source'))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: SizedBox(
                                          height: 35,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                checkedLeadSourceName.length,
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
                                                                  checkedLeadSourceName[
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
                                                                    // The "Yes" button
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            checkedLeadSourceName.remove(checkedLeadSourceName[i]);
                                                                            checkedLeadSource.remove(checkedLeadSource[i]);
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Yes')),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'No'))
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
                                getData();
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
              );
            },
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
