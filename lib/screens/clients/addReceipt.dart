// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/screens/clients/invoiceList.dart';
import 'package:login2/screens/clients/receiptList.dart';
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../models/clients/receiptAddCommonDetailsModel.dart';
import '../../models/clients/receiptAddModel.dart';
import '../../service/service.dart';
import '../homePage.dart';
import '../leadManagement/dashboard.dart';
import 'clientList.dart';

class ReceiptAdd extends StatefulWidget {
  String token;
  String clientId;
  String invoiceId;
  ReceiptAdd(this.token, this.clientId, this.invoiceId, {Key? key})
      : super(key: key);

  @override
  State<ReceiptAdd> createState() => _ReceiptAddState();
}

class _ReceiptAddState extends State<ReceiptAdd> {
  var fromdate = DateTime.now();
  ReceiptAddCommonDetailsModel? receiptDetails;
  bool result = true;

  dynamic paymentMethod;
  TextEditingController payAmount = TextEditingController();
  List<Staff> items = [];
  List<Staff> filteredItems = [];
  String collectedBy = "";
  String collectedByName = "Collected By";
  TextEditingController search = TextEditingController();
  String? templateImage;
  @override
  void initState() {
    super.initState();
    getData();
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

    receiptDetails = await HttpService.receiptCommonDetails(
        widget.token, widget.clientId, widget.invoiceId);
    if (receiptDetails != null) {
      items = receiptDetails!.data!.staff!;
      filteredItems.addAll(items);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? WillPopScope(
            onWillPop: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InvoiceList(widget.token)),
              );
              return true;
            },
            child: Scaffold(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InvoiceList(widget.token)),
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
                              'Receipt',
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
                                    border: Border.all(
                                        color: Colors.white, width: 0),
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
                                        image: AssetImage(
                                            'assets/main/avatar.png')),
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
                                    receiptDetails!.data!.name.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Receipt No: ${receiptDetails!.data!.displayRecNumber}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    'Invoice No: ${receiptDetails!.data!.displayInvNumber}',
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
                                          contentPadding:
                                              const EdgeInsets.all(3),
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Collected By',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    // SizedBox(
                                    //   width: MediaQuery.of(context).size.width *
                                    //       0.45,
                                    //   child: FormField<
                                    //       String>(
                                    //     builder: (FormFieldState<
                                    //         String>
                                    //     state) {
                                    //       return Container(
                                    //         width: MediaQuery.of(context)
                                    //             .size
                                    //             .width *
                                    //             0.43,
                                    //         decoration: BoxDecoration(
                                    //             border: Border.all(
                                    //                 color: Colors
                                    //                     .grey.shade900,
                                    //                 width:
                                    //                 0),
                                    //             color: Colors
                                    //                 .white,
                                    //             borderRadius: const BorderRadius
                                    //                 .all(
                                    //                 Radius.circular(5))),
                                    //         child:
                                    //         DropdownButtonHideUnderline(
                                    //           child: DropdownButton<
                                    //               String>(
                                    //             isExpanded:
                                    //             true,
                                    //             hint:
                                    //             const Padding(
                                    //               padding:
                                    //               EdgeInsets.only(left: 20),
                                    //               child:
                                    //               Text('Collected by'),
                                    //             ),
                                    //             value: collectedBy,
                                    //             items:receiptDetails!.data!.staff!.map((data) {
                                    //               return DropdownMenuItem(
                                    //                 value: data.userId.toString(),
                                    //                 child: Padding(
                                    //                   padding: const EdgeInsets.only(left: 20),
                                    //                   child: Text(data.staffName.toString()),
                                    //                 ),
                                    //               );
                                    //             }).toList(),
                                    //             onChanged:
                                    //                 (newValue1) {
                                    //               setState(() {
                                    //                 collectedBy = newValue1;
                                    //               });
                                    //             },
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextField(
                                                          controller: search,
                                                          autocorrect: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .visiblePassword,
                                                          autofocus: true,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              filteredItems = items
                                                                  .where((item) => item
                                                                      .staffName!
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          value
                                                                              .toLowerCase()))
                                                                  .toList();
                                                            });
                                                          },
                                                          decoration:
                                                              const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            hintText: 'Search',
                                                            prefixIcon: Icon(
                                                                Icons.search),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            .3,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              filteredItems
                                                                  .length,
                                                          physics:
                                                              const ScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return ListTile(
                                                                onTap: () {
                                                                  collectedByName =
                                                                      filteredItems[
                                                                              index]
                                                                          .staffName!;
                                                                  collectedBy =
                                                                      filteredItems[
                                                                              index]
                                                                          .userId!;
                                                                  search
                                                                      .clear();
                                                                  filteredItems
                                                                      .addAll(
                                                                          items);
                                                                  setState(
                                                                      () {});
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                },
                                                                title: SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        1,
                                                                    child: Text(
                                                                      filteredItems[
                                                                              index]
                                                                          .staffName!,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                          filteredItems
                                                              .addAll(items);
                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            "Close")),
                                                  ],
                                                );
                                              });
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                child: Text(
                                                  collectedByName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          )),
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
                                        builder:
                                            (FormFieldState<String> state) {
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
                                                    .data!.paymentMethods!
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
                                    color: Color(0xFFece9fd),
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
                                        receiptDetails!.data!.particulars
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        receiptDetails!.data!.totalAmount
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
                                    color: Color(0xFFece9fd),
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
                                          double.parse(receiptDetails!
                                                  .data!.amountDue
                                                  .toString())
                                              .toStringAsFixed(2),
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
                                    color: Color(0xFFece9fd),
                                  ),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          left: 8, right: 8, top: 15),
                                      child: Text('Amount to Pay',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: payAmount,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              // labelText: 'Amount',
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
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
                          paymentMethod == '2'
                              ? Container(
                                  child: templateImage == null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: _selectFile,
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
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
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: InkWell(
                                                  onTap: _selectFile,
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade300,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
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
                          const SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () async {
                              if (collectedBy == "") {
                                Common.toastMessaage(
                                    'Please add collected Staff', Colors.red);
                              } else if (paymentMethod == null) {
                                Common.toastMessaage(
                                    'Please add payment method', Colors.red);
                              } else if (payAmount.text.isEmpty) {
                                Common.toastMessaage(
                                    'Type Valid pay amount', Colors.red);
                              } else if (double.parse(payAmount.text) >
                                  double.parse(receiptDetails!.data!.amountDue
                                      .toString())) {
                                Common.toastMessaage(
                                    'Maximum Amount to pay is ${receiptDetails!.data!.amountDue}',
                                    Colors.red);
                              } else {
                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                }
                                ReceiptAddModel object =
                                    await HttpService.addReceipt(
                                        widget.token,
                                        widget.invoiceId,
                                        widget.clientId,
                                        receiptDetails!.data!.receiptNumber,
                                        fromdate,
                                        payAmount.text,
                                        collectedBy,
                                        paymentMethod,
                                        templateImage);

                                if (object.data == true) {
                                  Common.toastMessaage(
                                      object.message, Colors.green);
                                  {
                                    if (mounted) {
                                      showDialog(
                                          barrierDismissible: false,
                                          barrierColor:
                                              Colors.white.withOpacity(.2),
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WillPopScope(
                                              onWillPop: () async {
                                                return false;
                                              },
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 50),
                                                  child: Center(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.white,
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      height: 300,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 20,
                                                                right: 20),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              'assets/icons/check.png',
                                                              width: 80,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            const Text(
                                                              'Success',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              object.message
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              Dashboard(widget.token)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.25,
                                                                    //  color: RandomColorModel().getColor(),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.dashboard,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Dashboard',
                                                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              InvoiceList(widget.token)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.list_alt,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Invoice',
                                                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ReceiptList(widget.token)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.currency_rupee,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Receipt',
                                                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              HomePage(widget.token)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.25,
                                                                    //  color: RandomColorModel().getColor(),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.home,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Home',
                                                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ClientList(widget.token)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.person,
                                                                            size:
                                                                                15,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                              'Clients',
                                                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.25,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .green
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .details,
                                                                          size:
                                                                              15,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                            'Others',
                                                                            style:
                                                                                TextStyle(fontSize: 13, color: Colors.black),
                                                                            textAlign: TextAlign.center),
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
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                    // if(mounted){
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ReceiptList(widget.token)),
                                    //   );
                                    // }
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
}
