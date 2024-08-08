// ignore_for_file: must_be_immutable

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/addLeadFollowupModel.dart';
import 'package:login2/service/service.dart';

import '../../models/renewal/renewal_details.dart';

class PostConfirmedFollowup extends StatefulWidget {
  String callMasterId;
  bool renewalPermission;
  bool installmentPermission;
  PostConfirmedFollowup(
      {super.key,
      required this.callMasterId,
      required this.renewalPermission,
      required this.installmentPermission});

  @override
  State<PostConfirmedFollowup> createState() => _PostConfirmedFollowupState();
}

class _PostConfirmedFollowupState extends State<PostConfirmedFollowup> {
  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController search = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController invoiceRemarks = TextEditingController();
  TextEditingController renewalRemarks = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  RenewalDetailslModel? detailsResponse;
  Color paidColor = Colors.black;
  String templateId = "";
  List<Template> filteredTemplates = [];
  String invoiceNumber = '';
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
  bool createRenewal = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      invoiceNumber = detailsResponse!.data.invoiceNumber.toString();
      items = detailsResponse!.data.products;
      filteredTemplates = detailsResponse!.data.template;
      filteredItems.addAll(items);
    }
    setState(() {});
  }

  postConfirmedFollowup() async {
    AddLeadFollowupModels object1 = await HttpService.postConfirmedFollowup(
        widget.callMasterId,
        invoiceRemarks.text,
        renewalRemarks.text,
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
      Common.toastMessaage(object1.message, Colors.green);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
      body: detailsResponse == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    initialValue: invoiceDate.toString(),
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
                                          invoiceDate = DateTime.parse(value);
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
                                                  'Product Details',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                          return AlertDialog(
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        search,
                                                                    autocorrect:
                                                                        false,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .visiblePassword,
                                                                    autofocus:
                                                                        true,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        filteredItems = items
                                                                            .where((item) =>
                                                                                item.productName.toLowerCase().contains(value.toLowerCase()))
                                                                            .toList();
                                                                      });
                                                                    },
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
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
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return ListTile(
                                                                          onTap:
                                                                              () {
                                                                            productQty.text =
                                                                                "1";
                                                                            productName =
                                                                                filteredItems[index].productName;
                                                                            productId =
                                                                                filteredItems[index].id;
                                                                            productRate.text =
                                                                                filteredItems[index].sellingPrice;
                                                                            productTaxPercent.text =
                                                                                filteredItems[index].taxPercent;
                                                                            productTaxAmount.text =
                                                                                filteredItems[index].taxAmount;
                                                                            productTotalAmount.text =
                                                                                ((double.parse(productRate.text) + double.parse(productTaxAmount.text)) * double.parse(productQty.text)).toString();
                                                                            productTotalAmount.text =
                                                                                double.parse(productTotalAmount.text).toStringAsFixed(2);
                                                                            setState(() {});
                                                                            if (context.mounted) {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          title:
                                                                              Text(filteredItems[index].productName));
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Center(
                                                        child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
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
                                                                productName,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                                      child: TextFormField(
                                                        onChanged: (value) {
                                                          if (value == '') {
                                                            value = '0';
                                                          }
                                                          productTaxAmount
                                                              .text = (double
                                                                      .parse(
                                                                          value) *
                                                                  double.parse(
                                                                      productTaxPercent
                                                                          .text) /
                                                                  100)
                                                              .toString();
                                                          productTotalAmount
                                                              .text = ((double.parse(
                                                                          value) +
                                                                      double.parse(
                                                                          productTaxAmount
                                                                              .text)) *
                                                                  double.parse(
                                                                      productQty
                                                                          .text))
                                                              .toString();

                                                          productTotalAmount
                                                              .text = double.parse(
                                                                  productTotalAmount
                                                                      .text)
                                                              .toStringAsFixed(
                                                                  2);

                                                          setState(() {});
                                                        },
                                                        controller: productRate,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Rate',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .arrow_right,
                                                                    color:
                                                                        Colors
                                                                            .grey),
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 110,
                                                      child: TextFormField(
                                                        onChanged: (value) {
                                                          if (value == '') {
                                                            value = '0';
                                                          }
                                                          productTotalAmount
                                                              .text = ((double.parse(
                                                                          productRate
                                                                              .text) +
                                                                      double.parse(
                                                                          productTaxAmount
                                                                              .text)) *
                                                                  double.parse(
                                                                      value))
                                                              .toString();
                                                          productTotalAmount
                                                              .text = double.parse(
                                                                  productTotalAmount
                                                                      .text)
                                                              .toStringAsFixed(
                                                                  2);
                                                          setState(() {});
                                                        },
                                                        controller: productQty,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Qty',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .arrow_right,
                                                                    color:
                                                                        Colors
                                                                            .grey),
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
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
                                                      child: TextFormField(
                                                        onChanged: (value) {
                                                          if (value == '') {
                                                            value = '0';
                                                          }
                                                          productTaxAmount
                                                              .text = (double.parse(
                                                                      productRate
                                                                          .text) *
                                                                  double.parse(
                                                                      value) /
                                                                  100)
                                                              .toString();
                                                          productTotalAmount
                                                              .text = ((double.parse(
                                                                          productRate
                                                                              .text) +
                                                                      double.parse(
                                                                          productTaxAmount
                                                                              .text)) *
                                                                  double.parse(
                                                                      productQty
                                                                          .text))
                                                              .toString();
                                                          productTotalAmount
                                                              .text = double.parse(
                                                                  productTotalAmount
                                                                      .text)
                                                              .toStringAsFixed(
                                                                  2);
                                                          setState(() {});
                                                        },
                                                        controller:
                                                            productTaxPercent,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Tax Percent',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .arrow_right,
                                                                    color:
                                                                        Colors
                                                                            .grey),
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 110,
                                                      child: TextFormField(
                                                        controller:
                                                            productTaxAmount,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        readOnly: true,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Tax Amount',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .arrow_right,
                                                                    color:
                                                                        Colors
                                                                            .grey),
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
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
                                                        TextInputType.number,
                                                    readOnly: true,
                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    top: 2,
                                                                    bottom: 2),
                                                            labelText:
                                                                'Total Amount',
                                                            fillColor:
                                                                Colors.white,
                                                            filled: true,
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
                                                                      color: Colors
                                                                          .grey),
                                                            ),
                                                            labelStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                  ),
                                                ),

                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10,
                                                                    left: 30,
                                                                    right: 30),
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          )),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (productRate
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Product Rate',
                                                              Colors.red);
                                                        } else if (productQty
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Product Qty',
                                                              Colors.red);
                                                        } else if (productTaxPercent
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Product Tax Percent',
                                                              Colors.red);
                                                        } else if (productTaxAmount
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Product Tax Amount',
                                                              Colors.red);
                                                        } else if (productTotalAmount
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Product Total Amount',
                                                              Colors.red);
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
                                                                productQty.text,
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
                                                              double.parse(
                                                                      productTaxAmount
                                                                          .text) *
                                                                  double.parse(
                                                                      productQty
                                                                          .text);
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
                                                          productName =
                                                              "Choose Product";
                                                          productId = "";
                                                          productDescription
                                                              .clear();
                                                          productRate.clear();
                                                          productQty.clear();
                                                          productTaxPercent
                                                              .clear();
                                                          productTaxAmount
                                                              .clear();
                                                          productTotalAmount
                                                              .clear();
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10,
                                                                    left: 25,
                                                                    right: 25),
                                                            child: Text(
                                                              'Add',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
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
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 10),
                                    child: Text(
                                      '+ Add Product',
                                      style: TextStyle(color: Colors.white),
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
                                      MediaQuery.of(context).size.width *
                                          0.2), // Using 10%
                                  1: FixedColumnWidth(
                                      MediaQuery.of(context).size.width *
                                          0.14), // Using 30%
                                  2: FixedColumnWidth(
                                      MediaQuery.of(context).size.width * 0.14),
                                  3: FixedColumnWidth(
                                      MediaQuery.of(context).size.width *
                                          0.14), // Using 20%
                                  4: FixedColumnWidth(
                                      MediaQuery.of(context).size.width * 0.20),
                                  5: FixedColumnWidth(
                                      MediaQuery.of(context).size.width * 0.10),
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
                                        child: Text('Product',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Rate',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Qty',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                          8.0,
                                        ),
                                        child: Text('Tax',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Amount',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
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
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
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
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    Color color = index % 2 == 0
                                        ? const Color(0xFFF3F3F3)
                                        : const Color(0xFFece9fd);
                                    return Padding(
                                      padding: const EdgeInsets.all(1.0),
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
                                                  BorderRadius.circular(1),
                                              color: color,
                                            ),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  products[index]
                                                      ['product_name'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  products[index]
                                                      ['product_rate'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  products[index]['quantity'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  products[index]
                                                      ['total_tax_amount'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  products[index]
                                                      ['total_amount'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  subTotal = subTotal -
                                                      double.parse(
                                                        products[index]
                                                            ['total_amount'],
                                                      );
                                                  totalTaxAmount = totalTaxAmount -
                                                      double.parse(products[
                                                                  index][
                                                              'total_tax_amount']) *
                                                          double.parse(
                                                              products[index]
                                                                  ['quantity']);

                                                  allTotal = subTotal +
                                                      double.parse(
                                                          shippingCharge.text ==
                                                                  ''
                                                              ? '0'
                                                              : shippingCharge
                                                                  .text) -
                                                      double.parse(
                                                          discount.text == ''
                                                              ? '0'
                                                              : discount.text);
                                                  products.removeWhere(
                                                    (item) => mapEquals(
                                                        item,
                                                        ({
                                                          "product_name":
                                                              products[index][
                                                                  'product_name'],
                                                          "product_id":
                                                              products[index][
                                                                  'product_id'],
                                                          "description":
                                                              products[index][
                                                                  'description'],
                                                          "product_rate":
                                                              products[index][
                                                                  'product_rate'],
                                                          "quantity":
                                                              products[index]
                                                                  ['quantity'],
                                                          "tax_percent":
                                                              products[index][
                                                                  'tax_percent'],
                                                          "total_tax_amount":
                                                              products[index][
                                                                  'total_tax_amount'],
                                                          "total_amount":
                                                              products[index][
                                                                  'total_amount'],
                                                        })),
                                                  );
                                                  if (products.isEmpty) {
                                                    discount.clear();
                                                    shippingCharge.clear();
                                                    allTotal = 0.00;
                                                  }

                                                  setState(() {});
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.delete_outline,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Sub Total :'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
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
                                        child:
                                            Text(subTotal.toStringAsFixed(2)),
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Tax Amount:'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
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
                                        child: Text(
                                            totalTaxAmount.toStringAsFixed(2)),
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Discount:'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 35,
                                    child: TextFormField(
                                      onChanged: (value) {
                                        if (products.isNotEmpty) {
                                          if (value == '') {
                                            value = '0';
                                          }
                                          allTotal = subTotal +
                                              double.parse(
                                                  shippingCharge.text == ''
                                                      ? '0'
                                                      : shippingCharge.text) -
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
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(
                                            // width: 0.0 produces a thin "hairline" border
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          //labelText: 'Invoice Number',
                                          fillColor: Colors.grey[300],
                                          filled: true,
                                          // border: const OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Shipping Charge:'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 35,
                                    child: TextFormField(
                                      onChanged: (value) {
                                        if (products.isNotEmpty) {
                                          if (value == '') {
                                            value = '0';
                                          }

                                          allTotal = subTotal +
                                              double.parse(value) -
                                              double.parse(discount.text == ''
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
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          //labelText: 'Invoice Number',
                                          fillColor: Colors.grey[300],
                                          filled: true,
                                          border: const OutlineInputBorder(
                                            // width: 0.0 produces a thin "hairline" border
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Pay Status * :'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 35,
                                    child: FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5))),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                child: Text('Status'),
                                              ),
                                              value: paymentStatus,
                                              items: detailsResponse!
                                                  .data.paymentStatus
                                                  .map((data) {
                                                return DropdownMenuItem(
                                                  value: data.paymentStatus
                                                      .toString(),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                      child: Text(
                                                        data.displaySts
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  paymentStatus = newValue;
                                                  if (paymentStatus == "paid") {
                                                    paidAmount.text =
                                                        allTotal.toString();
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
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Paid Amount * :'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 35,
                                    child: TextFormField(
                                      readOnly: paymentStatus == "paid",
                                      style: TextStyle(color: paidColor),
                                      onChanged: (val) {
                                        if (double.parse(val) > allTotal) {
                                          Common.toastMessaage(
                                              'Enter valid amount', Colors.red);
                                          paidColor = Colors.red;
                                        } else {
                                          paidColor = Colors.black;
                                        }
                                        setState(() {});
                                      },
                                      controller: paidAmount,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          //labelText: 'Invoice Number',
                                          fillColor: Colors.grey[300],
                                          filled: true,
                                          border: const OutlineInputBorder(
                                            // width: 0.0 produces a thin "hairline" border
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
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
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                (FormFieldState<String> state) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    hint: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20),
                                                      child: Text('Method'),
                                                    ),
                                                    value: paymentMethod,
                                                    items: detailsResponse!
                                                        .data.paymentMethods
                                                        .map((data) {
                                                      return DropdownMenuItem(
                                                        value:
                                                            data.id.toString(),
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
                                                    onChanged: (newValue) {
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
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                (FormFieldState<String> state) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    hint: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20),
                                                      child: Text('Staff'),
                                                    ),
                                                    value: collectedStaff,
                                                    items: detailsResponse!
                                                        .data.staff
                                                        .map((data) {
                                                      return DropdownMenuItem(
                                                        value: data.userId
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
                                                    onChanged: (newValue) {
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
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextFormField(
                                controller: invoiceRemarks,
                                maxLines: 1,
                                decoration: InputDecoration(
                                    labelText: 'Remarks',
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    if (widget.renewalPermission)
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Create Renewal'),
                          value: createRenewal, // initial value of the checkbox
                          onChanged: (bool? value) {
                            setState(() {
                              createRenewal = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: createRenewal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: startDate,
                              readOnly: true,
                              onTap: () async {
                                DateTime? selectedValue = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                setState(() {
                                  startDate.text = DateFormat('dd-MM-yyyy')
                                      .format(selectedValue!);
                                });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Select Start Date";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  labelText: 'Start Date *',
                                  prefixIcon: const Icon(Icons.calendar_month,
                                      color: Colors.black54),
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black)),
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
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  labelText: 'End Date *',
                                  prefixIcon: const Icon(Icons.calendar_month,
                                      color: Colors.black54),
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(height: 14.0),
                            TextFormField(
                              onTap: () {
                                dropDialog(context);
                              },
                              readOnly: true,
                              controller: reminderTemplate,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(8),
                                  labelText: 'Remind Template ',
                                  prefixIcon: const Icon(Icons.notifications,
                                      color: Colors.black54),
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: renewalRemarks,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  labelText: 'Remarks',
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                      child: GestureDetector(
                        onTap: () {
                          if (products.isEmpty) {
                            Common.toastMessaage(
                                'Please add a product to continue', Colors.red);
                          } else if (paidAmount.text.isEmpty ||
                              paymentStatus == null) {
                            Common.toastMessaage(
                                'Paid Amount and Payment Status is required to add invoice',
                                Colors.red);
                          } else if (paymentStatus != "1" &&
                              paymentMethod == null) {
                            Common.toastMessaage(
                                'Payment Method is required to add invoice',
                                Colors.red);
                          } else if (paymentStatus != "1" &&
                              collectedStaff == null) {
                            Common.toastMessaage(
                                'Collected Staff is required to add invoice',
                                Colors.red);
                          } else if (createRenewal == true &&
                              startDate.text == "") {
                            Common.toastMessaage(
                                'Start date is required to add renewal',
                                Colors.red);
                          } else if (createRenewal == true &&
                              endDate.text == "") {
                            Common.toastMessaage(
                                'End date is required to add renewal',
                                Colors.red);
                          } else {
                            if (context.mounted) {
                              Common.showProgressDialog(context, "Loading..");
                            }
                            postConfirmedFollowup();
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
                    ),
                  ],
                ),
              ),
            ),
    );
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
