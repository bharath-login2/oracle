// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/models/clients/editReceiptDetailsModel.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/editReceiptModel.dart';
import '../../../models/clients/receiptFileDeleteModel.dart';
import '../../../service/service.dart';

class EditReceipt extends StatefulWidget {
  String token;
  String receiptId;
  EditReceipt(this.token, this.receiptId, {super.key});

  @override
  State<EditReceipt> createState() => _EditReceiptState();
}

class _EditReceiptState extends State<EditReceipt> {
  var fromdate = DateTime.now();
  EditReceiptModelDetailsModel? receiptDetails;
  bool result = true;
  String? paymentMethod;
  TextEditingController payAmount = TextEditingController();
  List<Staff> items = [];
  List<Staff> filteredItems = [];
  String collectedBy = "";
  String collectedByName = "Account Head";
  TextEditingController search = TextEditingController();
  String? templateImage;
  List<TargetGroup> targets = [];
  List<TargetGroup> filteredTargets = [];
  List targetGroups = [];
  List targetGroupNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
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

    receiptDetails =
        await HttpService.editReceiptDetails(widget.token, widget.receiptId);
    if (receiptDetails != null) {
      targets = receiptDetails!.data.targetGroups;
      filteredTargets.addAll(targets);
      filteredItems.addAll(receiptDetails!.data.staff);
      items.addAll(receiptDetails!.data.staff);
      setState(() {
        if (receiptDetails!.data.collectedBy != '0') {
          collectedByName = receiptDetails!.data.collectedStaff.toString();
          collectedBy = receiptDetails!.data.collectedBy.toString();
        }
        if (receiptDetails!.data.paymentMethod != '0') {
          paymentMethod = receiptDetails!.data.paymentMethod;
        }
        payAmount.text = receiptDetails!.data.paidAmount.toString();
        fromdate = DateTime.parse(receiptDetails!.data.receiptDate.toString());
      });
      log(collectedByName);
      for (int i = 0; i < receiptDetails!.data.selectedGroups.length; i++) {
        targetGroups.add(receiptDetails!.data.selectedGroups[i].groupId);
        targetGroupNames.add(receiptDetails!.data.selectedGroups[i].groupName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
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
                            'Receipt',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: receiptDetails != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 60,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 20,
                                  minWidth: 20,
                                  maxHeight: 60,
                                  maxWidth: 60,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 0),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: const DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage('assets/main/avatar.png')),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiptDetails!.data.clientName.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Receipt No: ${receiptDetails!.data.displayRecNumber}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Invoice No: ${receiptDetails!.data.displayInvNumber}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pay Date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Center(
                                  child: DateTimePicker(
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(3),
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Account Head',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: GestureDetector(
                                      onTap: () {
                                        collectedStaffDialog(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45,
                                              child: Text(
                                                collectedByName,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Payment Method',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
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
                                                child: Text('Payment Method'),
                                              ),
                                              value: paymentMethod,
                                              items: receiptDetails!
                                                  .data.paymentMethods
                                                  .map((data) {
                                                return DropdownMenuItem(
                                                  value: data.id.toString(),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Text(
                                                        data.name.toString()),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (newValue1) {
                                                setState(() {
                                                  paymentMethod = newValue1;
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
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Target Group :',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: GestureDetector(
                                  onTap: () {
                                    targetGroupDialog(context);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: targetGroups.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 10),
                                            child: Text('Target Group'))
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 40),
                                            child: SizedBox(
                                              height: 35,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    targetGroupNames.length,
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
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            6),
                                                                    bottomLeft:
                                                                        Radius.circular(
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
                                                                      targetGroupNames[
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
                                                                                targetGroupNames.remove(targetGroupNames[i]);
                                                                                targetGroups.remove(targetGroups[i]);
                                                                              });
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
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              6),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              6))),
                                                              child: const Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.red,
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Table(
                            columnWidths: {
                              0: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.6), // Using 10%
                              1: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.4), // Using 30%
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: const Color(0xFFece9fd),
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Particulars',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Amount',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Table(
                            columnWidths: {
                              0: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.6), // Using 10%
                              1: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.4), // Using 30%
                            },
                            children: [
                              // Each TableRow represents a row in the Table
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: const Color(0xFFF3F3F3),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      receiptDetails!.data.particulars
                                          .toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      receiptDetails!.data.totalAmount
                                          .toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Table(
                            columnWidths: {
                              0: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.6), // Using 10%
                              1: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.4), // Using 30%
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: const Color(0xFFece9fd),
                                ),
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total Amount Due',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        receiptDetails!.data.amountDue
                                            .toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Table(
                            columnWidths: {
                              0: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.6), // Using 10%
                              1: FixedColumnWidth(
                                  MediaQuery.of(context).size.width *
                                      0.4), // Using 30%
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: const Color(0xFFece9fd),
                                ),
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        left: 8, right: 8, top: 15),
                                    child: Text('Amount Received',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: TextFormField(
                                        controller: payAmount,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                left: 10, top: 2, bottom: 2),
                                            //labelText: 'Amount',
                                            fillColor: Colors.white,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            labelStyle:
                                                TextStyle(color: Colors.grey)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        receiptDetails!.data.uploadedImg == ''
                            ? Container(
                                child: paymentMethod == '2'
                                    ? Container(
                                        child: templateImage == null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: _selectFile,
                                                    child: Container(
                                                        width:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.4,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          child: Center(
                                                              child: Text(
                                                                  'Choose File')),
                                                        )),
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: InkWell(
                                                        onTap: _selectFile,
                                                        child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                right: 10,
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height: 80,
                                                                    width: 90,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .fitWidth,
                                                                        image:
                                                                            FileImage(
                                                                          File(
                                                                              templateImage!),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Add your image widget here
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  const Center(
                                                                      child: Text(
                                                                          'Change File')),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 0.0,
                                                      top: 0.0,
                                                      child: InkWell(
                                                        onTap: () {
                                                          templateImage = null;
                                                          setState(() {});
                                                        },
                                                        child: const Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ))
                                    : const SizedBox(),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          height: 80,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 80,
                                                  width: 90,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.fitWidth,
                                                      image: NetworkImage(
                                                        receiptDetails!
                                                            .data.uploadedImg
                                                            .toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  // Add your image widget here
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                const Center(
                                                    child: Text('Remove')),
                                              ],
                                            ),
                                          )),
                                    ),
                                    Positioned(
                                      right: 0.0,
                                      top: 0.0,
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  scrollable: true,
                                                  title: const Text(
                                                      'Please Confirm'),
                                                  content: const Text(
                                                      'Are you sure to Delete?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('No')),
                                                    TextButton(
                                                        onPressed: () async {
                                                          ReceiptFileDeleteModel
                                                              deleteReceiptFile =
                                                              await HttpService
                                                                  .deleteReceiptFile(
                                                                      widget
                                                                          .token,
                                                                      receiptDetails!
                                                                          .data
                                                                          .receiptId);
                                                          if (deleteReceiptFile
                                                                  .data ==
                                                              true) {
                                                            Common.toastMessaage(
                                                                deleteReceiptFile
                                                                    .message,
                                                                Colors.green);
                                                            if (context
                                                                .mounted) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => EditReceipt(
                                                                        widget
                                                                            .token,
                                                                        widget
                                                                            .receiptId)),
                                                              );
                                                            }
                                                          } else {
                                                            Common.toastMessaage(
                                                                deleteReceiptFile
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
                                                        child:
                                                            const Text('Yes')),
                                                  ],
                                                );
                                              });
                                        },
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () async {
                            if (payAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Type Valid pay amount', Colors.red);
                            } else if (double.parse(payAmount.text) >
                                double.parse(receiptDetails!.data.checkAmount
                                    .toString())) {
                              Common.toastMessaage(
                                  'Maximum Amount Received can be ${receiptDetails!.data.checkAmount}',
                                  Colors.red);
                            } else {
                              if (context.mounted) {
                                Common.showProgressDialog(context, "Loading..");
                              }
                              EditReceiptModel object =
                                  await HttpService.editReceipt(
                                      widget.token,
                                      widget.receiptId,
                                      fromdate,
                                      payAmount.text,
                                      collectedBy,
                                      paymentMethod,
                                      templateImage,
                                      targetGroups);

                              if (object.data == true) {
                                Common.toastMessaage(
                                    object.message, Colors.green);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              } else {
                                Common.toastMessaage(
                                    object.message, Colors.red);
                              }
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
                          height: 30,
                        ),
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

  Future<dynamic> collectedStaffDialog(BuildContext context) {
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
                        filteredItems = items
                            .where((item) => item.staffName
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
                    itemCount: filteredItems.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            collectedByName = filteredItems[index].staffName;
                            collectedBy = filteredItems[index].userId;
                            filteredItems.addAll(items);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Text(
                                filteredItems[index].staffName,
                                overflow: TextOverflow.ellipsis,
                              )));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    search.clear();
                    filteredItems.addAll(items);
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

  pickTemplateImage(context, source) async {
    try {
      Navigator.pop(context);
      final pickedFile = await ImagePicker().pickImage(source: source);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        templateImage = pickedFile!.path;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  _selectFile() {
    showModalBottomSheet(
      context: context,
      builder: ((builder) {
        return Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width * 1,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: <Widget>[
              const Text(
                "Choose  photo",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await pickTemplateImage(context, ImageSource.camera);
                      },
                      child: const Column(
                        children: [Icon(Icons.camera), Text('Camera')],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    InkWell(
                      onTap: () async {
                        await pickTemplateImage(context, ImageSource.gallery);
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.image),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ])
            ],
          ),
        );
      }),
    );
  }

  Future<dynamic> targetGroupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredTargets = targets
                              .where((item) => item.groupName
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
                    height: MediaQuery.of(context).size.height * .32,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ListView.builder(
                      // Remove NeverScrollableScrollPhysics to enable scrolling
                      shrinkWrap: true,
                      itemCount: filteredTargets.length,
                      itemBuilder: (context, ind) {
                        return CheckboxListTile(
                          title: SizedBox(
                            width: 200,
                            child: Text(
                              filteredTargets[ind].groupName.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          value: targetGroups
                                  .contains(filteredTargets[ind].id.toString())
                              ? true
                              : false,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                targetGroups
                                    .add(filteredTargets[ind].id.toString());
                                targetGroupNames.add(
                                    filteredTargets[ind].groupName.toString());
                              } else {
                                targetGroups
                                    .remove(filteredTargets[ind].id.toString());
                                targetGroupNames.remove(
                                    filteredTargets[ind].groupName.toString());
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  filteredTargets.clear();
                  filteredTargets.addAll(targets);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }
}
