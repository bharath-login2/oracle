import 'package:call_log/call_log.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/common.dart';
import '../../models/callLogs/callLogHistoryModel.dart';
import '../../models/callLogs/callLogUploadModel.dart';
import '../../models/callLogs/deleteCallHistoryModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';

class CallLogs extends StatefulWidget {
  String? token;
  String? name;
  String? userId;

  CallLogs(this.token, this.name, this.userId, {Key? key}) : super(key: key);

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> history = [];
  List historyIndex = [];
  bool onLongPress = false;
  bool refresh = false;
  CallLogHistoryModel? logHistory;
  String? permissionAccess = '';
  List deleteHistoryIds = [];
  bool onLongPressHistory = false;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  bool isSearch = true;
  bool search = false;
  AddLeadCommonDataModel? commonDetails;
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  int from =
      DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
  int to = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedData();
  }

  getSharedData() async {
    refresh = true;
    permissionAccess = await Common.getSharedPref("callLogPermission");
    setState(() {});
    if (permissionAccess == 'true') {
      if (await Permission.phone.request().isGranted) {
        final Iterable<CallLogEntry> result = await CallLog.query(
          dateFrom: from,
          dateTo: to,
        );
        setState(() {
          _callLogEntries = result;
          refresh = false;
        });
      }
    }
  }

  getData() async {
    if (search == false) {
      assignStaff = widget.name.toString();
      assignStaffId = widget.userId.toString();
    }
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (commonDetails != null) {
      setState(() {});
    }
    logHistory = await HttpService.callLogHistory(
        widget.token, fromdate, todate, assignStaffId);
    if (logHistory != null) {
      setState(() {
        if (isSearch == false) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
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
                        'Call Logs',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      history.isNotEmpty
                          ? InkWell(
                              onTap: () async {
                                Map<String, dynamic> body = {
                                  "token": widget.token,
                                  'log': history,
                                };

                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Uploading..");
                                }

                                CallLogUploadModel object1 =
                                    await HttpService.callLogUpload(body);
                                if (object1.data == true) {
                                  Common.toastMessaage(
                                      object1.message, Colors.green);
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CallLogs(
                                              widget.token,
                                              widget.name,
                                              widget.userId)),
                                    );
                                  }
                                } else {
                                  Common.toastMessaage(
                                      object1.message, Colors.red);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green),
                                child: const Center(
                                  child: Text("Upload",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.none,
                                          color: Colors.white)),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      deleteHistoryIds.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Please Confirm'),
                                        content: const Text(
                                            'Are you sure to Delete?'),
                                        actions: [
                                          // The "Yes" button
                                          TextButton(
                                              onPressed: () async {
                                                Map<String, dynamic> body = {
                                                  "token": widget.token,
                                                  'deletedIds':
                                                      deleteHistoryIds,
                                                };
                                                DeleteCallHistoryModel delete =
                                                    await HttpService
                                                        .deleteCallHistoryLogs(
                                                            body);
                                                if (delete.data == true) {
                                                  deleteHistoryIds.clear();
                                                  Common.toastMessaage(
                                                      delete.message,
                                                      Colors.green);
                                                  if (context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CallLogs(
                                                                  widget.token,
                                                                  widget.name,
                                                                  widget
                                                                      .userId)),
                                                    );
                                                  }
                                                } else {
                                                  Common.toastMessaage(
                                                      delete.message,
                                                      Colors.red);
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                  }
                                                }
                                              },
                                              child: const Text('Yes')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'))
                                        ],
                                      );
                                    });
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: permissionAccess == 'true'
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
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
                                deleteHistoryIds.clear();
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .45,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Call Logs',
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
                                history.clear();
                                historyIndex.clear();
                              });
                              getData();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .45,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Call History',
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
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    selectedIndex == 0
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              //Text(_callLogEntries as String),

                              refresh == false
                                  ? Column(
                                      children: [
                                        Text(
                                          '${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(from))} - ${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(to))} (Last 30 Days)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        _callLogEntries.isNotEmpty
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    _callLogEntries.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (context, indexStaff) {
                                                  return InkWell(
                                                      onLongPress: () {
                                                        setState(() {
                                                          onLongPress = true;
                                                          history.add({
                                                            "name": _callLogEntries
                                                                .elementAt(
                                                                    indexStaff)
                                                                .name,
                                                            "phone_number":
                                                                _callLogEntries
                                                                    .elementAt(
                                                                        indexStaff)
                                                                    .number,
                                                            "callTypes": _callLogEntries
                                                                .elementAt(
                                                                    indexStaff)
                                                                .callType
                                                                .toString()
                                                                .substring(_callLogEntries
                                                                        .elementAt(
                                                                            indexStaff)
                                                                        .callType
                                                                        .toString()
                                                                        .indexOf(
                                                                            '.') +
                                                                    1),
                                                            "time":
                                                                '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                            "duration":
                                                                _callLogEntries
                                                                    .elementAt(
                                                                        indexStaff)
                                                                    .duration,
                                                            "simName": _callLogEntries
                                                                .elementAt(
                                                                    indexStaff)
                                                                .simDisplayName,
                                                            "timeStamp":
                                                                _callLogEntries
                                                                    .elementAt(
                                                                        indexStaff)
                                                                    .timestamp,
                                                          });
                                                          historyIndex
                                                              .add(indexStaff);
                                                        });
                                                      },
                                                      onTap: () {
                                                        if (onLongPress ==
                                                            true) {
                                                          if (historyIndex
                                                              .contains(
                                                                  indexStaff)) {
                                                            historyIndex.remove(
                                                                indexStaff);
                                                            history.removeWhere(
                                                              (item) =>
                                                                  mapEquals(
                                                                      item,
                                                                      ({
                                                                        "name": _callLogEntries
                                                                            .elementAt(indexStaff)
                                                                            .name,
                                                                        "phone_number": _callLogEntries
                                                                            .elementAt(indexStaff)
                                                                            .number,
                                                                        "callTypes": _callLogEntries
                                                                            .elementAt(
                                                                                indexStaff)
                                                                            .callType
                                                                            .toString()
                                                                            .substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') +
                                                                                1),
                                                                        "time":
                                                                            '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                        "duration": _callLogEntries
                                                                            .elementAt(indexStaff)
                                                                            .duration,
                                                                        "simName": _callLogEntries
                                                                            .elementAt(indexStaff)
                                                                            .simDisplayName,
                                                                        "timeStamp": _callLogEntries
                                                                            .elementAt(indexStaff)
                                                                            .timestamp,
                                                                      })),
                                                            );
                                                          } else {
                                                            history.add({
                                                              "name": _callLogEntries
                                                                  .elementAt(
                                                                      indexStaff)
                                                                  .name,
                                                              "phone_number":
                                                                  _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .number,
                                                              "callTypes": _callLogEntries
                                                                  .elementAt(
                                                                      indexStaff)
                                                                  .callType
                                                                  .toString()
                                                                  .substring(_callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .callType
                                                                          .toString()
                                                                          .indexOf(
                                                                              '.') +
                                                                      1),
                                                              "time":
                                                                  '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                              "duration":
                                                                  _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .duration,
                                                              "simName": _callLogEntries
                                                                  .elementAt(
                                                                      indexStaff)
                                                                  .simDisplayName,
                                                              "timeStamp":
                                                                  _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .timestamp,
                                                            });
                                                            historyIndex.add(
                                                                indexStaff);
                                                          }
                                                        }
                                                        setState(() {});
                                                      },
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
                                                            color: historyIndex
                                                                    .contains(
                                                                        indexStaff)
                                                                ? Colors
                                                                    .blueGrey
                                                                    .shade200
                                                                : Colors.white,
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
                                                                    // Text(
                                                                    //     'F. NUMBER  : ${_callLogEntries.elementAt(indexStaff).formattedNumber}'),
                                                                    // Text(
                                                                    //     'C.M. NUMBER: ${_callLogEntries.elementAt(indexStaff).cachedMatchedNumber}'),
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
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.6,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    _callLogEntries.elementAt(indexStaff).name.toString(),
                                                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 3,
                                                                                  ),
                                                                                  Text(
                                                                                    _callLogEntries.elementAt(indexStaff).number.toString(),
                                                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onLongPress != true
                                                                                ? InkWell(
                                                                                    onTap: () async {
                                                                                      Common.showProgressDialog(context, "Loading..");
                                                                                      history.add({
                                                                                        "name": _callLogEntries.elementAt(indexStaff).name,
                                                                                        "phone_number": _callLogEntries.elementAt(indexStaff).number,
                                                                                        "callTypes": _callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                                        "time": '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                                        "duration": _callLogEntries.elementAt(indexStaff).duration,
                                                                                        "simName": _callLogEntries.elementAt(indexStaff).simDisplayName,
                                                                                        "timeStamp": _callLogEntries.elementAt(indexStaff).timestamp,
                                                                                      });
                                                                                      historyIndex.add(indexStaff);
                                                                                      Map<String, dynamic> body = {
                                                                                        "token": widget.token,
                                                                                        'log': history,
                                                                                      };
                                                                                      CallLogUploadModel object1 = await HttpService.callLogUpload(body);
                                                                                      if (object1.data == true) {
                                                                                        Common.toastMessaage(object1.message, Colors.green);
                                                                                        if (context.mounted) {
                                                                                          Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(builder: (context) => CallLogs(widget.token, widget.name, widget.userId)),
                                                                                          );
                                                                                        }
                                                                                      } else {
                                                                                        Common.toastMessaage(object1.message, Colors.red);
                                                                                        if (context.mounted) {
                                                                                          Navigator.pop(context);
                                                                                        }
                                                                                      }
                                                                                    },
                                                                                    child: const Icon(Icons.upload))
                                                                                : const SizedBox(),
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
                                                                              '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
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
                                                                                '${(Duration(seconds: _callLogEntries.elementAt(indexStaff).duration!))}'.split('.')[0].padLeft(8, '0'),
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
                                                                          'Type  : ${_callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1)}',
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            child:
                                                                                Text(
                                                                              '${_callLogEntries.elementAt(indexStaff).simDisplayName}',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                })
                                            : Center(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 100,
                                                    ),
                                                    Image.asset(
                                                        'assets/main/noCallLog.png',
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.fill),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const Text(
                                                      'No Calls Found',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ],
                                    )
                                  : Center(
                                      child: Lottie.asset(
                                          'assets/main/loading.json',
                                          fit: BoxFit.fill),
                                    )
                            ],
                          )
                        : Column(
                            children: [
                              logHistory != null && commonDetails != null
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('From Date',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                    child: Center(
                                                      child: DateTimePicker(
                                                        decoration:
                                                            InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                filled: true,
                                                                //<-- SEE HERE
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                prefixIcon:
                                                                    const Icon(
                                                                  Icons
                                                                      .arrow_right,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                counterText: "",
                                                                hintText:
                                                                    'From Date',
                                                                isDense: true,
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .purple
                                                                            .shade100),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5))),
                                                        initialValue:
                                                            fromdate.toString(),
                                                        type: DateTimePickerType
                                                            .date,

                                                        //controller: fromDate,
                                                        firstDate:
                                                            DateTime(1995),
                                                        lastDate: DateTime.now()
                                                            .add(const Duration(
                                                                days: 365)),
                                                        // This will add one year from current date
                                                        validator: (value) {
                                                          return null;
                                                        },
                                                        onChanged: (value) {
                                                          if (value
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              fromdate =
                                                                  DateTime.parse(
                                                                      value);
                                                            });
                                                          }
                                                        },
                                                        // We can also use onSaved
                                                        onSaved: (value) {
                                                          if (value!
                                                              .isNotEmpty) {
                                                            fromdate =
                                                                DateTime.parse(
                                                                    value);
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('To Date',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                    child: Center(
                                                      child: DateTimePicker(
                                                        decoration:
                                                            InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                filled: true,
                                                                //<-- SEE HERE
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                prefixIcon:
                                                                    const Icon(
                                                                  Icons
                                                                      .arrow_right,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                counterText: "",
                                                                hintText:
                                                                    'From Date',
                                                                isDense: true,
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .purple
                                                                            .shade100),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5))),
                                                        initialValue:
                                                            todate.toString(),
                                                        type: DateTimePickerType
                                                            .date,

                                                        //controller: fromDate,
                                                        firstDate:
                                                            DateTime(1995),
                                                        lastDate: DateTime.now()
                                                            .add(const Duration(
                                                                days: 365)),
                                                        // This will add one year from current date
                                                        validator: (value) {
                                                          return null;
                                                        },
                                                        onChanged: (value) {
                                                          if (value
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              todate = DateTime
                                                                  .parse(value);
                                                            });
                                                          }
                                                        },
                                                        // We can also use onSaved
                                                        onSaved: (value) {
                                                          if (value!
                                                              .isNotEmpty) {
                                                            todate =
                                                                DateTime.parse(
                                                                    value);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                child: TextFormField(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              scrollable: true,
                                                              title: const Text(
                                                                  'Staffs'),
                                                              content: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    commonDetails!
                                                                        .data!
                                                                        .staff!
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        ind) {
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        assignStaff = commonDetails!
                                                                            .data!
                                                                            .staff![ind]
                                                                            .staffName
                                                                            .toString();
                                                                        assignStaffId = commonDetails!
                                                                            .data!
                                                                            .staff![ind]
                                                                            .staffId
                                                                            .toString();
                                                                        Navigator.pop(
                                                                            context,
                                                                            true);
                                                                      });
                                                                    },
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          50,
                                                                      child:
                                                                          Text(
                                                                        commonDetails!
                                                                            .data!
                                                                            .staff![ind]
                                                                            .staffName
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    maxLines: 1,
                                                    readOnly: true,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(3),
                                                        filled: true,
                                                        //<-- SEE HERE
                                                        fillColor: Colors.white,
                                                        prefixIcon: const Icon(
                                                          Icons
                                                              .arrow_drop_down_circle,
                                                          color: Colors.grey,
                                                        ),
                                                        counterText: "",
                                                        hintText: assignStaff,
                                                        isDense: true,
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .purple
                                                                    .shade100),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)))),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    search = true;
                                                    isSearch = false;
                                                    Common.showProgressDialog(
                                                        context, "Loading..");
                                                    getData();
                                                  });
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Center(
                                                    child: Text('Search',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        logHistory!.data!.isNotEmpty
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    logHistory!.data!.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onLongPress: () {
                                                        setState(() {
                                                          onLongPressHistory =
                                                              true;
                                                          deleteHistoryIds.add(
                                                              logHistory!
                                                                  .data![index]
                                                                  .id
                                                                  .toString());
                                                        });
                                                      },
                                                      onTap: () {
                                                        if (onLongPressHistory ==
                                                            true) {
                                                          if (deleteHistoryIds
                                                              .contains(logHistory!
                                                                  .data![index]
                                                                  .id
                                                                  .toString())) {
                                                            deleteHistoryIds
                                                                .remove(logHistory!
                                                                    .data![
                                                                        index]
                                                                    .id
                                                                    .toString());
                                                          } else {
                                                            deleteHistoryIds
                                                                .add(logHistory!
                                                                    .data![
                                                                        index]
                                                                    .id
                                                                    .toString());
                                                          }
                                                        }
                                                        setState(() {});
                                                      },
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
                                                            color: deleteHistoryIds
                                                                    .contains(logHistory!
                                                                        .data![
                                                                            index]
                                                                        .id
                                                                        .toString())
                                                                ? Colors
                                                                    .blueGrey
                                                                    .shade200
                                                                : Colors.white,
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
                                                                              logHistory!.data![index].name.toString(),
                                                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 3,
                                                                            ),
                                                                            Text(
                                                                              logHistory!.data![index].phoneNumber.toString(),
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
                                                                              logHistory!.data![index].dateTime.toString(),
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
                                                                                logHistory!.data![index].duration.toString().split('.')[0].padLeft(8, '0'),
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
                                                                          'Type  : ${logHistory!.data![index].callType}',
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
                                                })
                                            : Center(
                                                child: Lottie.asset(
                                                    'assets/main/no_history.json',
                                                    fit: BoxFit.fill),
                                              )
                                      ],
                                    )
                                  : Center(
                                      child: Lottie.asset(
                                          'assets/main/loading.json',
                                          fit: BoxFit.fill),
                                    )
                            ],
                          )
                  ],
                ),
              )
            : Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Permission",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                // decoration: TextDecoration.none,
                                //fontFamily: Theme.of(context).textTheme,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "We want to inform you that Login2 collects and uploads your call logs, including call duration and timestamps, to our secure servers. This data is shared with your company's super admin to enable them to track call activities.Your privacy is important to us, and we want to assure you that all data is handled with the utmost care and in accordance with our privacy policy. The information uploaded is encrypted to ensure its security during transmission and storage.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Dashboard(widget.token)),
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: const Color(0xffe94040)),
                                    child: const Center(
                                      child: Text("Deny",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              decoration: TextDecoration.none,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Permission.phone.request();
                                    setState(() {
                                      Common.saveSharedPref(
                                          "callLogPermission", 'true');
                                      refresh = true;
                                      getSharedData();
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.green),
                                    child: const Center(
                                      child: Text("Allow",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              decoration: TextDecoration.none,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
