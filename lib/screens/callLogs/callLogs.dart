// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:call_e_log/call_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/config.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/screens/leadManagement/add_leads.dart';
import 'package:lottie/lottie.dart';
// import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sim_data/sim_data.dart';
import '../../core/common.dart';
import '../../models/callLogUploadPermissionModel.dart';
import '../../models/callLogs/callLogHistoryModel.dart';
import '../../models/callLogs/callLogUploadModel.dart';
import '../../models/callLogs/callLogUploadPermissionUpdateModel.dart';
import '../../models/callLogs/deleteCallHistoryModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';

class CallLogs extends StatefulWidget {
  String? token;
  String? name;
  String? userId;

  CallLogs(this.token, this.name, this.userId, {super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  int selectedIndex = Platform.isAndroid ? 0 : 1;
  List<Map<String, dynamic>> history = [];
  List historyIndex = [];
  bool onLongPress = false;
  bool refresh = false;
  CallLogHistoryModel? logHistory;
  String? permissionAccess = '';
  String? uploadPermission = '';
  List deleteHistoryIds = [];
  bool onLongPressHistory = false;
  String fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String todate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isSearch = true;
  bool search = false;
  AddLeadCommonDataModel? commonDetails;
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  int from =
      DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
  int to = DateTime.now().millisecondsSinceEpoch;
  bool displayOverApps = false;
  CallLogUploadPermissionModel? callUploadPermission;
  String roleId = "";
  // String selectedSim = "";
  // String selectedSimId = "";
  List<Map<String, dynamic>> simList = [];
  String phoneNumber = "";

  void dialNumber(String number) {
    setState(() {
      phoneNumber += number;
    });
  }

  void deleteLastDigit() {
    if (phoneNumber.isNotEmpty) {
      setState(() {
        phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      });
    }
  }

  List<String> dialPadNumbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '*',
    '0',
    '#'
  ];

  @override
  void initState() {
    super.initState();
    assignStaff = widget.name.toString();
    assignStaffId = widget.userId.toString();
    if (Platform.isAndroid) {
      getSharedData();
      getPermission();
    } else {
      getData();
    }
     WidgetsBinding.instance.addPostFrameCallback((_) {
      askUserNeeds(context,false);
    });
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
     getSharedData();
  }

  

  Future<void> loadHiveData() async {
    fullHiveData.clear();
  final List<HiveCaallHistoryModel> hiveData = await HiveUtil.getAllCallLogs();
  log('hiveData LENGTH: ${hiveData.length}');
  for (var entry in hiveData) {
    log('Entry: ${entry.name} || ${entry.phoneNumber} || ${entry.isUploaded}');
  }

  setState(() {
    fullHiveData = hiveData;
    // You might also refresh _callLogEntries here if needed
    refresh = false;
  });
}

   
  void askUserNeeds(BuildContext context, bool showPopUp) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> callTypes = prefs.getStringList('callTypes') ?? [];
  // List<String> simOptions = prefs.getStringList('simOptions') ?? [];


  if (callTypes.isEmpty ||  showPopUp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button dismiss
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Center(child: Text('Permission Required')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                        child: Text(
                      'Please allow permission to access call logs.',
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(height: 10),

                    //! Call Type Selection
                    const Text('Select Call Type'),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (callTypes.contains('Incoming')) {
                                callTypes.remove('Incoming');
                              } else {
                                callTypes.add('Incoming');
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: callTypes.contains('Incoming')
                                  ? Colors.green
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.call_received,
                                    color: Colors.red),
                                const SizedBox(width: 5),
                                Text(
                                  'Incoming',
                                  style: TextStyle(
                                    color: callTypes.contains('Incoming')
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (callTypes.contains('Outgoing')) {
                                callTypes.remove('Outgoing');
                              } else {
                                callTypes.add('Outgoing');
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: callTypes.contains('Outgoing')
                                  ? Colors.green
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.call_made,
                                    color: Colors.blue),
                                const SizedBox(width: 5),
                                Text(
                                  'Outgoing',
                                  style: TextStyle(
                                    color: callTypes.contains('Outgoing')
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                   
                
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (callTypes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please select at least one Call Type'),
                            ),
                          );
                          return;
                        }

                        await prefs.setStringList('callTypes', callTypes);
                        // await prefs.setStringList('simOptions', simOptions);
                        await prefs.setString('callLogsStartingTime',  DateTime.now().toString());
                        //!
                         // 🔄 Save toggle history for incoming/outgoing
                          if (callTypes.contains("Incoming")) {
                            await ToggleStorage.addToggleEvent(CallLogToggleEvent(
                              type: "Incoming",
                              isEnabled: true,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            ));
                          } else {
                            await ToggleStorage.addToggleEvent(CallLogToggleEvent(
                              type: "Incoming",
                              isEnabled: false,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            ));
                          }

                          if (callTypes.contains("Outgoing")) {
                            await ToggleStorage.addToggleEvent(CallLogToggleEvent(
                              type: "Outgoing",
                              isEnabled: true,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            ));
                          } else {
                            await ToggleStorage.addToggleEvent(CallLogToggleEvent(
                              type: "Outgoing",
                              isEnabled: false,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            ));
                          }
                            //!
                            List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
                            log('callTypes : $callTypesQ');

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

  List<HiveCaallHistoryModel> fullHiveData =[];



  getSharedData() async {
    try {
      refresh = true;
      permissionAccess = await Common.getSharedPref("callLogPermission");
      uploadPermission = await Common.getSharedPref("uploadCallLog");
      roleId = await Common.getSharedPref("roleId");
      // var sim = await Common.getSharedPref("simName");
      // if (sim != null) {
      //   selectedSim = await Common.getSharedPref("simName");
      //   selectedSimId = await Common.getSharedPref("simId");
      // } else {
      //   selectedSim = "Tap to select";
      //   selectedSimId = "";
      // }
      if (uploadPermission != "true" && Platform.isIOS) {
        selectedIndex = -1;
      }
      setState(() {});
      if (permissionAccess == 'true') {
        if (await Permission.phone.request().isGranted) {
          final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();
            


          final Iterable<CallLogEntry> result = await CallLog.query(
            dateFrom: from,
            dateTo: to,
          );
          final filteredLogs = result.where((entry) {
          return isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
        }).toList();

          // getSimDetails();
           final List<HiveCaallHistoryModel> hiveData = await HiveUtil.getAllCallLogs();
          log('hiveData 1: ${hiveData}');
          log('hiveData 0: ${hiveData.length}');
          log('================================== HIVE DATA IN GET SHARED DATA ========================================');
          log('hiveData LENGTH 1 : ${hiveData.length}');
          for(var datassss in hiveData){
             log('hiveData LENGTH 2 : ${datassss.name} || ${datassss.phoneNumber} || ${datassss.isUploaded}');
          }
         
          setState(() {
              fullHiveData=hiveData;
            _callLogEntries = filteredLogs;
            refresh = false;
          });
        }
      }
      // !   UPDATE MISSING CALL LOG
        final int callLogCount = await HiveUtil.getCallLogCount();
        SharedPreferences prefs = await SharedPreferences.getInstance();
         List<HiveCaallHistoryModel> callLogData = <HiveCaallHistoryModel>[];
         final String dateTimeFrom = prefs.getString('callLogsStartingTime').toString();
        if (callLogCount==0) {
              log( 'No call logs found in Hive.');
              
              final DateTime startingTime = DateTime.parse(dateTimeFrom);
              final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

              final Iterable<CallLogEntry> result = await CallLog.query(
                dateFrom: from,
                dateTo: to,
              );
            final List<CallLogEntry> filteredLogs = result.where((entry) {
              final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
              
              // Only logs AFTER startingTime + pass your custom toggle filter
              return callTime.isAfter(startingTime) &&
                    isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
            }).toList();
             log('filteredLogs : ${filteredLogs.length}');
            if (filteredLogs.isNotEmpty) {
               for (var callLog in filteredLogs) {
                HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                  id: callLog.timestamp.toString(),
                  name: callLog.name.toString(),
                  phoneNumber: callLog.number.toString(),
                  callType: callLog.callType.toString().substring(callLog.callType.toString().indexOf('.') + 1),
                  duration: callLog.duration.toString(),
                  timeStamp: '${DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!)}',
                  simSlot: callLog.simDisplayName??"NIL",
                  callRecordFilePath: "",
                  isUploaded: false,
                  isDeleted:false,
                );
                await HiveUtil.addCallLog(hiveCallLog);
                callLogData.add(hiveCallLog);
                if (callLogData.isNotEmpty) {
                   await uploadMissingLogsToServer(callLogData);            
                }
                setState(() {
            refresh = false;
          });
          getSharedData();
          return;
              }
            } else { 
              log('No call logs found');
            }

        } else {
           log( 'call logs found in Hive.');
           
             callLogData.clear();
             final String dateTimeFrom = prefs.getString('callLogsStartingTime').toString();
             final DateTime startingTime = DateTime.parse(dateTimeFrom);

              final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

              final Iterable<CallLogEntry> result = await CallLog.query(
                dateFrom: from,
                dateTo: to,
              );
            final List<CallLogEntry> callLogsFromDevice = result.where((entry) {
              final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
              
              // Only logs AFTER startingTime + pass your custom toggle filter
              return callTime.isAfter(startingTime) &&
                    isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
            }).toList();
            //!
              log('Call logs from device : $callLogsFromDevice');
              log('Call logs from length : ${callLogsFromDevice.length}');
              if(callLogsFromDevice.isEmpty){
                log('no call logs in device');
                return ;
              }

              final deviceLatestCallLogTime = parseCallLogTime(callLogsFromDevice.first.timestamp.toString()); 

              final List<HiveCaallHistoryModel> hiveData = await HiveUtil.getAllCallLogs();

              final HiveCaallHistoryModel latestHiveCallLog2 = await HiveUtil.getLatestCallLogByTime() ?? hiveData.first ;
                log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded}');
              
              final hiveLatestDateTime = parseCallLogTime(latestHiveCallLog2.timeStamp); 

                      if (hiveLatestDateTime==deviceLatestCallLogTime) {
                          log('Latest Hive Call Log and Device Call Log are same.');
                          log('first call log : ${latestHiveCallLog2.isUploaded}');
                          return;
                        } else {
                   log('Latest Hive Call Log and Device Call Log are not same.');
                    // List<CallLogEntry> allCallLogsAfterHiveLatestData = await getFilteredCallLogs(hiveLatestDateTime);
                     final DateTime startingTime = DateTime.parse(dateTimeFrom);
                      final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

                      final Iterable<CallLogEntry> result = await CallLog.query(
                        dateFrom: from,
                        dateTo: to,
                      );
                    final List<CallLogEntry> allCallLogsAfterHiveLatestData = result.where((entry) {
                      final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
                      
                      // Only logs AFTER startingTime + pass your custom toggle filter
                      return callTime.isAfter(startingTime) &&
                            isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
                    }).toList();
                    log('Call logs from device after latest hive data : $allCallLogsAfterHiveLatestData');
                    log('Call logs from length after latest hive data : ${allCallLogsAfterHiveLatestData.length}');
                        // callLogData.addAll(hiveData);
                        history.clear();
                        callLogData.clear();

                         if (allCallLogsAfterHiveLatestData.isNotEmpty) {
                            for (var callLog in allCallLogsAfterHiveLatestData) {
                              HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                                id: callLog.timestamp.toString(),
                                name: callLog.name.toString(),
                                phoneNumber: callLog.number.toString(),
                                callType: callLog.callType.toString().substring(callLog.callType.toString().indexOf('.') + 1),
                                duration: callLog.duration.toString(),
                                timeStamp: '${DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!)}',
                                simSlot: callLog.simDisplayName??"NIL",
                                callRecordFilePath: "",
                                isUploaded: false,
                                isDeleted:false,
                              );
                              // await HiveUtil.addCallLog(hiveCallLog); // add to hive
                              callLogData.add(hiveCallLog);
                              // todo : add to DB also this case
                        }


                        log('callLogData : ${callLogData}');
                        log('callLogData : ${callLogData.length}');
                        // got all call logs
                        // get hive call logs
                        // get missing call logs from callLogData list
                          final List<HiveCaallHistoryModel> hiveData = await HiveUtil.getAllCallLogs();
                          log('hiveData 1: ${hiveData}');
                          log('hiveData 0: ${hiveData.length}');



                               Map<String, bool> existingItems = {};
  
                                for (var item in hiveData) {
                                  // Create a unique key using phone number and timestamp
                                  String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
                                  existingItems[uniqueKey] = true;
                                }

                                log('existingItems: $existingItems');
                                log('existingItems length: ${existingItems.length}');


                                List<HiveCaallHistoryModel> nonDuplicates = [];

                                  for (var item in callLogData) {
                                     String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
                                     if (!existingItems.containsKey(uniqueKey)) {

                                        log('Unique item found: ${item.phoneNumber} - ${item.timeStamp}');
                                        nonDuplicates.add(item);
                                      }else{
                                        log('Duplicate item found: ${item.phoneNumber} - ${item.timeStamp}');
                                      
                                      }
                                  }

                                   log('nonDuplicates: $nonDuplicates');
                                   log('nonDuplicates length: ${nonDuplicates.length}');

                                   callLogData = callLogData.where((log) => log.isDeleted != true).toList();
                                  callLogData = callLogData.reversed.toList();

                                   log('callLogData        : $callLogData');
                                   log('callLogData length : ${callLogData.length}');

                                    List<HiveCaallHistoryModel> notUploadedCallLogs = callLogData.where((log) => log.isUploaded != true).toList();

                                    if (notUploadedCallLogs.isNotEmpty) {
                                          uploadMissingLogsToServer(notUploadedCallLogs);    
                                          //  todo : update in HIve
                                          HiveUtil.addCallLogs(notUploadedCallLogs);
                                      }

                                    setState(() {
                                            refresh = false;
                                          });
                                    getSharedData();

                                  return;

                      } else {
                        log('No NEW Call Logs found in device.');
                      }
                }


        }

    } catch (e) {
      log(e.toString());
    }
    setState(() {});
   
  }

  Future<void> uploadMissingLogsToServer(List<HiveCaallHistoryModel> callLogData) async {

     List<Map<String, dynamic>> missingLogs = callLogData.map((log) => {
          "name": log.name,
          "phone_number": log.phoneNumber,
          "callTypes": log.callType 
                  .toString()
                  .substring(log.callType.toString().indexOf('.') + 1),
          // "time": DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp)).toString(), // log.timestamp,
          "time": log.timeStamp.toString(), // log.timestamp,
          "duration": log.duration,
          "simName": log.simSlot ?? "NIL",
          "timeStamp": log.timeStamp,
        }).toList();

        log("⚠️ Found ${missingLogs.length} missing logs.");

         if (missingLogs.isNotEmpty) {

       log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
                log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

       Map<String, dynamic> body = {
                  "token": await Common.getSharedPref("token"),
                  'log': missingLogs,
                };
                log('~~ OUTGOING CALL BODY : ${body} ~~~');



      CallLogUploadModel object1 =
                    await HttpService.callLogUpload(body);
                log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');
      // await HiveUtil.saveCallLog(missingLogs.last);
      if (object1.data == true) {
                  log('~~ OUTGOING CALL success ~~~');
                  log('success');
                } else {
                  log('~~ OUTGOING CALL failure ~~~');
                  log('failure');
                }
    }
 }



  getData() async {
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

  // void getSimDetails() async {
  //   try {
  //     simList.clear();
  //     // SimData simData = await SimDataPlugin.getSimData();
  //     final List<SimCard>? simData = await MobileNumber.getSimCards;
  //     for (var s in simData!.reversed) {
  //       log('id: ${s.slotIndex! + 1}');
  //       simList.add({"id": s.slotIndex! + 1, "name": s.displayName});
  //     }
  //     if (simList.length > 1) {
  //       simList.add({"id": "", "name": "Both"});
  //     } else if (simList.length == 1) {
  //       selectedSimId = simList[0]["id"].toString();
  //       selectedSim = simList[0]["name"].toString();
  //     }
  //   } on PlatformException catch (e) {
  //     log("error! code: ${e.code} - message: ${e.message}");
  //   }
  // }

  getPermission() async {
    Map<String, dynamic> body2 = {
      "token": await Common.getSharedPref("token"),
    };
    callUploadPermission = await HttpService.callLogUploadPermission(body2);
    if (callUploadPermission != null) {
      setState(() {});
    }
  }

  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getSharedData();
        getPermission();
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
                        'Call Logs',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      uploadPermission == "true" && onLongPress
                          ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    history.length.toString(),
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 17),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () async {
                                    bulkUpload();
                                  },
                                  child: const Icon(
                                    Icons.upload,
                                    size: 30,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      deleteHistoryIds.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                deleteDialog(context);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                          : const SizedBox(),
                      callUploadPermission != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  displayOverApps = await Permission
                                      .systemAlertWindow.isGranted;
                                  if (mounted) {
                                    mainPopupButton(context)
                                        .then((value) async {
                                      if (value != null) {
                                        if (value == '1') {
                                          Map<String, dynamic> body = {
                                            "token": await Common.getSharedPref(
                                                "token"),
                                            "type": "incoming"
                                          };
                                          CallLogUploadPermissionUpdateModel
                                              perm = await HttpService
                                                  .callLogUploadPermissionUpdate(
                                                      body);
                                          Common.toastMessaage(
                                              perm.message, Colors.green);
                                          getPermission();
                                          setState(() {});
                                        } else if (value == '2') {
                                          Map<String, dynamic> body = {
                                            "token": await Common.getSharedPref(
                                                "token"),
                                            "type": "outgoing"
                                          };
                                          CallLogUploadPermissionUpdateModel
                                              perm = await HttpService
                                                  .callLogUploadPermissionUpdate(
                                                      body);
                                          Common.toastMessaage(
                                              perm.message, Colors.green);
                                          getPermission();
                                          setState(() {});
                                        } else if (value == '3') {
                                          if (await Permission
                                              .systemAlertWindow.isGranted) {
                                            // Permission is already granted, show the overlay
                                            openAppSettings();
                                          } else {
                                            // Permission has not been granted, request it
                                            Config.requestPermission();
                                          }
                                        } else if (value == '4') {
                                          selectSim(context);
                                        }else if (value == '6'){
                                           askUserNeeds(context,true);
                                        }
                                      }
                                    });
                                  }
                                },
                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: permissionAccess == 'true' || Platform.isIOS
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
                              if (Platform.isAndroid) {
                                setState(() {
                                  selectedIndex = 0;
                                  deleteHistoryIds.clear();
                                  onLongPress = false;
                                });
                              } else {
                                Common.toastMessaage(
                                    "i phone can't access call logs",
                                    Colors.red);
                              }
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
                                        color: Platform.isIOS
                                            ? Colors.grey.shade300
                                            : selectedIndex == 0
                                                ? const Color(0xFF3c9f9a)
                                                : const Color(0xFF717171),
                                      ),
                                    ),
                                    Text(
                                      ' (${_callLogEntries.length})',
                                      style: TextStyle(
                                        color: Platform.isIOS
                                            ? Colors.grey.shade300
                                            : selectedIndex == 0
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
                              if (uploadPermission == "true") {
                                setState(() {
                                  selectedIndex = 1;
                                  history.clear();
                                  historyIndex.clear();
                                });
                                getData();
                              } else {
                                Common.toastMessaage(
                                    "Permission required to access call history",
                                    Colors.red);
                              }
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
                                    if (logHistory != null)
                                      Text(
                                        ' (${logHistory!.data!.length})',
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
                                          '${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(from))} - ${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(to))} (Last 3 Days)',
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

                                                       final entry = _callLogEntries.elementAt(indexStaff);
                                       
                                                       bool isUploaded = fullHiveData.any((item) => item.id == entry.timestamp.toString());

                                                  return Visibility(
                                                    // visible: selectedSimId ==
                                                    //         "" ||
                                                    //     selectedSimId ==
                                                    //         _callLogEntries
                                                    //             .elementAt(
                                                    //                 indexStaff)
                                                    //             .phoneAccountId,
                                                    child: Dismissible(
                                                      key: const Key('0'),
                                                      background: Container(
                                                        color: Colors.green,
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Icon(
                                                                Icons.call,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Text(
                                                                " Call",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      secondaryBackground:
                                                          Container(
                                                        color: Colors.blue,
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Text(
                                                                "Add Lead",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      confirmDismiss:
                                                          (direction) async {
                                                        if (direction ==
                                                            DismissDirection
                                                                .startToEnd) {
                                                          Common.dialPad(
                                                              _callLogEntries
                                                                  .elementAt(
                                                                      indexStaff)
                                                                  .number
                                                                  .toString());
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddLeads(
                                                                  widget.token,
                                                                  clientName: _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .name,
                                                                  phoneNumber: _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .number,
                                                                ),
                                                              ));
                                                        }

                                                        return null;
                                                      },
                                                      child: InkWell(
                                                          onLongPress: () {
                                                            log(_callLogEntries
                                                                .elementAt(
                                                                    indexStaff)
                                                                .phoneAccountId
                                                                .toString());
                                                            if (historyIndex
                                                                .contains(
                                                                    indexStaff)) {
                                                              historyIndex.remove(
                                                                  indexStaff);
                                                              history
                                                                  .removeWhere(
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
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                          "time":
                                                                              '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                          "duration": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .duration,
                                                                          "simName": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .simDisplayName??"NIL",
                                                                          "timeStamp": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .timestamp,
                                                                        })),
                                                              );
                                                            } else {
                                                              setState(() {
                                                                onLongPress =
                                                                    true;
                                                                history.add({
                                                                  "name": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .name ??
                                                                      "",
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
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .indexOf('.') +
                                                                          1),
                                                                  "time":
                                                                      '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                  "duration": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .duration,
                                                                  "simName": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .simDisplayName??"NIL",
                                                                  "timeStamp": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .timestamp,
                                                                });
                                                                historyIndex.add(
                                                                    indexStaff);
                                                              });
                                                            }
                                                          },
                                                          onTap: () {
                                                            if (onLongPress ==
                                                                true) {
                                                              if (historyIndex
                                                                  .contains(
                                                                      indexStaff)) {
                                                                historyIndex.remove(
                                                                    indexStaff);
                                                                history
                                                                    .removeWhere(
                                                                  (item) =>
                                                                      mapEquals(
                                                                          item,
                                                                          ({
                                                                            "name":
                                                                                _callLogEntries.elementAt(indexStaff).name,
                                                                            "phone_number":
                                                                                _callLogEntries.elementAt(indexStaff).number,
                                                                            "callTypes":
                                                                                _callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                            "time":
                                                                                '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                            "duration":
                                                                                _callLogEntries.elementAt(indexStaff).duration,
                                                                            "simName":
                                                                                _callLogEntries.elementAt(indexStaff).simDisplayName,
                                                                            "timeStamp":
                                                                                _callLogEntries.elementAt(indexStaff).timestamp,
                                                                          })),
                                                                );
                                                              } else {
                                                                history.add({
                                                                  "name": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .name ??
                                                                      "",
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
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .indexOf('.') +
                                                                          1),
                                                                  "time":
                                                                      '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                  "duration": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .duration,
                                                                  "simName": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .simDisplayName??"NIL",
                                                                  "timeStamp": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .timestamp,
                                                                });
                                                                historyIndex.add(
                                                                    indexStaff);
                                                              }
                                                            }
                                                            if (historyIndex
                                                                .isEmpty) {
                                                              onLongPress =
                                                                  false;
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
                                                                color: historyIndex.contains(
                                                                        indexStaff)
                                                                    ? Colors
                                                                        .blueGrey
                                                                        .shade200
                                                                    : Colors
                                                                        .white,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    offset:
                                                                        Offset(
                                                                            2.0,
                                                                            2.0),
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
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        right:
                                                                            10,
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
                                                                        // Text(
                                                                        //     'F. NUMBER  : ${_callLogEntries.elementAt(indexStaff).formattedNumber}'),
                                                                        // Text(
                                                                        //     'C.M. NUMBER: ${_callLogEntries.elementAt(indexStaff).cachedMatchedNumber}'),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              constraints: const BoxConstraints(
                                                                                maxHeight: 60,
                                                                              ),
                                                                              child: Container(
                                                                                constraints: const BoxConstraints(
                                                                                  minHeight: 20,
                                                                                  minWidth: 20,
                                                                                  maxHeight: 50,
                                                                                  maxWidth: 50,
                                                                                ),
                                                                                decoration: BoxDecoration(
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
                                                                              width: 20,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        _callLogEntries.elementAt(indexStaff).name ?? "Unknown",
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
                                                                                uploadPermission == "true" && onLongPress != true  && isUploaded ==false
                                                                                    ? InkWell(
                                                                                        onTap: () async {
                                                                                          Common.showProgressDialog(context, "Loading..");
                                                                                          history.add({
                                                                                            "name": _callLogEntries.elementAt(indexStaff).name ?? "",
                                                                                            "phone_number": _callLogEntries.elementAt(indexStaff).number,
                                                                                            "callTypes": _callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                                            "time": '${DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                                            "duration": _callLogEntries.elementAt(indexStaff).duration,
                                                                                            "simName": _callLogEntries.elementAt(indexStaff).simDisplayName??"NIL",
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
                                                                                              Navigator.pop(context);
                                                                                              getData();
                                                                                            }
                                                                                          } else {
                                                                                            Common.toastMessaage(object1.message, Colors.red);
                                                                                            if (context.mounted) {
                                                                                              Navigator.pop(context);
                                                                                            }
                                                                                          }
                                                                                          //!
                                                                                            bool isThisAlreadyInHiveCallLogDb = await HiveUtil.isCallLogWithIdAndNumberExists(
                                                                                                      _callLogEntries.elementAt(indexStaff).timestamp.toString(), 
                                                                                                      _callLogEntries.elementAt(indexStaff).number.toString()
                                                                                                    );
                                                                                                         log('isThisAlreadyInHiveCallLogDb : $isThisAlreadyInHiveCallLogDb');
                                                                                                     if(isThisAlreadyInHiveCallLogDb) {
                                                                                      log('already in hive');
                                                                                      // update
                                                                                     HiveUtil.markCallLogAsUploaded(_callLogEntries.elementAt(indexStaff).timestamp.toString());
                                                                                      log('updated in hive');
                                                                                      // todo : reload data
                                                                                     
                                                                                    } else {
                                                                                            log('not in hive');
                                                                                            // add
                                                                                            HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                                                                                                id: _callLogEntries.elementAt(indexStaff).timestamp.toString(),
                                                                                                name: _callLogEntries.elementAt(indexStaff).name.toString(),
                                                                                                phoneNumber: _callLogEntries.elementAt(indexStaff).number.toString(),
                                                                                                callType: _callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                                                duration: _callLogEntries.elementAt(indexStaff).duration.toString(),
                                                                                                // timeStamp: '${DateTime.fromMillisecondsSinceEpoch( int.parse(_callLogEntries.elementAt(indexStaff).timestamp))}',
                                                                                                // timeStamp: _callLogEntries.elementAt(indexStaff).timestamp.toString(),
                                                                                                timeStamp: DateTime.fromMillisecondsSinceEpoch(
                                                                                              _callLogEntries.elementAt(indexStaff).timestamp!  ).toIso8601String(),
                                                                                                simSlot: _callLogEntries.elementAt(indexStaff).simDisplayName??"NIL",
                                                                                                callRecordFilePath: "",
                                                                                                isUploaded: true,
                                                                                                isDeleted:false,
                                                                                              );
                                                                                              HiveUtil.addCallLog(hiveCallLog);
                                                                                          }
                                                                                          //!

                                                                                          setState(() {
                                                                                            history.clear();
                                                                                            historyIndex.clear();
                                                                                          });
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
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset("assets/icons/calendar.png", width: 20),
                                                                                const SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                Text(
                                                                                  DateFormat('dd-M-yyyy HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(_callLogEntries.elementAt(indexStaff).timestamp!)),
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
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              'Type  : ${_callLogEntries.elementAt(indexStaff).callType.toString().substring(_callLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1)}',
                                                                            ),
                                                                            const SizedBox()
                                                                            // Container(
                                                                            //   decoration: BoxDecoration(
                                                                            //       color: Colors.grey.shade300,
                                                                            //       borderRadius: BorderRadius.circular(5)),
                                                                            //   child:
                                                                            //       Padding(
                                                                            //     padding: const EdgeInsets.only(
                                                                            //         left: 10,
                                                                            //         right: 10,
                                                                            //         top: 5,
                                                                            //         bottom: 5),
                                                                            //     child:
                                                                            //         Text(
                                                                            //       '${_callLogEntries.elementAt(indexStaff).simDisplayName}',
                                                                            //     ),
                                                                            //   ),
                                                                            // ),
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
                                                          )),
                                                    ),
                                                  );
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  final selctedDatetimetemp =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime.now(),
                                                  );
                                                  fromdate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          selctedDatetimetemp!);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          fromdate,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
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
                                                  todate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          toDateSelectTemp!);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          todate,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
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
                                                      staffDialog(context);
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
                                                            borderSide:
                                                                BorderSide.none,
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
                                                  return Dismissible(
                                                    key: const Key('0'),
                                                    background: Container(
                                                      color: Colors.green,
                                                      child: const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Icon(
                                                              Icons.call,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            Text(
                                                              " Call",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    secondaryBackground:
                                                        Container(
                                                      color: Colors.blue,
                                                      child: const Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            Text(
                                                              "Add Lead",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    confirmDismiss:
                                                        (direction) async {
                                                      if (direction ==
                                                          DismissDirection
                                                              .startToEnd) {
                                                        Common.dialPad(
                                                            logHistory!
                                                                .data![index]
                                                                .phoneNumber
                                                                .toString());
                                                      } else {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      AddLeads(
                                                                widget.token,
                                                                clientName:
                                                                    logHistory!
                                                                        .data![
                                                                            index]
                                                                        .name,
                                                                phoneNumber:
                                                                    logHistory!
                                                                        .data![
                                                                            index]
                                                                        .phoneNumber,
                                                              ),
                                                            ));
                                                      }

                                                      return null;
                                                    },
                                                    child: InkWell(
                                                        onLongPress: () {
                                                          setState(() {
                                                            onLongPressHistory =
                                                                true;
                                                            deleteHistoryIds
                                                                .add(logHistory!
                                                                    .data![
                                                                        index]
                                                                    .id
                                                                    .toString());
                                                          });
                                                        },
                                                        onTap: () {
                                                          if (onLongPressHistory ==
                                                              true) {
                                                            if (deleteHistoryIds
                                                                .contains(logHistory!
                                                                    .data![
                                                                        index]
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
                                                              color: deleteHistoryIds.contains(
                                                                      logHistory!
                                                                          .data![
                                                                              index]
                                                                          .id
                                                                          .toString())
                                                                  ? Colors
                                                                      .blueGrey
                                                                      .shade200
                                                                  : Colors
                                                                      .white,
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey,
                                                                  offset:
                                                                      Offset(
                                                                          2.0,
                                                                          2.0),
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
                                                                          top:
                                                                              10,
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
                                                                              maxHeight: 60,
                                                                            ),
                                                                            child:
                                                                                Container(
                                                                              constraints: const BoxConstraints(
                                                                                minHeight: 20,
                                                                                minWidth: 20,
                                                                                maxHeight: 50,
                                                                                maxWidth: 50,
                                                                              ),
                                                                              decoration: BoxDecoration(
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
                                                                                logHistory!.data![index].name.toString() == "" || logHistory!.data![index].name.toString() == "null" ? "Unknown" : logHistory!.data![index].name.toString(),
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
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Image.asset("assets/icons/calendar.png", width: 20),
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
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            'Type  : ${logHistory!.data![index].callType}',
                                                                          ),
                                                                          const SizedBox()
                                                                          // Container(
                                                                          //   decoration: BoxDecoration(
                                                                          //       color: Colors.grey.shade300,
                                                                          //       borderRadius: BorderRadius.circular(5)),
                                                                          //   child:
                                                                          //       Padding(
                                                                          //     padding: const EdgeInsets.only(
                                                                          //         left: 10,
                                                                          //         right: 10,
                                                                          //         top: 5,
                                                                          //         bottom: 5),
                                                                          //     child:
                                                                          //         Text(
                                                                          //       "${logHistory!.data![index].simName}",
                                                                          //     ),
                                                                          //   ),
                                                                          // ),
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
                                                        )),
                                                  );
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
                              "We want to inform you that our app collects and uploads your call logs, including call duration and timestamps, to our secure servers. This data is shared with your company's super admin to enable them to track call activities.Your privacy is important to us, and we want to assure you that all data is handled with the utmost care and in accordance with our privacy policy. The information uploaded is encrypted to ensure its security during transmission and storage.",
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            dialPad(context);
          },
          child: const Icon(
            Icons.call,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<Object?> dialPad(BuildContext context) {
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
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.82,
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              phoneNumber.isEmpty
                                  ? "Enter Number"
                                  : phoneNumber,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: dialPadNumbers.length,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(
                                    () => dialNumber(dialPadNumbers[index]));
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  elevation: 2,
                                  shape: const CircleBorder(),
                                  backgroundColor: Colors.white),
                              child: Text(
                                dialPadNumbers[index],
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Delete Button
                          InkWell(
                            child: const Icon(Icons.backspace,
                                size: 30, color: Colors.grey),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (phoneNumber.isNotEmpty) {
                                setState(() => deleteLastDigit());
                              }
                            },
                            onLongPress: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                phoneNumber = "";
                              });
                            },
                          ),

                          /// Call Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                elevation: 5,
                                shape: const CircleBorder(),
                                backgroundColor: Colors.green),
                            onPressed: phoneNumber.isEmpty
                                ? null
                                : () async {
                                    Common.dialPad(phoneNumber);
                                  },
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
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

  Future<String?> mainPopupButton(BuildContext context) {
    return showMenu(
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 0.0, 1000.0, 0.0),
      items: [
          PopupMenuItem<String>(
          value: '6',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_suggest_outlined),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Settings'),
                ],
              ),
              displayOverApps == true
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const SizedBox()
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: '3',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.display_settings),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Display Over App'),
                ],
              ),
              displayOverApps == true
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const SizedBox()
            ],
          ),
        ),
        // if (simList.length > 1)
        // PopupMenuItem<String>(
        //   value: '4',
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Row(
        //         children: [
        //           const Icon(Icons.sim_card),
        //           const SizedBox(
        //             width: 5,
        //           ),
        //           Row(
        //             children: [
        //               const Text('Sim: '),
        //               Text(
        //                 selectedSim,
        //                 style: const TextStyle(color: Colors.green),
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Future<String?> selectSim(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              title: const Center(child: Text("Select Sim")),
              content: SizedBox(
                height: simList.length * 50,
                width: MediaQuery.of(context).size.width * .2,
                child: ListView.builder(
                  itemCount: simList.length,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                        // onTap: () {
                        //   selectedSimId = simList[index]["id"].toString();
                        //   selectedSim = simList[index]["name"].toString();
                        //   Common.saveSharedPref(
                        //       "simName", simList[index]["name"]);
                        //   Common.saveSharedPref(
                        //       "simId", simList[index]["id"].toString());
                        //   Navigator.pop(context);
                        // },
                        title:
                            Text("${index + 1} : ${simList[index]["name"]}"));
                  },
                ),
              ));
        });
      },
    );
  }

  Future<dynamic> staffDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Staffs'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * .35,
              width: MediaQuery.of(context).size.width * .7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commonDetails!.data.staff.length,
                itemBuilder: (context, ind) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        assignStaff =
                            commonDetails!.data.staff[ind].staffName.toString();
                        assignStaffId =
                            commonDetails!.data.staff[ind].userId.toString();
                        Navigator.pop(context, true);
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        commonDetails!.data.staff[ind].staffName.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<dynamic> deleteDialog(BuildContext context) {
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
                    Map<String, dynamic> body = {
                      "token": widget.token,
                      'deletedIds': deleteHistoryIds,
                    };
                    DeleteCallHistoryModel delete =
                        await HttpService.deleteCallHistoryLogs(body);
                    if (delete.data == true) {
                      deleteHistoryIds.clear();
                      Common.toastMessaage(delete.message, Colors.green);
                      getData();
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

  bulkUpload() async {
    Map<String, dynamic> body = {
      "token": widget.token,
      'log': history,
    };
    if (context.mounted) {
      Common.showProgressDialog(context, "Uploading..");
    }
    CallLogUploadModel object1 = await HttpService.callLogUpload(body);
    if (object1.data == true) {
      Common.toastMessaage(object1.message, Colors.green);
      if (context.mounted) {
        Navigator.pop(context);
        getData();
      }
    } else {
      Common.toastMessaage(object1.message, Colors.red);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
    setState(() {
      history.clear();
      historyIndex.clear();
    });
  }
}
