// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/addInvoiceUpdated.dart'
    hide Customer;
import 'package:login2/screens/accounts/clients/gstInvoice.dart';
import 'package:login2/screens/accounts/clients/print_invoice_view.dart';
import 'package:login2/screens/accounts/clients/receiptByInvoice.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_quick_renewal.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/deleteInvoiceModel.dart';
import '../../../models/clients/invoiceListModel.dart';
import '../../../service/service.dart';
import 'addReceipt.dart';
import 'clientDetails.dart';
import 'editInvoice.dart';

class UpdatedInvoiceList extends StatefulWidget {
  String token;

  UpdatedInvoiceList(this.token, {super.key});

  @override
  State<UpdatedInvoiceList> createState() => _UpdatedInvoiceListState();
}

class _UpdatedInvoiceListState extends State<UpdatedInvoiceList> {
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  InvoiceListModel? invoiceList;
  GetInvoiceSearchData? searchData;
  bool result = true;
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  String customerId = "";
  String customerName = "Choose Customer";
  List<Staff> staffs = [];
  List<Staff> filteredStaffs = [];
  String staffId = "";
  String staffName = "Choose Staff";
  List<Type> types = [];
  List<Type> filteredTypes = [];
  String typeId = "";
  String typeName = "Choose Type";
  String? name = '';
  String? role = '';
  String? userId = '';
  String? phoneCallLogPermission = '';
  TextEditingController search = TextEditingController();
  bool isSearch = false;
  Offset? _tapPosition;
  List<String> collectedByNames = [];
  List<String> collectedByIds = [];
  List<String> createdByNames = [];
  List<String> createdByIds = [];

  List<String> selectedStaffIds = [];
  List<String> selectedStaffNames = [];
  bool _showFloatingOptions = false;
  Offset _floatingButtonPosition = Offset(20, 100);
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
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

    invoiceList = await HttpService.invoiceList(
        widget.token,
        ""
            "",
        "",
        fDate == "From Date" ? "" : fDate.toString(),
        tDate == "To Date" ? "" : tDate.toString(),
        customerId,
        staffId,
        "",
        "",
        "",
        typeId);
    if (invoiceList != null) {
      searchData = await HttpService.getInvoiceSearch(widget.token);
      customers = searchData!.data.customers;
      filteredCustomers.addAll(customers);
      staffs = searchData!.data.staff;
      filteredStaffs.addAll(staffs);
      types = searchData!.data.types;
      filteredTypes.addAll(types);
      if (isSearch == true) {
        isSearch = false;
        if (mounted) {
          Navigator.pop(context);
        }
      }
      setState(() {});
    }
  }

  String _getProductDisplayText(List<dynamic> products) {
    if (products.isEmpty) {
      return "Products : No products";
    } else if (products.length == 1) {
      return "Products : ${products[0].productName}";
    } else {
      return "Products : ${products[0].productName} + ${products.length - 1} more...";
    }
  }

  void _updateFloatingButtonPosition(Offset newPosition) {
    setState(() {
      _floatingButtonPosition = newPosition;
    });
  }

// Then use it like this:
  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
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
                            'Sales List',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                fDate = "From Date";
                                tDate = "To Date";
                                typeId = "";
                                typeName = "Choose Type";
                                staffId = "";
                                staffName = "Choose Staff";
                                customerId = "";
                                customerName = "Choose Customer";
                                filtrationSheet(context);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: const Color(0xFFd5f5f4),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Image.asset(
                                        "assets/icons/filter.png",
                                        width: 20)),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddInvoiceUpdated(
                                    widget.token,
                                    "",
                                    "",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: invoiceList != null && searchData != null
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 12, top: 12, bottom: 80),
                              child: invoiceList!.data.lists.isNotEmpty
                                  ? ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: invoiceList!.data.lists.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReceiptByInvoice(
                                                            widget.token,
                                                            invoiceList!.data
                                                                .lists[index].id
                                                                .toString())),
                                              ).then((_) {
                                                getData();
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 1,
                                                      offset:
                                                          const Offset(1, 1),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: invoiceList!
                                                              .data
                                                              .lists[index]
                                                              .gstinvoiceCreated
                                                              .toString() ==
                                                          "1"
                                                      ? const Color.fromARGB(
                                                          255, 228, 248, 216)
                                                      : Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                          child: InkWell(
                                                            onTap: () {
                                                              // Navigator.push(
                                                              //   context,
                                                              //   MaterialPageRoute(
                                                              //       builder: (context) => ClientDetails(
                                                              //           widget
                                                              //               .token,
                                                              //           invoiceList!
                                                              //               .data
                                                              //               .lists[index]
                                                              //               .clientId
                                                              //               .toString())),
                                                              // );
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => CustomerDashboard(
                                                                      name:
                                                                          name!,
                                                                      token: widget
                                                                          .token!,
                                                                      userId:
                                                                          userId!,
                                                                      phoneCallLogPermission:
                                                                          phoneCallLogPermission,
                                                                      custId: invoiceList!
                                                                          .data
                                                                          .lists[
                                                                              index]
                                                                          .clientId
                                                                          .toString()),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                                invoiceList!
                                                                    .data
                                                                    .lists[
                                                                        index]
                                                                    .customerName
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                )),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
                                                              color: invoiceList!
                                                                          .data
                                                                          .lists[
                                                                              index]
                                                                          .status
                                                                          .toString() ==
                                                                      'Paid'
                                                                  ? const Color(
                                                                      0xffe6fbec)
                                                                  : const Color(
                                                                      0xfffcbcbc)),
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 12,
                                                                      right: 12,
                                                                      top: 6,
                                                                      bottom:
                                                                          6),
                                                              child: Text(
                                                                  invoiceList!
                                                                      .data
                                                                      .lists[
                                                                          index]
                                                                      .status
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: invoiceList!.data.lists[index].status.toString() ==
                                                                            'Paid'
                                                                        ? Colors
                                                                            .green
                                                                        : invoiceList!.data.lists[index].status.toString() ==
                                                                                'Renewed'
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        "Invoice No : ${invoiceList!.data.lists[index].invoiceNumber}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),

                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      child: Text(
                                                        _getProductDisplayText(
                                                            invoiceList!
                                                                .data
                                                                .lists[index]
                                                                .products),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    // SizedBox(
                                                    //   width:
                                                    //       MediaQuery.of(context)
                                                    //               .size
                                                    //               .width *
                                                    //           0.8,
                                                    //   child: Text(
                                                    //     invoiceList!
                                                    //                 .data
                                                    //                 .lists[
                                                    //                     index]
                                                    //                 .products
                                                    //                 .length !=
                                                    //             1
                                                    //         ? "Products : ${invoiceList!.data.lists[index].products[0].productName} + ${invoiceList!.data.lists[index].products.length - 1} more..."
                                                    //         : "Products : ${invoiceList!.data.lists[index].products[0].productName}",
                                                    //     overflow: TextOverflow
                                                    //         .ellipsis,
                                                    //     style: const TextStyle(
                                                    //       fontSize: 14,
                                                    //       fontWeight:
                                                    //           FontWeight.w400,
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        "Total Amount : ₹ ${invoiceList!.data.lists[index].totalAmount}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        "Paid Amount : ₹ ${invoiceList!.data.lists[index].totalPaid}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    invoiceList!
                                                                .data
                                                                .lists[index]
                                                                .balance !=
                                                            '0.00'
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Text(
                                                                "Balance Amount : ₹ ${invoiceList!.data.lists[index].balance}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                          child: Text(
                                                            "Pay Mode : ${invoiceList!.data.lists[index].paymentMode}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
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
                                                        Row(
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                        invoiceList!
                                                                            .data
                                                                            .lists[
                                                                                index]
                                                                            .invoiceDate
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
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
                                                              onTap: () async {
                                                                final pdfPath =
                                                                    await HttpService
                                                                        .printInvoice(
                                                                  widget.token,
                                                                  invoiceList!
                                                                      .data
                                                                      .lists[
                                                                          index]
                                                                      .id
                                                                      .toString(),
                                                                );

                                                                if (pdfPath !=
                                                                    null) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (_) =>
                                                                          PrintInvoiceView(
                                                                              pdfPath: pdfPath),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(const SnackBar(
                                                                          content:
                                                                              Text("Failed to load invoice")));
                                                                }
                                                              },

                                                              // onTap: () {
                                                              //   Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //         builder: (context) => ViewInvoice(
                                                              //             widget
                                                              //                 .token,
                                                              //             invoiceList!
                                                              //                 .data
                                                              //                 .lists[
                                                              //                     index]
                                                              //                 .id
                                                              //                 .toString(),
                                                              //             invoiceList!
                                                              //                 .data
                                                              //                 .lists[
                                                              //                     index]
                                                              //                 .clientId
                                                              //                 .toString(),
                                                              //             invoiceList!
                                                              //                 .data
                                                              //                 .lists[index]
                                                              //                 .invoiceNumber
                                                              //                 .toString())),
                                                              //   );
                                                              // },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                2),
                                                                    color: Colors
                                                                        .green
                                                                        .shade100),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    height: 20,
                                                                    width: 20,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            image:
                                                                                DecorationImage(image: AssetImage('assets/icons/pdf.png'))),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: invoiceList!
                                                                          .data
                                                                          .lists[
                                                                              index]
                                                                          .invType ==
                                                                      "1" ||
                                                                  invoiceList!
                                                                          .data
                                                                          .lists[
                                                                              index]
                                                                          .invType ==
                                                                      "2",
                                                              child: Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  invoiceList!
                                                                              .data
                                                                              .lists[index]
                                                                              .isPaid ==
                                                                          false
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ReceiptAdd(widget.token, invoiceList!.data.lists[index].clientId.toString(), invoiceList!.data.lists[index].id.toString())),
                                                                            ).then((_) {
                                                                              getData();
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xffe9d9fd)),
                                                                            child:
                                                                                const Padding(
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
                                                                      if (invoiceList!
                                                                              .data
                                                                              .lists[index]
                                                                              .invType ==
                                                                          "2") {
                                                                        if (invoiceList!.data.lists[index].renewalType ==
                                                                            "quick") {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => EditQuickRenewalScreen(
                                                                                        id: invoiceList!.data.lists[index].renewalId,
                                                                                      ))).then((_) {
                                                                            getData();
                                                                          });
                                                                        } else {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => EditCustomRenewal(
                                                                                        renId: invoiceList!.data.lists[index].renewalId,
                                                                                        renewalType: invoiceList!.data.lists[index].renewalType,
                                                                                      ))).then((_) {
                                                                            getData();
                                                                          });
                                                                        }
                                                                      } else {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => EditInvoice(widget.token, invoiceList!.data.lists[index].id.toString(), invoiceList!.data.lists[index].clientId.toString())),
                                                                        ).then(
                                                                            (_) {
                                                                          getData();
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              2),
                                                                          color:
                                                                              const Color(0xffaedcf4)),
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
                                                                        child: Icon(
                                                                            Icons
                                                                                .mode_edit_outlined,
                                                                            color:
                                                                                Colors.blue),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  InkWell(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    onTapDown:
                                                                        (TapDownDetails
                                                                            details) {
                                                                      _tapPosition =
                                                                          details
                                                                              .globalPosition;
                                                                    },
                                                                    onTap:
                                                                        () async {
                                                                      final Offset
                                                                          pos =
                                                                          _tapPosition ??
                                                                              Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);

                                                                      final RenderBox
                                                                          overlay =
                                                                          Overlay.of(context)
                                                                              .context
                                                                              .findRenderObject() as RenderBox;

                                                                      final RelativeRect
                                                                          position =
                                                                          RelativeRect
                                                                              .fromRect(
                                                                        Rect.fromLTWH(
                                                                          pos.dx,
                                                                          pos.dy,
                                                                          0,
                                                                          0,
                                                                        ),
                                                                        Offset.zero &
                                                                            overlay.size,
                                                                      );

                                                                      final value =
                                                                          await showMenu<
                                                                              String>(
                                                                        context:
                                                                            context,
                                                                        position:
                                                                            position,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8)),
                                                                        elevation:
                                                                            8,
                                                                        items: [
                                                                          if (invoiceList!.data.lists[index].gstinvoiceCreated ==
                                                                              "0")
                                                                            const PopupMenuItem(
                                                                              value: 'view',
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(Icons.auto_graph_outlined, color: Colors.purple),
                                                                                  SizedBox(width: 8),
                                                                                  Text("Create GST Invoice"),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          const PopupMenuItem(
                                                                            value:
                                                                                'delete',
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Icon(Icons.delete_outline, color: Colors.red),
                                                                                SizedBox(width: 8),
                                                                                Text("Delete"),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );

                                                                      if (value ==
                                                                          'view') {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => GstInvoice(widget.token, invoiceList!.data.lists[index].id.toString(), invoiceList!.data.lists[index].clientId.toString())),
                                                                        ).then(
                                                                            (_) {
                                                                          getData();
                                                                        });
                                                                      } else if (value ==
                                                                          'delete') {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext ctx) {
                                                                            return AlertDialog(
                                                                              scrollable: true,
                                                                              title: const Text('Please Confirm'),
                                                                              content: const Text('Are you sure you want to delete this invoice?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.of(ctx).pop(),
                                                                                  child: const Text('No'),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    Common.showProgressDialog(ctx, "Loading..");
                                                                                    DeleteInvoiceModel deleteInvoice = await HttpService.deleteInvoice(
                                                                                      widget.token,
                                                                                      invoiceList!.data.lists[index].id,
                                                                                    );
                                                                                    if (deleteInvoice.data == true) {
                                                                                      Common.toastMessaage(deleteInvoice.message, Colors.green);
                                                                                      if (context.mounted) {
                                                                                        Navigator.pop(ctx);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                      getData();
                                                                                    } else {
                                                                                      Common.toastMessaage(deleteInvoice.message, Colors.red);
                                                                                      if (context.mounted) Navigator.of(ctx).pop();
                                                                                    }
                                                                                  },
                                                                                  child: const Text('Yes'),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    },
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              6.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .more_horiz_outlined,
                                                                        color: Colors
                                                                            .black54,
                                                                        size:
                                                                            26,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
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
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                      invoiceList!.data.lists.isNotEmpty
                          ? Container(
                              height: 80.0,
                              color: Colors.grey.shade200,
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
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
                                          ': ${invoiceList!.data.totalInvoiceAmount}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
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
                                          ': ${invoiceList!.data.totalInvoicePaid}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
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
                                              'Total Balance Amount ',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Text(
                                          ': ${invoiceList!.data.balanceAmount}',
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            )
                          : const SizedBox(),
                      Positioned(
                        left: _floatingButtonPosition.dx,
                        top: _floatingButtonPosition.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _updateFloatingButtonPosition(
                              Offset(
                                _floatingButtonPosition.dx + details.delta.dx,
                                _floatingButtonPosition.dy + details.delta.dy,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              if (_showFloatingOptions) ...[
                                // Simple Invoice Option
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: FloatingActionButton(
                                    heroTag: "simple_invoice",
                                    onPressed: () {
                                      setState(() {
                                        _showFloatingOptions = false;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddInvoiceUpdated(
                                            widget.token,
                                            "",
                                            "",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt, size: 20),
                                        Text('Simple',
                                            style: TextStyle(fontSize: 8)),
                                      ],
                                    ),
                                    mini: true,
                                    backgroundColor: Colors.green,
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: FloatingActionButton(
                                    heroTag: "complex_invoice",
                                    onPressed: () {
                                      setState(() {
                                        _showFloatingOptions = false;
                                      });
                                      addInvoiceDialog(context);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.description, size: 20),
                                        Text('Complex',
                                            style: TextStyle(fontSize: 8)),
                                      ],
                                    ),
                                    mini: true,
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ],
                              FloatingActionButton(
                                heroTag: "main_floating_button",
                                onPressed: () {
                                  setState(() {
                                    _showFloatingOptions =
                                        !_showFloatingOptions;
                                  });
                                },
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: _showFloatingOptions
                                      ? Icon(Icons.close, color: Colors.white)
                                      : Icon(Icons.add, color: Colors.white),
                                ),
                                backgroundColor: _showFloatingOptions
                                    ? Colors.red
                                    : Color(0xFF2a86c9),
                              ),
                            ],
                          ),
                        ),
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

  Future<Object?> addInvoiceDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Customer  Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: search,
                                        autocorrect: false,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        autofocus: true,
                                        onChanged: (value) {
                                          setState(() {
                                            filteredCustomers = customers
                                                .where((item) => item.name
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      child: ListView.builder(
                                        itemCount: filteredCustomers.length,
                                        physics: const ScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              // onTap: () {
                                              //   customerName =
                                              //       filteredCustomers[index]
                                              //           .name;
                                              //   customerId =
                                              //       filteredCustomers[index].id;
                                              //   search.clear();
                                              //   filteredCustomers
                                              //       .addAll(customers);
                                              //   setState(() {});
                                              //   if (context.mounted) {
                                              //     Navigator.pop(context);
                                              //   }
                                              // },
                                              onTap: () {
                                                customerName =
                                                    filteredCustomers[index]
                                                        .name;
                                                customerId =
                                                    filteredCustomers[index].id;
                                                search.clear();
                                                filteredCustomers =
                                                    List.from(customers);
                                                setState(() {});
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              title: Text(
                                                  filteredCustomers[index]
                                                      .name));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      // onPressed: () {
                                      //   search.clear();
                                      //   filteredCustomers.addAll(customers);
                                      //   if (context.mounted) {
                                      //     Navigator.pop(context);
                                      //   }
                                      // },
                                      onPressed: () {
                                        search.clear();
                                        filteredCustomers =
                                            List.from(customers);
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
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    customerName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (customerId == '') {
                          Common.toastMessaage('Choose Client', Colors.red);
                        } else {
                          search.clear();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddInvoice(widget.token, customerId, "")),
                          ).then((_) {
                            getData();
                          });
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 25, right: 25),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

  Future<dynamic> filtrationSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Filtration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("From Date"),
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
                                    fDate = DateFormat('dd-MM-yyyy')
                                        .format(selctedDatetimetemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
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
                                            fDate,
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
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("To Date"),
                                GestureDetector(
                                  onTap: () async {
                                    final toDateSelectTemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    tDate = DateFormat('dd-MM-yyyy')
                                        .format(toDateSelectTemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
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
                                            tDate,
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
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Collected by"),
                            GestureDetector(
                              onTap: () async {
                                await staffDialog(context, 'collected');
                                (context as Element).markNeedsBuild();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          collectedByNames.isNotEmpty
                                              ? collectedByNames.join(', ')
                                              : "Select staff",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Created by"),
                            GestureDetector(
                              onTap: () async {
                                await staffDialog(context, 'created');
                                (context as Element).markNeedsBuild();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          createdByNames.isNotEmpty
                                              ? createdByNames.join(', ')
                                              : "Select staff",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Customer"),
                            GestureDetector(
                              onTap: () {
                                customerDialog(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
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
                                            customerName,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ],
                                  ),
                                )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Types"),
                            GestureDetector(
                              onTap: () {
                                typesDialog(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
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
                                            typeName,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ],
                                  ),
                                )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            isSearch = true;
                            Common.showProgressDialog(context, "Searching..");
                            getData();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xff2590cf)),
                            child: const Center(
                              child: Text("Filter",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  // Future<dynamic> staffDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: TextField(
  //                   controller: search,
  //                   autocorrect: false,
  //                   keyboardType: TextInputType.visiblePassword,
  //                   autofocus: true,
  //                   onChanged: (value) {
  //                     setState(() {
  //                       filteredStaffs = staffs
  //                           .where((item) => item.accountName
  //                               .toLowerCase()
  //                               .contains(value.toLowerCase()))
  //                           .toList();
  //                     });
  //                   },
  //                   decoration: const InputDecoration(
  //                     contentPadding: EdgeInsets.all(8),
  //                     hintText: 'Search',
  //                     prefixIcon: Icon(Icons.search),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: MediaQuery.of(context).size.height * .3,
  //                 width: MediaQuery.of(context).size.width * .8,
  //                 child: ListView.builder(
  //                   itemCount: filteredStaffs.length,
  //                   physics: const ScrollPhysics(),
  //                   shrinkWrap: true,
  //                   itemBuilder: (context, index) {
  //                     return ListTile(
  //                         onTap: () {
  //                           staffName = filteredStaffs[index].accountName;
  //                           staffId = filteredStaffs[index].accountId;
  //                           search.clear();
  //                           filteredStaffs.clear();
  //                           filteredStaffs.addAll(staffs);
  //                           setState(() {});
  //                           if (context.mounted) {
  //                             Navigator.pop(context);
  //                           }
  //                         },
  //                         title: Text(filteredStaffs[index].accountName));
  //                   },
  //                 ),
  //               )
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   search.clear();
  //                   filteredStaffs.clear();
  //                   filteredStaffs.addAll(staffs);
  //                   if (context.mounted) {
  //                     Navigator.pop(context);
  //                   }
  //                 },
  //                 child: const Text("Close")),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  Future<dynamic> staffDialog(BuildContext context, String type) {
    List<String> tempSelectedIds = [];
    List<String> tempSelectedNames = [];

    // Initialize selection only once, outside setState
    if (type == 'collected') {
      tempSelectedIds = List.from(collectedByIds);
      tempSelectedNames = List.from(collectedByNames);
    } else if (type == 'created') {
      tempSelectedIds = List.from(createdByIds);
      tempSelectedNames = List.from(createdByNames);
    }

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Staff"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: search,
                    onChanged: (value) {
                      setState(() {
                        filteredStaffs = staffs
                            .where((item) => item.accountName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search staff',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredStaffs.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaffs[index];
                      final selected =
                          tempSelectedIds.contains(staff.accountId);

                      return CheckboxListTile(
                        title: Text(staff.accountName),
                        value: selected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!tempSelectedIds.contains(staff.accountId)) {
                                tempSelectedIds.add(staff.accountId);
                                tempSelectedNames.add(staff.accountName);
                              }
                            } else {
                              tempSelectedIds.remove(staff.accountId);
                              tempSelectedNames.remove(staff.accountName);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (type == 'collected') {
                    collectedByIds = List.from(tempSelectedIds);
                    collectedByNames = List.from(tempSelectedNames);
                  } else {
                    createdByIds = List.from(tempSelectedIds);
                    createdByNames = List.from(tempSelectedNames);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> typesDialog(BuildContext context) {
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
                        filteredTypes = types
                            .where((item) => item.typeName
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
                    itemCount: filteredTypes.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            typeName = filteredTypes[index].typeName;
                            typeId = filteredTypes[index].id.toString();
                            search.clear();
                            filteredTypes.clear();
                            filteredTypes.addAll(types);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredTypes[index].typeName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    search.clear();
                    filteredTypes.clear();
                    filteredTypes.addAll(types);
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

  Future<dynamic> customerDialog(BuildContext context) {
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
                        filteredCustomers = customers
                            .where((item) => item.name
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
                    itemCount: filteredCustomers.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            customerName = filteredCustomers[index].name;
                            customerId = filteredCustomers[index].id;
                            search.clear();
                            filteredCustomers.clear();
                            filteredCustomers.addAll(customers);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredCustomers[index].name));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    search.clear();
                    filteredCustomers.clear();
                    filteredCustomers.addAll(customers);
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
}
