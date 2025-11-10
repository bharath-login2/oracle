// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/cloudCallModel.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import 'package:login2/screens/accounts/clients/receiptByInvoice.dart';
import 'package:login2/screens/accounts/clients/viewInvoice.dart';
import 'package:login2/screens/accounts/clients/viewReceipt.dart';
import 'package:login2/screens/accounts/renewal_mannagement/custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup.dart';
import 'package:login2/screens/accounts/renewal_mannagement/view_history.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:lottie/lottie.dart';

import '../../../core/common.dart';
import '../../../models/clients/deleteInvoiceModel.dart';
import '../../../models/clients/deleteMainClientModel.dart';
import '../../../models/clients/mainClientDetailsModel.dart';
import '../../../models/clients/receiptDeleteModel.dart';
import '../../../service/service.dart';
import '../../leadManagement/webview.dart';
import '../renewal_mannagement/edit_quick_renewal.dart';
import '../renewal_mannagement/renew_custom_renewal.dart';
import '../renewal_mannagement/renew_quick_renewal.dart';
import 'addInvoice.dart';
import 'addReceipt.dart';
import 'editClient.dart';
import 'editInvoice.dart';
import 'editRecipt.dart';

class ClientDetails extends StatefulWidget {
  String token;
  String clientId;

  ClientDetails(this.token, this.clientId, {super.key});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  int selectedIndex = 0;
  MainClientDetailsModel? mainClientDetail;
  bool result = true;
  RenewalTemplateModel? template;
  TextEditingController recieverName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  HideModel? hideResponse;
  PostReminderModel? postReminderRes;
  String cloudCall = "";
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
  String updateLeadPermission = "false";
  String deleteLeadPermission = "false";
  String cloudCallPermission = "false";
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
    mainClientDetail =
        await HttpService.mainClientDetails(widget.token, widget.clientId);
    if (mainClientDetail != null) {
      setState(() {});
    }
    cloudCall = await Common.getSharedPref("cloudCallPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
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
                            'Customer Details',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: mainClientDetail != null
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 15, bottom: 10),
                              child: InkWell(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(2.0, 2.0),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
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
                                                // Text(
                                                //     'F. NUMBER  : ${_callLogEntries.elementAt(indexStaff).formattedNumber}'),
                                                // Text(
                                                //     'C.M. NUMBER: ${_callLogEntries.elementAt(indexStaff).cachedMatchedNumber}'),
                                                Row(
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
                                                              color:
                                                                  Colors.white,
                                                              width: 0),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    1, 1)),
                                                          ],
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          child: Text(
                                                            mainClientDetail!
                                                                .data.name
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          mainClientDetail!
                                                              .data.contactNo
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.email_outlined),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        mainClientDetail!
                                                            .data.emailId
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons
                                                        .location_on_outlined),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        mainClientDetail!
                                                            .data.address
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.arrow_right),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        'GST:${mainClientDetail!.data.gstNum}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.arrow_right),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        'Pincode:${mainClientDetail!.data.pincode}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                  height: 10,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditClients(
                                                              widget.token,
                                                              widget.clientId)),
                                                ).then((_) {
                                                  getData();
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors.blue)),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 7,
                                                        right: 7,
                                                        top: 7,
                                                        bottom: 7),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                      size: 18,
                                                    ),
                                                  )),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text(
                                                            'Please Confirm'),
                                                        content: const Text(
                                                            'Are you sure to Delete?'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'No')),
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                Common.showProgressDialog(
                                                                    context,
                                                                    "Loading..");
                                                                DeleteMainClientModel
                                                                    deleteClients =
                                                                    await HttpService.deleteMainClients(
                                                                        widget
                                                                            .token,
                                                                        widget
                                                                            .clientId);
                                                                if (deleteClients
                                                                        .data ==
                                                                    true) {
                                                                  Common.toastMessaage(
                                                                      deleteClients
                                                                          .message,
                                                                      Colors
                                                                          .green);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                } else {
                                                                  Common.toastMessaage(
                                                                      deleteClients
                                                                          .message,
                                                                      Colors
                                                                          .red);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Yes')),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors.red)),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 7,
                                                        right: 7,
                                                        top: 7,
                                                        bottom: 7),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                  )),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddInvoice(
                                                              widget.token,
                                                              widget.clientId,"")),
                                                ).then((_) {
                                                  getData();
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors.green)),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 7,
                                                        right: 7,
                                                        top: 7,
                                                        bottom: 7),
                                                    child: Icon(
                                                      Icons.currency_rupee,
                                                      color: Colors.green,
                                                      size: 18,
                                                    ),
                                                  )),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CustomRenewal(
                                                        custId: widget.clientId,
                                                        custName:
                                                            mainClientDetail!
                                                                .data.name
                                                                .toString(),
                                                      ),
                                                    )).then((_) {
                                                  getData();
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color:
                                                              Colors.purple)),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 7,
                                                        right: 7,
                                                        top: 7,
                                                        bottom: 7),
                                                    child: Icon(
                                                      Icons.restart_alt,
                                                      color: Colors.purple,
                                                      size: 18,
                                                    ),
                                                  )),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    mainClientDetail!.data.invoice.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              setState(() {
                                                selectedIndex = 0;
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
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
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(6))),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Lead Report',
                                                      style: TextStyle(
                                                        color:
                                                            selectedIndex == 0
                                                                ? const Color(
                                                                    0xFF3c9f9a)
                                                                : const Color(
                                                                    0xFF717171),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    mainClientDetail!.data.invoice.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              setState(() {
                                                selectedIndex = 1;
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
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
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(6))),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Invoice',
                                                      style: TextStyle(
                                                        color:
                                                            selectedIndex == 1
                                                                ? const Color(
                                                                    0xFF3c9f9a)
                                                                : const Color(
                                                                    0xFF717171),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    mainClientDetail!.data.receipts.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              setState(() {
                                                selectedIndex = 2;
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
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
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(6))),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Receipts',
                                                      style: TextStyle(
                                                        color:
                                                            selectedIndex == 2
                                                                ? const Color(
                                                                    0xFF3c9f9a)
                                                                : const Color(
                                                                    0xFF717171),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    mainClientDetail!
                                            .data.renewalLists.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              setState(() {
                                                selectedIndex = 3;
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: selectedIndex == 3
                                                          ? Colors.grey
                                                          : Colors.white,
                                                      width: 0),
                                                  color: selectedIndex == 3
                                                      ? const Color(0xFFd5f5f4)
                                                      : Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(6))),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Renewals',
                                                      style: TextStyle(
                                                        color:
                                                            selectedIndex == 3
                                                                ? const Color(
                                                                    0xFF3c9f9a)
                                                                : const Color(
                                                                    0xFF717171),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            selectedIndex == 0
                                ? Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      mainClientDetail!
                                              .data.leadLists.isNotEmpty
                                          ? ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: mainClientDetail!
                                                  .data.leadLists.length,
                                              itemBuilder: (context, index) {
                                                return leadListWidget(
                                                    context, index);
                                              },
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 180,
                                                    height: 180,
                                                    child: Image.asset(
                                                      "assets/icons/nodatafound.png",
                                                    ),
                                                  ),
                                                  const Text(
                                                    'No Data Found',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            )
                                    ],
                                  )
                                : selectedIndex == 1
                                    ? Container(
                                        child:
                                            mainClientDetail!
                                                    .data.invoice.isNotEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: ListView.builder(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          mainClientDetail!.data
                                                              .invoice.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ReceiptByInvoice(
                                                                        widget
                                                                            .token,
                                                                        mainClientDetail!
                                                                            .data
                                                                            .invoice[index]
                                                                            .invid
                                                                            .toString())),
                                                              ).then((_) {
                                                                getData();
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                      offset:
                                                                          const Offset(
                                                                              1,
                                                                              1),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        14.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.6,
                                                                          child: Text(
                                                                              "Invoice No : ${mainClientDetail!.data.invoice[index].invoiceNumber}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600,
                                                                              )),
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: mainClientDetail!.data.invoice[index].status.toString() == 'Paid' ? const Color(0xffe6fbec) : const Color(0xfffcbcbc)),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                                                                              child: Text(mainClientDetail!.data.invoice[index].status.toString(),
                                                                                  style: TextStyle(
                                                                                    color: mainClientDetail!.data.invoice[index].status.toString() == 'Paid' ? Colors.green : Colors.red,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.8,
                                                                      child:
                                                                          Text(
                                                                        mainClientDetail!.data.invoice[index].products.length !=
                                                                                1
                                                                            ? "Products : ${mainClientDetail!.data.invoice[index].products[0].productName} + ${mainClientDetail!.data.invoice[index].products.length - 1} more..."
                                                                            : "Products : ${mainClientDetail!.data.invoice[index].products[0].productName}",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.41,
                                                                        child:
                                                                            Text(
                                                                          "Total Amount : ₹ ${mainClientDetail!.data.invoice[index].totalAmount}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.41,
                                                                        child:
                                                                            Text(
                                                                          "Paid Amount : ₹ ${mainClientDetail!.data.invoice[index].paidAmount}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.41,
                                                                        child:
                                                                            Text(
                                                                          "Balance Amount : ₹ ${mainClientDetail!.data.invoice[index].balanceAmount}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            color: double.parse(mainClientDetail!.data.invoice[index].balanceAmount) > 0
                                                                                ? Colors.red
                                                                                : Colors.black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.41,
                                                                        child:
                                                                            Text(
                                                                          "Pay Mode : ${mainClientDetail!.data.invoice[index].paymentMethod}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.calendar_month,
                                                                                      color: Colors.grey,
                                                                                      size: 20,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 8,
                                                                                    ),
                                                                                    Text(mainClientDetail!.data.invoice[index].invoiceDate.toString(),
                                                                                        maxLines: 2,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: const TextStyle(
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.w400,
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => ViewInvoice(widget.token, mainClientDetail!.data.invoice[index].invid.toString(), widget.clientId, mainClientDetail!.data.invoice[index].invoiceNumber.toString())),
                                                                                ).then((_) {
                                                                                  getData();
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.green.shade100),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Container(
                                                                                    height: 20,
                                                                                    width: 20,
                                                                                    decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/icons/pdf.png'))),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            mainClientDetail!.data.invoice[index].isPaid == false
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) => ReceiptAdd(widget.token, widget.clientId, mainClientDetail!.data.invoice[index].invid.toString())),
                                                                                      ).then((_) {
                                                                                        getData();
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xffe9d9fd)),
                                                                                      child: const Padding(
                                                                                        padding: EdgeInsets.all(8.0),
                                                                                        child: Icon(Icons.currency_rupee, color: Color(0xff9747FF)),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : const SizedBox(),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => EditInvoice(widget.token, mainClientDetail!.data.invoice[index].invid.toString(), widget.clientId)),
                                                                                ).then((_) {
                                                                                  getData();
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xffaedcf4)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.mode_edit_outlined, color: Colors.blue),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                showDialog(
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
                                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                                DeleteInvoiceModel deleteInvoice = await HttpService.deleteInvoice(widget.token, mainClientDetail!.data.invoice[index].invid);
                                                                                                if (deleteInvoice.data == true) {
                                                                                                  Common.toastMessaage(deleteInvoice.message, Colors.green);
                                                                                                  if (context.mounted) {
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                  }
                                                                                                } else {
                                                                                                  Common.toastMessaage(deleteInvoice.message, Colors.red);
                                                                                                  if (context.mounted) {
                                                                                                    Navigator.of(context).pop();
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              child: const Text('Yes')),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xfffcbcbc)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.delete_outline, color: Colors.red),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 180,
                                                          height: 180,
                                                          child: Image.asset(
                                                            "assets/icons/nodatafound.png",
                                                          ),
                                                        ),
                                                        const Text(
                                                          'No Data Found',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                      )
                                    : selectedIndex == 2
                                        ? Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              mainClientDetail!
                                                      .data.receipts.isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12,
                                                              right: 12,
                                                              top: 12,
                                                              bottom: 12),
                                                      child: ListView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            mainClientDetail!
                                                                .data
                                                                .receipts
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                      offset:
                                                                          const Offset(
                                                                              1,
                                                                              1),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        14.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.6,
                                                                          child: Text(
                                                                              "Receipt No : ${mainClientDetail!.data.receipts[index].receiptNumber.toString()}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600,
                                                                              )),
                                                                        ),
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              color: const Color(0xffe6fbec)),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                                                                              child: Text(mainClientDetail!.data.receipts[index].paidAmount.toString(),
                                                                                  style: const TextStyle(
                                                                                    color: Colors.green,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.41,
                                                                        child:
                                                                            Text(
                                                                          "Invoice No : ${mainClientDetail!.data.receipts[index].invoiceNumber.toString()}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .person,
                                                                          color:
                                                                              Colors.grey,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              8,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.7,
                                                                          child: Text(
                                                                              "Collected by : ${mainClientDetail!.data.receipts[index].collectedBy.toString()} ",
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                              )),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.calendar_month,
                                                                                      color: Colors.grey,
                                                                                      size: 20,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 8,
                                                                                    ),
                                                                                    Text(mainClientDetail!.data.receipts[index].receiptDate.toString(),
                                                                                        maxLines: 2,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: const TextStyle(
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.w400,
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => ViewReceipt(widget.token, mainClientDetail!.data.receipts[index].receiptId.toString(), widget.clientId, mainClientDetail!.data.receipts[index].receiptNumber.toString())),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xffe9d9fd)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.local_print_shop_outlined, color: Color(0xff9747FF)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => EditReceipt(widget.token, mainClientDetail!.data.receipts[index].receiptId.toString())),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xffaedcf4)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.mode_edit_outlined, color: Colors.blue),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                showDialog(
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
                                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                                ReceiptDeleteModel deleteReceipt = await HttpService.deleteReceipt(widget.token, mainClientDetail!.data.receipts[index].receiptId.toString());
                                                                                                if (deleteReceipt.data == true) {
                                                                                                  Common.toastMessaage(deleteReceipt.message, Colors.green);
                                                                                                  if (context.mounted) {
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                  }
                                                                                                } else {
                                                                                                  Common.toastMessaage(deleteReceipt.message, Colors.red);
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
                                                                                              child: const Text('No')),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xfffcbcbc)),
                                                                                child: const Padding(
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Icon(Icons.delete_outline, color: Colors.red),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            mainClientDetail!.data.receipts[index].uploadedFile != ''
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) => WebViewPage('image', mainClientDetail!.data.receipts[index].uploadedFile.toString())),
                                                                                      );
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.green.shade100),
                                                                                      child: const Padding(
                                                                                        padding: EdgeInsets.all(8.0),
                                                                                        child: Icon(Icons.screenshot, color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : const SizedBox()
                                                                          ],
                                                                        )
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 180,
                                                            height: 180,
                                                            child: Image.asset(
                                                              "assets/icons/nodatafound.png",
                                                            ),
                                                          ),
                                                          const Text(
                                                            'No Data Found',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                            ],
                                          )
                                        : selectedIndex == 3
                                            ? Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  mainClientDetail!
                                                          .data
                                                          .renewalLists
                                                          .isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 12,
                                                                  right: 12,
                                                                  top: 12,
                                                                  bottom: 12),
                                                          child:
                                                              ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                mainClientDetail!
                                                                    .data
                                                                    .renewalLists
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            8.0,
                                                                        top:
                                                                            0.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    if (mainClientDetail!
                                                                            .data
                                                                            .renewalLists[index]
                                                                            .isRenewed ==
                                                                        false) {
                                                                      setState(
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => RenewalFollowup(mainClientDetail!.data.renewalLists[index].id, DateTime.now()))).then(
                                                                            (_) {
                                                                          getData();
                                                                        });
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .9,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          16.0),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.shopping_basket,
                                                                                        size: 20,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * .50,
                                                                                        child: Text(
                                                                                          " ${mainClientDetail!.data.renewalLists[index].products}",
                                                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.phone,
                                                                                        size: 18,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * .50,
                                                                                        child: Text(
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          " ${mainClientDetail!.data.renewalLists[index].contactNo}",
                                                                                          style: const TextStyle(fontSize: 14),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.calendar_month,
                                                                                        size: 18,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * .50,
                                                                                        child: Text(
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          " ${mainClientDetail!.data.renewalLists[index].startDate} To ${mainClientDetail!.data.renewalLists[index].endDate}",
                                                                                          style: const TextStyle(fontSize: 14),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.currency_rupee,
                                                                                        size: 18,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                      Text(
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        " ${mainClientDetail!.data.renewalLists[index].cost}/-",
                                                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: [
                                                                                  Container(
                                                                                    color: mainClientDetail!.data.renewalLists[index].isRenewed == false ? Colors.red : Colors.teal,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                                                      child: Text(
                                                                                        mainClientDetail!.data.renewalLists[index].isRenewed == true ? "Renewed" : "Not Renewed",
                                                                                        style: const TextStyle(color: Colors.white),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Container(
                                                                                    color: Colors.yellow,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                                                      child: Text(
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        mainClientDetail!.data.renewalLists[index].remainingDays,
                                                                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Visibility(
                                                                                visible: mainClientDetail!.data.renewalLists[index].isRenewed == false,
                                                                                child: InkWell(
                                                                                  onTap: () async {
                                                                                    Common.showProgressDialog(context, "Loading..");
                                                                                    getRenewalReminderMessage(mainClientDetail!.data.renewalLists[index].id, mainClientDetail!.data.renewalLists[index].contactNo);
                                                                                    recieverName.text = mainClientDetail!.data.renewalLists[index].clientName;
                                                                                    contactNumber.text = mainClientDetail!.data.renewalLists[index].contactNo;

                                                                                    // setState(() {});
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 40,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.teal),
                                                                                    child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset("assets/icons/whatsapp_white.png")),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Visibility(
                                                                                visible: mainClientDetail!.data.renewalLists[index].isRenewed == false,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    if (mainClientDetail!.data.renewalLists[index].isRenewed == "quick") {
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => RenewQuickRenewal(
                                                                                              id: mainClientDetail!.data.renewalLists[index].id,
                                                                                            ),
                                                                                          )).then((_) {
                                                                                        getData();
                                                                                      });
                                                                                    } else {
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => RenewCustomRenewal(
                                                                                              renId: mainClientDetail!.data.renewalLists[index].id,
                                                                                              renewalType: mainClientDetail!.data.renewalLists[index].renewalType,
                                                                                            ),
                                                                                          )).then((_) {
                                                                                        getData();
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.green),
                                                                                    child: const Padding(
                                                                                      padding: EdgeInsets.all(8.0),
                                                                                      child: Icon(Icons.restart_alt, color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Visibility(
                                                                                visible: mainClientDetail!.data.renewalLists[index].isRenewed == false,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    if (mainClientDetail!.data.renewalLists[index].renewalType == "quick") {
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                              builder: (context) => EditQuickRenewalScreen(
                                                                                                    id: mainClientDetail!.data.renewalLists[index].id,
                                                                                                  ))).then((r) {
                                                                                        getData();
                                                                                      });
                                                                                    } else {
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                              builder: (context) => EditCustomRenewal(
                                                                                                    renId: mainClientDetail!.data.renewalLists[index].id,
                                                                                                    renewalType: mainClientDetail!.data.renewalLists[index].renewalType,
                                                                                                  ))).then((_) {
                                                                                        getData();
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.blueAccent),
                                                                                    child: const Padding(
                                                                                      padding: EdgeInsets.all(8.0),
                                                                                      child: Icon(Icons.edit, color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return AlertDialog(
                                                                                          scrollable: true,
                                                                                          title: const Text('Please Confirm'),
                                                                                          content: const Text('Are you sure to Hide?'),
                                                                                          actions: [
                                                                                            TextButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                                child: const Text('No')),
                                                                                            TextButton(
                                                                                                onPressed: () async {
                                                                                                  Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                        builder: (context) => const RenewalDashboard(),
                                                                                                      ));
                                                                                                  await hide(mainClientDetail!.data.renewalLists[index].id);
                                                                                                  getData();
                                                                                                },
                                                                                                child: const Text('Yes')),
                                                                                          ],
                                                                                        );
                                                                                      });
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.grey),
                                                                                  child: const Padding(
                                                                                    padding: EdgeInsets.all(8.0),
                                                                                    child: Icon(Icons.visibility_off, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) => ViewHistory(
                                                                                          id: mainClientDetail!.data.renewalLists[index].id,
                                                                                          title: mainClientDetail!.data.renewalLists[index].clientName,
                                                                                        ),
                                                                                      ));
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.blueGrey),
                                                                                  child: const Padding(
                                                                                    padding: EdgeInsets.all(8.0),
                                                                                    child: Icon(Icons.history, color: Colors.white),
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
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                width: 180,
                                                                height: 180,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/icons/nodatafound.png",
                                                                ),
                                                              ),
                                                              const Text(
                                                                'No Data Found',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                ],
                                              )
                                            : const SizedBox(),
                            const SizedBox(
                              height: 70,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 60.0,
                        color: Colors.grey.shade200,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              mainClientDetail!.data.invoice.isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: const Text(
                                              'Total Invoice Amount ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Text(
                                          ': ${mainClientDetail!.data.totalInvoiceAmount}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              mainClientDetail!.data.receipts.isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: const Text(
                                              'Total Paid Amount ',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Text(
                                          ': ${mainClientDetail!.data.totalReceiptAmount}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        )),
                      ),
                    ],
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ))
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

  getRenewalReminderMessage(String renewalId, String contactId) async {
    template = await HttpService.getRenewalReminderMessage(renewalId);
    if (template != null && template!.status == true) {
      setState(() {
        Navigator.pop(context);
        reminderBottomSheet(renewalId, contactId);
      });
    } else {
      Common.toastMessaage(template!.message, Colors.red);
      Navigator.pop(context);
      setState(() {});
    }
  }

  reminderBottomSheet(String id, String contactNo) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Send Reminder",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: recieverName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please EnterName";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: contactNumber,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Contact Number";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Contact No',
                              prefixIcon: Icon(Icons.phone, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 4.0, bottom: 4.0),
                          child: Text("Reminder Message"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(template!.data.message),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await postReminder(id, contactNo);
                            },
                            child: const Text("Send Reminder",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
      },
    );
  }

  postReminder(String renewalId, String contactNumber) async {
    postReminderRes = await HttpService.postReminder(
        renewalId,
        contactNumber,
        template!.data.templateType,
        template!.data.templateName,
        template!.data.templateId,
        template!.data.customerId,
        template!.data.message);
    if (postReminderRes != null && postReminderRes!.status == true) {
      Common.toastMessaage(postReminderRes!.message, Colors.green);
    } else {
      Common.toastMessaage(postReminderRes!.message, Colors.red);
    }
  }

  hide(id) async {
    hideResponse = await HttpService.hideRenewal(id);
    if (hideResponse != null && hideResponse!.status == true) {
      Common.toastMessaage(hideResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(hideResponse!.message, Colors.red);
    }
  }

  Padding leadListWidget(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeadDetails(
                      widget.token,
                      updateLeadPermission == "true" ? true : false,
                      deleteLeadPermission == "true" ? true : false,
                      cloudCallPermission == "true" ? true : false,
                      mainClientDetail!.data.leadLists[index].callMasterId,
                      pageName: "",
                    )),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            color: mainClientDetail!.data.leadLists[index].isSelected == false
                ? Colors.grey.shade100
                : Colors.blue.shade100,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .88,
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                if (mainClientDetail!
                                        .data.leadLists[index].priority ==
                                    '1')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (mainClientDetail!
                                        .data.leadLists[index].priority ==
                                    '2')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (mainClientDetail!
                                        .data.leadLists[index].priority ==
                                    '3')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (mainClientDetail!
                                        .data.leadLists[index].priority ==
                                    '4')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .46,
                                  child: Text(
                                    mainClientDetail!
                                        .data.leadLists[index].clientName
                                        .toString(),
                                    // mainClientDetail!.data.leadLists.length.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        decoration: mainClientDetail!
                                                    .data
                                                    .leadLists[index]
                                                    .priority ==
                                                "4"
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationThickness: 1.5,
                                        decorationColor: Colors.red,
                                        color: mainClientDetail!.data
                                                .leadLists[index].isCustomer
                                            ? Colors.green
                                            : Colors.black,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.pink.shade100,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 2, bottom: 2),
                                      child: Text(
                                        mainClientDetail!
                                            .data.leadLists[index].leadCategory
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: mainClientDetail!.data
                                              .leadLists[index].categoryCount
                                              .toString() !=
                                          "1" &&
                                      mainClientDetail!.data.leadLists[index]
                                              .categoryCount
                                              .toString() !=
                                          "",
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        mainClientDetail!
                                            .data.leadLists[index].categoryCount
                                            .toString(),
                                        // mainClientDetail!.data.leadLists.length.toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.68,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mainClientDetail!
                                          .data.leadLists[index].contactNumber1
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            'Assigned to : ${mainClientDetail!.data.leadLists[index].staffName}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: _colors[mainClientDetail!
                                                  .data
                                                  .leadLists[index]
                                                  .callResultId],
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                top: 2,
                                                bottom: 2),
                                            child: Text(
                                              mainClientDetail!.data
                                                  .leadLists[index].callResult
                                                  .toString(),
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
                                    mainClientDetail!.data.leadLists[index]
                                                .callResultId ==
                                            1
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFd5f5f4),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 5,
                                                  bottom: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      "assets/icons/calendar.png",
                                                      width: 20),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Created Time',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        mainClientDetail!
                                                            .data
                                                            .leadLists[index]
                                                            .createdDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
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
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFd5f5f4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/icons/calendar.png",
                                                          width: 20),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            'Called Date',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            mainClientDetail!
                                                                        .data
                                                                        .leadLists[
                                                                            index]
                                                                        .isCalled ==
                                                                    false
                                                                ? '--'
                                                                : mainClientDetail!
                                                                    .data
                                                                    .leadLists[
                                                                        index]
                                                                    .calledDate
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFd5f5f4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/icons/calendar.png",
                                                          width: 20),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            'Followup Date',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            mainClientDetail!
                                                                .data
                                                                .leadLists[
                                                                    index]
                                                                .scheduledDate
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
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
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(mainClientDetail!
                                          .data.leadLists[index].profilePic
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
                                if (mainClientDetail!.data.contactNo ==
                                    "false") {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Alert !!!'),
                                          // content: Text(response!
                                          //     .data.warningMessage
                                          //     .toString()),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Close')),
                                            TextButton(
                                                onPressed: () {
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           LeadDetails(
                                                  //             widget.token,
                                                  //             widget.editLead,
                                                  //             widget.deleteLead,
                                                  //             widget.cloudCall,
                                                  //             response!
                                                  //                 .data
                                                  //                 .leadData[
                                                  //                     index]
                                                  //                 .callMasterId,
                                                  //             pageName: "",
                                                  //           )),
                                                  // );
                                                },
                                                child: const Text('followup')),
                                          ],
                                        );
                                      });
                                } else {
                                  if (cloudCall == true) {
                                    chooseCallDialog(context, index);
                                  } else {
                                    Common.dialPad(mainClientDetail!
                                        .data.leadLists[index].contactNumber1);
                                  }
                                }
                              },
                              child: Container(
                                width: 65,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Call',
                                          style: TextStyle(
                                              fontFamily: "MontserratMedium",
                                              fontSize: 14,
                                              color: Colors.white,
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
      ),
    );
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Choose Call Type'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    Common.showProgressDialog(context, "Loading..");
                    CloudCallModel object1 = await HttpService.addCloudCall(
                        widget.token,
                        mainClientDetail!.data.leadLists[index].callMasterId,
                        mainClientDetail!.data.leadLists[index].contactNumber1);
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, Colors.green);
                        Navigator.pop(context);
                        Navigator.pop(context);
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
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5)),
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
                    Navigator.pop(context);
                    Common.dialPad(
                        mainClientDetail!.data.leadLists[index].contactNumber1);
                  },
                  child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5)),
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
  }
}
