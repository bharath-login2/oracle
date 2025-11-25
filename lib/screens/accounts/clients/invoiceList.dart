// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart';
import 'package:login2/screens/accounts/clients/gstInvoice.dart';
import 'package:login2/screens/accounts/clients/print_invoice_view.dart';
import 'package:login2/screens/accounts/clients/receiptByInvoice.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_quick_renewal.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/deleteInvoiceModel.dart';
import '../../../models/clients/invoiceListModel.dart';
import '../../../service/service.dart';
import 'addInvoice.dart';
import 'addReceipt.dart';
import 'clientDetails.dart';
import 'editInvoice.dart';

class InvoiceList extends StatefulWidget {
  String token;

  InvoiceList(this.token, {super.key});

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
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
  String statusName = "";
  TextEditingController search = TextEditingController();
  bool isSearch = false;
  Offset? _tapPosition;
  List<String> collectedByNames = [];
  List<String> collectedByIds = [];
  List<String> createdByNames = [];
  List<String> createdByIds = [];

  List<String> selectedStaffIds = [];
  List<String> selectedStaffNames = [];
  List<String> selectedCustomerIds = [];
  List<String> selectedCustomerNames = [];
  List<String> selectedTypeIds = [];
  List<String> selectedTypeNames = [];
  List<String> selectedStatuses = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  bool _isStatusSelected(String status) {
    return selectedStatuses.contains(status);
  }

  void _addStatus(String status) {
    if (!selectedStatuses.contains(status)) {
      selectedStatuses.add(status);
    }
  }

  void _removeStatus(String status) {
    selectedStatuses.remove(status);
  }

  void _clearAllStatuses() {
    selectedStatuses.clear();
  }

  List<String> _getSelectedStatuses() {
    return List.from(selectedStatuses);
  }

  void clearAllFilters() {
    fDate = "From Date";
    tDate = "To Date";
    typeId = "";
    typeName = "Choose Type";
    staffId = "";
    staffName = "Choose Staff";
    customerId = "";
    customerName = "Choose Customer";
    statusName = "";
    createdByIds.clear();
    createdByNames.clear();
    selectedCustomerIds.clear();
    selectedCustomerNames.clear();
    selectedTypeIds.clear();
    selectedTypeNames.clear();
    selectedStatuses.clear();
    filteredCustomers = List.from(customers);
    filteredStaffs = List.from(staffs);
    filteredTypes = List.from(types);
  }

  // getData() async {
  //   final connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     setState(() {
  //       result = true;
  //     });
  //   } else {
  //     setState(() {
  //       result = false;
  //     });
  //   }
  //   String collectedByStaffIds = collectedByIds.join(',');
  //   String createdByStaffIds = createdByIds.join(',');
  //   invoiceList = await HttpService.invoiceList(
  //       widget.token,
  //       fDate == "From Date" ? "" : fDate.toString(),
  //       tDate == "To Date" ? "" : tDate.toString(),
  //       customerId,
  //       staffId,
  //       collectedByStaffIds,
  //       createdByStaffIds,
  //       statusName,
  //       typeId);
  //   if (invoiceList != null) {
  //     searchData = await HttpService.getInvoiceSearch(widget.token);
  //     customers = searchData!.data.customers;
  //     filteredCustomers.addAll(customers);
  //     staffs = searchData!.data.staff;
  //     filteredStaffs.addAll(staffs);
  //     types = searchData!.data.types;
  //     filteredTypes.addAll(types);
  //     if (isSearch == true) {
  //       isSearch = false;
  //       if (mounted) {
  //         Navigator.pop(context);
  //       }
  //     }
  //     setState(() {});
  //   }
  // }

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

    String collectedByStaffIds = collectedByIds.join(',');
    String createdByStaffIds = createdByIds.join(',');
    String customerFilter = selectedCustomerIds.join(',');
    String typeFilter = selectedTypeIds.join(',');
    String statusFilter = selectedStatuses.join(',');

    print('API Parameters:');
    print('From Date: ${fDate == "From Date" ? "" : fDate}');
    print('To Date: ${tDate == "To Date" ? "" : tDate}');
    print('Customers: $customerFilter');
    print('Collected By: $collectedByStaffIds');
    print('Created By: $createdByStaffIds');
    print('Status: $statusFilter');
    print('Type: $typeFilter');

    invoiceList = await HttpService.invoiceList(
        widget.token,
        fDate == "From Date" ? "" : fDate.toString(),
        tDate == "To Date" ? "" : tDate.toString(),
        customerFilter,
        "",
        collectedByStaffIds,
        createdByStaffIds,
        statusFilter,
        typeFilter);

    if (invoiceList != null) {
      searchData = await HttpService.getInvoiceSearch(widget.token);
      customers = searchData!.data.customers;
      filteredCustomers = List.from(customers);
      staffs = searchData!.data.staff;
      filteredStaffs = List.from(staffs);
      types = searchData!.data.types;
      filteredTypes = List.from(types);
      if (isSearch == true) {
        isSearch = false;
        if (mounted) {
          Navigator.pop(context);
        }
      }
      setState(() {});
    }
  }

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
                            'Invoice List',
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
                              addInvoiceDialog(context);
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
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ClientDetails(
                                                                        widget
                                                                            .token,
                                                                        invoiceList!
                                                                            .data
                                                                            .lists[index]
                                                                            .clientId
                                                                            .toString())),
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
                                                        invoiceList!
                                                                    .data
                                                                    .lists[
                                                                        index]
                                                                    .products
                                                                    .length !=
                                                                1
                                                            ? "Products : ${invoiceList!.data.lists[index].products[0].productName} + ${invoiceList!.data.lists[index].products.length - 1} more..."
                                                            : "Products : ${invoiceList!.data.lists[index].products[0].productName}",
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
                                                                          if (invoiceList!.data.lists[index].gstinvoiceCreated == "0" &&
                                                                              invoiceList!.data.lists[index].status != "Unpaid")
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
                          : const SizedBox()
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
                    )
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        String selectedTab = "Created By";
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildFilterTab(
                                icon: Icons.person_outline,
                                title: "Created By",
                                selected: selectedTab == "Created By",
                                onTap: () {
                                  setState(() {
                                    selectedTab = "Created By";
                                  });
                                },
                              ),
                              _buildFilterTab(
                                icon: Icons.date_range,
                                title: "Date Range",
                                selected: selectedTab == "Date Range",
                                onTap: () {
                                  setState(() {
                                    selectedTab = "Date Range";
                                  });
                                },
                              ),
                              _buildFilterTab(
                                icon: Icons.people_alt_outlined,
                                title: "Customer",
                                selected: selectedTab == "Customer",
                                onTap: () {
                                  setState(() {
                                    selectedTab = "Customer";
                                  });
                                },
                              ),
                              _buildFilterTab(
                                icon: Icons.list_alt,
                                title: "Type",
                                selected: selectedTab == "Type",
                                onTap: () {
                                  setState(() {
                                    selectedTab = "Type";
                                  });
                                },
                              ),
                              _buildFilterTab(
                                icon: Icons.verified_outlined,
                                title: "Status",
                                selected: selectedTab == "Status",
                                onTap: () {
                                  setState(() {
                                    selectedTab = "Status";
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRightFilterSection(
                              selectedTab, setState, context),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      isSearch = true;
                      Common.showProgressDialog(context, "Applying filters...");
                      getData();
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 49, 133, 243),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Apply Filters",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 Build Right Filter Section based on selected tab
  Widget _buildRightFilterSection(
      String selectedTab, StateSetter setState, BuildContext context) {
    switch (selectedTab) {
      case "Created By":
        return _buildCreatedBySection(setState, context);
      case "Date Range":
        return _buildDateRangeSection(setState, context);
      case "Customer":
        return _buildCustomerSection(setState, context);
      case "Type":
        return _buildTypeSection(setState, context);
      case "Status":
        return _buildStatusSection(setState, context);
      default:
        return _buildCreatedBySection(setState, context);
    }
  }

  /// 🔹 Created By Section
  Widget _buildCreatedBySection(StateSetter setState, BuildContext context) {
    return ListView(
      children: [
        const Text(
          "Created By",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search staff...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              filteredStaffs = staffs
                  .where((item) => item.accountName
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                  .toList();
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: filteredStaffs.isEmpty
              ? const Center(
                  child: Text(
                    'No staff members found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredStaffs.length,
                  itemBuilder: (context, index) {
                    final staff = filteredStaffs[index];
                    final isSelected = createdByIds.contains(staff.accountId);

                    return CheckboxListTile(
                      title: Text(
                        staff.accountName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!createdByIds.contains(staff.accountId)) {
                              createdByIds.add(staff.accountId);
                              createdByNames.add(staff.accountName);
                            }
                          } else {
                            createdByIds.remove(staff.accountId);
                            createdByNames.remove(staff.accountName);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
        ),
        if (createdByNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Selected Staff:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: createdByNames.map((name) {
              return Chip(
                label: Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  final index = createdByNames.indexOf(name);
                  if (index != -1) {
                    createdByNames.removeAt(index);
                    createdByIds.removeAt(index);
                    setState(() {});
                  }
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              createdByIds.clear();
              createdByNames.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Clear All",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateRangeSection(StateSetter setState, BuildContext context) {
    return ListView(
      children: [
        const Text(
          "Date Range",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "From Date",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _buildDatePickerTile(
              context: context,
              title: "Select from date",
              date: fDate,
              onSelect: (date) {
                fDate = date;
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "To Date",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _buildDatePickerTile(
              context: context,
              title: "Select to date",
              date: tDate,
              onSelect: (date) {
                tDate = date;
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (fDate != "From Date" || tDate != "To Date")
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Selected: ${fDate != "From Date" ? fDate : "Any"} - ${tDate != "To Date" ? tDate : "Any"}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (fDate != "From Date" || tDate != "To Date") ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              fDate = "From Date";
              tDate = "To Date";
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Clear Dates",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerSection(StateSetter setState, BuildContext context) {
    // Reset filtered list only if needed
    if (filteredCustomers.isEmpty ||
        filteredCustomers.length != customers.length) {
      filteredCustomers = List.from(customers);
    }

    return ListView(
      children: [
        const Text(
          "Customer",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search customers...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                filteredCustomers = List.from(customers);
              } else {
                filteredCustomers = customers
                    .where((item) =>
                        item.name.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: filteredCustomers.isEmpty
              ? const Center(
                  child: Text(
                    'No customers found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    final isSelected =
                        selectedCustomerIds.contains(customer.id);

                    return CheckboxListTile(
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedCustomerIds.contains(customer.id)) {
                              selectedCustomerIds.add(customer.id);
                              selectedCustomerNames.add(customer.name);
                            }
                          } else {
                            selectedCustomerIds.remove(customer.id);
                            selectedCustomerNames.remove(customer.name);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
        ),

        // Selected customers chips
        if (selectedCustomerNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Selected Customers:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedCustomerNames.map((name) {
              return Chip(
                label: Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  final index = selectedCustomerNames.indexOf(name);
                  if (index != -1) {
                    selectedCustomerNames.removeAt(index);
                    selectedCustomerIds.removeAt(index);
                    setState(() {});
                  }
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),

          // Clear all button
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              selectedCustomerIds.clear();
              selectedCustomerNames.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Clear All",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeSection(StateSetter setState, BuildContext context) {
    if (filteredTypes.isEmpty || filteredTypes.length != types.length) {
      filteredTypes = List.from(types);
    }

    return ListView(
      children: [
        const Text(
          "Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search types...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                filteredTypes = List.from(types);
              } else {
                filteredTypes = types
                    .where((item) => item.typeName
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: filteredTypes.isEmpty
              ? const Center(
                  child: Text(
                    'No types found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredTypes.length,
                  itemBuilder: (context, index) {
                    final type = filteredTypes[index];
                    final isSelected =
                        selectedTypeIds.contains(type.id.toString());

                    return CheckboxListTile(
                      title: Text(
                        type.typeName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedTypeIds.contains(type.id.toString())) {
                              selectedTypeIds.add(type.id.toString());
                              selectedTypeNames.add(type.typeName);
                            }
                          } else {
                            selectedTypeIds.remove(type.id.toString());
                            selectedTypeNames.remove(type.typeName);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
        ),

        // Selected types chips
        if (selectedTypeNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Selected Types:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedTypeNames.map((name) {
              return Chip(
                label: Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  final index = selectedTypeNames.indexOf(name);
                  if (index != -1) {
                    selectedTypeNames.removeAt(index);
                    selectedTypeIds.removeAt(index);
                    setState(() {});
                  }
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),

          // Clear all button
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              selectedTypeIds.clear();
              selectedTypeNames.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Clear All",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection(StateSetter setState, BuildContext context) {
    return ListView(
      children: [
        const Text(
          "Status",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search status...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: [
              _buildStatusCheckbox(
                "Paid",
                "",
                setState,
              ),
              _buildStatusCheckbox(
                "Unpaid",
                "",
                setState,
              ),
              _buildStatusCheckbox(
                "Partial Paid",
                "",
                setState,
              ),
            ],
          ),
        ),
        if (_getSelectedStatuses().isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Selected Status:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getSelectedStatuses().map((status) {
              return Chip(
                label: Text(
                  status,
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  _removeStatus(status);
                  setState(() {});
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              _clearAllStatuses();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Clear All",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCheckbox(
      String status, String description, StateSetter setState) {
    final isSelected = _isStatusSelected(status);

    return CheckboxListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      value: isSelected,
      onChanged: (bool? value) {
        if (value == true) {
          _addStatus(status);
        } else {
          _removeStatus(status);
        }
        setState(() {});
      },
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildDatePickerTile({
    required BuildContext context,
    required String title,
    required String date,
    required Function(String) onSelect,
  }) {
    final bool hasDate =
        date.isNotEmpty && date != "From Date" && date != "To Date";

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onSelect(DateFormat('dd-MM-yyyy').format(pickedDate));
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: hasDate ? const Color(0xff2590cf) : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasDate ? const Color(0xffe7f3ff) : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasDate ? date : title,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      hasDate ? const Color(0xff2590cf) : Colors.grey.shade600,
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.calendar_month,
              color: hasDate ? const Color(0xff2590cf) : Colors.grey.shade500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffe7f3ff) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: const Color(0xff2590cf), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xff2590cf) : Colors.grey,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xff2590cf) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<dynamic> filtrationSheet(BuildContext context) {
  //   return showModalBottomSheet(
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return Container(
  //               height: MediaQuery.of(context).size.height * 0.6,
  //               width: double.maxFinite,
  //               clipBehavior: Clip.antiAlias,
  //               padding: const EdgeInsets.all(16),
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                 ),
  //               ),
  //               child: Material(
  //                 color: Colors.white,
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     children: [
  //                       const SizedBox(height: 20),
  //                       const Text(
  //                         'Filtration',
  //                         style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 20),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               const Text("From Date"),
  //                               GestureDetector(
  //                                 onTap: () async {
  //                                   final selctedDatetimetemp =
  //                                       await showDatePicker(
  //                                     context: context,
  //                                     initialDate: DateTime(DateTime.now().year,
  //                                         DateTime.now().month, 1),
  //                                     firstDate: DateTime(2000),
  //                                     lastDate: DateTime.now(),
  //                                   );
  //                                   fDate = DateFormat('dd-MM-yyyy')
  //                                       .format(selctedDatetimetemp!);
  //                                   setState(() {});
  //                                 },
  //                                 child: Container(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.45,
  //                                   height: 45,
  //                                   decoration: BoxDecoration(
  //                                       border: Border.all(),
  //                                       borderRadius: BorderRadius.circular(5),
  //                                       color: Colors.white),
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Padding(
  //                                         padding:
  //                                             const EdgeInsets.only(left: 10),
  //                                         child: Text(
  //                                           fDate,
  //                                           style: const TextStyle(
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.w400,
  //                                             color: Colors.black,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       Container(
  //                                         width: 40,
  //                                         height: 40,
  //                                         decoration: BoxDecoration(
  //                                           borderRadius:
  //                                               BorderRadius.circular(2),
  //                                           color: Colors.white,
  //                                         ),
  //                                         child: const Icon(
  //                                           Icons.calendar_month,
  //                                           color: Colors.grey,
  //                                         ),
  //                                       )
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               const Text("To Date"),
  //                               GestureDetector(
  //                                 onTap: () async {
  //                                   final toDateSelectTemp =
  //                                       await showDatePicker(
  //                                     context: context,
  //                                     initialDate: DateTime.now(),
  //                                     firstDate: DateTime(2000),
  //                                     lastDate: DateTime(2100),
  //                                   );
  //                                   tDate = DateFormat('dd-MM-yyyy')
  //                                       .format(toDateSelectTemp!);
  //                                   setState(() {});
  //                                 },
  //                                 child: Container(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.45,
  //                                   height: 45,
  //                                   decoration: BoxDecoration(
  //                                     border: Border.all(),
  //                                     borderRadius: BorderRadius.circular(5),
  //                                     color: Colors.white,
  //                                   ),
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Padding(
  //                                         padding:
  //                                             const EdgeInsets.only(left: 10),
  //                                         child: Text(
  //                                           tDate,
  //                                         ),
  //                                       ),
  //                                       Container(
  //                                         width: 40,
  //                                         height: 40,
  //                                         decoration: BoxDecoration(
  //                                           borderRadius:
  //                                               BorderRadius.circular(5),
  //                                           color: Colors.white,
  //                                         ),
  //                                         child: const Icon(
  //                                           Icons.calendar_month,
  //                                           color: Colors.grey,
  //                                         ),
  //                                       )
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text("Collected by"),
  //                           GestureDetector(
  //                             onTap: () async {
  //                               await staffDialog(context, 'collected');
  //                               (context as Element).markNeedsBuild();
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 border: Border.all(color: Colors.black),
  //                                 borderRadius: BorderRadius.circular(4),
  //                               ),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 16.0, vertical: 12.0),
  //                                 child: Row(
  //                                   children: [
  //                                     Expanded(
  //                                       child: Text(
  //                                         collectedByNames.isNotEmpty
  //                                             ? collectedByNames.join(', ')
  //                                             : "Select staff",
  //                                         overflow: TextOverflow.ellipsis,
  //                                         maxLines: 2,
  //                                       ),
  //                                     ),
  //                                     const Icon(Icons.arrow_drop_down),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text("Created by"),
  //                           GestureDetector(
  //                             onTap: () async {
  //                               await staffDialog(context, 'created');
  //                               (context as Element).markNeedsBuild();
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 border: Border.all(color: Colors.black),
  //                                 borderRadius: BorderRadius.circular(4),
  //                               ),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 16.0, vertical: 12.0),
  //                                 child: Row(
  //                                   children: [
  //                                     Expanded(
  //                                       child: Text(
  //                                         createdByNames.isNotEmpty
  //                                             ? createdByNames.join(', ')
  //                                             : "Select staff",
  //                                         overflow: TextOverflow.ellipsis,
  //                                         maxLines: 2,
  //                                       ),
  //                                     ),
  //                                     const Icon(Icons.arrow_drop_down),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text("Customer"),
  //                           GestureDetector(
  //                             onTap: () {
  //                               customerDialog(context);
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 border: Border.all(color: Colors.black),
  //                                 borderRadius: BorderRadius.circular(4),
  //                               ),
  //                               child: Center(
  //                                   child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 16.0, vertical: 12.0),
  //                                 child: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     SizedBox(
  //                                         width: MediaQuery.of(context)
  //                                                 .size
  //                                                 .width *
  //                                             0.35,
  //                                         child: Text(
  //                                           customerName,
  //                                           overflow: TextOverflow.ellipsis,
  //                                         )),
  //                                   ],
  //                                 ),
  //                               )),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text("Types"),
  //                           GestureDetector(
  //                             onTap: () {
  //                               typesDialog(context);
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 border: Border.all(color: Colors.black),
  //                                 borderRadius: BorderRadius.circular(4),
  //                               ),
  //                               child: Center(
  //                                   child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 16.0, vertical: 12.0),
  //                                 child: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     SizedBox(
  //                                         width: MediaQuery.of(context)
  //                                                 .size
  //                                                 .width *
  //                                             0.35,
  //                                         child: Text(
  //                                           typeName,
  //                                           overflow: TextOverflow.ellipsis,
  //                                         )),
  //                                   ],
  //                                 ),
  //                               )),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text("Status"),
  //                           const SizedBox(height: 6),
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               border: Border.all(color: Colors.black),
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 16.0, vertical: 4.0),
  //                             child: DropdownButtonHideUnderline(
  //                               child: DropdownButton<String>(
  //                                 value: (statusName == 'Paid' ||
  //                                         statusName == 'Unpaid' ||
  //                                         statusName == 'Partial Paid')
  //                                     ? statusName
  //                                     : null,
  //                                 hint: const Text("Select Status"),
  //                                 isExpanded: true,
  //                                 items: const [
  //                                   DropdownMenuItem(
  //                                       value: 'Paid', child: Text('Paid')),
  //                                   DropdownMenuItem(
  //                                       value: 'Unpaid', child: Text('Unpaid')),
  //                                   DropdownMenuItem(
  //                                       value: 'Partial Paid',
  //                                       child: Text('Partial Paid')),
  //                                 ],
  //                                 onChanged: (value) {
  //                                   setState(() {
  //                                     statusName = value!;
  //                                   });
  //                                 },
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(
  //                         height: 20,
  //                       ),
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                           isSearch = true;
  //                           Common.showProgressDialog(context, "Searching..");
  //                           getData();
  //                         },
  //                         child: Container(
  //                           height: 40,
  //                           decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(4),
  //                               color: const Color(0xff2590cf)),
  //                           child: const Center(
  //                             child: Text("Filter",
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.w600,
  //                                 )),
  //                           ),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       });
  // }

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
    TextEditingController search = TextEditingController();
    if (type == 'collected') {
      tempSelectedIds = List.from(collectedByIds);
      tempSelectedNames = List.from(collectedByNames);
    } else if (type == 'created') {
      tempSelectedIds = List.from(createdByIds);
      tempSelectedNames = List.from(createdByNames);
    }
    List<Staff> filteredStaffs = List.from(staffs);
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                                if (!tempSelectedIds
                                    .contains(staff.accountId)) {
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
          },
        );
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
