// ignore_for_file: file_names, must_be_immutable, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/addInvoiceModel.dart';
import '../../../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../../../models/clients/postalCodeModel.dart';
import '../../../service/service.dart';

class AddInvoice extends StatefulWidget {
  String token;
  String clientId;

  AddInvoice(this.token, this.clientId, {super.key});

  @override
  State<AddInvoice> createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> {
  InvoiceAddCommonDetailsModel? invDetails;
  bool result = true;
  var fromdate = DateTime.now();
  TextEditingController billingName = TextEditingController();
  TextEditingController billingAddress = TextEditingController();
  TextEditingController billingPhone = TextEditingController();
  TextEditingController billingGstNo = TextEditingController();
  TextEditingController billingPinCode = TextEditingController();
  TextEditingController billingPostOffice = TextEditingController();
  TextEditingController shippingName = TextEditingController();
  TextEditingController shippingAddress = TextEditingController();
  TextEditingController shippingPhone = TextEditingController();
  TextEditingController shippingGstNo = TextEditingController();
  TextEditingController shippingPinCode = TextEditingController();
  TextEditingController shippingPostOffice = TextEditingController();
  TextEditingController invoiceNumber = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController renewalRemarks = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  bool isDifrent = false;
  List<Map<String, dynamic>> renProducts = [];
  TextEditingController renProductRate = TextEditingController();
  TextEditingController renProductQty = TextEditingController(text: "1");
  TextEditingController renProductTaxPercent = TextEditingController();
  TextEditingController renProductTaxAmount = TextEditingController();
  TextEditingController renProductTotalAmount = TextEditingController();

  List<Map<String, dynamic>> products = [];
  double subTotal = 0.00;
  double totalTaxAmount = 0.00;
  double allTotal = 0.00;
  bool isPaying = false;
  dynamic paymentMethod;
  dynamic paymentStatus;
  List<Staff> filteredStaff = [];
  String staffId = "";
  String staffName = "Staff";
  List<Product> items = [];
  List<Product> filteredItems = [];
  String productId = "";
  String productName = "Choose Product";
  String renProductId = "";
  String renProductName = "";
  PostalCodeModel? billingPostal;
  PostalCodeModel? shippingPostal;
  bool header = true;
  bool headerContent = false;
  Color paidColor = Colors.black;
  var code = '91';
  String? templateImage;
  bool createRenewal = false;
  String typeDuration = "";
  String templateId = "";
  List<Template> filteredTemplates = [];
  List<TargetGroup> filteredTargets = [];
  List targetGroups = [];
  List targetGroupNames = [];

  void headerToggle() {
    setState(() {
      header = !header;
      headerContent = !headerContent;
    });
  }

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

    invDetails =
        await HttpService.invoiceCommonDetails(widget.token, widget.clientId);
    if (invDetails != null) {
      filteredTargets.addAll(invDetails!.data.targetGroups);
      filteredStaff.addAll(invDetails!.data.staff);
      filteredTemplates = invDetails!.data.template;
      billingName.text = invDetails!.data.billingAddress.billingName.toString();
      billingAddress.text =
          invDetails!.data.billingAddress.billingAddress.toString();
      billingPhone.text =
          invDetails!.data.billingAddress.billingContactNo.toString();
      billingGstNo.text = invDetails!.data.billingAddress.billingGst.toString();
      billingPinCode.text =
          invDetails!.data.billingAddress.billingPincode.toString();
      billingPostOffice.text =
          invDetails!.data.billingAddress.billingPostOffice.toString();
      if (invDetails!.data.billingAddress.billingCountryCode.toString() != '') {
        code = invDetails!.data.billingAddress.billingCountryCode.toString();
      }
      if (billingPinCode.text != '') {
        billingPostal = await HttpService.fetchPostOffice(billingPinCode.text);
      }
      shippingName.text =
          invDetails!.data.shippingAddress.shippingName.toString();
      shippingAddress.text =
          invDetails!.data.shippingAddress.shippingAddress.toString();
      shippingPhone.text =
          invDetails!.data.shippingAddress.shippingContactNo.toString();
      shippingGstNo.text =
          invDetails!.data.shippingAddress.shippingGst.toString();
      shippingPinCode.text =
          invDetails!.data.shippingAddress.shippingPincode.toString();
      shippingPostOffice.text =
          invDetails!.data.shippingAddress.shippingPostOffice.toString();
      if (shippingPinCode.text != '') {
        shippingPostal =
            await HttpService.fetchPostOffice(shippingPinCode.text);
      }

      invoiceNumber.text = invDetails!.data.displayInvoice.toString();
      startDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      items = invDetails!.data.products;
      filteredItems.addAll(items);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
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
                            'Invoice',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: invDetails != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        header == false
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox(),
                        invDetails!.data.companyDetails.isNotEmpty
                            ? Column(
                                children: [
                                  InkWell(
                                    onTap: headerToggle,
                                    child: Visibility(
                                      visible: header,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .3,
                                                child: Center(
                                                  child: Image.network(
                                                    invDetails!
                                                        .data
                                                        .companyDetails[0]
                                                        .companyLogo
                                                        .toString(),
                                                    width: 100,
                                                  ),
                                                )),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'Registration Number',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyRegNo
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                const Text(
                                                  'Contact Number',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyContactNo
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: headerToggle,
                                    child: Visibility(
                                      visible: headerContent,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    color: Colors.white,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .3,
                                                    child: Center(
                                                      child: Image.network(
                                                        invDetails!
                                                            .data
                                                            .companyDetails[0]
                                                            .companyLogo
                                                            .toString(),
                                                        width: 150,
                                                      ),
                                                    )),
                                                const Text(
                                                  'Address',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                SizedBox(
                                                    width: 200,
                                                    child: Text(
                                                      invDetails!
                                                          .data
                                                          .companyDetails[0]
                                                          .companyAddress
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    )),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyEmail
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'Registration Number',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyRegNo
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                const Text(
                                                  'Contact Number',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyContactNo
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                const Text(
                                                  'Pin code',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  invDetails!
                                                      .data
                                                      .companyDetails[0]
                                                      .companyPincode
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        header == false
                            ? const SizedBox(
                                height: 5,
                              )
                            : const SizedBox(),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Billing Address(${billingName.text})',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 7, right: 7, top: 7, bottom: 7),
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
                                                content: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(
                                                        'Billing Address',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 24),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller: billingName,
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
                                                                    'Name',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .person,
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            billingAddress,
                                                        maxLines: 2,
                                                        decoration:
                                                            const InputDecoration(
                                                                contentPadding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Address',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .location_on,
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            billingPhone,
                                                        decoration:
                                                            InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                labelText:
                                                                    'Phone Number',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefix:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    showCountryPicker(
                                                                      context:
                                                                          context,
                                                                      searchAutofocus:
                                                                          false,
                                                                      showPhoneCode:
                                                                          true,
                                                                      // optional. Shows phone code before the country name.
                                                                      onSelect:
                                                                          (Country
                                                                              country) {
                                                                        setState(
                                                                            () {
                                                                          code =
                                                                              country.phoneCode;
                                                                        });

                                                                        // flag = country.flagEmoji;
                                                                        // print(countryPickerController.code.value);
                                                                        // print(flag);
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                    // color: Colors.blue,
                                                                    width: 70,
                                                                    // width: MediaQuery.of(context).size.width/3.5,
                                                                    child: Row(
                                                                        children: [
                                                                          Text(
                                                                              "+$code"),
                                                                          const Icon(
                                                                              Icons.arrow_drop_down),
                                                                        ]),
                                                                  ),
                                                                ),
                                                                border:
                                                                    const OutlineInputBorder(),
                                                                focusedBorder:
                                                                    const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                labelStyle: const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            billingGstNo,
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
                                                                    'GST Number',
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        onChanged:
                                                            (value) async {
                                                          if (value.length >=
                                                              6) {
                                                            billingPostal =
                                                                await HttpService
                                                                    .fetchPostOffice(
                                                                        value);
                                                            setState(() {});
                                                          } else {
                                                            billingPostal =
                                                                null;
                                                            billingPostOffice
                                                                .clear();
                                                            setState(() {});
                                                          }
                                                        },
                                                        controller:
                                                            billingPinCode,
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
                                                                    'Pin Code',
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .pin_drop,
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      billingPostal != null
                                                          ? TextFormField(
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
                                                                          title:
                                                                              const Text('Post Office'),
                                                                          content: billingPostal!.postOffice != null
                                                                              ? SizedBox(
                                                                                  height: MediaQuery.of(context).size.height * .32,
                                                                                  width: MediaQuery.of(context).size.height * .8,
                                                                                  child: ListView.builder(
                                                                                    shrinkWrap: true,
                                                                                    itemCount: billingPostal!.postOffice!.length,
                                                                                    itemBuilder: (context, ind) {
                                                                                      return InkWell(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            billingPostOffice.text = billingPostal!.postOffice![ind].name.toString();
                                                                                            Navigator.pop(context, true);
                                                                                          });
                                                                                        },
                                                                                        child: SizedBox(
                                                                                          height: 50,
                                                                                          child: Text(
                                                                                            billingPostal!.postOffice![ind].name.toString(),
                                                                                            style: const TextStyle(fontSize: 18),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                )
                                                                              : const Text('No Post Office Found'));
                                                                    });
                                                              },
                                                              maxLines: 1,
                                                              readOnly: true,
                                                              controller:
                                                                  billingPostOffice,
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
                                                                          'Post Office',
                                                                      fillColor:
                                                                          Colors
                                                                              .white,
                                                                      filled:
                                                                          true,
                                                                      prefixIcon: Icon(
                                                                          Icons
                                                                              .arrow_drop_down_circle_outlined,
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
                                                                          TextStyle(
                                                                              color: Colors.grey)),
                                                            )
                                                          : const SizedBox(),
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
                                                                      left: 30,
                                                                      right:
                                                                          30),
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
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
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
                                                                      left: 30,
                                                                      right:
                                                                          30),
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
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Invoice Number :',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(invoiceNumber.text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
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
                                        initialValue: fromdate.toString(),

                                        // initialValue or controller.text can be null, empty or a DateTime string otherwise it will throw an error.
                                        type: DateTimePickerType.date,
                                        //icon: Icon(Icons.calendar_today),
                                        //dateHintText: 'From Date',
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
                                            fromdate = value as DateTime;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                addProductsDialog(context).then((_) {
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
                                      'Add Product',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: true,
                          child: Column(
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
                                            0.16), // Using 30%
                                    2: FixedColumnWidth(
                                        MediaQuery.of(context).size.width *
                                            0.10),
                                    3: FixedColumnWidth(
                                        MediaQuery.of(context).size.width *
                                            0.16), // Using 20%
                                    4: FixedColumnWidth(
                                        MediaQuery.of(context).size.width *
                                            0.22),
                                    5: FixedColumnWidth(
                                        MediaQuery.of(context).size.width *
                                            0.10),
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: SingleChildScrollView(
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
                                          MediaQuery.of(context).size.width *
                                              0.2), // Using 10%
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.16), // Using 30%
                                      2: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.10),
                                      3: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.16), // Using 20%
                                      4: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.22),
                                      5: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              products[index]['product_name'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              products[index]['product_rate'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              products[index]['quantity'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              products[index]
                                                  ['total_tax_amount'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              products[index]['total_amount'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                                                  double.parse(products[index][
                                                          'total_tax_amount']) *
                                                      double.parse(
                                                          products[index]
                                                              ['quantity']);

                                              allTotal = subTotal +
                                                  double.parse(
                                                      shippingCharge.text == ''
                                                          ? '0'
                                                          : shippingCharge
                                                              .text) -
                                                  double.parse(
                                                      discount.text == ''
                                                          ? '0'
                                                          : discount.text);
                                              paidAmount.text =
                                                  allTotal.toString();

                                              // products.removeWhere(
                                              //   (item) => mapEquals(
                                              //       item,
                                              //       ({
                                              //         "product_name":
                                              //             products[index]
                                              //                 ['product_name'],
                                              //         "product_id":
                                              //             products[index]
                                              //                 ['product_id'],
                                              //         "description":
                                              //             products[index]
                                              //                 ['description'],
                                              //         "product_rate":
                                              //             products[index]
                                              //                 ['product_rate'],
                                              //         "quantity":
                                              //             products[index]
                                              //                 ['quantity'],
                                              //         "tax_percent":
                                              //             products[index]
                                              //                 ['tax_percent'],
                                              //         "total_tax_amount":
                                              //             products[index][
                                              //                 'total_tax_amount'],
                                              //         "total_amount":
                                              //             products[index]
                                              //                 ['total_amount'],
                                              //       })),
                                              // );
                                              products.removeAt(index);
                                              if (renProducts.isNotEmpty) {
                                                renProducts.removeAt(index);
                                              }
                                              if (products.isEmpty) {
                                                discount.clear();
                                                shippingCharge.clear();
                                                allTotal = 0.00;
                                                paidAmount.text =
                                                    allTotal.toString();
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
                                          paidAmount.text = allTotal.toString();
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
                                          paidAmount.text = allTotal.toString();

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
                                    height: 35,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
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
                                              items: invDetails!
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
                            if (paymentStatus != "unpaid")
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
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 35,
                                      child: TextFormField(
                                        readOnly: paymentStatus == "paid",
                                        style: TextStyle(color: paidColor),
                                        onChanged: (val) {
                                          if (double.parse(val) > subTotal) {
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
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 10,
                                                    top: 2,
                                                    bottom: 2),
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
                                                    items: invDetails!
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
                                          child: GestureDetector(
                                            onTap: () {
                                              collectedStaffDialog(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Center(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0),
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
                                                            0.38,
                                                        child: Text(
                                                          staffName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      color:
                                                          Colors.grey.shade600,
                                                    )
                                                  ],
                                                ),
                                              )),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Target Group :',
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          child: GestureDetector(
                                            onTap: () {
                                              targetGroupDialog(context);
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade300,
                                              ),
                                              child: targetGroups.isEmpty
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          top: 15,
                                                          bottom: 10),
                                                      child:
                                                          Text('Target Group'))
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 40),
                                                      child: SizedBox(
                                                        height: 35,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              targetGroupNames
                                                                  .length,
                                                          itemBuilder:
                                                              (context, i) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5,
                                                                      right: 5),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          35,
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Colors
                                                                                  .grey,
                                                                              width:
                                                                                  0),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius: const BorderRadius
                                                                              .only(
                                                                              topLeft: Radius.circular(6),
                                                                              bottomLeft: Radius.circular(6))),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: Text(
                                                                                targetGroupNames[i],
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: const Text('Please Confirm'),
                                                                                content: const Text('Are you sure to Remove this Number?'),
                                                                                actions: [
                                                                                  TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: const Text('No')),
                                                                                  TextButton(
                                                                                      onPressed: () async {
                                                                                        setState(() {
                                                                                          targetGroupNames.remove(targetGroupNames[i]);
                                                                                          targetGroups.remove(targetGroups[i]);
                                                                                        });
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: const Text('Yes')),
                                                                                ],
                                                                              );
                                                                            });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.grey, width: 0),
                                                                            color: Colors.grey.shade100,
                                                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))),
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .close,
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
                                ],
                              ),
                            ),
                            paymentMethod == '2'
                                ? Container(
                                    child: templateImage == null
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, top: 15),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: _selectFile,
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
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
                                            padding: const EdgeInsets.only(
                                                right: 10, top: 15),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: _selectFile,
                                                    child: Container(
                                                        width:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                        height: 80,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
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
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            child: TextFormField(
                              controller: remarks,
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
                        ),
                        if (invDetails!.data.createRenewal)
                          CheckboxListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: const Text('Create Renewal'),
                              value:
                                  createRenewal, // initial value of the checkbox
                              onChanged: (bool? value) {
                                setState(() {
                                  createRenewal = value!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading),
                        Visibility(
                          visible: createRenewal,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
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
                                                    days: int.parse(
                                                        typeDuration)));
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
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            labelText: 'Start Date *',
                                            prefixIcon: const Icon(
                                                Icons.calendar_month,
                                                color: Colors.black54),
                                            fillColor: Colors.grey[300],
                                            filled: true,
                                            //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            labelStyle: const TextStyle(
                                                color: Colors.black)),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        onTap: () async {
                                          DateTime? selectedEndDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          endDate.text =
                                              DateFormat('dd-MM-yyyy')
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
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            labelText: 'End Date *',
                                            prefixIcon: const Icon(
                                                Icons.calendar_month,
                                                color: Colors.black54),
                                            fillColor: Colors.grey[300],
                                            filled: true,
                                            //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            labelStyle: const TextStyle(
                                                color: Colors.black)),
                                      ),
                                    ),
                                  ],
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
                                      prefixIcon: const Icon(
                                          Icons.notifications,
                                          color: Colors.black54),
                                      fillColor: Colors.grey[300],
                                      filled: true,
                                      //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      labelStyle:
                                          const TextStyle(color: Colors.black)),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                        'Is renewal amount is diffrent?'),
                                    value:
                                        isDifrent, // initial value of the checkbox
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isDifrent = value!;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading),
                                const SizedBox(
                                  height: 14,
                                ),
                                Visibility(
                                  visible: isDifrent,
                                  child: Column(
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
                                                    0.16), // Using 30%
                                            2: FixedColumnWidth(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.10),
                                            3: FixedColumnWidth(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.16), // Using 20%
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
                                      renProducts.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                "No Products !",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            )
                                          : SingleChildScrollView(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: renProducts.length,
                                                itemBuilder: (context, index) {
                                                  Color color = index % 2 == 0
                                                      ? const Color(0xFFF3F3F3)
                                                      : const Color(0xFFece9fd);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    child: Table(
                                                      columnWidths: {
                                                        0: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2), // Using 10%
                                                        1: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.14), // Using 30%
                                                        2: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.14),
                                                        3: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.14), // Using 20%
                                                        4: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.20),
                                                        5: FixedColumnWidth(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.10),
                                                      },
                                                      children: [
                                                        // Each TableRow represents a row in the Table
                                                        TableRow(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                            color: color,
                                                          ),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                renProducts[
                                                                        index][
                                                                    'product_name'],
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                renProducts[
                                                                        index][
                                                                    'product_rate'],
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                renProducts[
                                                                        index][
                                                                    'quantity'],
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                renProducts[
                                                                        index][
                                                                    'total_tax_amount'],
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                renProducts[
                                                                        index][
                                                                    'total_amount'],
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                changeAmount(
                                                                        context,
                                                                        renProducts[index]
                                                                            [
                                                                            'product_name'],
                                                                        renProducts[index]
                                                                            [
                                                                            'product_rate'],
                                                                        renProducts[index]
                                                                            [
                                                                            'quantity'],
                                                                        renProducts[index]
                                                                            [
                                                                            'total_tax_amount'],
                                                                        renProducts[index]
                                                                            [
                                                                            'tax_percent'],
                                                                        renProducts[index]
                                                                            [
                                                                            'total_amount'],
                                                                        renProducts[index]
                                                                            [
                                                                            'product_id'],
                                                                        renProducts[index]
                                                                            [
                                                                            'description'],
                                                                        index)
                                                                    .then((_) {
                                                                  setState(
                                                                      () {});
                                                                });
                                                              },
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .blue,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () async {
                                if (products.isEmpty) {
                                  Common.toastMessaage(
                                      'Add at least one product', Colors.red);
                                } else if (paidAmount.text.isNotEmpty &&
                                    double.parse(paidAmount.text) > allTotal) {
                                  Common.toastMessaage(
                                      ' The paid amount should not exceed the total amount',
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
                                } else if (double.parse(discount.text == ""
                                        ? "0.0"
                                        : discount.text) >
                                    subTotal) {
                                  Common.toastMessaage(
                                      'The discount should not exceed the total amount',
                                      Colors.red);
                                } else if (double.parse(discount.text == ""
                                        ? "0.0"
                                        : discount.text) <
                                    0) {
                                  Common.toastMessaage(
                                      'Please enter valid discount amount',
                                      Colors.red);
                                } else if (double.parse(
                                        shippingCharge.text == ""
                                            ? "0.0"
                                            : shippingCharge.text) <
                                    0) {
                                  Common.toastMessaage(
                                      'Please enter valid shipping charge',
                                      Colors.red);
                                } else {
                                  Common.showProgressDialog(
                                      context, "Loading..");

                                  var body = FormData.fromMap({
                                    "token": widget.token,
                                    'invoice_number':
                                        invDetails!.data.invoiceNumber,
                                    'invoice_date': DateFormat("dd-MM-yyyy")
                                        .format(DateTime.parse(
                                            fromdate.toString())),
                                    'customer_id': invDetails!.data.customerId,
                                    'sub_total': subTotal,
                                    'estimated_tax': totalTaxAmount,
                                    'discount_amount': discount.text,
                                    'shipping_amount': shippingCharge.text,
                                    'total_invoice_amount': allTotal,
                                    'payment_method': paymentMethod,
                                    'payment_status': paymentStatus,
                                    'collected_staff': staffId,
                                    'billing_name': billingName.text,
                                    'billing_address': billingAddress.text,
                                    'billing_country_code': code,
                                    'billing_contact_no': billingPhone.text,
                                    'billing_gst': billingGstNo.text,
                                    "billing_pincode": billingPinCode.text,
                                    "billing_post_office":
                                        billingPostOffice.text,
                                    'shipping_name': shippingName.text,
                                    'shipping_address': shippingAddress.text,
                                    'shipping_contact_no': shippingPhone.text,
                                    'shipping_gst': shippingGstNo.text,
                                    "shipping_pincode": shippingPinCode.text,
                                    'shipping_country_code': code,
                                    "shipping_post_office":
                                        shippingPostOffice.text,
                                    'amount_paid': paidAmount.text,
                                    'product_details': jsonEncode(products),
                                    'upload_file': templateImage != null
                                        ? await MultipartFile.fromFile(
                                            templateImage.toString())
                                        : '',
                                    "reminder_template": templateId,
                                    "start_date": startDate.text,
                                    "end_date": endDate.text,
                                    "create_type":
                                        createRenewal ? 'renewal' : 'invoice',
                                    "invoice_remarks": remarks.text,
                                    "renewal_remarks": renewalRemarks.text,
                                    "next_cost_diff": isDifrent,
                                    "next_renewal_product":
                                        jsonEncode(renProducts),
                                    'target_group': jsonEncode(targetGroups),
                                  });
                                  if (context.mounted) {
                                    Common.showProgressDialog(
                                        context, "Loading..");
                                  }
                                  AddInvoiceModel inv =
                                      await HttpService.addInvoice(body);
                                  if (inv.status == true) {
                                    Common.toastMessaage(
                                        inv.message, Colors.green);
                                    if (mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }

                                    // if (mounted) {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => InvoiceList(
                                    //             widget.token)),
                                    //   );
                                    // }
                                  } else {
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                    Common.toastMessaage(
                                        inv.message, Colors.green);
                                  }
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 70,
                                        right: 70),
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ),
            // resizeToAvoidBottomInset: false,
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

  Future<Object?> addProductsDialog(BuildContext context) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddProducts(),
                                )).then((_) {
                              getData();
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF2a86c9),
                                Color(0xFF406dbe)
                              ]),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "add");
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
                                    productName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
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
                              productCalculation();
                            },
                            controller: productRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
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
                              productCalculation();
                            },
                            controller: productTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: productTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: productTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon:
                                Icon(Icons.arrow_right, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (productRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (productQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (productTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (productTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (productTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else {
                              products.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });
                              renProducts.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });

                              subTotal = subTotal +
                                  double.parse(productTotalAmount.text);
                              totalTaxAmount = totalTaxAmount +
                                  double.parse(productTaxAmount.text) *
                                      double.parse(productQty.text);
                              allTotal = subTotal +
                                  double.parse(shippingCharge.text == ''
                                      ? '0'
                                      : shippingCharge.text) -
                                  double.parse(discount.text == ''
                                      ? '0'
                                      : discount.text);
                              paidAmount.text = allTotal.toString();
                              productName = "Choose Product";
                              productId = "";
                              productDescription.clear();
                              productRate.clear();
                              productQty.clear();
                              productTaxPercent.clear();
                              productTaxAmount.clear();
                              productTotalAmount.clear();

                              final endValue = DateTime.now()
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDate.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
                              Navigator.of(context).pop();
                              setState(() {});
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
                                  'Add',
                                  style: TextStyle(color: Colors.white),
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
                          Navigator.pop(context);
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
    filteredTemplates = invDetails!.data.template
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredStaff = invDetails!.data.staff
                            .where((item) => item.accountName
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
                    itemCount: filteredStaff.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            staffName = filteredStaff[index].accountName;
                            staffId = filteredStaff[index].accountId;
                            filteredStaff.addAll(invDetails!.data.staff);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaff[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredStaff.addAll(invDetails!.data.staff);
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

  Future<dynamic> productDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Icon(Icons.close)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            filteredItems = items
                                .where((item) => item.productName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
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
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFFCFBFA)),
                          child: ListTile(
                            onTap: () {
                              if (type == "add") {
                                if (productQty.text == "") {
                                  productQty.text = "1";
                                }
                                productName = filteredItems[index].productName;
                                productId = filteredItems[index].id;
                                productRate.text =
                                    filteredItems[index].sellingPrice;
                                productTaxPercent.text =
                                    filteredItems[index].taxPercent;
                                productTaxAmount.text =
                                    filteredItems[index].taxAmount;
                                productTotalAmount.text =
                                    ((double.parse(productRate.text) +
                                                double.parse(
                                                    productTaxAmount.text)) *
                                            double.parse(productQty.text))
                                        .toString();
                                productTotalAmount.text =
                                    double.parse(productTotalAmount.text)
                                        .toStringAsFixed(2);
                                if (paymentStatus == "paid") {
                                  paidAmount.text = productTotalAmount.text;
                                }
                                typeDuration = filteredItems[index].noOfDays;
                              } else {
                                if (renProductQty.text == "") {
                                  renProductQty.text = "1";
                                }
                                renProductName =
                                    filteredItems[index].productName;
                                renProductId = filteredItems[index].id;
                                renProductRate.text =
                                    filteredItems[index].sellingPrice;
                                renProductTaxPercent.text =
                                    filteredItems[index].taxPercent;
                                renProductTaxAmount.text =
                                    filteredItems[index].taxAmount;
                                renProductTotalAmount.text =
                                    ((double.parse(renProductRate.text) +
                                                double.parse(
                                                    renProductTaxAmount.text)) *
                                            double.parse(renProductQty.text))
                                        .toString();
                                renProductTotalAmount.text =
                                    double.parse(renProductTotalAmount.text)
                                        .toStringAsFixed(2);
                              }
                              setState(() {});
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            title: Text(filteredItems[index].productName),
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Text(filteredItems[index].productName[0]),
                            ),
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

  Future<Object?> changeAmount(
      BuildContext context,
      String name,
      String rate,
      String qty,
      String tax,
      String taxPerccent,
      String amount,
      String id,
      String des,
      int index) {
    renProductQty.text = qty;
    renProductRate.text = rate;
    renProductTaxPercent.text = taxPerccent;
    renProductTaxAmount.text = tax;
    renProductTotalAmount.text = amount;
    renProductId = id;
    renProductName = name;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              renProducts.removeAt(index);
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "edit");
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
                                    renProductName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
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
                              renProductCalculation();
                            },
                            controller: renProductRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation();
                            },
                            controller: renProductQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
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
                              renProductCalculation();
                            },
                            controller: renProductTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: renProductTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: renProductTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (renProductRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (renProductQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (renProductTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (renProductTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (renProductTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else {
                              renProducts[index] = {
                                "product_name": renProductName,
                                "product_id": renProductId,
                                "description": des,
                                "product_rate": renProductRate.text,
                                "quantity": renProductQty.text,
                                "tax_percent": renProductTaxPercent.text,
                                "total_tax_amount": renProductTaxAmount.text,
                                "total_amount": renProductTotalAmount.text,
                              };
                              Navigator.of(context).pop();
                              setState(() {});
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
                                  'Change',
                                  style: TextStyle(color: Colors.white),
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
                          filteredTargets = invDetails!.data.targetGroups
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
                  filteredTargets.addAll(invDetails!.data.targetGroups);
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

  productCalculation() {
    productTaxAmount.text =
        ((double.parse(productRate.text == "" ? "0" : productRate.text) *
                    double.parse(productTaxPercent.text == ""
                        ? "0"
                        : productTaxPercent.text) /
                    100) *
                double.parse(productQty.text == "" ? "0" : productQty.text))
            .toString();
    productTotalAmount.text = ((double.parse(
                    productRate.text == "" ? "0" : productRate.text) *
                double.parse(productQty.text == "" ? "0" : productQty.text)) +
            double.parse(productTaxAmount.text))
        .toString();
    productTotalAmount.text =
        double.parse(productTotalAmount.text).toStringAsFixed(2);
    setState(() {});
  }

  renProductCalculation() {
    renProductTaxAmount.text = ((double.parse(
                    renProductRate.text == "" ? "0" : renProductRate.text) *
                double.parse(renProductTaxPercent.text == ""
                    ? "0"
                    : renProductTaxPercent.text) /
                100) *
            double.parse(renProductQty.text == "" ? "0" : renProductQty.text))
        .toString();
    renProductTotalAmount.text =
        ((double.parse(renProductRate.text == "" ? "0" : renProductRate.text) *
                    double.parse(
                        renProductQty.text == "" ? "0" : renProductQty.text)) +
                double.parse(renProductTaxAmount.text))
            .toString();
    renProductTotalAmount.text =
        double.parse(renProductTotalAmount.text).toStringAsFixed(2);
    setState(() {});
  }
}
