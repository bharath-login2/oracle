// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/staff_report/staff_call_details_model.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/models/userManagement/deleteStaffModel.dart';
import 'package:login2/screens/callLogs/callLogs.dart';
import 'package:login2/screens/leadManagement/viewLeads.dart';
import 'package:login2/screens/staff_reports/achievementDetailspage.dart';
import 'package:login2/screens/staff_reports/imageView.dart';
import 'package:login2/screens/staff_reports/pdfView.dart';
import 'package:login2/screens/userManagement/changePassword.dart';
import 'package:login2/screens/userManagement/editStaffPage.dart';
import 'package:login2/service/service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';

import 'timeline_page.dart';

class StaffReportDashboard extends StatefulWidget {
  String id;
  StaffReportDashboard({super.key, required this.id});

  @override
  State<StaffReportDashboard> createState() => _StaffReportDashboardState();
}

class _StaffReportDashboardState extends State<StaffReportDashboard> {
  Map<String, double> data = {};
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.purple,
    Colors.deepOrange,
    Colors.green,
    Colors.redAccent,
    Colors.black,
    Colors.blueGrey,
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
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
  ];

  int selectedIndex = 0;
  var targetFromDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var targetToDate = DateTime.now().toString();
  // var targetFDate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  // var targetTDate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  var fromDate = DateTime.now().toString();
  var toDate = DateTime.now().toString();
  // var fDate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  // var tDate = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  String? updateStaffPermission;
  String? deleteStaffPermission;
  String? updateStaffPasswordPermission;
  String? token;
  String cloudCallPermission = '';
  String deleteLeadPermission = '';
  String viewLeadPermission = '';
  String updateLeadPermission = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;

  UserDashboardModel? staffDetails;
  StaffCalldetailsModel? callDetails;
  bool isLoading = true;

  getStaffDetails() async {
    staffDetails = await HttpService.getStaffDashboard(
        widget.id, targetFromDate, targetToDate);

    if (staffDetails != null && staffDetails!.status == true) {
      setState(() {});
    } else {}
  }

  getCallDetails() async {
    callDetails =
        await HttpService.getStaffCallDetails(widget.id, fromDate, toDate);

    if (callDetails != null && callDetails!.status == true) {
      for (int i = 0; i < callDetails!.data.leadStatusGraph.length; i++) {
        data.addAll({
          callDetails!.data.leadStatusGraph[i].callResult: double.parse(
              callDetails!.data.leadStatusGraph[i].resCount.toString())
        });
      }
      setState(() {});
    } else {}
  }

  bool _isImage(String ext) {
  return ['jpg', 'jpeg', 'png'].contains(ext.toLowerCase());
}

  initData() async {
    setState(() {
      isLoading = true;
    });
    await getStaffDetails();
    await getCallDetails();
    token = await Common.getSharedPref("token");
    updateStaffPermission = await Common.getSharedPref("updateStaffPermission");
    deleteStaffPermission = await Common.getSharedPref("deleteStaffPermission");
    updateStaffPasswordPermission =
        await Common.getSharedPref("updateStaffPasswordPermission");
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    if (updateLeadPermission == 'true') {
      updateLeadPermission1 = true;
    }
    if (deleteLeadPermission == 'true') {
      deleteLeadPermission1 = true;
    }
    if (cloudCallPermission == 'true') {
      cloudCallPermission1 = true;
    }
    token = await Common.getSharedPref("token");
    updateStaffPermission = await Common.getSharedPref("updateStaffPermission");
    deleteStaffPermission = await Common.getSharedPref("deleteStaffPermission");
    updateStaffPasswordPermission =
        await Common.getSharedPref("updateStaffPasswordPermission");
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
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
                      width: 10,
                    ),
                    staffDetails != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              staffDetails!.data.userData.profilePic,
                            ),
                          )
                        : Shimmer.fromColors(
                            enabled: true,
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: const CircleAvatar()),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (staffDetails != null)
                            Text(
                              staffDetails!.data.userData.staffName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          if (staffDetails != null)
                            Text(
                              staffDetails!.data.userData.designation,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  padding: const EdgeInsets.only(left: 35),
                  iconColor: Colors.white,
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == "0") {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                                staffId: staffDetails!.data.userData.userId,
                              )));
                    } else if (value == "1") {
                      deleteDialog(context, staffDetails!.data.userData.userId);
                    } else if (value == "2") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePassword(token!,
                                staffDetails!.data.userData.userId.toString())),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      if (updateStaffPermission == 'true')
                        const PopupMenuItem<String>(
                          value: '0',
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
                      if (deleteStaffPermission == 'true')
                        const PopupMenuItem<String>(
                          value: '1',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      if (updateStaffPasswordPermission == 'true')
                        const PopupMenuItem<String>(
                          value: '2',
                          child: Row(
                            children: [
                              Icon(
                                Icons.key,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Change password',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading == true
          ? Center(
              child: dashboardShimmer(),
            )
          : SafeArea(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .95,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Target Report",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    InkWell(
                                      onTap: () {
                                        filtrationSheet(context, "target");
                                      },
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.calendar_month,
                                          color: Colors.black,
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              // const Divider(
                              //   color: Colors.grey,
                              //   height: 1,
                              // ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    // InkWell(
                                    //   onTap: () {
                                    //     setState(() {
                                    //       selectedIndex = 0;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     width:
                                    //         MediaQuery.of(context).size.width *
                                    //             .4,
                                    //     height: 30,
                                    //     decoration: BoxDecoration(
                                    //         border: Border.all(
                                    //             color: Colors.grey, width: 0),
                                    //         color: selectedIndex == 0
                                    //             ? const Color(0xFFd5f5f4)
                                    //             : Colors.white,
                                    //         borderRadius:
                                    //             const BorderRadius.all(
                                    //                 Radius.circular(6))),
                                    //     child: Center(
                                    //       child: Text(
                                    //         'Cost',
                                    //         style: TextStyle(
                                    //           color: selectedIndex == 0
                                    //               ? const Color(0xFF3c9f9a)
                                    //               : const Color(0xFF717171),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // InkWell(
                                    //   onTap: () {
                                    //     setState(() {
                                    //       selectedIndex = 1;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     width:
                                    //         MediaQuery.of(context).size.width *
                                    //             .4,
                                    //     height: 30,
                                    //     decoration: BoxDecoration(
                                    //         border: Border.all(
                                    //             color: Colors.grey, width: 0),
                                    //         color: selectedIndex == 1
                                    //             ? const Color(0xFFd5f5f4)
                                    //             : Colors.white,
                                    //         borderRadius:
                                    //             const BorderRadius.all(
                                    //                 Radius.circular(6))),
                                    //     child: Center(
                                    //       child: Text(
                                    //         'Calls',
                                    //         style: TextStyle(
                                    //           color: selectedIndex == 1
                                    //               ? const Color(0xFF3c9f9a)
                                    //               : const Color(0xFF717171),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 20.0),
                                  child: selectedIndex == 0
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .88,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: const [
                                                    Color(0xFF2a86c9),
                                                    Color(0xFF406dbe)
                                                  ]),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child:
                                                staffDetails!
                                                        .data.userTarget.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                        "No Details !",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ))
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: staffDetails!
                                                            .data
                                                            .userTarget
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final target =
                                                              staffDetails!.data
                                                                      .userTarget[
                                                                  index];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AchievementDetailsPage(
                                                                    targetData:
                                                                        target,
                                                                    targetFromDate:
                                                                        DateTime.tryParse(
                                                                            targetFromDate),
                                                                    targetToDate:
                                                                        DateTime.tryParse(
                                                                            targetToDate),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 15.0,
                                                                      bottom:
                                                                          15.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          20.0),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        staffDetails!
                                                                            .data
                                                                            .userTarget[index]
                                                                            .groupName,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 16),
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                              "Target : ${staffDetails!.data.userTarget[index].targetAmount}",
                                                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                                                          Text(
                                                                              "Achieved : ${staffDetails!.data.userTarget[index].achieved}",
                                                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Stack(
                                                                    children: [
                                                                      LinearProgressIndicator(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        backgroundColor: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        value: double.parse(staffDetails!.data.userTarget[index].progressPercentage) /
                                                                            100,
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                                                        minHeight:
                                                                            20,
                                                                      ),
                                                                      Positioned(
                                                                        left:
                                                                            15,
                                                                        child:
                                                                            Text(
                                                                          "${staffDetails!.data.userTarget[index].progressPercentage}%",
                                                                          style: TextStyle(
                                                                              color: Colors.blue.shade900,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                          ),
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .88,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: const [
                                                    Color(0xFF2a86c9),
                                                    Color(0xFF406dbe)
                                                  ]),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child:
                                                staffDetails!.data
                                                        .staffCallTarget.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                        "No Details !",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ))
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: staffDetails!
                                                            .data
                                                            .staffCallTarget
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 15.0,
                                                                    bottom:
                                                                        15.0,
                                                                    left: 20.0,
                                                                    right:
                                                                        20.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staffDetails!
                                                                          .data
                                                                          .staffCallTarget[
                                                                              index]
                                                                          .groupName,
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                            "Target : ${staffDetails!.data.staffCallTarget[index].targetCall}",
                                                                            style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14)),
                                                                        Text(
                                                                            "Achieved : ${staffDetails!.data.staffCallTarget[index].achieved}",
                                                                            style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14)),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                Stack(
                                                                  children: [
                                                                    LinearProgressIndicator(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      backgroundColor: Colors
                                                                          .grey
                                                                          .shade400,
                                                                      value: double.parse(staffDetails!
                                                                              .data
                                                                              .staffCallTarget[index]
                                                                              .progressPercentage) /
                                                                          100,
                                                                      valueColor: AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .white),
                                                                      minHeight:
                                                                          20,
                                                                    ),
                                                                    Positioned(
                                                                      left: 15,
                                                                      child:
                                                                          Text(
                                                                        "${staffDetails!.data.staffCallTarget[index].progressPercentage}%",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue.shade900,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                          ),
                                        ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .95,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 35.0, horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: const Text("Call Status Details",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      filtrationSheet(context, "call");
                                    },
                                    child: Center(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.calendar_month,
                                        color: Colors.black,
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CallLogs(
                                          token,
                                          staffDetails!.data.userData.staffName,
                                          staffDetails!.data.userData.userId),
                                    ));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 50,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Column(
                                          children: [
                                            const Text("Cloud Call Duration :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!.data.callDetails
                                                    .totDuration,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_red_eye,
                                                  color: Colors.black),
                                              onPressed: () {
                                                final staffId = staffDetails!
                                                    .data.userData.userId;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TimelinePage(),
                                                    settings: RouteSettings(
                                                      arguments: {
                                                        "staffId": staffId
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const Text("Phone Call Duration :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!.data.callDetails
                                                    .phoneCallDuration,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (callDetails!.data.callDetails.closedCalls != 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    viewLeadPermission == 'true'
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ViewLeads(
                                                    token,
                                                    updateLeadPermission1,
                                                    deleteLeadPermission1,
                                                    cloudCallPermission1,
                                                    pageName: 'Closed Leads',
                                                    fromDate: DateTime.now()
                                                        .toString(),
                                                    toDate: DateTime.now()
                                                        .toString(),
                                                    status: '4')),
                                          ).then((r) {
                                            initData();
                                          })
                                        : _dialogue(context, 'View Leads');
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 202, 230, 213),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Icon(
                                            Icons.done_all,
                                            size: 50,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            child: Column(
                                              children: [
                                                const Text("Closed :",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                                Text(
                                                    callDetails!.data
                                                        .callDetails.closedCalls
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (callDetails!.data.callDetails.totalCost != "0")
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .8,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 238, 211, 240),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.money,
                                          size: 50,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .4,
                                          child: Column(
                                            children: [
                                              const Text("Cost :",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16)),
                                              Text(
                                                  callDetails!.data.callDetails
                                                      .totalCost
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 30.0,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: callDetails!
                                    .data.callCountByResponse.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        left: 20.0,
                                        right: 20.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewLeads(
                                                    token,
                                                    updateLeadPermission1,
                                                    deleteLeadPermission1,
                                                    cloudCallPermission1,
                                                    pageName: 'Total Called',
                                                    fromDate: fromDate,
                                                    toDate: toDate,
                                                     staffId: widget.id,
                                                    callStatus: "1",
                                                    leadType: "-1",
                                                    callResId: callDetails!
                                                                .data
                                                                .callCountByResponse[
                                                                    index]
                                                                .callResponse !=
                                                            "Total Called"
                                                        ? callDetails!
                                                            .data
                                                            .callCountByResponse[
                                                                index]
                                                            .callResponseId
                                                            .toString()
                                                        : null,
                                                    callResName: callDetails!
                                                                .data
                                                                .callCountByResponse[
                                                                    index]
                                                                .callResponse !=
                                                            "Total Called"
                                                        ? callDetails!
                                                            .data
                                                            .callCountByResponse[
                                                                index]
                                                            .callResponse
                                                            .toString()
                                                        : null,
                                                  )),
                                        ).then((r) {
                                          initData();
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                callDetails!
                                                    .data
                                                    .callCountByResponse[index]
                                                    .callResponse,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                callDetails!
                                                    .data
                                                    .callCountByResponse[index]
                                                    .resCount,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          LinearProgressIndicator(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            backgroundColor: Colors.grey,
                                            value: double.parse(callDetails!
                                                    .data
                                                    .callCountByResponse[index]
                                                    .resPercentage) /
                                                100,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    _colors[index]),
                                            minHeight: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            // STAFF DOCUMENT VIEW SECTION
                            if (staffDetails!.data.userFiles.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Text(
                                  "Staff Documents",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: staffDetails!.data.userFiles.length,
                                itemBuilder: (context, index) {
                                  final file =
                                      staffDetails!.data.userFiles[index];
                                  final isImage = _isImage(file.ext);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => isImage
                                              ? ImageViewPage(file.link)
                                              : PdfViewPage(file.link),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 20),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          isImage
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: CachedNetworkImage(
                                                    imageUrl: file.link,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Icon(Icons.picture_as_pdf,
                                                  size: 40, color: Colors.red),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(file.document,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15)),
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              size: 16)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 25),
                            ],

                            Visibility(
                              visible: data.isNotEmpty,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 60.0,
                                        bottom: 60.0,
                                        left: 40.0,
                                        right: 16),
                                    child: PieChart(
                                      dataMap: data,
                                      animationDuration:
                                          const Duration(milliseconds: 800),
                                      chartLegendSpacing: 20,
                                      chartRadius:
                                          MediaQuery.of(context).size.width /
                                              2.5,
                                      colorList: _colors,
                                      initialAngleInDegree: 0,
                                      chartType: ChartType.ring,
                                      ringStrokeWidth: 25,
                                      centerText: "",
                                      legendOptions: const LegendOptions(
                                        legendShape: BoxShape.rectangle,
                                        showLegendsInRow: false,
                                        legendPosition: LegendPosition.right,
                                        showLegends: true,
                                        legendTextStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      chartValuesOptions:
                                          const ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        // showChartValuesInPercentage: true,
                                        showChartValuesOutside: true,
                                        decimalPlaces: 1,
                                      ),
                                      // gradientList: ---To add gradient colors---
                                      // emptyColorGradient: ---Empty Color gradient---
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: SizedBox(
                            //     width: MediaQuery .of(context).size.width *2,
                            //     child: Column(
                            //       children: [
                            //         Padding(
                            //           padding:
                            //               const EdgeInsets.symmetric(horizontal: 8.0),
                            //           child: Table(
                            //             columnWidths: {
                            //               0: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .05,
                            //               ),
                            //               1: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .18,
                            //               ),
                            //               2: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .18,
                            //               ),
                            //               3: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .16,
                            //               ),
                            //               4: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .17,
                            //               ),
                            //               5: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .16,
                            //               ),
                            //             },
                            //             children: const [
                            //               TableRow(children: [
                            //                 Text(
                            //                   " ",
                            //                   style: TextStyle(fontSize: 10),
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.blue,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(
                            //                       " Total leads",
                            //                       style: TextStyle(fontSize: 10),
                            //                     ),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.green,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Confirmed",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.red,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Rejected",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.yellow,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Follow up",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.redAccent,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Closed",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //               ])
                            //             ],
                            //           ),
                            //         ),
                            //         const Divider(
                            //       color: Colors.grey,
                            //     ),
                            //     SizedBox(
                            //       child: ListView.builder(
                            //         itemCount: 3,
                            //         shrinkWrap: true,
                            //         itemBuilder: (context, index) {
                            //           return Padding(
                            //             padding: const EdgeInsets.symmetric(
                            //                 vertical: 4.0),
                            //             child: Padding(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 8.0),
                            //               child: Table(
                            //                 columnWidths: {
                            //                   0: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .05,
                            //                   ),
                            //                   1: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .18,
                            //                   ),
                            //                   2: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .18,
                            //                   ),
                            //                   3: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .16,
                            //                   ),
                            //                   4: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .17,
                            //                   ),
                            //                   5: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .16,
                            //                   ),
                            //                 },
                            //                 children: const [
                            //                   TableRow(children: [
                            //                     Center(
                            //                       child: CircleAvatar(
                            //                         backgroundColor:
                            //                             Colors.redAccent,
                            //                         minRadius: 10,
                            //                       ),
                            //                     ),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                   ])
                            //                 ],
                            //               ),
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //     ),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            Visibility(
                              visible: callDetails!
                                  .data.leadCategoryCount.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8)),
                                    dividerThickness: .5,
                                    dataRowHeight: 30,
                                    columnSpacing: 10,
                                    headingRowHeight: 40,
                                    columns:
                                        _buildColumns(), // Dynamically build columns
                                    rows: _buildRows(
                                        callDetails!.data.leadCategoryCount),
                                    checkboxHorizontalMargin: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60.0,
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  )
                ],
              ),
            )),
    );
  }

  Future<Object?> filtrationSheet(BuildContext context, String type) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
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
                      'Filter By Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: const Text(
                              'From Date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.6,
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
                                          color: Colors.purple.shade100),
                                      borderRadius: BorderRadius.circular(5))),
                              initialValue: type == "target"
                                  ? targetFromDate.toString()
                                  : fromDate.toString(),
                              type: DateTimePickerType.date,

                              //controller: fromDate,
                              firstDate: DateTime(1995),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              // This will add one year from current date
                              validator: (value) {
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (type == "target") {
                                    setState(() {
                                      targetFromDate =
                                          DateTime.parse(value).toString();
                                      // targetFDate = DateFormat('dd-MM-yyyy')
                                      //     .format(DateTime.parse(value))
                                      //     .toString();
                                    });
                                  } else {
                                    fromDate = DateTime.parse(value).toString();
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: const Text(
                              'To Date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.6,
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
                                  hintText: 'To date',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.purple.shade100),
                                      borderRadius: BorderRadius.circular(5))),
                              initialValue: type == "target"
                                  ? targetToDate.toString()
                                  : toDate,
                              type: DateTimePickerType.date,
                              firstDate: DateTime(1995),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              // This will add one year from current date
                              validator: (value) {
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (type == "target") {
                                    setState(() {
                                      targetToDate =
                                          DateTime.parse(value).toString();
                                      // targetFDate = DateFormat('dd-MM-yyyy')
                                      //     .format(DateTime.parse(value))
                                      //     .toString();
                                    });
                                  } else {
                                    toDate = DateTime.parse(value).toString();
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 40,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3375e0),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: RawMaterialButton(
                        onPressed: () {
                          initData();
                          Navigator.pop(context);
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

  List<DataColumn> _buildColumns() {
    if (callDetails != null) {
      return callDetails!.data.leadCategory.asMap().entries.map((entry) {
        String key = entry.value;
        return DataColumn(
          label: Text(
            key,
            // style: TextStyle(color: _colorsTable[index % _colorsTable.length]),
          ),
        );
      }).toList();
    } else {
      return []; // Return an empty list if callDetails or its properties are null
    }
  }

  List<DataRow> _buildRows(List<dynamic> data) {
    return data.asMap().entries.map((entry) {
      dynamic item = entry.value;
      return DataRow(
        cells: [
          DataCell(Text(
            item.leadCategory,
          )),
          DataCell(Center(
            child: Text(
              item.the1Count,
            ),
          )),
          DataCell(Center(
            child: Text(item.the2Count),
          )),
          DataCell(Center(
            child: Text(
              item.the3Count,
            ),
          )),
          DataCell(Center(
            child: Text(item.the4Count),
          )),
          DataCell(Center(
            child: Text(item.the5Count),
          )),
          if (callDetails!.data.totalRowCount > 5)
            DataCell(Center(
              child: Text(item.the6Count),
            )),
          if (callDetails!.data.totalRowCount > 6)
            DataCell(Center(
              child: Text(item.the7Count),
            )),
          if (callDetails!.data.totalRowCount > 7)
            DataCell(Center(
              child: Text(item.the8Count),
            )),
          if (callDetails!.data.totalRowCount > 8)
            DataCell(Center(
              child: Text(item.the9Count),
            )),
          if (callDetails!.data.totalRowCount > 9)
            DataCell(Center(
              child: Text(item.the10Count),
            )),
        ],
      );
    }).toList();
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: const Text(
                'You have no permission to access the feature please contact the support team'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }
}

Future<dynamic> deleteDialog(BuildContext context, String id) {
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
                  DeleteStaffModel delete = await HttpService.deleteStaff(id);
                  if (delete.data == true) {
                    Common.toastMessaage(delete.message, Colors.green);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  } else {
                    Common.toastMessaage(delete.message, Colors.red);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Yes')),
          ],
        );
      });
}

Shimmer dashboardShimmer() {
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
