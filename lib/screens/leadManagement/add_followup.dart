// ignore_for_file: file_names


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/addLeadFollowupModel.dart';
import '../../models/lead_management/callResultResonModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../screens/leadManagement/leadDetails.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AddFollowup extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String callMasterId;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  String? callingDate;
  String? callHistoryId;
  int? scrollToIndex;
  String? leadTypeId;
  String? leadType;
  String? leadSubTypeId;
  String? leadSubType;
  String? cost;
  String? address;
  String? searchKey;
  String? priority;
  String? priorityId;
  String? leadType1;

  AddFollowup(this.token, this.editLead, this.deleteLead, this.cloudCall,
      this.callMasterId,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.callingDate,
      this.callHistoryId,
      this.scrollToIndex,
      this.leadTypeId,
      this.leadType,
      this.leadSubTypeId,
      this.leadSubType,
      this.cost,
      this.address,
      this.searchKey,
      this.priority,
      this.priorityId,
      this.leadType1});

  @override
  State<AddFollowup> createState() => _AddFollowupState();
}

class _AddFollowupState extends State<AddFollowup> {
  AddLeadCommonDataModel? commonDetails;
  RenewalDetailslModel? detailsResponse;
  LeadSubTypeModel? leadSubTypeList;
  CallResultResonModel? callResultReason;
  List<Template> filteredTemplates = [];
  String templateId = "";
  String callResult = 'Followup';
  String callResultId = '2';
  String callResponse = 'Call Response';
  String callResponseId = '';
  String? nextFollowupDate = '';
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String callResultReasonName = 'Reason';
  String callResultReasonId = '';
  String invoiceNumber = '';
  String typeDuration = "";

  TextEditingController cost = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController calledDate1 = TextEditingController();
  TextEditingController nextFollowupDate1 = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController callResultVal = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  TextEditingController timeBefore = TextEditingController(text: "10");
  TextEditingController callReasonVal = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController(text: "1");
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController search = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  bool result = true;
  var invoiceDate = DateTime.now();
  List<Map<String, dynamic>> products = [];
  double subTotal = 0.00;
  double totalTaxAmount = 00;
  double allTotal = 0.00;
  bool isPaying = false;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic collectedStaff;
  List<Product> items = [];
  List<Product> filteredItems = [];
  String productId = "";
  String productName = "Choose Product";
  PostalCodeModel? billingPostal;
  PostalCodeModel? shippingPostal;
  bool header = true;
  bool headerContent = false;
  Color paidColor = Colors.black;
  var code = '91';
  bool? result1 = true;
  String? callHistoryId;
  String priority = 'Normal';
  String priorityId = '2';
  bool checked = false;
  bool createOrder = false;
  bool createRenewal = false;
  bool isExpand = false;
  bool isChecked = false;
  bool isMoreDetails = false;
  bool timeOut = false;

  void toggleTextFieldVisibility() {
    setState(() {
      checked = !checked;
    });
  }

  void toggleMoreDetails() {
    setState(() {
      isMoreDetails = !isMoreDetails;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void changeRadioValue(int? value) {
    priorityId = value.toString();
    setState(() {});
  }

  getData() async {
    try {
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
      detailsResponse = await HttpService.getRenewalDetails();
      if (detailsResponse != null) {
        invoiceNumber = detailsResponse!.data.invoiceNumber.toString();
        items = detailsResponse!.data.products;
        filteredTemplates = detailsResponse!.data.template;
        filteredItems.addAll(items);
      }
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      if (commonDetails != null) {
        callResultReasonList();
        if (widget.leadTypeId != '') {
          leadSubTypeList = await HttpService.leadSubType(widget.leadTypeId);
          if (leadSubTypeList == null) {
            setState(() {
              timeOut = true;
            });
          }
          if (widget.leadType != null) {
            leadType = widget.leadType.toString();
            leadTypeId = widget.leadTypeId.toString();
          }
          if (widget.leadSubType != null) {
            leadSubType = widget.leadSubType.toString();
            leadSubTypeId = widget.leadSubTypeId.toString();
          }
          if (widget.cost != null) {
            cost.text = widget.cost.toString();
          }
          if (widget.address != null) {
            address.text = widget.address.toString();
          }
          if (widget.priority != null) {
            priority = widget.priority.toString();
            priorityId = widget.priorityId.toString();
          }
          setState(() {});
        }
        setState(() {});
      } else {
        setState(() {
          timeOut = true;
        });
      }
    } catch (e) {
      setState(() {
        timeOut = true;
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

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  @override
  Widget build(BuildContext context) {
    callResultVal.text = callResult;
    callReasonVal.text = callResultReasonName;
    callResponseVal.text = callResponse;
    leadTypeVal.text = leadType;
    leadSubTypeVal.text = leadSubType;
    priorityVal.text = priority;
    if (widget.callHistoryId != null) {
      callHistoryId = widget.callHistoryId.toString();
    } else {
      callHistoryId = '';
    }
    if (widget.callingDate != null) {
      calledDate1.text = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(widget.callingDate.toString()));
    } else {
      calledDate1.text = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    }

    return result == true && timeOut == false
        ? Scaffold(
            backgroundColor: Colors.white,
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
                            'Add Followup',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: const Text('Called Date : ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ))),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                          String newDate =
                                              selectedDate.toString();
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
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
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
                                                .18,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: commonDetails!
                                              .data.callResultNew.length,
                                          itemBuilder: (context, ind) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  callResult = commonDetails!
                                                      .data
                                                      .callResultNew[ind]
                                                      .callResultNew
                                                      .toString();

                                                  callResultId = commonDetails!
                                                      .data
                                                      .callResultNew[ind]
                                                      .callResultIdNew
                                                      .toString();
                                                  callResultReasonList();
                                                  if (callResultId != '2') {
                                                    nextFollowupDate = '';
                                                    checked = false;
                                                  }
                                                  Navigator.pop(context, true);
                                                });
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Text(
                                                  commonDetails!
                                                      .data
                                                      .callResultNew[ind]
                                                      .callResultNew
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
                            controller: callResultVal,
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
                          const SizedBox(
                            height: 15,
                          ),
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
                                        labelText: 'Call Result',
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
                              : const SizedBox(),
                          if (callResultId == '2')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: checked == true
                                      ? MediaQuery.of(context).size.width * 0.55
                                      : MediaQuery.of(context).size.width * 0.8,
                                  child: TextFormField(
                                    controller: nextFollowupDate1,
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
                                            String newDate =
                                                selectedDate.toString();
                                            newDate = newDate.substring(
                                                0, newDate.indexOf(" "));
                                            String convertedNewDate =
                                                getYmdFromDmy(newDate);
                                            if (selectedTime != null) {
                                              nextFollowupDate1.text =
                                                  "$convertedNewDate ${selectedTime.format(context)}";
                                            } else {}
                                          });
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Next Followup Date',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons.calendar_month_sharp,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                Visibility(
                                  visible: checked,
                                  child: SizedBox(
                                    width: 90,
                                    child: Container(
                                      width: 80,
                                      foregroundDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: Colors.blueGrey,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.all(8.0),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              controller: timeBefore,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: false,
                                                signed: true,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 38.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.arrow_drop_up,
                                                      size: 18.0,
                                                    ),
                                                    onTap: () {
                                                      int currentValue =
                                                          int.parse(
                                                              timeBefore.text);
                                                      setState(() {
                                                        currentValue++;
                                                        timeBefore.text =
                                                            (currentValue)
                                                                .toString(); // incrementing value
                                                      });
                                                    },
                                                  ),
                                                ),
                                                InkWell(
                                                  child: const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18.0,
                                                  ),
                                                  onTap: () {
                                                    int currentValue =
                                                        int.parse(
                                                            timeBefore.text);
                                                    setState(() {
                                                      currentValue--;
                                                      timeBefore
                                                          .text = (currentValue >
                                                                  0
                                                              ? currentValue
                                                              : 0)
                                                          .toString(); // decrementing value
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (callResultId == '2')
                                  InkWell(
                                    onTap: toggleTextFieldVisibility,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: SizedBox(
                                        width: 10,
                                        child: Icon(Icons.notifications,
                                            color: checked == false
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          if (callResultId == '2')
                            const SizedBox(
                              height: 15,
                            ),
                          TextFormField(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text('Call Response'),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: commonDetails!
                                              .data.callResponseStatus.length,
                                          itemBuilder: (context, ind) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  callResponse = commonDetails!
                                                      .data
                                                      .callResponseStatus[ind]
                                                      .callResponse
                                                      .toString();

                                                  callResponseId =
                                                      commonDetails!
                                                          .data
                                                          .callResponseStatus[
                                                              ind]
                                                          .callResponseId
                                                          .toString();
                                                  Navigator.pop(context, true);
                                                });
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Text(
                                                  commonDetails!
                                                      .data
                                                      .callResponseStatus[ind]
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
                                prefixIcon:
                                    Icon(Icons.add_call, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: const Text(
                                    'Priority',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          commonDetails!.data.priority.length,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 30),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Radio(
                                                    activeColor: int.parse(
                                                                priorityId) ==
                                                            1
                                                        ? Colors.grey
                                                        : int.parse(priorityId) ==
                                                                2
                                                            ? Colors.green
                                                            : int.parse(priorityId) ==
                                                                    3
                                                                ? Colors.red
                                                                : Colors.purple,
                                                    value: int.parse(
                                                        commonDetails!
                                                            .data
                                                            .priority[i]
                                                            .priorityId
                                                            .toString()),
                                                    groupValue:
                                                        int.parse(priorityId),
                                                    onChanged: (int? value) {
                                                      changeRadioValue(value);
                                                    }),
                                              ),
                                              Text(commonDetails!
                                                  .data.priority[i].priority
                                                  .toString()),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: InkWell(
                              onTap: toggleMoreDetails,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(isMoreDetails == false
                                      ? 'More Details'
                                      : 'Less Details'),
                                  Icon(isMoreDetails == false
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up)
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isMoreDetails,
                            child: Column(
                              children: [
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
                                  controller: leadTypeVal,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: const Text('Lead Category'),
                                            content: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .8,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: commonDetails!
                                                    .data.leadCategory.length,
                                                itemBuilder: (context, ind) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      leadSubTypeList =
                                                          await HttpService.leadSubType(
                                                              commonDetails!
                                                                  .data
                                                                  .leadCategory[
                                                                      ind]
                                                                  .leadCategoryId
                                                                  .toString());
                                                      setState(() {
                                                        leadSubType =
                                                            'Lead Sub Category';
                                                        leadSubTypeId = '';
                                                        leadType =
                                                            commonDetails!
                                                                .data
                                                                .leadCategory[
                                                                    ind]
                                                                .leadCategory
                                                                .toString();
                                                        leadTypeId =
                                                            commonDetails!
                                                                .data
                                                                .leadCategory[
                                                                    ind]
                                                                .leadCategoryId
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
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'Lead Category',
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(Icons.category,
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
                                  height: 20,
                                ),
                                leadSubTypeList != null &&
                                        leadSubTypeList!.data!.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: TextFormField(
                                          controller: leadSubTypeVal,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    scrollable: true,
                                                    title: const Text(
                                                        'Lead Sub Category'),
                                                    content: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .8,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            leadSubTypeList!
                                                                .data!.length,
                                                        itemBuilder: (context,
                                                            subIndex) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                leadSubType = leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategory
                                                                    .toString();
                                                                leadSubTypeId = leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategoryId
                                                                    .toString();
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              });
                                                            },
                                                            child: SizedBox(
                                                              height: 50,
                                                              child: Text(
                                                                leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategory
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
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
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              labelText: 'Lead Sub Category',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(Icons.subtitles,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      )
                                    : const SizedBox(),
                                TextFormField(
                                  controller: address,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                      labelText: 'Address',
                                      fillColor: Colors.white,
                                      filled: true,
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
                                SizedBox(
                                  height: 30,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        commonDetails!.data.callResponse.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 10),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              remarks.text = commonDetails!
                                                  .data.callResponse[i]
                                                  .toString();
                                            });
                                          },
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0),
                                                color: Colors.white,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(6))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Text(
                                                    commonDetails!
                                                        .data.callResponse[i]
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Color(0xFF717171),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: remarks,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                      labelText: 'Remarks',
                                      fillColor: Colors.white,
                                      filled: true,
                                      //prefixIcon: Icon(myIcon, color: prefixIconColor),
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
                              ],
                            ),
                          ),
                          if (callResultId == '4' &&
                              commonDetails!
                                      .data.customerAddInvoicePermission ==
                                  true)
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Order'),
                                value:
                                    createOrder, // initial value of the checkbox
                                onChanged: (bool? value) {
                                  setState(() {
                                    createOrder = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          Visibility(
                            visible: createOrder &&
                                callResultId == '4' &&
                                commonDetails!
                                        .data.customerAddInvoicePermission ==
                                    true,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Invoice Number :',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Text(invoiceNumber,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Invoice Date : ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: Center(
                                          child: DateTimePicker(
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            initialValue:
                                                invoiceDate.toString(),
                                            type: DateTimePickerType.date,
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
                                                  invoiceDate =
                                                      DateTime.parse(value);
                                                });
                                              }
                                            },
                                            // We can also use onSaved
                                            onSaved: (value) {
                                              if (value!.isNotEmpty) {
                                                invoiceDate = value as DateTime;
                                              }
                                            },
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
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        showGeneralDialog(
                                          barrierLabel: "showGeneralDialog",
                                          barrierDismissible: true,
                                          barrierColor:
                                              Colors.black.withOpacity(0.6),
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                          context: context,
                                          pageBuilder: (context, _, __) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              return Align(
                                                alignment: Alignment.center,
                                                child: SingleChildScrollView(
                                                  child: AlertDialog(
                                                    content: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                          'Product Details',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                  return AlertDialog(
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                search,
                                                                            autocorrect:
                                                                                false,
                                                                            keyboardType:
                                                                                TextInputType.visiblePassword,
                                                                            autofocus:
                                                                                true,
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                filteredItems = items.where((item) => item.productName.toLowerCase().contains(value.toLowerCase())).toList();
                                                                              });
                                                                            },
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              contentPadding: EdgeInsets.all(8),
                                                                              hintText: 'Search',
                                                                              prefixIcon: Icon(Icons.search),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              MediaQuery.of(context).size.height * .3,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * .8,
                                                                          child:
                                                                              ListView.builder(
                                                                            itemCount:
                                                                                filteredItems.length,
                                                                            physics:
                                                                                const ScrollPhysics(),
                                                                            shrinkWrap:
                                                                                true,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              return ListTile(
                                                                                  onTap: () {
                                                                                    if (productQty.text == "") {
                                                                                      productQty.text = "1";
                                                                                    }
                                                                                    productName = filteredItems[index].productName;
                                                                                    productId = filteredItems[index].id;
                                                                                    productRate.text = filteredItems[index].sellingPrice;
                                                                                    productTaxPercent.text = filteredItems[index].taxPercent;
                                                                                    productTaxAmount.text = filteredItems[index].taxAmount;
                                                                                    productTotalAmount.text = ((double.parse(productRate.text) + double.parse(productTaxAmount.text)) * double.parse(productQty.text)).toString();
                                                                                    productTotalAmount.text = double.parse(productTotalAmount.text).toStringAsFixed(2);
                                                                                    if (paymentStatus == "paid") {
                                                                                      paidAmount.text = productTotalAmount.text;
                                                                                    }
                                                                                    typeDuration = filteredItems[index].noOfDays;
                                                                                    setState(() {});
                                                                                    if (context.mounted) {
                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                  },
                                                                                  title: Text(filteredItems[index].productName));
                                                                            },
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (context.mounted) {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          child:
                                                                              const Text("Close")),
                                                                    ],
                                                                  );
                                                                });
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Center(
                                                                child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16.0,
                                                                      vertical:
                                                                          12.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.5,
                                                                      child:
                                                                          Text(
                                                                        productName,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      )),
                                                                ],
                                                              ),
                                                            )),
                                                          ),
                                                        ),

                                                        // Padding(
                                                        //   padding: const EdgeInsets.all(8.0),
                                                        //   child: SizedBox(
                                                        //     child: TextFormField(
                                                        //       controller: productName,
                                                        //       keyboardType: TextInputType.text,
                                                        //       decoration: const InputDecoration(
                                                        //           hintText: 'Product Name',
                                                        //           contentPadding:
                                                        //           EdgeInsets.symmetric(
                                                        //               vertical: 10,
                                                        //               horizontal: 10),
                                                        //           border: OutlineInputBorder()),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 110,
                                                              child:
                                                                  TextFormField(
                                                                onChanged:
                                                                    (value) {
                                                                  if (value ==
                                                                      '') {
                                                                    value = '0';
                                                                  }
                                                                  productTaxAmount
                                                                      .text = (double.parse(
                                                                              value) *
                                                                          double.parse(
                                                                              productTaxPercent.text) /
                                                                          100)
                                                                      .toString();
                                                                  productTotalAmount
                                                                      .text = ((double.parse(value) +
                                                                              double.parse(productTaxAmount.text)) *
                                                                          double.parse(productQty.text))
                                                                      .toString();

                                                                  productTotalAmount
                                                                      .text = double.parse(
                                                                          productTotalAmount
                                                                              .text)
                                                                      .toStringAsFixed(
                                                                          2);

                                                                  setState(
                                                                      () {});
                                                                },
                                                                controller:
                                                                    productRate,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                2,
                                                                            bottom:
                                                                                2),
                                                                        labelText:
                                                                            'Rate',
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        prefixIcon: Icon(
                                                                            Icons
                                                                                .arrow_right,
                                                                            color: Colors
                                                                                .grey),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(color: Colors.grey)),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              width: 110,
                                                              child:
                                                                  TextFormField(
                                                                onChanged:
                                                                    (value) {
                                                                  if (value ==
                                                                      '') {
                                                                    value = '0';
                                                                  }
                                                                  productTotalAmount
                                                                      .text = ((double.parse(productRate.text) +
                                                                              double.parse(productTaxAmount.text)) *
                                                                          double.parse(value))
                                                                      .toString();
                                                                  productTotalAmount
                                                                      .text = double.parse(
                                                                          productTotalAmount
                                                                              .text)
                                                                      .toStringAsFixed(
                                                                          2);
                                                                  setState(
                                                                      () {});
                                                                },
                                                                controller:
                                                                    productQty,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                2,
                                                                            bottom:
                                                                                2),
                                                                        labelText:
                                                                            'Qty',
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        prefixIcon: Icon(
                                                                            Icons
                                                                                .arrow_right,
                                                                            color: Colors
                                                                                .grey),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(color: Colors.grey)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),

                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 110,
                                                              child:
                                                                  TextFormField(
                                                                onChanged:
                                                                    (value) {
                                                                  if (value ==
                                                                      '') {
                                                                    value = '0';
                                                                  }
                                                                  productTaxAmount
                                                                      .text = (double.parse(productRate
                                                                              .text) *
                                                                          double.parse(
                                                                              value) /
                                                                          100)
                                                                      .toString();
                                                                  productTotalAmount
                                                                      .text = ((double.parse(productRate.text) +
                                                                              double.parse(productTaxAmount.text)) *
                                                                          double.parse(productQty.text))
                                                                      .toString();
                                                                  productTotalAmount
                                                                      .text = double.parse(
                                                                          productTotalAmount
                                                                              .text)
                                                                      .toStringAsFixed(
                                                                          2);
                                                                  setState(
                                                                      () {});
                                                                },
                                                                controller:
                                                                    productTaxPercent,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                2,
                                                                            bottom:
                                                                                2),
                                                                        labelText:
                                                                            'Tax Percent',
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        prefixIcon: Icon(
                                                                            Icons
                                                                                .arrow_right,
                                                                            color: Colors
                                                                                .grey),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(color: Colors.grey)),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              width: 110,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    productTaxAmount,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                readOnly: true,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                2,
                                                                            bottom:
                                                                                2),
                                                                        labelText:
                                                                            'Tax Amount',
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        prefixIcon: Icon(
                                                                            Icons
                                                                                .arrow_right,
                                                                            color: Colors
                                                                                .grey),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(color: Colors.grey)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        SizedBox(
                                                          child: TextFormField(
                                                            controller:
                                                                productTotalAmount,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            readOnly: true,
                                                            decoration:
                                                                const InputDecoration(
                                                                    contentPadding: EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                    labelText:
                                                                        'Total Amount',
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    filled:
                                                                        true,
                                                                    prefixIcon: Icon(
                                                                        Icons
                                                                            .arrow_right,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            color:
                                                                                Colors.grey)),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child:
                                                                      const Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            30,
                                                                        right:
                                                                            30),
                                                                    child: Text(
                                                                      'Cancel',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  )),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (productRate
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Product Rate',
                                                                      Colors
                                                                          .red);
                                                                } else if (productQty
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Product Qty',
                                                                      Colors
                                                                          .red);
                                                                } else if (productTaxPercent
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Product Tax Percent',
                                                                      Colors
                                                                          .red);
                                                                } else if (productTaxAmount
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Product Tax Amount',
                                                                      Colors
                                                                          .red);
                                                                } else if (productTotalAmount
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Product Total Amount',
                                                                      Colors
                                                                          .red);
                                                                } else {
                                                                  products.add({
                                                                    "product_name":
                                                                        productName,
                                                                    "product_id":
                                                                        productId,
                                                                    "description":
                                                                        productDescription
                                                                            .text,
                                                                    "product_rate":
                                                                        productRate
                                                                            .text,
                                                                    "quantity":
                                                                        productQty
                                                                            .text,
                                                                    "tax_percent":
                                                                        productTaxPercent
                                                                            .text,
                                                                    "total_tax_amount":
                                                                        productTaxAmount
                                                                            .text,
                                                                    "total_amount":
                                                                        productTotalAmount
                                                                            .text,
                                                                  });
                                                                  subTotal = subTotal +
                                                                      double.parse(
                                                                          productTotalAmount
                                                                              .text);
                                                                  totalTaxAmount = totalTaxAmount +
                                                                      double.parse(productTaxAmount
                                                                              .text) *
                                                                          double.parse(
                                                                              productQty.text);
                                                                  allTotal = subTotal +
                                                                      double.parse(shippingCharge.text ==
                                                                              ''
                                                                          ? '0'
                                                                          : shippingCharge
                                                                              .text) -
                                                                      double.parse(discount.text ==
                                                                              ''
                                                                          ? '0'
                                                                          : discount
                                                                              .text);
                                                                  productName =
                                                                      "Choose Product";
                                                                  productId =
                                                                      "";
                                                                  productDescription
                                                                      .clear();
                                                                  productRate
                                                                      .clear();
                                                                  productQty
                                                                      .clear();
                                                                  productTaxPercent
                                                                      .clear();
                                                                  productTaxAmount
                                                                      .clear();
                                                                  productTotalAmount
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child:
                                                                      const Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            25,
                                                                        right:
                                                                            25),
                                                                    child: Text(
                                                                      'Add',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                          transitionBuilder:
                                              (_, animation1, __, child) {
                                            return SlideTransition(
                                              position: Tween(
                                                begin: const Offset(0, 1),
                                                end: const Offset(0, 0),
                                              ).animate(animation1),
                                              child: child,
                                            );
                                          },
                                        ).then((_) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                                top: 5,
                                                bottom: 5,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              '+ Add Product',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2), // Using 10%
                                          1: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14), // Using 30%
                                          2: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14),
                                          3: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14), // Using 20%
                                          4: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20),
                                          5: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10),
                                        },
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              color: const Color(0xFFece9fd),
                                            ),
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Product',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Rate',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Qty',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text('Tax',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(' ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                products.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "No Products !",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: products.length,
                                          itemBuilder: (context, index) {
                                            Color color = index % 2 == 0
                                                ? const Color(0xFFF3F3F3)
                                                : const Color(0xFFece9fd);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Table(
                                                columnWidths: {
                                                  0: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.2), // Using 10%
                                                  1: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14), // Using 30%
                                                  2: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14),
                                                  3: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14), // Using 20%
                                                  4: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.20),
                                                  5: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10),
                                                },
                                                children: [
                                                  // Each TableRow represents a row in the Table
                                                  TableRow(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1),
                                                      color: color,
                                                    ),
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_name'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_rate'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['quantity'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index][
                                                              'total_tax_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['total_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          subTotal = subTotal -
                                                              double.parse(
                                                                products[index][
                                                                    'total_amount'],
                                                              );
                                                          totalTaxAmount = totalTaxAmount -
                                                              double.parse(products[
                                                                          index]
                                                                      [
                                                                      'total_tax_amount']) *
                                                                  double.parse(products[
                                                                          index]
                                                                      [
                                                                      'quantity']);

                                                          allTotal = subTotal +
                                                              double.parse(shippingCharge
                                                                          .text ==
                                                                      ''
                                                                  ? '0'
                                                                  : shippingCharge
                                                                      .text) -
                                                              double.parse(
                                                                  discount.text ==
                                                                          ''
                                                                      ? '0'
                                                                      : discount
                                                                          .text);
                                                          products.removeWhere(
                                                            (item) => mapEquals(
                                                                item,
                                                                ({
                                                                  "product_name":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_name'],
                                                                  "product_id":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_id'],
                                                                  "description":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'description'],
                                                                  "product_rate":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_rate'],
                                                                  "quantity": products[
                                                                          index]
                                                                      [
                                                                      'quantity'],
                                                                  "tax_percent":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'tax_percent'],
                                                                  "total_tax_amount":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'total_tax_amount'],
                                                                  "total_amount":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'total_amount'],
                                                                })),
                                                          );
                                                          if (products
                                                              .isEmpty) {
                                                            discount.clear();
                                                            shippingCharge
                                                                .clear();
                                                            allTotal = 0.00;
                                                          }

                                                          setState(() {});
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                          ),
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Sub Total :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Text(subTotal
                                                    .toStringAsFixed(2)),
                                              ))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Tax Amount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Text(totalTaxAmount
                                                    .toStringAsFixed(2)),
                                              ))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Discount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }
                                                  allTotal = subTotal +
                                                      double.parse(
                                                          shippingCharge.text ==
                                                                  ''
                                                              ? '0'
                                                              : shippingCharge
                                                                  .text) -
                                                      double.parse(value);
                                                  setState(() {});
                                                } else {
                                                  discount.clear();
                                                  Common.toastMessaage(
                                                      'choose at least one product',
                                                      Colors.red);
                                                }
                                              },
                                              controller: discount,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  // border: const OutlineInputBorder(),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Shipping Charge:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }

                                                  allTotal = subTotal +
                                                      double.parse(value) -
                                                      double.parse(
                                                          discount.text == ''
                                                              ? '0'
                                                              : discount.text);
                                                  setState(() {});
                                                } else {
                                                  shippingCharge.clear();
                                                  Common.toastMessaage(
                                                      'choose at least one product',
                                                      Colors.red);
                                                }
                                              },
                                              controller: shippingCharge,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total :',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              allTotal.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Divider(),

                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Pay Status * :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 35,
                                            child: FormField<String>(
                                              builder: (FormFieldState<String>
                                                  state) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5))),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      isExpanded: true,
                                                      hint: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                        child: Text('Status'),
                                                      ),
                                                      value: paymentStatus,
                                                      items: detailsResponse!
                                                          .data.paymentStatus
                                                          .map((data) {
                                                        return DropdownMenuItem(
                                                          value: data
                                                              .paymentStatus
                                                              .toString(),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              child: Text(
                                                                data.displaySts
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          paymentStatus =
                                                              newValue;
                                                          if (paymentStatus ==
                                                              "paid") {
                                                            paidAmount.text =
                                                                allTotal
                                                                    .toString();
                                                          }
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
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (paymentStatus != "unpaid")
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text('Paid Amount * :'),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              height: 35,
                                              child: TextFormField(
                                                readOnly:
                                                    paymentStatus == "paid",
                                                style:
                                                    TextStyle(color: paidColor),
                                                onChanged: (val) {
                                                  if (double.parse(val) >
                                                      allTotal) {
                                                    Common.toastMessaage(
                                                        'Enter valid amount',
                                                        Colors.red);
                                                    paidColor = Colors.red;
                                                  } else {
                                                    paidColor = Colors.black;
                                                  }
                                                  setState(() {});
                                                },
                                                controller: paidAmount,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 2,
                                                            bottom: 2),
                                                    //labelText: 'Invoice Number',
                                                    fillColor: Colors.grey[300],
                                                    filled: true,
                                                    border:
                                                        const OutlineInputBorder(
                                                      // width: 0.0 produces a thin "hairline" border
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: paymentStatus == "paid" ||
                                          paymentStatus == "partial",
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Pay Method * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: FormField<String>(
                                                    builder:
                                                        (FormFieldState<String>
                                                            state) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            isExpanded: true,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child: Text(
                                                                  'Method'),
                                                            ),
                                                            value:
                                                                paymentMethod,
                                                            items: detailsResponse!
                                                                .data
                                                                .paymentMethods
                                                                .map((data) {
                                                              return DropdownMenuItem(
                                                                value: data.id
                                                                    .toString(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      data.name
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged:
                                                                (newValue) {
                                                              setState(() {
                                                                paymentMethod =
                                                                    newValue;
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
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Collected By * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: FormField<String>(
                                                    builder:
                                                        (FormFieldState<String>
                                                            state) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            isExpanded: true,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child:
                                                                  Text('Staff'),
                                                            ),
                                                            value:
                                                                collectedStaff,
                                                            items:
                                                                detailsResponse!
                                                                    .data.staff
                                                                    .map(
                                                                        (data) {
                                                              return DropdownMenuItem(
                                                                value: data
                                                                    .userId
                                                                    .toString(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      data.staffName
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged:
                                                                (newValue) {
                                                              setState(() {
                                                                collectedStaff =
                                                                    newValue;
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    // paymentMethod == '2'
                                    //     ? Container(
                                    //         child: templateImage == null
                                    //             ? Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.only(
                                    //                         right: 10),
                                    //                 child: Align(
                                    //                   alignment:
                                    //                       Alignment.topRight,
                                    //                   child: InkWell(
                                    //                     onTap: _selectFile,
                                    //                     child: Container(
                                    //                         width: MediaQuery.of(
                                    //                                     context)
                                    //                                 .size
                                    //                                 .width *
                                    //                             0.4,
                                    //                         height: 35,
                                    //                         decoration: BoxDecoration(
                                    //                             color: Colors
                                    //                                 .grey
                                    //                                 .shade300,
                                    //                             borderRadius:
                                    //                                 BorderRadius
                                    //                                     .circular(
                                    //                                         5)),
                                    //                         child:
                                    //                             const Padding(
                                    //                           padding: EdgeInsets
                                    //                               .only(
                                    //                                   left: 10,
                                    //                                   right: 10,
                                    //                                   top: 5,
                                    //                                   bottom:
                                    //                                       5),
                                    //                           child: Center(
                                    //                               child: Text(
                                    //                                   'Choose File')),
                                    //                         )),
                                    //                   ),
                                    //                 ),
                                    //               )
                                    //             : Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.only(
                                    //                         right: 10),
                                    //                 child: Stack(
                                    //                   children: [
                                    //                     Align(
                                    //                       alignment: Alignment
                                    //                           .topRight,
                                    //                       child: InkWell(
                                    //                         onTap: _selectFile,
                                    //                         child: Container(
                                    //                             width: MediaQuery.of(
                                    //                                         context)
                                    //                                     .size
                                    //                                     .width *
                                    //                                 0.6,
                                    //                             height: 80,
                                    //                             decoration: BoxDecoration(
                                    //                                 color: Colors
                                    //                                     .grey
                                    //                                     .shade300,
                                    //                                 borderRadius:
                                    //                                     BorderRadius.circular(
                                    //                                         5)),
                                    //                             child: Padding(
                                    //                               padding:
                                    //                                   const EdgeInsets
                                    //                                       .only(
                                    //                                 right: 10,
                                    //                               ),
                                    //                               child: Row(
                                    //                                 children: [
                                    //                                   Container(
                                    //                                     height:
                                    //                                         80,
                                    //                                     width:
                                    //                                         90,
                                    //                                     decoration:
                                    //                                         BoxDecoration(
                                    //                                       image:
                                    //                                           DecorationImage(
                                    //                                         fit:
                                    //                                             BoxFit.fitWidth,
                                    //                                         image:
                                    //                                             FileImage(
                                    //                                           File(templateImage!),
                                    //                                         ),
                                    //                                       ),
                                    //                                     ),
                                    //                                     // Add your image widget here
                                    //                                   ),
                                    //                                   const SizedBox(
                                    //                                     width:
                                    //                                         20,
                                    //                                   ),
                                    //                                   const Center(
                                    //                                       child:
                                    //                                           Text('Change File')),
                                    //                                 ],
                                    //                               ),
                                    //                             )),
                                    //                       ),
                                    //                     ),
                                    //                     Positioned(
                                    //                       right: 0.0,
                                    //                       top: 0.0,
                                    //                       child: InkWell(
                                    //                         onTap: () {
                                    //                           templateImage =
                                    //                               null;
                                    //                           setState(() {});
                                    //                         },
                                    //                         child: const Icon(
                                    //                           Icons
                                    //                               .remove_circle,
                                    //                           color: Colors.red,
                                    //                         ),
                                    //                       ),
                                    //                     )
                                    //                   ],
                                    //                 ),
                                    //               ))
                                    //     : const SizedBox(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          if (callResultId == '4' &&
                              createOrder &&
                              commonDetails!.data.isRenewal)
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Renewal'),
                                value:
                                    createRenewal, // initial value of the checkbox
                                onChanged: (bool? value) {
                                  setState(() {
                                    createRenewal = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          Visibility(
                              visible: createRenewal &&
                                  createOrder &&
                                  commonDetails!.data.isRenewal,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: startDate,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? selectedValue =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      setState(() {
                                        startDate.text =
                                            DateFormat('dd-MM-yyyy')
                                                .format(selectedValue!);
                                        final endValue = selectedValue.add(
                                            Duration(
                                                days: int.parse(typeDuration)));
                                        endDate.text =
                                            DateFormat('dd-MM-yyyy')
                                                .format(endValue);
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Select Start Date";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        labelText: 'Start Date *',
                                        prefixIcon: Icon(Icons.calendar_month,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                  const SizedBox(height: 14.0),
                                  TextFormField(
                                    onTap: () async {
                                      DateTime? selectedEndDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      endDate.text = DateFormat('dd-MM-yyyy')
                                          .format(selectedEndDate!);
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Select End Date";
                                      }
                                      return null;
                                    },
                                    readOnly: true,
                                    controller: endDate,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        labelText: 'End Date *',
                                        prefixIcon: Icon(Icons.calendar_month,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                  const SizedBox(height: 14.0),
                                  TextFormField(
                                    onTap: () {
                                      dropDialog(context);
                                    },
                                    readOnly: true,
                                    controller: reminderTemplate,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        labelText: 'Remind Template ',
                                        prefixIcon: Icon(Icons.notifications,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              final connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if (connectivityResult ==
                                      ConnectivityResult.mobile ||
                                  connectivityResult ==
                                      ConnectivityResult.wifi) {
                                if (callResultId == '') {
                                  Common.toastMessaage(
                                      'Choose any Status', Colors.red);
                                }
                                if (callResponseId == '') {
                                  Common.toastMessaage(
                                      'Choose call response', Colors.red);
                                } else if (callResultId == '2' &&
                                    nextFollowupDate1.text.isEmpty) {
                                  Common.toastMessaage(
                                      'Choose next followup date', Colors.red);
                                } else if (createOrder == true &&
                                    products.isEmpty &&
                                    commonDetails!
                                        .data.customerAddInvoicePermission) {
                                  Common.toastMessaage(
                                      'Please add a product to continue',
                                      Colors.red);
                                } else if (createOrder == true &&
                                    commonDetails!
                                        .data.customerAddInvoicePermission &&
                                    paymentStatus == null) {
                                  Common.toastMessaage(
                                      'Payment Status is required to add invoice',
                                      Colors.red);
                                } else if (createOrder == true &&
                                    paidAmount.text.isEmpty &&
                                    commonDetails!
                                        .data.customerAddInvoicePermission &&
                                    paymentStatus != "unpaid") {
                                  Common.toastMessaage(
                                      'Paid Amount is required to add invoice',
                                      Colors.red);
                                } else if (createOrder == true &&
                                    paymentStatus != "unpaid" &&
                                    commonDetails!
                                        .data.customerAddInvoicePermission &&
                                    paymentMethod == null) {
                                  Common.toastMessaage(
                                      'Payment Method is required to add invoice',
                                      Colors.red);
                                } else if (createOrder == true &&
                                    commonDetails!
                                        .data.customerAddInvoicePermission &&
                                    paymentStatus != "unpaid" &&
                                    collectedStaff == null) {
                                  Common.toastMessaage(
                                      'Collected Staff is required to add invoice',
                                      Colors.red);
                                } else if (createRenewal == true &&
                                    commonDetails!.data.isRenewal &&
                                    startDate.text == "") {
                                  Common.toastMessaage(
                                      'Start date is required to add renewal',
                                      Colors.red);
                                } else if (createRenewal == true &&
                                    commonDetails!.data.isRenewal &&
                                    endDate.text == "") {
                                  Common.toastMessaage(
                                      'End date is required to add renewal',
                                      Colors.red);
                                } else {
                                  if (context.mounted) {
                                    Common.showProgressDialog(
                                        context, "Loading..");
                                  }
                                  AddLeadFollowupModel object1 =
                                      await HttpService.addLeadsFollowup(
                                          widget.token,
                                          callResultId,
                                          nextFollowupDate1.text,
                                          cost.text,
                                          address.text,
                                          leadTypeId,
                                          leadSubTypeId,
                                          remarks.text,
                                          widget.callMasterId,
                                          calledDate1.text,
                                          callHistoryId,
                                          priorityId,
                                          checked,
                                          timeBefore.text,
                                          callResponseId,
                                          callResultReasonId,
                                          createOrder,
                                          createRenewal ? "renewal" : "invoice",
                                          detailsResponse!.data.checkId,
                                          invoiceDate,
                                          products,
                                          reminderTemplate.text,
                                          allTotal,
                                          startDate.text,
                                          endDate.text,
                                          paymentStatus,
                                          subTotal,
                                          totalTaxAmount,
                                          discount.text,
                                          shippingCharge.text,
                                          paymentMethod,
                                          paidAmount.text,
                                          collectedStaff);
                                  if (object1.status == true) {
                                    Common.toastMessaage(
                                        object1.message, Colors.green);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LeadDetails(
                                                  widget.token!,
                                                  widget.editLead,
                                                  widget.deleteLead,
                                                  widget.cloudCall,
                                                  widget.callMasterId,
                                                  pageName: widget.pageName
                                                      .toString(),
                                                  fromDate: widget.fromDate,
                                                  toDate: widget.toDate,
                                                  status: widget.status,
                                                  category: widget.category,
                                                  staff: widget.staff,
                                                  isCalled: widget.isCalled,
                                                  searchKey: widget.searchKey,
                                                  scrollToIndex:
                                                      widget.scrollToIndex,
                                                  leadType: widget.leadType1,
                                                )),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    Common.toastMessaage(
                                        object1.message, Colors.red);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              } else {
                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No Network Found..Try Again Later..'),
                                      backgroundColor: Colors.redAccent,
                                      elevation: 10,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  );
                                });
                              }
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
                  Text(
                    timeOut == true
                        ? "There seems to be a temporary issue, \n Please retry to continue"
                        : 'No Network Found !',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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

  Future<dynamic> dropDialog(BuildContext context) {
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
                          setState(() {
                            filterTemplates(value);
                          });
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
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          reminderTemplate.text =
                              filteredTemplates[index].templateName;
                          templateId = filteredTemplates[index].id;
                          filterTemplates("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            filteredTemplates[index].templateName.toString(),
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

  void filterTemplates(
    String query,
  ) {
    filteredTemplates = detailsResponse!.data.template
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
