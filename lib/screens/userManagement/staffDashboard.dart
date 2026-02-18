import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login2/models/lead_management/leadCategoryStaffWiseModel.dart';
import 'package:login2/models/lead_management/staff_dashboard_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/leadManagement/callHistoryPage.dart';
import '../../screens/leadManagement/viewLeadCategory.dart';
import '../../screens/settings/notificationTemplateSettings.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../service/service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../leadManagement/dashboard.dart';

// ignore: must_be_immutable
class StaffDashboard extends StatefulWidget {
  String? token;
  String? staffId;
  String? staffName;

  StaffDashboard(this.token, this.staffId, this.staffName, {super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _toolTipKey = GlobalKey<State<Tooltip>>();
  final _toolTipKey1 = GlobalKey<State<Tooltip>>();
  final _toolTipKey2 = GlobalKey<State<Tooltip>>();
  final _toolTipKey3 = GlobalKey<State<Tooltip>>();
  final _toolTipKey4 = GlobalKey<State<Tooltip>>();
  final _toolTipKey5 = GlobalKey<State<Tooltip>>();
  bool? result = true;
  bool? result1 = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, double> data = {};
  StaffDashboardModel? staffDashboard;
  CommonConfigureModel? configure;
  LeadCategoryStaffWiseModel? staffWise;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  String name = '';
  String role = '';
  String profilePic = '';
  String userId = '';
  int id = 0;
  String navigationActionId = 'id_3';
  bool popUpShown = false;
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String phoneCallLogPermission = '';
  String accessCallHistoryPermission = '';
  String viewLeadCategoryPermission = '';
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String accessCallRecordingPermission = '';
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;
  int catNew = 0;
  int catPending = 0;
  int catFollowup = 0;
  int catRejected = 0;
  int catClosed = 0;
  int stfNew = 0;
  int stfPending = 0;
  int stfFollowup = 0;
  int stfRejected = 0;
  int stfClosed = 0;

  @override
  void initState() {
    getData(widget.token, fromdate, todate);
    super.initState();
  }

  getData(token, fromDate, toDate) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     result = true;
    //   });
    // } else {
    //   setState(() {
    //     result = false;
    //   });
    // }
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    profilePic = await Common.getSharedPref("profile_pic");
    userId = await Common.getSharedPref("userId");
    createLeadPermission = await Common.getSharedPref("createLeadPermission");
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    accessCallHistoryPermission =
        await Common.getSharedPref("accessCallHistoryPermission");
    viewLeadCategoryPermission =
        await Common.getSharedPref("viewLeadCategoryPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
    accessCallRecordingPermission =
        await Common.getSharedPref("accessCallRecordingPermission");
    if (createLeadCategory == 'true') {
      createLeadCategory1 = true;
    }
    if (updateLeadCategory == 'true') {
      updateLeadCategory1 = true;
    }
    if (deleteLeadCategory == 'true') {
      deleteLeadCategory1 = true;
    }
    if (accessCallRecordingPermission == 'true') {
      accessCallRecordingPermission1 = true;
    }

    configure = await HttpService.configure(token);
    if (configure != null) {
      setState(() {});
    }
    staffDashboard = await HttpService.leadDashboardStaff(
        token, fromdate, todate, fromdate1, todate1, widget.staffId);
    setState(() {});
    staffWise = await HttpService.leadDashboard1Staff(
        token, fromdate, todate, fromdate1, todate1, widget.staffId);
    setState(() {
      data.clear();
      for (int i = 0; i < staffWise!.data!.categoryGraph!.length; i++) {
        data.addAll({
          staffWise!.data!.categoryGraph![i].categoryName.toString():
              staffWise!.data!.categoryGraph![i].categoryCount!.toDouble(),
        });
      }
    });
    catNew = 0;
    catPending = 0;
    catFollowup = 0;
    catRejected = 0;
    catClosed = 0;
    stfNew = 0;
    stfPending = 0;
    stfFollowup = 0;
    stfRejected = 0;
    stfClosed = 0;

    for (int i = 0; i < staffWise!.data!.categoryLeads!.length; i++) {
      catNew = int.parse(catNew.toString()) +
          int.parse(staffWise!.data!.categoryLeads![i].newCount.toString());
      catPending = int.parse(catPending.toString()) +
          int.parse(staffWise!.data!.categoryLeads![i].pendingCount.toString());
      catFollowup = int.parse(catFollowup.toString()) +
          int.parse(
              staffWise!.data!.categoryLeads![i].followupCount.toString());
      catRejected = int.parse(catRejected.toString()) +
          int.parse(
              staffWise!.data!.categoryLeads![i].rejectedCount.toString());
      catClosed = int.parse(catClosed.toString()) +
          int.parse(
              staffWise!.data!.categoryLeads![i].confirmedCount.toString());
    }
    for (int i = 0; i < staffWise!.data!.staffLeads!.length; i++) {
      stfNew = int.parse(stfNew.toString()) +
          int.parse(staffWise!.data!.staffLeads![i].newCount.toString());
      stfPending = int.parse(stfPending.toString()) +
          int.parse(staffWise!.data!.staffLeads![i].pendingCount.toString());
      stfFollowup = int.parse(stfFollowup.toString()) +
          int.parse(staffWise!.data!.staffLeads![i].followupCount.toString());
      stfRejected = int.parse(stfRejected.toString()) +
          int.parse(staffWise!.data!.staffLeads![i].rejectedCount.toString());
      stfClosed = int.parse(stfClosed.toString()) +
          int.parse(staffWise!.data!.staffLeads![i].confirmedCount.toString());
    }
  }

  final List<Color> _colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.purple
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        getData(widget.token, fromdate, todate);
        return;
      },
      child: result == true
          ? Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              body: configure != null
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.asset("assets/icons/staffHeader.png",
                                  width: size.width),
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 45,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                                onTap: () => logout(context),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 2,
                                                          color: Colors
                                                              .grey.shade800,
                                                          offset: const Offset(
                                                              0, 2.0),
                                                        )
                                                      ],
                                                      shape: BoxShape.circle,
                                                      color: const Color(
                                                          0xFF2191ce)),
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                      profilePic,
                                                    ),
                                                  ),
                                                )),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  role,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _scaffoldKey.currentState!
                                                .openEndDrawer();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Image.asset(
                                                "assets/icons/menu.png",
                                                width: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 30),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Image.asset(
                                                "assets/icons/graph.png",
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    'LEAD MANAGEMENT',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Calling features that give you \n wings that fast..',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      configure!.data!.isExpired == false &&
                                              staffDashboard != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: PopupMenuButton(
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            blurRadius: 3,
                                                            color: Colors
                                                                .grey.shade800,
                                                          )
                                                        ],
                                                        shape: BoxShape.circle,
                                                        color: Colors.white),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                        "assets/icons/settings.png",
                                                      ),
                                                    ),
                                                  ),
                                                  itemBuilder: (context) {
                                                    return [
                                                      PopupMenuItem<int>(
                                                          value: 5,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/icons/viewLeads.png",
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Text(
                                                                  'View Leads'),
                                                            ],
                                                          )),
                                                      PopupMenuItem<int>(
                                                          value: 7,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/icons/viewLeads.png",
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                      'Missed Leads'),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5),
                                                                        color: Colors
                                                                            .red),
                                                                    child: Center(
                                                                        child: Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        staffDashboard!
                                                                            .data
                                                                            .missedLeads
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )),
                                                      PopupMenuItem<int>(
                                                          value: 8,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/icons/viewLeads.png",
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                      'Transfer Leads'),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5),
                                                                        color: Colors
                                                                            .red),
                                                                    child: Center(
                                                                        child: Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        staffDashboard!
                                                                            .data
                                                                            .transferLeads
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )),
                                                      PopupMenuItem<int>(
                                                          value: 6,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/icons/callHistory.png",
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Text(
                                                                  'Call History'),
                                                            ],
                                                          )),
                                                    ];
                                                  },
                                                  onSelected: (value) {
                                                    if (value == 1) {}
                                                    if (value == 2) {
                                                      Common.saveSharedPref(
                                                          "statusWise", 'no');
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewLeadCategory(
                                                                    widget
                                                                        .token!,
                                                                    createLeadCategory1,
                                                                    updateLeadCategory1,
                                                                    deleteLeadCategory1)),
                                                      );
                                                    }
                                                    if (value == 3) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                WhatsappSettings(
                                                                    widget
                                                                        .token)),
                                                      );
                                                    }
                                                    if (value == 4) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NotificationTemplateSettings()),
                                                      );
                                                    }
                                                    if (value == 5) {
                                                      // leadDashboard!.data!
                                                      //     .viewLead ==
                                                      //     true
                                                      //     ? Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder:
                                                      //           (context) =>
                                                      //           StaffViewLeads(
                                                      //             widget.token,
                                                      //             widget.staffId,
                                                      //             widget.staffName,
                                                      //             pageName:
                                                      //             'View Leads',
                                                      //             fromDate:
                                                      //             fromdate.toString(),
                                                      //             toDate:
                                                      //             todate.toString(),
                                                      //           )),
                                                      // )
                                                      //     : _dialogue(context,
                                                      //     'View Leads');
                                                    }
                                                    if (value == 6) {
                                                      accessCallHistoryPermission ==
                                                              'true'
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      CallHistoryPage(
                                                                          widget
                                                                              .token!,
                                                                          name,
                                                                          userId,
                                                                          accessCallRecordingPermission1)),
                                                            )
                                                          : _dialogue(context,
                                                              'Call History');
                                                    }
                                                    if (value == 7) {
                                                      // Common.saveSharedPref(
                                                      //     "statusWise", 'no');
                                                      // leadDashboard!.data!
                                                      //     .viewLead ==
                                                      //     true
                                                      //     ? Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder:
                                                      //           (context) =>
                                                      //           StaffViewLeads(
                                                      //               widget.token,
                                                      //               widget.staffId,
                                                      //               widget.staffName,
                                                      //               pageName:
                                                      //               'Transfer Leads',
                                                      //               fromDate:
                                                      //               fromdate.toString(),
                                                      //               toDate:
                                                      //               todate.toString(),
                                                      //               leadType:'1'
                                                      //           )),
                                                      // )
                                                      //     : _dialogue(context,
                                                      //     'View Leads');
                                                    }
                                                    if (value == 8) {
                                                      // Common.saveSharedPref(
                                                      //     "statusWise", 'no');
                                                      // leadDashboard!.data!
                                                      //     .viewLead ==
                                                      //     true
                                                      //     ? Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder:
                                                      //           (context) =>
                                                      //           StaffViewLeads(
                                                      //               widget.token,
                                                      //              widget.staffId,
                                                      //               widget.staffName,
                                                      //               pageName:
                                                      //               'Transfer Leads',
                                                      //               fromDate:
                                                      //               fromdate.toString(),
                                                      //               toDate:
                                                      //               todate.toString(),
                                                      //               leadType:'2'
                                                      //           )),
                                                      // )
                                                      //     : _dialogue(context,
                                                      //     'View Leads');
                                                    }
                                                  }),
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  configure!.data!.isExpired == false
                                      ? Column(
                                          children: [
                                            staffDashboard != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Row(
                                                        //   mainAxisAlignment:
                                                        //   MainAxisAlignment
                                                        //       .spaceBetween,
                                                        //   children: [
                                                        //     InkWell(
                                                        //       onTap: () {
                                                        //         leadDashboard!.data!
                                                        //             .createLead ==
                                                        //             true
                                                        //             ? Navigator.push(
                                                        //           context,
                                                        //           MaterialPageRoute(
                                                        //               builder: (context) =>
                                                        //                   AddLeads(
                                                        //                       widget.token)),
                                                        //         )
                                                        //             : _dialogue(context,
                                                        //             'Add Leads');
                                                        //       },
                                                        //       child: Container(
                                                        //         width: MediaQuery
                                                        //             .of(
                                                        //             context)
                                                        //             .size
                                                        //             .width *
                                                        //             .42,
                                                        //         height: 30,
                                                        //         decoration: const BoxDecoration(
                                                        //             boxShadow: [
                                                        //               BoxShadow(
                                                        //                 color:
                                                        //                 Colors.grey,
                                                        //                 offset: Offset(
                                                        //                     0, 2.0),
                                                        //               )
                                                        //             ],
                                                        //             color: Color(
                                                        //                 0xFFf7f7f7),
                                                        //             borderRadius:
                                                        //             BorderRadius
                                                        //                 .all(Radius
                                                        //                 .circular(
                                                        //                 6))),
                                                        //         child: Row(
                                                        //           mainAxisAlignment:
                                                        //           MainAxisAlignment
                                                        //               .start,
                                                        //           children: [
                                                        //             Container(
                                                        //               width: 32,
                                                        //               height: 32,
                                                        //               decoration: const BoxDecoration(
                                                        //                   color: Color(
                                                        //                       0xFFe7e7e7),
                                                        //                   borderRadius:
                                                        //                   BorderRadius.all(
                                                        //                       Radius.circular(
                                                        //                           6))),
                                                        //               child: const Icon(
                                                        //                 Icons.add,
                                                        //                 color: Color(
                                                        //                     0xFF7a7a7a),
                                                        //                 size: 20,
                                                        //               ),
                                                        //             ),
                                                        //             const SizedBox(
                                                        //               width: 15,
                                                        //             ),
                                                        //             const Text(
                                                        //               'Add Leads',
                                                        //               style: TextStyle(
                                                        //                   color: Colors
                                                        //                       .black,
                                                        //                   fontSize: 12),
                                                        //             ),
                                                        //           ],
                                                        //         ),
                                                        //       ),
                                                        //     ),
                                                        //     Row(
                                                        //       children: [
                                                        //         leadDashboard!.data!
                                                        //             .accessCallHistory ==
                                                        //             true
                                                        //             ? Row(
                                                        //           children: [
                                                        //             InkWell(
                                                        //               onTap: () {
                                                        //                 Navigator
                                                        //                     .push(
                                                        //                   context,
                                                        //                   MaterialPageRoute(
                                                        //                       builder: (
                                                        //                           context) =>
                                                        //                           SearchPage(
                                                        //                               widget
                                                        //                                   .token,
                                                        //                               leadDashboard!
                                                        //                                   .data!
                                                        //                                   .updateLead!,
                                                        //                               leadDashboard!
                                                        //                                   .data!
                                                        //                                   .deleteLead!,
                                                        //                               leadDashboard!
                                                        //                                   .data!
                                                        //                                   .cloudCall!,
                                                        //                               '')),
                                                        //                 );
                                                        //               },
                                                        //               child: Container(
                                                        //                   width: 50,
                                                        //                   height: 32,
                                                        //                   padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                       horizontal: 15,
                                                        //                       vertical: 5),
                                                        //                   decoration: BoxDecoration(
                                                        //                       border: Border.all(
                                                        //                           color: Colors
                                                        //                               .white,
                                                        //                           width: 0),
                                                        //                       boxShadow: const [
                                                        //                         BoxShadow(
                                                        //                             color: Colors
                                                        //                                 .grey,
                                                        //                             blurRadius: 5,
                                                        //                             offset: Offset(
                                                        //                                 1, 1)),
                                                        //                       ],
                                                        //                       color: Colors.white,
                                                        //                       borderRadius: const BorderRadius
                                                        //                           .all(
                                                        //                           Radius.circular(
                                                        //                               5))),
                                                        //                   child: const Icon(
                                                        //                       Icons.search)),
                                                        //             ),
                                                        //             const SizedBox(
                                                        //                 width:
                                                        //                 10),
                                                        //             InkWell(
                                                        //               onTap: () {
                                                        //                 Navigator
                                                        //                     .push(
                                                        //                   context,
                                                        //                   MaterialPageRoute(
                                                        //                       builder: (
                                                        //                           context) =>
                                                        //                           CallHistoryPage(
                                                        //                               widget
                                                        //                                   .token!,
                                                        //                               name,
                                                        //                               userId,
                                                        //                               leadDashboard!
                                                        //                                   .data!
                                                        //                                   .accessCallRecording!)),
                                                        //                 );
                                                        //               },
                                                        //               child: Container(
                                                        //                   width: 50,
                                                        //                   height: 32,
                                                        //                   padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                       horizontal: 15,
                                                        //                       vertical: 5),
                                                        //                   decoration: BoxDecoration(
                                                        //                       border: Border.all(
                                                        //                           color: Colors
                                                        //                               .white,
                                                        //                           width: 0),
                                                        //                       boxShadow: const [
                                                        //                         BoxShadow(
                                                        //                             color: Colors
                                                        //                                 .grey,
                                                        //                             blurRadius: 5,
                                                        //                             offset: Offset(
                                                        //                                 1, 1)),
                                                        //                       ],
                                                        //                       color: Colors.white,
                                                        //                       borderRadius: const BorderRadius
                                                        //                           .all(
                                                        //                           Radius.circular(
                                                        //                               5))),
                                                        //                   child: const Icon(
                                                        //                     Icons
                                                        //                         .phone_in_talk_rounded,
                                                        //                     size:
                                                        //                     20,
                                                        //                   )),
                                                        //             ),
                                                        //           ],
                                                        //         )
                                                        //             : InkWell(
                                                        //           onTap: () {
                                                        //             Navigator
                                                        //                 .push(
                                                        //               context,
                                                        //               MaterialPageRoute(
                                                        //                   builder: (context) =>
                                                        //                       SearchPage(
                                                        //                           widget.token,
                                                        //                           leadDashboard!
                                                        //                               .data!
                                                        //                               .updateLead!,
                                                        //                           leadDashboard!
                                                        //                               .data!
                                                        //                               .deleteLead!,
                                                        //                           leadDashboard!
                                                        //                               .data!
                                                        //                               .cloudCall!,
                                                        //                           '')),
                                                        //             );
                                                        //           },
                                                        //           child: Container(
                                                        //               width: 110,
                                                        //               height: 32,
                                                        //               padding: const EdgeInsets
                                                        //                   .symmetric(
                                                        //                   horizontal: 15,
                                                        //                   vertical: 5),
                                                        //               decoration: BoxDecoration(
                                                        //                   border: Border.all(
                                                        //                       color: Colors.white,
                                                        //                       width: 0),
                                                        //                   boxShadow: const [
                                                        //                     BoxShadow(
                                                        //                         color: Colors
                                                        //                             .grey,
                                                        //                         blurRadius: 5,
                                                        //                         offset: Offset(
                                                        //                             1, 1)),
                                                        //                   ],
                                                        //                   color: Colors.white,
                                                        //                   borderRadius: const BorderRadius
                                                        //                       .all(
                                                        //                       Radius.circular(
                                                        //                           5))),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                 MainAxisAlignment
                                                        //                     .start,
                                                        //                 children: [
                                                        //                   const Icon(
                                                        //                       Icons.search),
                                                        //                   Expanded(
                                                        //                     child:
                                                        //                     Container(
                                                        //                       margin:
                                                        //                       const EdgeInsets
                                                        //                           .only(
                                                        //                           left: 10),
                                                        //                       child:
                                                        //                       const Text(
                                                        //                           'Search'),
                                                        //                     ),
                                                        //                   ),
                                                        //                 ],
                                                        //               )),
                                                        //         ),
                                                        //         const SizedBox(
                                                        //             width: 10),
                                                        //         InkWell(
                                                        //           onTap: () {
                                                        //             showGeneralDialog(
                                                        //               barrierLabel:
                                                        //               "showGeneralDialog",
                                                        //               barrierDismissible:
                                                        //               true,
                                                        //               barrierColor: Colors
                                                        //                   .black
                                                        //                   .withOpacity(
                                                        //                   0.6),
                                                        //               transitionDuration:
                                                        //               const Duration(
                                                        //                   milliseconds:
                                                        //                   400),
                                                        //               context: context,
                                                        //               pageBuilder:
                                                        //                   (context, _,
                                                        //                   __) {
                                                        //                 return Align(
                                                        //                   alignment:
                                                        //                   Alignment
                                                        //                       .bottomCenter,
                                                        //                   child:
                                                        //                   IntrinsicHeight(
                                                        //                     child:
                                                        //                     Container(
                                                        //                       width: double
                                                        //                           .maxFinite,
                                                        //                       clipBehavior:
                                                        //                       Clip.antiAlias,
                                                        //                       padding:
                                                        //                       const EdgeInsets
                                                        //                           .all(
                                                        //                           16),
                                                        //                       decoration:
                                                        //                       const BoxDecoration(
                                                        //                         color: Colors
                                                        //                             .white,
                                                        //                         borderRadius:
                                                        //                         BorderRadius.only(
                                                        //                           topLeft:
                                                        //                           Radius.circular(
                                                        //                               16),
                                                        //                           topRight:
                                                        //                           Radius.circular(
                                                        //                               16),
                                                        //                         ),
                                                        //                       ),
                                                        //                       child:
                                                        //                       Material(
                                                        //                         child:
                                                        //                         Column(
                                                        //                           children: [
                                                        //                             const SizedBox(
                                                        //                                 height: 20),
                                                        //                             const Text(
                                                        //                               'Filter By Date Range',
                                                        //                               style: TextStyle(
                                                        //                                 fontSize: 18,
                                                        //                                 fontWeight: FontWeight
                                                        //                                     .w500,
                                                        //                               ),
                                                        //                             ),
                                                        //                             const SizedBox(
                                                        //                                 height: 20),
                                                        //                             Row(
                                                        //                               children: [
                                                        //                                 SizedBox(
                                                        //                                     width: MediaQuery
                                                        //                                         .of(
                                                        //                                         context)
                                                        //                                         .size
                                                        //                                         .width *
                                                        //                                         0.25,
                                                        //                                     child: const Text(
                                                        //                                       'From Date',
                                                        //                                       style: TextStyle(
                                                        //                                         fontSize: 15,
                                                        //                                         fontWeight: FontWeight
                                                        //                                             .w500,
                                                        //                                       ),
                                                        //                                     )),
                                                        //                                 const SizedBox(
                                                        //                                   width: 10,
                                                        //                                 ),
                                                        //                                 SizedBox(
                                                        //                                   height: 50,
                                                        //                                   width: MediaQuery
                                                        //                                       .of(
                                                        //                                       context)
                                                        //                                       .size
                                                        //                                       .width *
                                                        //                                       0.6,
                                                        //                                   child: Center(
                                                        //                                     child: DateTimePicker(
                                                        //                                       decoration: InputDecoration(
                                                        //                                           filled: true,
                                                        //                                           //<-- SEE HERE
                                                        //                                           fillColor: Colors
                                                        //                                               .white,
                                                        //                                           prefixIcon: const Icon(
                                                        //                                             Icons
                                                        //                                                 .arrow_right,
                                                        //                                             color: Colors
                                                        //                                                 .grey,
                                                        //                                           ),
                                                        //                                           counterText: "",
                                                        //                                           hintText: 'From Date',
                                                        //                                           isDense: true,
                                                        //                                           border: OutlineInputBorder(
                                                        //                                               borderSide: BorderSide(
                                                        //                                                   color: Colors
                                                        //                                                       .purple
                                                        //                                                       .shade100),
                                                        //                                               borderRadius: BorderRadius
                                                        //                                                   .circular(
                                                        //                                                   5))),
                                                        //                                       initialValue: fromdate
                                                        //                                           .toString(),
                                                        //                                       type: DateTimePickerType
                                                        //                                           .date,
                                                        //
                                                        //                                       //controller: fromDate,
                                                        //                                       firstDate: DateTime(
                                                        //                                           1995),
                                                        //                                       lastDate: DateTime
                                                        //                                           .now()
                                                        //                                           .add(
                                                        //                                           const Duration(
                                                        //                                               days: 365)),
                                                        //                                       // This will add one year from current date
                                                        //                                       validator: (
                                                        //                                           value) {
                                                        //                                         return null;
                                                        //                                       },
                                                        //                                       onChanged: (
                                                        //                                           value) {
                                                        //                                         if (value
                                                        //                                             .isNotEmpty) {
                                                        //                                           setState(() {
                                                        //                                             fromdate =
                                                        //                                                 DateTime
                                                        //                                                     .parse(
                                                        //                                                     value);
                                                        //                                           });
                                                        //                                         }
                                                        //                                       },
                                                        //                                       // We can also use onSaved
                                                        //                                       onSaved: (
                                                        //                                           value) {
                                                        //                                         if (value!
                                                        //                                             .isNotEmpty) {
                                                        //                                           fromdate =
                                                        //                                               DateTime
                                                        //                                                   .parse(
                                                        //                                                   value);
                                                        //                                         }
                                                        //                                       },
                                                        //                                     ),
                                                        //                                   ),
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                             const SizedBox(
                                                        //                               height: 10,
                                                        //                             ),
                                                        //                             Row(
                                                        //                               children: [
                                                        //                                 SizedBox(
                                                        //                                     width: MediaQuery
                                                        //                                         .of(
                                                        //                                         context)
                                                        //                                         .size
                                                        //                                         .width *
                                                        //                                         0.25,
                                                        //                                     child: const Text(
                                                        //                                       'To Date',
                                                        //                                       style: TextStyle(
                                                        //                                         fontSize: 15,
                                                        //                                         fontWeight: FontWeight
                                                        //                                             .w500,
                                                        //                                       ),
                                                        //                                     )),
                                                        //                                 const SizedBox(
                                                        //                                   width: 10,
                                                        //                                 ),
                                                        //                                 SizedBox(
                                                        //                                   height: 50,
                                                        //                                   width: MediaQuery
                                                        //                                       .of(
                                                        //                                       context)
                                                        //                                       .size
                                                        //                                       .width *
                                                        //                                       0.6,
                                                        //                                   child: Center(
                                                        //                                     child: DateTimePicker(
                                                        //                                       decoration: InputDecoration(
                                                        //                                           filled: true,
                                                        //                                           //<-- SEE HERE
                                                        //                                           fillColor: Colors
                                                        //                                               .white,
                                                        //                                           prefixIcon: const Icon(
                                                        //                                             Icons
                                                        //                                                 .arrow_right,
                                                        //                                             color: Colors
                                                        //                                                 .grey,
                                                        //                                           ),
                                                        //                                           counterText: "",
                                                        //                                           hintText: 'To date',
                                                        //                                           isDense: true,
                                                        //                                           border: OutlineInputBorder(
                                                        //                                               borderSide: BorderSide(
                                                        //                                                   color: Colors
                                                        //                                                       .purple
                                                        //                                                       .shade100),
                                                        //                                               borderRadius: BorderRadius
                                                        //                                                   .circular(
                                                        //                                                   5))),
                                                        //                                       initialValue: todate
                                                        //                                           .toString(),
                                                        //                                       type: DateTimePickerType
                                                        //                                           .date,
                                                        //
                                                        //                                       //controller: fromDate,
                                                        //                                       firstDate: DateTime(
                                                        //                                           1995),
                                                        //                                       lastDate: DateTime
                                                        //                                           .now()
                                                        //                                           .add(
                                                        //                                           const Duration(
                                                        //                                               days: 365)),
                                                        //                                       // This will add one year from current date
                                                        //                                       validator: (
                                                        //                                           value) {
                                                        //                                         return null;
                                                        //                                       },
                                                        //                                       onChanged: (
                                                        //                                           value) {
                                                        //                                         if (value
                                                        //                                             .isNotEmpty) {
                                                        //                                           setState(() {
                                                        //                                             todate =
                                                        //                                                 DateTime
                                                        //                                                     .parse(
                                                        //                                                     value);
                                                        //                                           });
                                                        //                                         }
                                                        //                                       },
                                                        //                                       // We can also use onSaved
                                                        //                                       onSaved: (
                                                        //                                           value) {
                                                        //                                         if (value!
                                                        //                                             .isNotEmpty) {
                                                        //                                           todate =
                                                        //                                               DateTime
                                                        //                                                   .parse(
                                                        //                                                   value);
                                                        //                                         }
                                                        //                                       },
                                                        //                                     ),
                                                        //                                   ),
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                             const SizedBox(
                                                        //                                 height: 16),
                                                        //                             Container(
                                                        //                               height: 40,
                                                        //                               width: double
                                                        //                                   .maxFinite,
                                                        //                               decoration: const BoxDecoration(
                                                        //                                 color: Color(
                                                        //                                     0xFF3375e0),
                                                        //                                 borderRadius: BorderRadius
                                                        //                                     .all(
                                                        //                                     Radius
                                                        //                                         .circular(
                                                        //                                         8)),
                                                        //                               ),
                                                        //                               child: RawMaterialButton(
                                                        //                                 onPressed: () {
                                                        //                                   setState(() {
                                                        //                                     data
                                                        //                                         .remove(
                                                        //                                         data);
                                                        //                                   });
                                                        //
                                                        //                                   getData(
                                                        //                                       widget
                                                        //                                           .token,
                                                        //                                       fromdate,
                                                        //                                       todate);
                                                        //                                   Navigator
                                                        //                                       .of(
                                                        //                                       context,
                                                        //                                       rootNavigator: true)
                                                        //                                       .pop();
                                                        //                                 },
                                                        //                                 child: const Center(
                                                        //                                   child: Text(
                                                        //                                     'Continue',
                                                        //                                     style: TextStyle(
                                                        //                                       color: Colors
                                                        //                                           .white,
                                                        //                                       fontWeight: FontWeight
                                                        //                                           .w500,
                                                        //                                     ),
                                                        //                                   ),
                                                        //                                 ),
                                                        //                               ),
                                                        //                             ),
                                                        //                           ],
                                                        //                         ),
                                                        //                       ),
                                                        //                     ),
                                                        //                   ),
                                                        //                 );
                                                        //               },
                                                        //               transitionBuilder:
                                                        //                   (_,
                                                        //                   animation1,
                                                        //                   __,
                                                        //                   child) {
                                                        //                 return SlideTransition(
                                                        //                   position:
                                                        //                   Tween(
                                                        //                     begin:
                                                        //                     const Offset(
                                                        //                         0,
                                                        //                         1),
                                                        //                     end:
                                                        //                     const Offset(
                                                        //                         0,
                                                        //                         0),
                                                        //                   ).animate(
                                                        //                       animation1),
                                                        //                   child: child,
                                                        //                 );
                                                        //               },
                                                        //             );
                                                        //           },
                                                        //           child: Container(
                                                        //             width: 32,
                                                        //             height: 32,
                                                        //             decoration: BoxDecoration(
                                                        //                 color: Colors
                                                        //                     .white,
                                                        //                 borderRadius:
                                                        //                 BorderRadius
                                                        //                     .circular(
                                                        //                     5)),
                                                        //             child: Center(
                                                        //               child: Center(
                                                        //                   child: Image.asset(
                                                        //                       "assets/icons/calendar.png",
                                                        //                       width:
                                                        //                       32)),
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     )
                                                        //   ],
                                                        // ),
                                                        // const SizedBox(height: 20),
                                                        Text(
                                                          'Staff Dashboard : ${widget.staffName}',
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise", 'no');
                                                                // leadDashboard!.data!
                                                                //     .viewLead ==
                                                                //     true
                                                                //     ? Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder:
                                                                //           (context) =>
                                                                //           StaffViewLeads(
                                                                //             widget.token,
                                                                //             widget.staffId,
                                                                //             widget.staffName,
                                                                //             pageName: 'New Leads',
                                                                //             fromDate: fromdate
                                                                //                 .toString(),
                                                                //             toDate: todate
                                                                //                 .toString(),
                                                                //             status: '1',
                                                                //           )),
                                                                // )
                                                                //     : _dialogue(context,
                                                                //     'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFf0ebef),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "New Leads",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip = _toolTipKey.currentState;
                                                                                toolTip.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'The combined count of new leads \n and  unattended leads',
                                                                                key: _toolTipKey,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .newLeads
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");

                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '1', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
                                                                                      barrierLabel: "showGeneralDialog",
                                                                                      barrierDismissible: true,
                                                                                      barrierColor: Colors.black.withOpacity(0.6),
                                                                                      transitionDuration: const Duration(milliseconds: 400),
                                                                                      context: context,
                                                                                      pageBuilder: (context, _, __) {
                                                                                        return Align(
                                                                                          alignment: Alignment.bottomCenter,
                                                                                          child: IntrinsicHeight(
                                                                                            child: SingleChildScrollView(
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
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      const SizedBox(height: 15),
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: () => {
                                                                                                              Navigator.pop(context),
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              width: 25,
                                                                                                              height: 25,
                                                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                              child: const Center(
                                                                                                                child: Icon(
                                                                                                                  Icons.close,
                                                                                                                  color: Colors.black,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                      const Text(
                                                                                                        'New Leads',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(height: 10),
                                                                                                      Text(
                                                                                                        object1.data!.totalCount.toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          color: Colors.green.shade900,
                                                                                                        ),
                                                                                                      ),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Staff Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  itemCount: object1.data!.staffLeads!.length,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //              widget.staffId,
                                                                                                                              //             widget.staffName,
                                                                                                                              //               pageName: 'New Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: todate
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '1',
                                                                                                                              //              )),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Category Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.categoryLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //               widget.staffId,
                                                                                                                              //               widget.staffName,
                                                                                                                              //               pageName: 'New Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: todate
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '1',
                                                                                                                              //               category: object1
                                                                                                                              //                   .data!
                                                                                                                              //                   .categoryLeads![i]
                                                                                                                              //                   .categoryId
                                                                                                                              //                   .toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                              progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.missedLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Missed Leads',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.missedLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.missedLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.missedLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.missedLeads![i].missedstaffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.missedLeads![i].missedstaffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //               widget.staffId,
                                                                                                                              //             widget.staffName,
                                                                                                                              //               pageName: 'New Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day -
                                                                                                                              //                       1)
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '1',
                                                                                                                              //              )),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.missedLeads![i].missedstaffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.missedLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                    ],
                                                                                                  ),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise", 'no');
                                                                // leadDashboard!.data!
                                                                //     .viewLead ==
                                                                //     true
                                                                //     ? Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           StaffViewLeads(
                                                                //               widget
                                                                //                   .token,
                                                                //              widget.staffId,
                                                                //               widget.staffName,
                                                                //               pageName:
                                                                //               'Followup Leads',
                                                                //               fromDate:
                                                                //               DateTime(DateTime
                                                                //                   .now()
                                                                //                   .year, DateTime
                                                                //                   .now()
                                                                //                   .month - 3,
                                                                //                   DateTime
                                                                //                       .now()
                                                                //                       .day)
                                                                //                   .toString(),
                                                                //               toDate: todate
                                                                //                   .toString(),
                                                                //               status:
                                                                //               '2')),
                                                                // )
                                                                //     : _dialogue(context,
                                                                //     'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFd6ebff),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "Followup Leads",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip1 = _toolTipKey1.currentState;
                                                                                toolTip1.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'The current count of leads \n assigned for today including \n missed follow up leads',
                                                                                key: _toolTipKey1,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .followupLeads
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '2', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
                                                                                      barrierLabel: "showGeneralDialog",
                                                                                      barrierDismissible: true,
                                                                                      barrierColor: Colors.black.withOpacity(0.6),
                                                                                      transitionDuration: const Duration(milliseconds: 400),
                                                                                      context: context,
                                                                                      pageBuilder: (context, _, __) {
                                                                                        return Align(
                                                                                          alignment: Alignment.bottomCenter,
                                                                                          child: IntrinsicHeight(
                                                                                            child: SingleChildScrollView(
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
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      const SizedBox(height: 15),
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: () => {
                                                                                                              Navigator.pop(context),
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              width: 25,
                                                                                                              height: 25,
                                                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                              child: const Center(
                                                                                                                child: Icon(
                                                                                                                  Icons.close,
                                                                                                                  color: Colors.black,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                      const Text(
                                                                                                        'Followup Leads',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(height: 10),
                                                                                                      Text(
                                                                                                        object1.data!.totalCount.toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          color: Colors.green.shade900,
                                                                                                        ),
                                                                                                      ),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Staff Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.staffLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //               widget.staffId,
                                                                                                                              //             widget.staffName,
                                                                                                                              //               pageName: 'Followup Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: todate
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '2',
                                                                                                                              //               )),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Category Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.categoryLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //               widget.staffId,
                                                                                                                              //               widget.staffName,
                                                                                                                              //               pageName: 'Followup Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: todate
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '2',
                                                                                                                              //               category: object1
                                                                                                                              //                   .data!
                                                                                                                              //                   .categoryLeads![i]
                                                                                                                              //                   .categoryId
                                                                                                                              //                   .toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                              progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.missedLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Missed Leads',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.missedLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.missedLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.missedLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.missedLeads![i].missedstaffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.missedLeads![i].missedstaffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator
                                                                                                                              //     .push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(
                                                                                                                              //       builder: (
                                                                                                                              //           context) =>
                                                                                                                              //           StaffViewLeads(
                                                                                                                              //               widget
                                                                                                                              //                   .token,
                                                                                                                              //               widget.staffId,
                                                                                                                              //             widget.staffName,
                                                                                                                              //               pageName: 'Followup Leads',
                                                                                                                              //               fromDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month -
                                                                                                                              //                       3,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day)
                                                                                                                              //                   .toString(),
                                                                                                                              //               toDate: DateTime(
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .year,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .month,
                                                                                                                              //                   DateTime
                                                                                                                              //                       .now()
                                                                                                                              //                       .day -
                                                                                                                              //                       1)
                                                                                                                              //                   .toString(),
                                                                                                                              //               status: '2',
                                                                                                                              //               )),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.missedLeads![i].missedstaffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.missedLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                    ],
                                                                                                  ),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise", 'no');
                                                                // leadDashboard!.data!
                                                                //     .viewLead ==
                                                                //     true
                                                                //     ? Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           StaffViewLeads(
                                                                //               widget
                                                                //                   .token,
                                                                //               widget.staffId,
                                                                //               widget.staffName,
                                                                //               pageName:
                                                                //               'Closed Leads',
                                                                //               fromDate:
                                                                //               fromdate
                                                                //                   .toString(),
                                                                //               toDate: todate
                                                                //                   .toString(),
                                                                //               status:
                                                                //               '4')),
                                                                // )
                                                                //     : _dialogue(context,
                                                                //     'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFced2de),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "Closed Leads",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip2 = _toolTipKey2.currentState;
                                                                                toolTip2.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'Closed leads can be filtered \n using a specific date range to \n determine the count of closed \n leads within that period',
                                                                                key: _toolTipKey2,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .closedLeads
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '4', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
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
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    const SizedBox(height: 15),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                                      children: [
                                                                                                        InkWell(
                                                                                                          onTap: () => {
                                                                                                            Navigator.pop(context),
                                                                                                          },
                                                                                                          child: Container(
                                                                                                            width: 25,
                                                                                                            height: 25,
                                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                            child: const Center(
                                                                                                              child: Icon(
                                                                                                                Icons.close,
                                                                                                                color: Colors.black,
                                                                                                                size: 15,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                    const Text(
                                                                                                      'Closed Leads',
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(height: 10),
                                                                                                    Text(
                                                                                                      object1.data!.totalCount.toString(),
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        color: Colors.green.shade900,
                                                                                                      ),
                                                                                                    ),
                                                                                                    object1.data!.staffLeads!.isNotEmpty
                                                                                                        ? const Padding(
                                                                                                            padding: EdgeInsets.only(bottom: 20),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  'Staff Wise Lead',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.staffLeads!.isNotEmpty
                                                                                                        ? SizedBox(
                                                                                                            height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                            // 70% height
                                                                                                            child: MediaQuery.removePadding(
                                                                                                              context: context,
                                                                                                              removeTop: true,
                                                                                                              child: ListView.builder(
                                                                                                                shrinkWrap: true,
                                                                                                                itemCount: object1.data!.staffLeads!.length,
                                                                                                                itemBuilder: (context, i) {
                                                                                                                  return Column(
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                        child: Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                          children: [
                                                                                                                            Text(
                                                                                                                              object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Text(
                                                                                                                              'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            // Navigator
                                                                                                                            //     .push(
                                                                                                                            //   context,
                                                                                                                            //   MaterialPageRoute(
                                                                                                                            //       builder: (
                                                                                                                            //           context) =>
                                                                                                                            //           StaffViewLeads(
                                                                                                                            //               widget
                                                                                                                            //                   .token,
                                                                                                                            //               widget.staffId,
                                                                                                                            //             widget.staffName,
                                                                                                                            //               pageName: 'Closed Leads',
                                                                                                                            //               fromDate: fromdate
                                                                                                                            //                   .toString(),
                                                                                                                            //               toDate: todate
                                                                                                                            //                   .toString(),
                                                                                                                            //               status: '4',
                                                                                                                            //               )),
                                                                                                                            // );
                                                                                                                          },
                                                                                                                          child: LinearPercentIndicator(
                                                                                                                            width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                            animation: true,
                                                                                                                            lineHeight: 15.0,
                                                                                                                            animationDuration: 2500,
                                                                                                                            percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                            progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(
                                                                                                                        height: 15,
                                                                                                                      )
                                                                                                                    ],
                                                                                                                  );
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.categoryLeads!.isNotEmpty
                                                                                                        ? const Padding(
                                                                                                            padding: EdgeInsets.only(bottom: 20),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  'Category Wise Lead',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.categoryLeads!.isNotEmpty
                                                                                                        ? SizedBox(
                                                                                                            height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                            // 70% height
                                                                                                            child: MediaQuery.removePadding(
                                                                                                              context: context,
                                                                                                              removeTop: true,
                                                                                                              child: ListView.builder(
                                                                                                                shrinkWrap: true,
                                                                                                                itemCount: object1.data!.categoryLeads!.length,
                                                                                                                itemBuilder: (context, i) {
                                                                                                                  return Column(
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                        child: Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                          children: [
                                                                                                                            Text(
                                                                                                                              object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Text(
                                                                                                                              'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            // Navigator
                                                                                                                            //     .push(
                                                                                                                            //   context,
                                                                                                                            //   MaterialPageRoute(
                                                                                                                            //       builder: (
                                                                                                                            //           context) =>
                                                                                                                            //           StaffViewLeads(
                                                                                                                            //               widget
                                                                                                                            //                   .token,
                                                                                                                            //               widget.staffId,
                                                                                                                            //               widget.staffName,
                                                                                                                            //               pageName: 'Closed Leads',
                                                                                                                            //               fromDate: fromdate
                                                                                                                            //                   .toString(),
                                                                                                                            //               toDate: todate
                                                                                                                            //                   .toString(),
                                                                                                                            //               status: '4',
                                                                                                                            //               category: object1
                                                                                                                            //                   .data!
                                                                                                                            //                   .categoryLeads![i]
                                                                                                                            //                   .categoryId
                                                                                                                            //                   .toString())),
                                                                                                                            // );
                                                                                                                          },
                                                                                                                          child: LinearPercentIndicator(
                                                                                                                            width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                            animation: true,
                                                                                                                            lineHeight: 15.0,
                                                                                                                            animationDuration: 2500,
                                                                                                                            percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                            progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(
                                                                                                                        height: 15,
                                                                                                                      )
                                                                                                                    ],
                                                                                                                  );
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise", 'no');
                                                                // leadDashboard!.data!
                                                                //     .viewLead ==
                                                                //     true
                                                                //     ? Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           StaffViewLeads(
                                                                //               widget
                                                                //                   .token,
                                                                //               widget.staffId,
                                                                //               widget.staffName,
                                                                //               pageName:
                                                                //               'Total Called',
                                                                //               fromDate:
                                                                //               fromdate
                                                                //                   .toString(),
                                                                //               toDate: todate
                                                                //                   .toString(),
                                                                //               status:
                                                                //               '-1')),
                                                                // )
                                                                //     : _dialogue(context,
                                                                //     'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFb4c2dd),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "Total Called",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip3 = _toolTipKey3.currentState;
                                                                                toolTip3.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'Total called can be filtered \n using a specific date range to \n determine the count of total leads \n within that period',
                                                                                key: _toolTipKey3,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .totalCalled
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '-1', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
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
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    const SizedBox(height: 15),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                                      children: [
                                                                                                        InkWell(
                                                                                                          onTap: () => {
                                                                                                            Navigator.pop(context),
                                                                                                          },
                                                                                                          child: Container(
                                                                                                            width: 25,
                                                                                                            height: 25,
                                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                            child: const Center(
                                                                                                              child: Icon(
                                                                                                                Icons.close,
                                                                                                                color: Colors.black,
                                                                                                                size: 15,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                    const Text(
                                                                                                      'Total Called',
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(height: 10),
                                                                                                    Text(
                                                                                                      object1.data!.totalCount.toString(),
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        color: Colors.green.shade900,
                                                                                                      ),
                                                                                                    ),
                                                                                                    object1.data!.staffLeads!.isNotEmpty
                                                                                                        ? const Padding(
                                                                                                            padding: EdgeInsets.only(bottom: 20),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  'Staff Wise Lead',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.staffLeads!.isNotEmpty
                                                                                                        ? SizedBox(
                                                                                                            height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                            // 70% height
                                                                                                            child: MediaQuery.removePadding(
                                                                                                              context: context,
                                                                                                              removeTop: true,
                                                                                                              child: ListView.builder(
                                                                                                                shrinkWrap: true,
                                                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                                                itemCount: object1.data!.staffLeads!.length,
                                                                                                                itemBuilder: (context, i) {
                                                                                                                  return Column(
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                        child: Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                          children: [
                                                                                                                            Text(
                                                                                                                              object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Text(
                                                                                                                              'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            // Navigator
                                                                                                                            //     .push(
                                                                                                                            //   context,
                                                                                                                            //   MaterialPageRoute(
                                                                                                                            //       builder: (
                                                                                                                            //           context) =>
                                                                                                                            //           StaffViewLeads(
                                                                                                                            //               widget
                                                                                                                            //                   .token,
                                                                                                                            //               widget.staffId,
                                                                                                                            //             widget.staffName,
                                                                                                                            //               pageName: 'Total Called',
                                                                                                                            //               fromDate: fromdate
                                                                                                                            //                   .toString(),
                                                                                                                            //               toDate: todate
                                                                                                                            //                   .toString(),
                                                                                                                            //               status: '-1',
                                                                                                                            //               )),
                                                                                                                            // );
                                                                                                                          },
                                                                                                                          child: LinearPercentIndicator(
                                                                                                                            width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                            animation: true,
                                                                                                                            lineHeight: 15.0,
                                                                                                                            animationDuration: 2500,
                                                                                                                            percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                            progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(
                                                                                                                        height: 15,
                                                                                                                      )
                                                                                                                    ],
                                                                                                                  );
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.categoryLeads!.isNotEmpty
                                                                                                        ? const Padding(
                                                                                                            padding: EdgeInsets.only(bottom: 20),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  'Category Wise Lead',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.categoryLeads!.isNotEmpty
                                                                                                        ? SizedBox(
                                                                                                            height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                            // 70% height
                                                                                                            child: MediaQuery.removePadding(
                                                                                                              context: context,
                                                                                                              removeTop: true,
                                                                                                              child: ListView.builder(
                                                                                                                shrinkWrap: true,
                                                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                                                itemCount: object1.data!.categoryLeads!.length,
                                                                                                                itemBuilder: (context, i) {
                                                                                                                  return Column(
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                        child: Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                          children: [
                                                                                                                            Text(
                                                                                                                              object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Text(
                                                                                                                              'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            // Navigator
                                                                                                                            //     .push(
                                                                                                                            //   context,
                                                                                                                            //   MaterialPageRoute(
                                                                                                                            //       builder: (
                                                                                                                            //           context) =>
                                                                                                                            //           StaffViewLeads(
                                                                                                                            //               widget
                                                                                                                            //                   .token,
                                                                                                                            //               widget.staffId,
                                                                                                                            //               widget.staffName,
                                                                                                                            //               pageName: 'Total Called',
                                                                                                                            //               fromDate: fromdate
                                                                                                                            //                   .toString(),
                                                                                                                            //               toDate: todate
                                                                                                                            //                   .toString(),
                                                                                                                            //               status: '-1',
                                                                                                                            //               category: object1
                                                                                                                            //                   .data!
                                                                                                                            //                   .categoryLeads![i]
                                                                                                                            //                   .categoryId
                                                                                                                            //                   .toString())),
                                                                                                                            // );
                                                                                                                          },
                                                                                                                          child: LinearPercentIndicator(
                                                                                                                            width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                            animation: true,
                                                                                                                            lineHeight: 15.0,
                                                                                                                            animationDuration: 2500,
                                                                                                                            percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                            progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(
                                                                                                                        height: 15,
                                                                                                                      )
                                                                                                                    ],
                                                                                                                  );
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.statusLeads!.isNotEmpty
                                                                                                        ? const Padding(
                                                                                                            padding: EdgeInsets.only(bottom: 20),
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  'Status Wise Lead',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    object1.data!.statusLeads!.isNotEmpty
                                                                                                        ? SizedBox(
                                                                                                            height: 60 * double.parse(object1.data!.statusLeads!.length.toString()),
                                                                                                            // 70% height
                                                                                                            child: MediaQuery.removePadding(
                                                                                                              context: context,
                                                                                                              removeTop: true,
                                                                                                              child: ListView.builder(
                                                                                                                shrinkWrap: true,
                                                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                                                itemCount: object1.data!.statusLeads!.length,
                                                                                                                itemBuilder: (context, i) {
                                                                                                                  return Column(
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                        child: Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                          children: [
                                                                                                                            Text(
                                                                                                                              object1.data!.statusLeads![i].statusName.toString(),
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Text(
                                                                                                                              'Count : ${object1.data!.statusLeads![i].statusCount}',
                                                                                                                              style: const TextStyle(
                                                                                                                                fontSize: 14,
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                color: Colors.black,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            // Navigator
                                                                                                                            //     .push(
                                                                                                                            //   context,
                                                                                                                            //   MaterialPageRoute(
                                                                                                                            //       builder: (
                                                                                                                            //           context) =>
                                                                                                                            //           StaffViewLeads(
                                                                                                                            //               widget
                                                                                                                            //                   .token,
                                                                                                                            //               widget.staffId,
                                                                                                                            //               widget.staffName,
                                                                                                                            //               pageName: 'Total Called',
                                                                                                                            //               fromDate: fromdate
                                                                                                                            //                   .toString(),
                                                                                                                            //               toDate: todate
                                                                                                                            //                   .toString(),
                                                                                                                            //               status: object1
                                                                                                                            //                   .data!
                                                                                                                            //                   .statusLeads![i]
                                                                                                                            //                   .statusId
                                                                                                                            //                   .toString())),
                                                                                                                            // );
                                                                                                                          },
                                                                                                                          child: LinearPercentIndicator(
                                                                                                                            width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                            animation: true,
                                                                                                                            lineHeight: 15.0,
                                                                                                                            animationDuration: 2500,
                                                                                                                            percent: double.parse(object1.data!.statusLeads![i].statusPercentage.toString()),
                                                                                                                            progressColor: object1.data!.statusLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      const SizedBox(
                                                                                                                        height: 15,
                                                                                                                      )
                                                                                                                    ],
                                                                                                                  );
                                                                                                                },
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise",
                                                                //     'no');
                                                                // viewLeadPermission ==
                                                                //         'true'
                                                                //     ? Navigator.push(
                                                                //         context,
                                                                //         MaterialPageRoute(
                                                                //             builder:
                                                                //                 (context) =>
                                                                //                     ViewLeads(
                                                                //                       widget.token,
                                                                //                       updateLeadPermission1,
                                                                //                       deleteLeadPermission1,
                                                                //                       cloudCallPermission1,
                                                                //                       pageName: 'Transfered Leads',
                                                                //                       leadType: "2",
                                                                //                     )),
                                                                //       )
                                                                //     : _dialogue(
                                                                //         context,
                                                                //         'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        189,
                                                                        226,
                                                                        249),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "Transfered Leads",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip4 = _toolTipKey4.currentState;
                                                                                toolTip4.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'Transfered leads can be filtered \n using a specific date range to \n determine the count of closed \n leads within that period',
                                                                                key: _toolTipKey4,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .transferLeads
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                Common.saveSharedPref("statusWise", 'no');
                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '-2', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
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
                                                                                                child: SingleChildScrollView(
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      const SizedBox(height: 15),
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: () => {
                                                                                                              Navigator.pop(context),
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              width: 25,
                                                                                                              height: 25,
                                                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                              child: const Center(
                                                                                                                child: Icon(
                                                                                                                  Icons.close,
                                                                                                                  color: Colors.black,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                      const Text(
                                                                                                        'Transfered Leads',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(height: 10),
                                                                                                      Text(
                                                                                                        object1.data!.totalCount.toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          color: Colors.green.shade900,
                                                                                                        ),
                                                                                                      ),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Staff Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  itemCount: object1.data!.staffLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator.push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(builder: (context) => ViewLeads(widget.token, updateLeadPermission1, deleteLeadPermission1, cloudCallPermission1, pageName: 'Transfered Leads', fromDate: fromdate.toString(), toDate: todate.toString(), leadType: "2", staff: object1.data!.staffLeads![i].staffId.toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Category Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  itemCount: object1.data!.categoryLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator.push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(builder: (context) => ViewLeads(widget.token, updateLeadPermission1, deleteLeadPermission1, cloudCallPermission1, pageName: 'Transfered Leads', fromDate: fromdate.toString(), toDate: todate.toString(), leadType: "2", category: object1.data!.categoryLeads![i].categoryId.toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                              progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                    ],
                                                                                                  ),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                // Common.saveSharedPref(
                                                                //     "statusWise",
                                                                //     'no');
                                                                // viewLeadPermission ==
                                                                //         'true'
                                                                //     ? Navigator.push(
                                                                //         context,
                                                                //         MaterialPageRoute(
                                                                //             builder:
                                                                //                 (context) =>
                                                                //                     ViewLeads(
                                                                //                       widget.token,
                                                                //                       updateLeadPermission1,
                                                                //                       deleteLeadPermission1,
                                                                //                       cloudCallPermission1,
                                                                //                       pageName: 'Missed Leads',
                                                                //                       leadType: "1",
                                                                //                     )),
                                                                //       )
                                                                //     : _dialogue(
                                                                //         context,
                                                                //         'View Leads');
                                                              },
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.42,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        239,
                                                                        210,
                                                                        214),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            const Text(
                                                                              "Missed Leads",
                                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                dynamic toolTip5 = _toolTipKey5.currentState;
                                                                                toolTip5.ensureTooltipVisible();
                                                                              },
                                                                              child: Tooltip(
                                                                                padding: const EdgeInsets.all(10),
                                                                                message: 'Missed Leads can be filtered \n using a specific date range to \n determine the count of total leads \n within that period',
                                                                                key: _toolTipKey5,
                                                                                child: Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    '?',
                                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          staffDashboard!
                                                                              .data
                                                                              .missedLeads
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            const Text(
                                                                              "View Leads",
                                                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                Common.saveSharedPref("statusWise", 'no');
                                                                                LeadProgressbarModel object1 = await HttpService.leadProgressbarStaff(widget.token, fromdate, todate, '-3', widget.staffId);
                                                                                if (object1.status == true) {
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    showGeneralDialog(
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
                                                                                                child: SingleChildScrollView(
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      const SizedBox(height: 15),
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: () => {
                                                                                                              Navigator.pop(context),
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              width: 25,
                                                                                                              height: 25,
                                                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all()),
                                                                                                              child: const Center(
                                                                                                                child: Icon(
                                                                                                                  Icons.close,
                                                                                                                  color: Colors.black,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                      const Text(
                                                                                                        'Missed Leads',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(height: 10),
                                                                                                      Text(
                                                                                                        object1.data!.totalCount.toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          color: Colors.green.shade900,
                                                                                                        ),
                                                                                                      ),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Staff Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.staffLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.staffLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.staffLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.staffLeads![i].staffName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.staffLeads![i].staffCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator.push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(builder: (context) => ViewLeads(widget.token, updateLeadPermission1, deleteLeadPermission1, cloudCallPermission1, pageName: 'Missed Leads', fromDate: fromdate.toString(), toDate: todate.toString(), leadType: '1', staff: object1.data!.staffLeads![i].staffId.toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.staffLeads![i].staffPercentage.toString()),
                                                                                                                              progressColor: object1.data!.staffLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Category Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.categoryLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.categoryLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.categoryLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.categoryLeads![i].categoryName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.categoryLeads![i].categoryCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator.push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(builder: (context) => ViewLeads(widget.token, updateLeadPermission1, deleteLeadPermission1, cloudCallPermission1, pageName: 'Missed Leads', fromDate: fromdate.toString(), toDate: todate.toString(), leadType: '1', category: object1.data!.categoryLeads![i].categoryId.toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.categoryLeads![i].categoryPercentage.toString()),
                                                                                                                              progressColor: object1.data!.categoryLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.statusLeads!.isNotEmpty
                                                                                                          ? const Padding(
                                                                                                              padding: EdgeInsets.only(bottom: 20),
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    'Status Wise Lead',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 16,
                                                                                                                      fontWeight: FontWeight.w500,
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                      object1.data!.statusLeads!.isNotEmpty
                                                                                                          ? SizedBox(
                                                                                                              height: 60 * double.parse(object1.data!.statusLeads!.length.toString()),
                                                                                                              // 70% height
                                                                                                              child: MediaQuery.removePadding(
                                                                                                                context: context,
                                                                                                                removeTop: true,
                                                                                                                child: ListView.builder(
                                                                                                                  shrinkWrap: true,
                                                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                                                  itemCount: object1.data!.statusLeads!.length,
                                                                                                                  itemBuilder: (context, i) {
                                                                                                                    return Column(
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                                                                                                          child: Row(
                                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                            children: [
                                                                                                                              Text(
                                                                                                                                object1.data!.statusLeads![i].statusName.toString(),
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              Text(
                                                                                                                                'Count : ${object1.data!.statusLeads![i].statusCount}',
                                                                                                                                style: const TextStyle(
                                                                                                                                  fontSize: 14,
                                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                                  color: Colors.black,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ],
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                                                                                                                          child: InkWell(
                                                                                                                            onTap: () {
                                                                                                                              // Navigator.push(
                                                                                                                              //   context,
                                                                                                                              //   MaterialPageRoute(builder: (context) => ViewLeads(widget.token, deleteLeadPermission1, deleteLeadPermission1, cloudCallPermission1, pageName: 'Missed Leads', fromDate: fromdate.toString(), leadType: "1", toDate: todate.toString(), status: object1.data!.statusLeads![i].statusId.toString())),
                                                                                                                              // );
                                                                                                                            },
                                                                                                                            child: LinearPercentIndicator(
                                                                                                                              width: MediaQuery.of(context).size.width * 0.82,
                                                                                                                              animation: true,
                                                                                                                              lineHeight: 15.0,
                                                                                                                              animationDuration: 2500,
                                                                                                                              percent: double.parse(object1.data!.statusLeads![i].statusPercentage.toString()),
                                                                                                                              progressColor: object1.data!.statusLeads!.length > _colors.length ? Colors.red : _colors[i],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        const SizedBox(
                                                                                                                          height: 15,
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            )
                                                                                                          : const SizedBox(),
                                                                                                    ],
                                                                                                  ),
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
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(boxShadow: [
                                                                                  BoxShadow(color: Colors.grey.shade500, offset: const Offset(0, 2.0))
                                                                                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Center(
                                                                                      child: Image.asset(
                                                                                    "assets/icons/lineSegment.png",
                                                                                  )),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                      ],
                                                    ))
                                                : Shimmer.fromColors(
                                                    enabled: true,
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child:
                                                        SingleChildScrollView(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 12.0,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                            staffWise != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                offset: Offset(
                                                                    0, 2.0),
                                                              )
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          const Text(
                                                                            'Category Wise Report',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          viewLeadCategoryPermission == 'true'
                                                                              ? InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(builder: (context) => ViewLeadCategory(widget.token!, createLeadCategory1, updateLeadCategory1, deleteLeadCategory1)),
                                                                                    );
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.settings,
                                                                                    color: Colors.blue.shade800,
                                                                                    size: 15,
                                                                                  ),
                                                                                )
                                                                              : const SizedBox()
                                                                        ],
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showGeneralDialog(
                                                                            barrierLabel:
                                                                                "showGeneralDialog",
                                                                            barrierDismissible:
                                                                                true,
                                                                            barrierColor:
                                                                                Colors.black.withOpacity(0.6),
                                                                            transitionDuration:
                                                                                const Duration(milliseconds: 400),
                                                                            context:
                                                                                context,
                                                                            pageBuilder: (context,
                                                                                _,
                                                                                __) {
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
                                                                                      child: Column(
                                                                                        children: [
                                                                                          const SizedBox(height: 20),
                                                                                          const Text(
                                                                                            'Filter By Date Range',
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
                                                                                                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                                                    initialValue: fromdate1.toString(),
                                                                                                    type: DateTimePickerType.date,

                                                                                                    //controller: fromDate,
                                                                                                    firstDate: DateTime(1995),
                                                                                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                                                                                    // This will add one year from current date
                                                                                                    validator: (value) {
                                                                                                      return null;
                                                                                                    },
                                                                                                    onChanged: (value) {
                                                                                                      if (value.isNotEmpty) {
                                                                                                        setState(() {
                                                                                                          fromdate1 = DateTime.parse(value).toString();
                                                                                                        });
                                                                                                      }
                                                                                                    },
                                                                                                    // We can also use onSaved
                                                                                                    onSaved: (value) {
                                                                                                      if (value!.isNotEmpty) {
                                                                                                        fromdate1 = DateTime.parse(value).toString();
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
                                                                                                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                                                    initialValue: todate1.toString(),
                                                                                                    type: DateTimePickerType.date,

                                                                                                    //controller: fromDate,
                                                                                                    firstDate: DateTime(1995),
                                                                                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                                                                                    // This will add one year from current date
                                                                                                    validator: (value) {
                                                                                                      return null;
                                                                                                    },
                                                                                                    onChanged: (value) {
                                                                                                      if (value.isNotEmpty) {
                                                                                                        setState(() {
                                                                                                          todate1 = DateTime.parse(value);
                                                                                                        });
                                                                                                      }
                                                                                                    },
                                                                                                    // We can also use onSaved
                                                                                                    onSaved: (value) {
                                                                                                      if (value!.isNotEmpty) {
                                                                                                        todate1 = DateTime.parse(value);
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
                                                                                                setState(() {
                                                                                                  data.remove(data);
                                                                                                });

                                                                                                getData(widget.token, fromdate, todate);
                                                                                                Navigator.of(context, rootNavigator: true).pop();
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
                                                                            transitionBuilder: (_,
                                                                                animation1,
                                                                                __,
                                                                                child) {
                                                                              return SlideTransition(
                                                                                position: Tween(
                                                                                  begin: const Offset(0, 1),
                                                                                  end: const Offset(0, 0),
                                                                                ).animate(animation1),
                                                                                child: child,
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade100,
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Center(child: Image.asset("assets/icons/calendar.png", width: 25)),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              20),
                                                                  child: Text(
                                                                      'From ${DateFormat("dd-MM-yyyy").format(DateTime.parse(fromdate1))} To ${DateFormat("dd-MM-yyyy").format(todate1)}'),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Divider(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  thickness:
                                                                      1.0,
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                data.isNotEmpty
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            PieChart(
                                                                          dataMap:
                                                                              data,
                                                                          animationDuration:
                                                                              const Duration(milliseconds: 800),
                                                                          chartLegendSpacing:
                                                                              20,
                                                                          chartRadius:
                                                                              MediaQuery.of(context).size.width / 2.5,
                                                                          colorList:
                                                                              _colors,
                                                                          initialAngleInDegree:
                                                                              0,
                                                                          chartType:
                                                                              ChartType.ring,
                                                                          ringStrokeWidth:
                                                                              25,
                                                                          centerText: staffDashboard!
                                                                              .data
                                                                              .currentLeadsCount
                                                                              .total,
                                                                          centerTextStyle: const TextStyle(
                                                                              fontSize: 20,
                                                                              color: Colors.black),
                                                                          legendOptions:
                                                                              const LegendOptions(
                                                                            legendShape:
                                                                                BoxShape.rectangle,
                                                                            showLegendsInRow:
                                                                                false,
                                                                            legendPosition:
                                                                                LegendPosition.right,
                                                                            showLegends:
                                                                                true,
                                                                            legendTextStyle:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          chartValuesOptions:
                                                                              const ChartValuesOptions(
                                                                            showChartValueBackground:
                                                                                false,
                                                                            showChartValues:
                                                                                false,
                                                                            showChartValuesInPercentage:
                                                                                false,
                                                                            showChartValuesOutside:
                                                                                false,
                                                                            decimalPlaces:
                                                                                1,
                                                                          ),
                                                                          // gradientList: ---To add gradient colors---
                                                                          // emptyColorGradient: ---Empty Color gradient---
                                                                        ),
                                                                      )
                                                                    : Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/icons/nodatafound.png',
                                                                                width: 100,
                                                                                height: 100,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const Text(
                                                                            'Result Not Found',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          const Text(
                                                                            'Whoops... this information is \n not available for a moment',
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                15,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                data.isNotEmpty
                                                                    ? Column(
                                                                        children: [
                                                                          Table(columnWidths: const {
                                                                            0: FlexColumnWidth(10),
                                                                            1: FlexColumnWidth(5),
                                                                            2: FlexColumnWidth(5),
                                                                            3: FlexColumnWidth(5),
                                                                            4: FlexColumnWidth(5),
                                                                            5: FlexColumnWidth(5),
                                                                          }, children: [
                                                                            const TableRow(
                                                                                // decoration: new BoxDecoration(
                                                                                //     color: Colors.greenAccent),
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      "",
                                                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      'New',
                                                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      'Pending',
                                                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      'Followup',
                                                                                      style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      'Rejected',
                                                                                      style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      'Closed',
                                                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                    )),
                                                                                  ),
                                                                                ]),
                                                                            for (int i = 0;
                                                                                i < staffWise!.data!.categoryLeads!.length;
                                                                                i++)
                                                                              TableRow(children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10, left: 10),
                                                                                  child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].categoryName.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].newCount.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].pendingCount.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].followupCount.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].rejectedCount.toString(),
                                                                                    style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    staffWise!.data!.categoryLeads![i].confirmedCount.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ),
                                                                              ]),
                                                                          ]),
                                                                          const Divider(
                                                                            endIndent:
                                                                                8,
                                                                            indent:
                                                                                8,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 5.0, bottom: 12.0),
                                                                            child:
                                                                                Table(
                                                                              columnWidths: const {
                                                                                0: FlexColumnWidth(10),
                                                                                1: FlexColumnWidth(5),
                                                                                2: FlexColumnWidth(5),
                                                                                3: FlexColumnWidth(5),
                                                                                4: FlexColumnWidth(5),
                                                                                5: FlexColumnWidth(5),
                                                                              },
                                                                              children: [
                                                                                TableRow(children: [
                                                                                  const Center(
                                                                                      child: Text(
                                                                                    "Total Leads",
                                                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                  Center(
                                                                                      child: Text(
                                                                                    catNew.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                  Center(
                                                                                      child: Text(
                                                                                    catPending.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                  Center(
                                                                                      child: Text(
                                                                                    catFollowup.toString(),
                                                                                    style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                  Center(
                                                                                      child: Text(
                                                                                    catRejected.toString(),
                                                                                    style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                  Center(
                                                                                      child: Text(
                                                                                    catClosed.toString(),
                                                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                                ]),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : const SizedBox()
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    enabled: true,
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child:
                                                        SingleChildScrollView(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 96.0,
                                                                  height: 72.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            100.0,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 96.0,
                                                                  height: 72.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            200,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            100.0,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 200,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 96.0,
                                                                  height: 72.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                      ),
                                                                      Container(
                                                                        width:
                                                                            100.0,
                                                                        height:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white,
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.1),
                                                child: Card(
                                                  // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  // Set the clip behavior of the card
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  // Define the child widgets of the card
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                                      Image.asset(
                                                        'assets/main/packageimage.png',
                                                        height: 160,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      // Add a container with padding that contains the card's title, text, and buttons
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                15, 15, 15, 0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            const Text(
                                                              'Package Expired..',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                            // Add a row with two buttons spaced apart and aligned to the right side of the card
                                                            Row(
                                                              children: <Widget>[
                                                                // Add a spacer to push the buttons to the right side of the card
                                                                const Spacer(),
                                                                // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                                                // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    "UPGRADE",
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    _upgrade(
                                                                        context);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Add a small space between the card and the next widget
                                                      Container(height: 5),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Shimmer.fromColors(
                      enabled: true,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200.0,
                              margin: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 200,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 10.0,
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
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
                      )),
              endDrawer: DraweScreen(widget.token!),
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
                    const Text(
                      'No Network Found !',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        getData(widget.token, fromdate, todate);
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

  void _upgrade(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Upgrade Package !!!'),
            content: const Text(
                'Please contact the support team to upgrade your current plan'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
              TextButton(
                  onPressed: () async {
                    String url = 'tel:${configure!.data!.supportTeamNumber}';
                    await launch(url);
                  },
                  child: const Text('Call'))
            ],
          );
        });
  }

  bool toBoolean(String val) {
    return (val == "true" || val == "1") ? true : false;
  }
}
