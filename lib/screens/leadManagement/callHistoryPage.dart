import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/playWidget.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/callLogs/callLogHistoryModel.dart';
import '../../models/lead_management/callHistoryModel.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CallHistoryPage extends StatefulWidget {
  String token;
  String name;
  String userId;
  bool accessCallRecord;

  CallHistoryPage(this.token, this.name, this.userId, this.accessCallRecord,
      {super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  CallHistoryModel? callHistory;
  String fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String todate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  CallLogHistoryModel? logHistory;
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  bool? result = true;
  bool? result1 = true;
  bool search = false;
  bool isSearch = true;
  int selectedIndex = 0;
  int callHistoryCount = 0;
  //final GlobalKey<AudioItemsState> _keyChild1 = GlobalKey();
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String cloudCallPermission = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  final List<Color> _colors = [
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
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    if (search == false) {
      assignStaff = widget.name;
      assignStaffId = widget.userId;
    }
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
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    if (updateLeadPermission == 'true') {
      updateLeadPermission1 = true;
    }
    if (deleteLeadPermission == 'true') {
      deleteLeadPermission1 = true;
    }
    if (cloudCallPermission == 'true') {
      cloudCallPermission1 = true;
    }
    callHistory = await HttpService.callHistory(
        widget.token, assignStaffId, fromdate, todate);
    if (callHistory != null) {
      setState(() {
        isSearch = false;
      });
    }
    callHistoryCount = 0;
    getHistoryCount();

    logHistory = await HttpService.callLogHistory(
        widget.token, fromdate, todate, assignStaffId);
    if (logHistory != null) {
      if (mounted) {
        setState(() {
          // If search was previously true, we might want to pop a dialog if one was showing
          // but usually this is just a data refresh.
        });
      }
    }
  }

  getHistoryCount() {
    for (int i = 0; i < callHistory!.data!.callHistory!.length; i++) {
      callHistoryCount =
          callHistoryCount + callHistory!.data!.callHistory![i].history!.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getData();
        return;
      },
      child: result1 == true
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
                              'Call History',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: callHistory != null && isSearch == false
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                    fromdate = DateFormat('dd-MM-yyyy')
                                        .format(selctedDatetimetemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
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
                                            fromdate,
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
                                GestureDetector(
                                  onTap: () async {
                                    final toDateSelectTemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    todate = DateFormat('dd-MM-yyyy')
                                        .format(toDateSelectTemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
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
                                            todate,
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: const Text('Staffs'),
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
                                                itemCount: callHistory!
                                                    .data!.staffList!.length,
                                                itemBuilder: (context, ind) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        assignStaff =
                                                            callHistory!
                                                                .data!
                                                                .staffList![ind]
                                                                .staffName
                                                                .toString();
                                                        assignStaffId =
                                                            callHistory!
                                                                .data!
                                                                .staffList![ind]
                                                                .userId
                                                                .toString();
                                                        Navigator.pop(
                                                            context, true);
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 50,
                                                      child: Text(
                                                        callHistory!
                                                            .data!
                                                            .staffList![ind]
                                                            .staffName
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.white),
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
                                                assignStaff,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ],
                                      ),
                                    )),
                                  ),
                                ),
                                // SizedBox(
                                //   width: MediaQuery.of(context).size.width *
                                //       0.45,
                                //   child: TextFormField(
                                //       onTap: () {
                                //         showDialog(
                                //             context: context,
                                //             builder: (BuildContext context) {
                                //               return AlertDialog(
                                //                 scrollable: true,
                                //                 title: const Text('Staffs'),
                                //                 content: ListView.builder(
                                //                   shrinkWrap: true,
                                //                   itemCount: callHistory!
                                //                       .data!
                                //                       .staffList!
                                //                       .length,
                                //                   itemBuilder:
                                //                       (context, ind) {
                                //                     return InkWell(
                                //                       onTap: () {
                                //                         setState(() {
                                //                           assignStaff =
                                //                               callHistory!
                                //                                   .data!
                                //                                   .staffList![
                                //                                       ind]
                                //                                   .staffName
                                //                                   .toString();
                                //                           assignStaffId =
                                //                               callHistory!
                                //                                   .data!
                                //                                   .staffList![
                                //                                       ind]
                                //                                   .userId
                                //                                   .toString();
                                //                           Navigator.pop(
                                //                               context, true);
                                //                         });
                                //                       },
                                //                       child: SizedBox(
                                //                         height: 50,
                                //                         child: Text(
                                //                           callHistory!
                                //                               .data!
                                //                               .staffList![ind]
                                //                               .staffName
                                //                               .toString(),
                                //                           style:
                                //                               const TextStyle(
                                //                                   fontSize:
                                //                                       18),
                                //                         ),
                                //                       ),
                                //                     );
                                //                   },
                                //                 ),
                                //               );
                                //             });
                                //       },
                                //       maxLines: 1,
                                //       readOnly: true,
                                //       keyboardType: TextInputType.text,
                                //       decoration: InputDecoration(
                                //           filled: true,
                                //           //<-- SEE HERE
                                //           fillColor: Colors.white,
                                //           suffixIcon: const Icon(
                                //             Icons.arrow_drop_down_circle,
                                //             color: Colors.grey,
                                //           ),
                                //           counterText: "",
                                //           hintText: assignStaff,
                                //           isDense: true,
                                //           border: OutlineInputBorder(
                                //
                                //               borderRadius:
                                //                   BorderRadius.circular(
                                //                       5)))),
                                // ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      search = true;
                                      isSearch = true;
                                      // Common.showProgressDialog(
                                      //     context, "Loading..");
                                      getData();
                                    });
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
                                      child: Text('Search',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .32,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selectedIndex == 0
                                                ? Colors.grey
                                                : Colors.white,
                                            width: 0),
                                        color: selectedIndex == 0
                                            ? const Color(0xFFd5f5f4)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Call History (${callHistoryCount.toString()})',
                                            style: TextStyle(
                                              color: selectedIndex == 0
                                                  ? const Color(0xFF3c9f9a)
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                    getData();
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selectedIndex == 1
                                                ? Colors.grey
                                                : Colors.white,
                                            width: 0),
                                        color: selectedIndex == 1
                                            ? const Color(0xFFd5f5f4)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Followup History',
                                            style: TextStyle(
                                              color: selectedIndex == 1
                                                  ? const Color(0xFF3c9f9a)
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      selectedIndex = 2;
                                    });
                                    getData();
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .25,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selectedIndex == 2
                                                ? Colors.grey
                                                : Colors.white,
                                            width: 0),
                                        color: selectedIndex == 2
                                            ? const Color(0xFFd5f5f4)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Call Log',
                                            style: TextStyle(
                                              color: selectedIndex == 2
                                                  ? const Color(0xFF3c9f9a)
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          selectedIndex == 0
                              ? SizedBox(
                                  child: callHistory!
                                          .data!.callHistory!.isNotEmpty
                                      ? Column(
                                          children: [
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: callHistory!
                                                    .data!.callHistory!.length,
                                                itemBuilder: (context, i) {
                                                  return Column(
                                                    children: [
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Colors
                                                                      .white),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: Center(
                                                                child: Text(
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .date
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                          )),
                                                      ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history!
                                                                  .length,
                                                          itemBuilder:
                                                              (context, ind) {
                                                            return AudioItems(
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .direction
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .time
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .isAttended!,
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .calledTime
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .status
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .resourceURL
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .callDurationHr
                                                                  .toString(),
                                                              widget
                                                                  .accessCallRecord,
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .clientName
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .leadCategory
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .callResult
                                                                  .toString(),
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .callHistoryImage
                                                                  .toString(),
                                                              fromdate
                                                                  .toString(),
                                                              todate.toString(),
                                                              updateLeadPermission1,
                                                              deleteLeadPermission1,
                                                              cloudCallPermission1,
                                                              callHistory!
                                                                  .data!
                                                                  .callHistory![
                                                                      i]
                                                                  .history![ind]
                                                                  .callMasterId
                                                                  .toString(),
                                                              widget.token,
                                                              widget.name,
                                                              widget.userId,
                                                            );
                                                          }),
                                                    ],
                                                  );
                                                }),
                                          ],
                                        )
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.55,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DashboardLeadNewUpdatedTwo(
                                                                      widget
                                                                          .token)),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Center(
                                                    child: Text('Go Back',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                              : selectedIndex == 1
                                  ? SizedBox(
                                      child: callHistory!
                                              .data!.followupHistory!.isNotEmpty
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: callHistory!.data!
                                                  .followupHistory!.length,
                                              itemBuilder: (context, ind) {
                                                return Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 50.0),
                                                      child: InkWell(
                                                        child: Card(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors
                                                                  .green
                                                                  .shade100,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                  spreadRadius:
                                                                      4,
                                                                  blurRadius: 6,
                                                                  offset:
                                                                      const Offset(
                                                                          1, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 40),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                120,
                                                                            child:
                                                                                Text(
                                                                              callHistory!.data!.followupHistory![ind].clientName.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                120,
                                                                            child:
                                                                                Text(
                                                                              callHistory!.data!.followupHistory![ind].contactNumber1.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.w400),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            SizedBox(
                                                                          child:
                                                                              Text(
                                                                            callHistory!.data!.followupHistory![ind].calledTime.toString(),
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.w400, color: Colors.green),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Called By: ${callHistory!.data!.followupHistory![ind].staffName}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Scheduled Date : ${callHistory!.data!.followupHistory![ind].scheduledDate}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Remark:${callHistory!.data!.followupHistory![ind].remarks}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          const Text(
                                                                            'Status :',
                                                                            style:
                                                                                TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              // color: _colors[int.parse(callHistory!.data!.followupHistory![ind].callResultId.toString())], borderRadius: BorderRadius.circular(5)
                                                                              color: (() {
                                                                                final callResultId = callHistory?.data?.followupHistory?[ind].callResultId;
                                                                                final id = int.tryParse(callResultId?.toString() ?? '');
                                                                                if (id != null && id >= 0 && id < _colors.length) {
                                                                                  return _colors[id];
                                                                                } else {
                                                                                  return Colors.grey;
                                                                                }
                                                                              })(),
                                                                              borderRadius: BorderRadius.circular(5),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                                                                              child: Text(
                                                                                callHistory!.data!.followupHistory![ind].callResult.toString(),
                                                                                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  callHistory!
                                                                              .data!
                                                                              .followupHistory![ind]
                                                                              .reason !=
                                                                          ''
                                                                      ? Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 8),
                                                                          child:
                                                                              Text(
                                                                            'Reason: ${callHistory!.data!.followupHistory![ind].reason}',
                                                                            style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                  callHistory!
                                                                              .data!
                                                                              .followupHistory![ind]
                                                                              .callResponse !=
                                                                          ''
                                                                      ? Text(
                                                                          'Call Response : ${callHistory!.data!.followupHistory![ind].callResponse}',
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        )
                                                                      : const SizedBox(),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0.0,
                                                      bottom: 0.0,
                                                      left: 35.0,
                                                      child: Container(
                                                        height: double.infinity,
                                                        width: 1.0,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 30.0,
                                                      left: 15.0,
                                                      child: Container(
                                                        height: 30.0,
                                                        width: 80.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    1, 1)),
                                                          ],
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                          callHistory!
                                                              .data!
                                                              .followupHistory![
                                                                  ind]
                                                              .calledDate
                                                              .toString(),
                                                        )),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              })
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.55,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Whoops... this information is \n not available for a moment',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DashboardLeadNewUpdatedTwo(
                                                                          widget
                                                                              .token)),
                                                              (Route<dynamic>
                                                                      route) =>
                                                                  false);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Center(
                                                        child: Text('Go Back',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))
                                  : SizedBox(
                                      child: (logHistory
                                                  ?.data?.lists?.isNotEmpty ??
                                              false)
                                          ? Column(
                                              children: [
                                                if (logHistory
                                                        ?.data?.totalDuration !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors
                                                                .blue.shade200),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                            'Total Call Duration:',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                          Text(
                                                            logHistory!.data!
                                                                .totalDuration!,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: logHistory!
                                                        .data!.lists!.length,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10,
                                                                bottom: 10),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                offset: Offset(
                                                                    2.0, 2.0),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        right:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
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
                                                                              minHeight: 20,
                                                                              minWidth: 20,
                                                                              maxHeight: 50,
                                                                              maxWidth: 50,
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.white, width: 0),
                                                                              boxShadow: const [
                                                                                BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(1, 1)),
                                                                              ],
                                                                              color: Colors.white,
                                                                              shape: BoxShape.circle,
                                                                              image: const DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/main/avatar.png')),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              logHistory!.data!.lists![index].name.toString(),
                                                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 3,
                                                                            ),
                                                                            Text(
                                                                              logHistory!.data!.lists![index].phoneNumber.toString(),
                                                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Image.asset("assets/icons/calendar.png",
                                                                                width: 20),
                                                                            const SizedBox(
                                                                              width: 15,
                                                                            ),
                                                                            Text(
                                                                              logHistory!.data!.lists![index].dateTime.toString(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const Icon(Icons.timer_outlined),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 10),
                                                                              child: Text(
                                                                                logHistory!.data!.lists![index].duration.toString().split('.')[0].padLeft(8, '0'),
                                                                                style: const TextStyle(fontSize: 15, color: Colors.green),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Type  : ${logHistory!.data!.lists![index].callType}',
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          child:
                                                                              const Padding(
                                                                            padding: EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            child:
                                                                                Text(
                                                                              'SIM 1',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                    // Text(
                                                                    //     'ACCOUNT ID : ${_callLogEntries.elementAt(indexStaff).phoneAccountId}',
                                                                    //     ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                    }),
                                              ],
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.55,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Whoops... this information is \n not available for a moment',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DashboardLeadNewUpdatedTwo(
                                                                          widget
                                                                              .token)),
                                                              (Route<dynamic>
                                                                      route) =>
                                                                  false);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Center(
                                                        child: Text('Go Back',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))
                        ],
                      ),
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              )),
    );
  }
}

// ignore: must_be_immutable
