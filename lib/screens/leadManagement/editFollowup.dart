import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/callResultResonModel.dart';
import '../../models/lead_management/editLeadFollowupModel.dart';
import '../../models/lead_management/followupDetailsModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/inputTextFeildWidget.dart';

// ignore: must_be_immutable
class EditFollowup extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String callMasterId;
  String callFollowupId;

  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;

  EditFollowup(this.token, this.editLead, this.deleteLead, this.cloudCall,
      this.callMasterId, this.callFollowupId,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrollToIndex});

  @override
  State<EditFollowup> createState() => _EditFollowupState();
}

class _EditFollowupState extends State<EditFollowup> {
  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  CallResultResonModel? callResultReason;
  String callResult = 'New';
  String callResultId = '1';
  String callResponse = 'Call Response';
  String callResponseId = '';
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String callResultReasonName = 'Reason';
  String callResultReasonId = '';
  TextEditingController cost = TextEditingController();
  TextEditingController remarks = TextEditingController();
  bool? result = true;
  bool? result1 = true;
  FollowupDetailsModel? followupDetails;
  TextEditingController calledDate1 = TextEditingController();
  TextEditingController nextFollowupDate1 = TextEditingController();
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController callResultVal = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController callReasonVal = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  getData() async {
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

    commonDetails = await HttpService.addLeadCommonData(widget.token);
    followupDetails =
        await HttpService.followupDetails(widget.token, widget.callFollowupId);
    if (followupDetails != null) {
      if (followupDetails!.data!.leadCategoryId.toString() != '') {
        leadSubTypeList = await HttpService.leadSubType(
            followupDetails!.data!.leadCategoryId.toString());
        setState(() {});
      }

      setState(() {
        callResult = followupDetails!.data!.callResult.toString();
        callResultId = followupDetails!.data!.callResultId.toString();
        calledDate1.text = DateFormat('dd-MM-yyyy HH:mm').format(
            DateTime.parse(followupDetails!.data!.calledDate.toString()));
        nextFollowupDate1.text = DateFormat('dd-MM-yyyy HH:mm').format(
            DateTime.parse(followupDetails!.data!.followupDate.toString()));
        leadType = followupDetails!.data!.leadCategory.toString();
        leadTypeId = followupDetails!.data!.leadCategoryId.toString();
        cost.text = followupDetails!.data!.cost.toString();
        remarks.text = followupDetails!.data!.remarks.toString();

        leadSubType = followupDetails!.data!.leadSubCategory.toString();
        leadSubTypeId = followupDetails!.data!.leadSubCategoryId.toString();
        leadTypeVal.text = followupDetails!.data!.leadCategory.toString();
        leadSubTypeVal.text = followupDetails!.data!.leadSubCategory.toString();
        callResultVal.text = followupDetails!.data!.callResult.toString();
        callResponse = followupDetails!.data!.callResponse.toString();
        callResponseId = followupDetails!.data!.callResponseId.toString();
        callResponseVal.text = followupDetails!.data!.callResponse.toString();

        callResultReasonName = followupDetails!.data!.reason.toString();
        callResultReasonId = followupDetails!.data!.reasonId.toString();
        callReasonVal.text = followupDetails!.data!.reason.toString();
        callResultReasonList();
      });
    }
  }

  editFollowup() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (callResultId == '') {
        Common.toastMessaage('Choose any Status', Colors.red);
      } else if (callResultId == '2' && nextFollowupDate1.text == '') {
        Common.toastMessaage('Choose next followup date', Colors.red);
      } else {
        if (context.mounted) {
          Common.showProgressDialog(context, "Loading..");
        }
        print(callResponseId);
        EditLeadFollowupModel object1 = await HttpService.editLeadsFollowup(
            widget.token,
            widget.callFollowupId,
            callResultId,
            nextFollowupDate1.text,
            cost.text,
            leadTypeId,
            leadSubTypeId,
            remarks.text,
            calledDate1.text,
            widget.callMasterId,
            callResponseId,
            callResultReasonId);
        if (object1.status == true) {
          Common.toastMessaage(object1.message, Colors.green);
          if (context.mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        } else {
          Common.toastMessaage(object1.message, Colors.red);
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Network Found..Try Again Later..'),
            backgroundColor: Colors.redAccent,
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
          ),
        );
      });
    }
  }

  callResultReasonList() async {
    callResultReason =
        await HttpService.callResultReasonLiat(widget.token, callResultId);
    if (commonDetails != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
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
                              Navigator.of(context).pop();
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
                            'Edit Followup',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: commonDetails != null && callResultReason != null
                ? SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: calledDate1,
                            readOnly: true,
                            onTap: () async {
                              await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100))
                                  .then((selectedDate) {
                                if (selectedDate != null) {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((selectedTime) {
                                    String newDate = selectedDate.toString();
                                    newDate = newDate.substring(
                                        0, newDate.indexOf(" "));
                                    String convertedNewDate =
                                        getYmdFromDmy(newDate);
                                    if (selectedTime != null) {
                                      calledDate1.text =
                                          "$convertedNewDate ${selectedTime.format(context)}";
                                    } else {}
                                  });
                                }
                              });
                            },
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Called Date',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: callResultVal,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text('Status'),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .25,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: commonDetails!
                                              .data.callResult.length,
                                          itemBuilder: (context, ind) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  callResultVal.text =
                                                      commonDetails!
                                                          .data
                                                          .callResult[ind]
                                                          .callResult
                                                          .toString();
                                                  callResult = commonDetails!
                                                      .data
                                                      .callResult[ind]
                                                      .callResult
                                                      .toString();

                                                  callResultId = commonDetails!
                                                      .data
                                                      .callResult[ind]
                                                      .callResultId
                                                      .toString();
                                                  callResultReasonList();
                                                  if (callResultId != '2') {
                                                    nextFollowupDate1.text = '';
                                                  }
                                                  Navigator.pop(context, true);
                                                });
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Text(
                                                  commonDetails!
                                                      .data
                                                      .callResult[ind]
                                                      .callResult
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
                            maxLines: 1,
                            readOnly: true,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Call Result',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(height: 15),
                          callResultId == '2'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: nextFollowupDate1,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? selectedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );

                                      if (selectedDate != null) {
                                        TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );

                                        if (selectedTime != null) {
                                          final now = DateTime.now();
                                          final selectedDateTime = DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            selectedTime.hour,
                                            selectedTime.minute,
                                          );

                                          if (selectedDateTime.isAfter(now)) {
                                            String convertedNewDate =
                                                getYmdFromDmy(selectedDate
                                                    .toString()
                                                    .split(' ')[0]);
                                            nextFollowupDate1.text =
                                                "$convertedNewDate ${selectedTime.format(context)}";
                                          } else {
                                            Common.toastMessaage(
                                              "You cannot choose a past time for the follow-up date",
                                              Colors.red,
                                            );
                                          }
                                        }
                                      }
                                    },
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Next Followup Date',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              : const SizedBox(),
                          callResultReason!.data!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: TextFormField(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text('Reason'),
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
                                                  itemCount: callResultReason!
                                                      .data!.length,
                                                  itemBuilder: (context, ind) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          callResultReasonName =
                                                              callResultReason!
                                                                  .data![ind]
                                                                  .reason
                                                                  .toString();
                                                          callResultReasonId =
                                                              callResultReason!
                                                                  .data![ind].id
                                                                  .toString();
                                                          callReasonVal.text =
                                                              callResultReason!
                                                                  .data![ind]
                                                                  .reason
                                                                  .toString();

                                                          Navigator.pop(
                                                              context, true);
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Text(
                                                          callResultReason!
                                                              .data![ind].reason
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
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
                                    maxLines: 1,
                                    readOnly: true,
                                    controller: callReasonVal,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Reason',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(Icons.reply_all_sharp,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              : TextFormField(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: const Text('Call Response'),
                                            content: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .8,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: commonDetails!.data
                                                    .callResponseStatus.length,
                                                itemBuilder: (context, ind) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        callResponseVal.text =
                                                            commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponse
                                                                .toString();
                                                        callResponse =
                                                            commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponse
                                                                .toString();

                                                        callResponseId =
                                                            commonDetails!
                                                                .data
                                                                .callResponseStatus[
                                                                    ind]
                                                                .callResponseId
                                                                .toString();
                                                        Navigator.pop(
                                                            context, true);
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 50,
                                                      child: Text(
                                                        commonDetails!
                                                            .data
                                                            .callResponseStatus[
                                                                ind]
                                                            .callResponse
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
                                  maxLines: 1,
                                  readOnly: true,
                                  controller: callResponseVal,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'Call Response',
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(
                                          Icons.arrow_drop_down_circle_outlined,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: cost,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Cost',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(Icons.currency_rupee,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          // InputTextField(
                          //   hintText: 'Cost',
                          //   hintTextColor: Colors.white,
                          //   backgroundColor: Colors.white,
                          //   controller: cost,
                          //   width: 1,
                          //   iconData: Icons.currency_rupee,
                          //   keyboardType: TextInputType.number,
                          //
                          // ),

                          const SizedBox(height: 15),
                          TextFormField(
                            controller: leadTypeVal,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text('Lead Category'),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: commonDetails!
                                              .data.leadCategory.length,
                                          itemBuilder: (context, ind) {
                                            return InkWell(
                                              onTap: () async {
                                                leadSubTypeList =
                                                    await HttpService
                                                        .leadSubType(
                                                            commonDetails!
                                                                .data
                                                                .leadCategory[
                                                                    ind]
                                                                .leadCategoryId
                                                                .toString());
                                                setState(() {
                                                  leadTypeVal.text =
                                                      commonDetails!
                                                          .data
                                                          .leadCategory[ind]
                                                          .leadCategory
                                                          .toString();
                                                  leadSubType =
                                                      'Lead Sub Category';
                                                  leadSubTypeId = '';
                                                  leadType = commonDetails!
                                                      .data
                                                      .leadCategory[ind]
                                                      .leadCategory
                                                      .toString();
                                                  leadTypeId = commonDetails!
                                                      .data
                                                      .leadCategory[ind]
                                                      .leadCategoryId
                                                      .toString();
                                                  leadSubType =
                                                      'Lead Sub Category';
                                                  leadSubTypeId = '';
                                                  leadSubTypeVal.text =
                                                      'Lead Sub Category';
                                                  Navigator.pop(context, true);
                                                });
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Text(
                                                  commonDetails!
                                                      .data
                                                      .leadCategory[ind]
                                                      .leadCategory
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
                            maxLines: 1,
                            readOnly: true,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Lead Category',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(height: 10),
                          leadSubTypeList != null &&
                                  leadSubTypeList!.data!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: leadSubTypeVal,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title:
                                                const Text('Lead Sub Category'),
                                            content: SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .height *
                                                      0.8, // Adjust as needed
                                                ),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: leadSubTypeList!
                                                      .data!.length,
                                                  itemBuilder:
                                                      (context, subIndex) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          leadSubType =
                                                              leadSubTypeList!
                                                                  .data![
                                                                      subIndex]
                                                                  .leadSubCategory
                                                                  .toString();
                                                          leadSubTypeId =
                                                              leadSubTypeList!
                                                                  .data![
                                                                      subIndex]
                                                                  .leadSubCategoryId
                                                                  .toString();
                                                          Navigator.pop(
                                                              context, true);
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Text(
                                                          leadSubTypeList!
                                                              .data![subIndex]
                                                              .leadSubCategory
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    maxLines: 1,
                                    readOnly: true,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        labelText: 'Lead Sub Category',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              : const SizedBox(),
                          InputTextField(
                            hintText: 'Remarks',
                            hintTextColor: Colors.white,
                            backgroundColor: Colors.white,
                            controller: remarks,
                            width: 1,
                            height: 80,
                            maxLine: 2,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          InkWell(
                            onTap: () async {
                              editFollowup();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('Submit',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
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
}
