// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/screens/accounts/clients/viewInvoice.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/customerListModel.dart';
import '../../../models/clients/deleteInvoiceModel.dart';
import '../../../models/clients/pendingInvoiceListModel.dart';
import '../../../service/service.dart';
import 'addInvoice.dart';
import 'addReceipt.dart';
import 'clientDetails.dart';
import 'editInvoice.dart';

class PendingInvoice extends StatefulWidget {
  String token;
  PendingInvoice(this.token, {super.key});
  @override
  State<PendingInvoice> createState() => _PendingInvoiceState();
}

class _PendingInvoiceState extends State<PendingInvoice>
    with AutomaticKeepAliveClientMixin {
  dynamic client;
  PendingInvoiceListModel? invoiceResponse;
  CustomerListModel? customerList;
  bool result = true;
  List<Customer> items = [];
  List<Customer> filteredItems = [];
  List<ListElement> invoices = [];
  List<ListElement> filteredInvoices = [];
  String customerId = "";
  String customerName = "Customer";
  TextEditingController search = TextEditingController();
  TextEditingController invSearch = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;
  bool isSearch = false;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      _scrollPosition = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollPosition);
      }
    });
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

    invoiceResponse = await HttpService.pendingInvoiceList(widget.token);
    if (invoiceResponse != null) {
      invoices = invoiceResponse!.data.lists;
      filteredInvoices.addAll(invoices);
      customerList = await HttpService.customerList(widget.token);
      items = customerList!.data!;
      // filteredItems.addAll(items);
      filteredItems = List.from(items);

      if (isSearch == true) {
        isSearch = false;
        if (mounted) {
          Navigator.pop(context);
        }
      }
      setState(() {});
    }
  }

  filterInvoices(String value) {
    setState(() {
      filteredInvoices = invoices
          .where((item) =>
              item.customerName.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _restoreScrollPosition();
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
                            'Pending Invoice List',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () async {
                          showGeneralDialog(
                            barrierLabel: "showGeneralDialog",
                            barrierDismissible: true,
                            barrierColor: Colors.black.withOpacity(0.6),
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
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Customer  Details',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
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
                                                      builder:
                                                          (context, setState) {
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
                                                              controller:
                                                                  search,
                                                              autocorrect:
                                                                  false,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .visiblePassword,
                                                              autofocus: true,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  filteredItems = items
                                                                      .where((item) => item
                                                                          .name!
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              value.toLowerCase()))
                                                                      .toList();
                                                                });
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                hintText:
                                                                    'Search',
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .search),
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
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  filteredItems
                                                                      .length,
                                                              physics:
                                                                  const ScrollPhysics(),
                                                              shrinkWrap: true,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
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
                                                                          filteredItems[index]
                                                                              .name!;
                                                                      customerId =
                                                                          filteredItems[index]
                                                                              .id!;
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
                                                                    title: Text(
                                                                        filteredItems[index]
                                                                            .name!));
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
                                                              filteredItems
                                                                  .addAll(
                                                                      items);
                                                              if (context
                                                                  .mounted) {
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
                                                  1,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Center(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 12.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        child: Text(
                                                          customerName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                                Common.toastMessaage(
                                                    'Choose Client',
                                                    Colors.red);
                                              } else {
                                                search.clear();
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddInvoice(
                                                              widget.token,
                                                              customerId,
                                                              "")),
                                                ).then((_) {
                                                  getData();
                                                });
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 10,
                                                      left: 25,
                                                      right: 25),
                                                  child: Text(
                                                    'Submit',
                                                    style: TextStyle(
                                                        color: Colors.white),
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
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: invoiceResponse != null && customerList != null
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16),
                              child: TextField(
                                controller: invSearch,
                                autocorrect: false,
                                keyboardType: TextInputType.visiblePassword,
                                // autofocus: true,
                                onChanged: (value) {
                                  filterInvoices(value);
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  hintText: 'Search',
                                  prefixIcon: const Icon(Icons.search),
                                  fillColor: ColorConstant.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            filteredInvoices.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12, bottom: 80),
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: filteredInvoices.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(1, 1),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white),
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
                                                                      filteredInvoices[
                                                                              index]
                                                                          .clientId
                                                                          .toString())),
                                                            ).then((_) {
                                                              getData();
                                                            });
                                                          },
                                                          child: Text(
                                                              filteredInvoices[
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
                                                            color: filteredInvoices[
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
                                                                    bottom: 6),
                                                            child: Text(
                                                                filteredInvoices[
                                                                        index]
                                                                    .status
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: filteredInvoices[
                                                                                  index]
                                                                              .status
                                                                              .toString() ==
                                                                          'Paid'
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                  fontSize: 14,
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
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.41,
                                                      child: Text(
                                                        "Invoice No : ${filteredInvoices[index].invoiceNumber}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  if (filteredInvoices[index]
                                                      .products
                                                      .isNotEmpty)
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      child: Text(
                                                        filteredInvoices[index]
                                                                    .products
                                                                    .length !=
                                                                1
                                                            ? "Products : ${filteredInvoices[index].products[0].productName} + ${filteredInvoices[index].products.length - 1} more..."
                                                            : "Products : ${filteredInvoices[index].products[0].productName}",
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
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.41,
                                                      child: Text(
                                                        "Total Amount : ₹ ${filteredInvoices[index].totalAmount}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.41,
                                                      child: Text(
                                                        "Paid Amount : ₹ ${filteredInvoices[index].totalPaid}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.41,
                                                      child: Text(
                                                        "Balance Amount : ₹ ${filteredInvoices[index].balance}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14,
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
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        child: Text(
                                                          "Pay Mode : ${filteredInvoices[index].paymentMode}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                                      filteredInvoices[
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
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ViewInvoice(
                                                                        widget
                                                                            .token,
                                                                        filteredInvoices[index]
                                                                            .id
                                                                            .toString(),
                                                                        filteredInvoices[index]
                                                                            .clientId
                                                                            .toString(),
                                                                        filteredInvoices[index]
                                                                            .invoiceNumber
                                                                            .toString())),
                                                              ).then((_) {
                                                                getData();
                                                              });
                                                            },
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
                                                                  decoration: const BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image:
                                                                              AssetImage('assets/icons/pdf.png'))),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          filteredInvoices[
                                                                          index]
                                                                      .isPaid ==
                                                                  false
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ReceiptAdd(
                                                                              widget.token,
                                                                              filteredInvoices[index].clientId.toString(),
                                                                              filteredInvoices[index].id.toString())),
                                                                    ).then((_) {
                                                                      getData();
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                2),
                                                                        color: const Color(
                                                                            0xffe9d9fd)),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child: Icon(
                                                                          Icons
                                                                              .currency_rupee,
                                                                          color:
                                                                              Color(0xff9747FF)),
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
                                                                MaterialPageRoute(
                                                                    builder: (context) => EditInvoice(
                                                                        widget
                                                                            .token,
                                                                        filteredInvoices[index]
                                                                            .id
                                                                            .toString(),
                                                                        filteredInvoices[index]
                                                                            .clientId
                                                                            .toString())),
                                                              ).then((_) {
                                                                getData();
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2),
                                                                  color: const Color(
                                                                      0xffaedcf4)),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Icon(
                                                                    Icons
                                                                        .mode_edit_outlined,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
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
                                                                      scrollable:
                                                                          true,
                                                                      title: const Text(
                                                                          'Please Confirm'),
                                                                      content:
                                                                          const Text(
                                                                              'Are you sure to Delete?'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text('No')),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              Common.showProgressDialog(context, "Loading..");
                                                                              DeleteInvoiceModel deleteInvoice = await HttpService.deleteInvoice(widget.token, filteredInvoices[index].id);
                                                                              if (deleteInvoice.data == true) {
                                                                                Common.toastMessaage(deleteInvoice.message, Colors.green);
                                                                                if (context.mounted) {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.pop(context);
                                                                                }
                                                                                getData();
                                                                              } else {
                                                                                Common.toastMessaage(deleteInvoice.message, Colors.red);
                                                                                if (context.mounted) {
                                                                                  Navigator.of(context).pop();
                                                                                }
                                                                              }
                                                                            },
                                                                            child:
                                                                                const Text('Yes')),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2),
                                                                  color: const Color(
                                                                      0xfffcbcbc)),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color: Colors
                                                                        .red),
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
                                        );
                                      },
                                    ),
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
                          ],
                        ),
                      ),
                      filteredInvoices.isNotEmpty
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
                                          ': ${invoiceResponse!.data.totalInvoiceAmount}',
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
                                          ': ${invoiceResponse!.data.totalInvoicePaid}',
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
                                          ': ${invoiceResponse!.data.balanceAmount}',
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
}
