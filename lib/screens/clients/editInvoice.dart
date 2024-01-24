import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/clients/clientList.dart';
import 'package:login2/screens/clients/invoiceList.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/clients/addInvoiceModel.dart';
import '../../models/clients/editInvoiceDetailsModel.dart';
import '../../models/clients/editInvoiceModel.dart';
import '../../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../../models/clients/postalCodeModel.dart';
import '../../service/service.dart';
import '../homePage.dart';
import '../leadManagement/dashboard.dart';
import '../userManagement/viewUsers.dart';
import 'addReceipt.dart';

class EditInvoice extends StatefulWidget {
  String token;
  String invoiceId;
  String clientId;

  EditInvoice(this.token, this.invoiceId, this.clientId, {Key? key})
      : super(key: key);

  @override
  State<EditInvoice> createState() => _EditInvoiceState();
}

class _EditInvoiceState extends State<EditInvoice> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  InvoiceAddCommonDetailsModel? invDetails;
  EditInvoiceDetailsModel? invoiceEditDetails;
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
  TextEditingController search = TextEditingController();

  List<Map<String, dynamic>> products = [];
  double subTotal = 0.00;
  double totalTaxAmount = 00;
  double allTotal = 0.00;
  bool isPaying = false;
  dynamic paymentMethod;
  List<Products> items = [];
  List<Products> filteredItems = [];
  String productId = "";
  String productName = "Choose Product";
  PostalCodeModel? billingPostal;
  PostalCodeModel? shippingPostal;
  bool isTextFieldVisible = false;
  bool header = true;
  bool headerContent = false;
  var code = '91';

  void toggleTextFieldVisibility() {
    setState(() {
      isTextFieldVisible = !isTextFieldVisible;
    });
  }
  void headerToggle() {
    setState(() {
      header = !header;
      headerContent = !headerContent;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
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
    invoiceEditDetails =
        await HttpService.invoiceEditDetails(widget.token, widget.invoiceId);
    if (invoiceEditDetails != null) {
      billingName.text =
          invoiceEditDetails!.data!.billingAddress!.billingName.toString();
      billingAddress.text =
          invoiceEditDetails!.data!.billingAddress!.billingAddress.toString();
      billingPhone.text =
          invoiceEditDetails!.data!.billingAddress!.billingContactNo.toString();
      billingGstNo.text =
          invoiceEditDetails!.data!.billingAddress!.billingGst.toString();
      billingPinCode.text =
          invoiceEditDetails!.data!.billingAddress!.billingPincode.toString();
      billingPostOffice.text = invoiceEditDetails!
          .data!.billingAddress!.billingPostOffice
          .toString();
      if (billingPinCode.text != '') {
        billingPostal = await HttpService.fetchPostOffice(billingPinCode.text);
      }
      if(invoiceEditDetails!.data!.billingAddress!.billingCountryCode.toString()!='')
      {
        code = invoiceEditDetails!.data!.billingAddress!.billingCountryCode.toString();
      }

      shippingName.text =
          invoiceEditDetails!.data!.shippingAddress!.shippingName.toString();
      shippingAddress.text =
          invoiceEditDetails!.data!.shippingAddress!.shippingAddress.toString();
      shippingPhone.text = invoiceEditDetails!
          .data!.shippingAddress!.shippingContactNo
          .toString();
      shippingGstNo.text =
          invoiceEditDetails!.data!.shippingAddress!.shippingGst.toString();
      shippingPinCode.text =
          invoiceEditDetails!.data!.shippingAddress!.shippingPincode.toString();
      shippingPostOffice.text = invoiceEditDetails!
          .data!.shippingAddress!.shippingPostOffice
          .toString();
      if (shippingPinCode.text != '') {
        shippingPostal =
            await HttpService.fetchPostOffice(shippingPinCode.text);
      }

      invoiceNumber.text = invoiceEditDetails!.data!.displayInvoice.toString();
      fromdate =
          DateTime.parse(invoiceEditDetails!.data!.invoiceDate.toString());

      items = invDetails!.data!.products!;
      filteredItems.addAll(items);

      if (invoiceEditDetails!.data!.productDetails!.isNotEmpty) {
        for (int i = 0;
            i < invoiceEditDetails!.data!.productDetails!.length;
            i++) {
          products.add({
            "product_name":
                invoiceEditDetails!.data!.productDetails![i].productName,
            "product_id":
                invoiceEditDetails!.data!.productDetails![i].productId,
            "description":
                invoiceEditDetails!.data!.productDetails![i].productDescription,
            "product_rate": invoiceEditDetails!.data!.productDetails![i].rate,
            "quantity": invoiceEditDetails!.data!.productDetails![i].qty,
            "tax_percent":
                invoiceEditDetails!.data!.productDetails![i].taxPercentage,
            "total_tax_amount":
                invoiceEditDetails!.data!.productDetails![i].taxAmount,
            "total_amount": invoiceEditDetails!.data!.productDetails![i].amount,
          });
        }
        subTotal = double.parse(invoiceEditDetails!.data!.subTotal.toString());
        totalTaxAmount =
            double.parse(invoiceEditDetails!.data!.estimatedTax.toString());
        discount.text = invoiceEditDetails!.data!.discountAmount.toString();
        shippingCharge.text =
            invoiceEditDetails!.data!.shippingAmount.toString();
        allTotal = double.parse(
            invoiceEditDetails!.data!.totalInvoiceAmount.toString());
        remarks.text = invoiceEditDetails!.data!.remarks.toString();
      }
      isPaying=invoiceEditDetails!.data!.invoicePaymentStatus!;

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
                              'Invoice',
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
              body: invDetails != null
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          header==false?const SizedBox(
                            height: 10,
                          ):const SizedBox(),
                          invDetails!.data!.companyDetails!.isNotEmpty
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    .data!
                                                    .companyDetails![0]
                                                    .companyLogo
                                                    .toString(),
                                                width: 100,
                                              ),
                                            )),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Registration Number',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyRegNo
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text(
                                              'Contact Number',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyContactNo
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
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
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .3,
                                                child: Center(
                                                  child: Image.network(
                                                    invDetails!
                                                        .data!
                                                        .companyDetails![0]
                                                        .companyLogo
                                                        .toString(),
                                                    width: 150,
                                                  ),
                                                )),
                                            const Text(
                                              'Address',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            SizedBox(
                                                width: 200,
                                                child: Text(
                                                  invDetails!
                                                      .data!
                                                      .companyDetails![0]
                                                      .companyAddress
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                )),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyEmail
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
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
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyRegNo
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text(
                                              'Contact Number',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyContactNo
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text(
                                              'Pin code',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              invDetails!.data!.companyDetails![0]
                                                  .companyPincode
                                                  .toString(),
                                              style:
                                              const TextStyle(fontSize: 14),
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
                          header==false? const SizedBox(
                            height: 5,
                          ):const SizedBox(),
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
                                                    width:
                                                        MediaQuery.of(context)
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
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 24),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        TextFormField(
                                                          controller:
                                                              billingName,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                      const EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                  labelText:
                                                                      'Phone Number',
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  prefix: GestureDetector(
                                                                    onTap: () {
                                                                      showCountryPicker(
                                                                        context: context,
                                                                        searchAutofocus: false,
                                                                        showPhoneCode: true,
                                                                        // optional. Shows phone code before the country name.
                                                                        onSelect: (Country country) {
                                                                          setState(() {
                                                                            code = country.phoneCode;
                                                                          });

                                                                          // flag = country.flagEmoji;
                                                                          // print(countryPickerController.code.value);
                                                                          // print(flag);
                                                                        },
                                                                      );
                                                                    },
                                                                    child: SizedBox(
                                                                      // color: Colors.blue,
                                                                      width: 70,
                                                                      // width: MediaQuery.of(context).size.width/3.5,
                                                                      child: Row(children: [
                                                                        Text("+$code"),
                                                                        const Icon(Icons.arrow_drop_down),
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
                                                                  labelStyle:
                                                                      const TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                                ? ListView.builder(
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
                                                                            TextStyle(color: Colors.grey)),
                                                              )
                                                            : const SizedBox(),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                                                      BorderRadius
                                                                          .circular(
                                                                          5)),
                                                                  child:
                                                                  const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
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
                                                                          color: Colors
                                                                              .black),
                                                                    ),
                                                                  )),
                                                            ),
                                                            const SizedBox(width: 10,),
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
                                                                          BorderRadius
                                                                              .circular(
                                                                                  5)),
                                                                  child:
                                                                      const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top: 10,
                                                                            bottom:
                                                                                10,
                                                                            left:
                                                                                30,
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
                          // const SizedBox(
                          //   height: 5,
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 10, right: 10),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //        Column(
                          //         mainAxisAlignment: MainAxisAlignment.start,
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text(
                          //             'Shipping Address(${shippingName.text})',
                          //             style: const TextStyle(fontSize: 15),
                          //           ),
                          //         ],
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.only(
                          //             left: 7, right: 7, top: 7, bottom: 7),
                          //         child: InkWell(
                          //           onTap: () async {
                          //             showGeneralDialog(
                          //               barrierLabel: "showGeneralDialog",
                          //               barrierDismissible: true,
                          //               barrierColor:
                          //                   Colors.black.withOpacity(0.6),
                          //               transitionDuration:
                          //                   const Duration(milliseconds: 400),
                          //               context: context,
                          //               pageBuilder: (context, _, __) {
                          //                 return StatefulBuilder(
                          //                     builder: (context, setState) {
                          //                   return Align(
                          //                     alignment: Alignment.center,
                          //                     child: SingleChildScrollView(
                          //                       child: AlertDialog(
                          //                         content: SizedBox(
                          //                           width: MediaQuery.of(context).size.width * 1,
                          //                           child: Column(
                          //                             children: [
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               const Text(
                          //                                 'Shipping Address',
                          //                                 style: TextStyle(
                          //                                     fontWeight:
                          //                                         FontWeight
                          //                                             .bold,
                          //                                     fontSize: 24),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               TextFormField(
                          //                                 controller:
                          //                                     shippingName,
                          //                                 decoration: const InputDecoration(
                          //                                         contentPadding:
                          //                                             EdgeInsets.only(
                          //                                                 left:
                          //                                                     10,
                          //                                                 top:
                          //                                                     2,
                          //                                                 bottom:
                          //                                                     2),
                          //                                         labelText:
                          //                                             'Name',
                          //                                         fillColor:
                          //                                             Colors
                          //                                                 .white,
                          //                                         filled: true,
                          //                                         prefixIcon: Icon(
                          //                                             Icons
                          //                                                 .person,
                          //                                             color: Colors
                          //                                                 .grey),
                          //                                         border:
                          //                                             OutlineInputBorder(),
                          //                                         focusedBorder:
                          //                                             OutlineInputBorder(
                          //                                           borderSide:
                          //                                               BorderSide(
                          //                                                   color:
                          //                                                       Colors.grey),
                          //                                         ),
                          //                                         labelStyle:
                          //                                             TextStyle(
                          //                                                 color:
                          //                                                     Colors.grey)),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               TextFormField(
                          //                                 controller:
                          //                                     shippingAddress,
                          //                                 maxLines: 2,
                          //                                 decoration:
                          //                                     const InputDecoration(
                          //                                         contentPadding:
                          //                                             EdgeInsets.only(
                          //                                                 left:
                          //                                                     10,
                          //                                                 top:
                          //                                                     2,
                          //                                                 bottom:
                          //                                                     2),
                          //                                         labelText:
                          //                                             'Address',
                          //                                         fillColor:
                          //                                             Colors
                          //                                                 .white,
                          //                                         filled: true,
                          //                                         prefixIcon: Icon(
                          //                                             Icons
                          //                                                 .location_on,
                          //                                             color: Colors
                          //                                                 .grey),
                          //                                         border:
                          //                                             OutlineInputBorder(),
                          //                                         focusedBorder:
                          //                                             OutlineInputBorder(
                          //                                           borderSide:
                          //                                               BorderSide(
                          //                                                   color:
                          //                                                       Colors.grey),
                          //                                         ),
                          //                                         labelStyle:
                          //                                             TextStyle(
                          //                                                 color:
                          //                                                     Colors.grey)),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               TextFormField(
                          //                                 controller:
                          //                                     shippingPhone,
                          //                                 decoration:
                          //                                     const InputDecoration(
                          //                                         contentPadding:
                          //                                             EdgeInsets.only(
                          //                                                 left:
                          //                                                     10,
                          //                                                 top:
                          //                                                     2,
                          //                                                 bottom:
                          //                                                     2),
                          //                                         labelText:
                          //                                             'Phone Number',
                          //                                         fillColor:
                          //                                             Colors
                          //                                                 .white,
                          //                                         filled: true,
                          //                                         prefixIcon: Icon(
                          //                                             Icons
                          //                                                 .phone,
                          //                                             color: Colors
                          //                                                 .grey),
                          //                                         border:
                          //                                             OutlineInputBorder(),
                          //                                         focusedBorder:
                          //                                             OutlineInputBorder(
                          //                                           borderSide:
                          //                                               BorderSide(
                          //                                                   color:
                          //                                                       Colors.grey),
                          //                                         ),
                          //                                         labelStyle:
                          //                                             TextStyle(
                          //                                                 color:
                          //                                                     Colors.grey)),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               TextFormField(
                          //                                 controller:
                          //                                     shippingGstNo,
                          //                                 decoration:
                          //                                     const InputDecoration(
                          //                                         contentPadding:
                          //                                             EdgeInsets.only(
                          //                                                 left:
                          //                                                     10,
                          //                                                 top:
                          //                                                     2,
                          //                                                 bottom:
                          //                                                     2),
                          //                                         labelText:
                          //                                             'GST Number',
                          //                                         fillColor:
                          //                                             Colors
                          //                                                 .white,
                          //                                         filled: true,
                          //                                         prefixIcon: Icon(
                          //                                             Icons
                          //                                                 .arrow_right,
                          //                                             color: Colors
                          //                                                 .grey),
                          //                                         border:
                          //                                             OutlineInputBorder(),
                          //                                         focusedBorder:
                          //                                             OutlineInputBorder(
                          //                                           borderSide:
                          //                                               BorderSide(
                          //                                                   color:
                          //                                                       Colors.grey),
                          //                                         ),
                          //                                         labelStyle:
                          //                                             TextStyle(
                          //                                                 color:
                          //                                                     Colors.grey)),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               TextFormField(
                          //                                 onChanged:
                          //                                     (value) async {
                          //                                   if (value.length >=
                          //                                       6) {
                          //                                     shippingPostal =
                          //                                         await HttpService
                          //                                             .fetchPostOffice(
                          //                                                 value);
                          //                                     setState(() {});
                          //                                   } else {
                          //                                     shippingPostal =
                          //                                         null;
                          //                                     shippingPostOffice
                          //                                         .clear();
                          //                                     setState(() {});
                          //                                   }
                          //                                 },
                          //                                 controller:
                          //                                     shippingPinCode,
                          //                                 decoration:
                          //                                     const InputDecoration(
                          //                                         contentPadding:
                          //                                             EdgeInsets.only(
                          //                                                 left:
                          //                                                     10,
                          //                                                 top:
                          //                                                     2,
                          //                                                 bottom:
                          //                                                     2),
                          //                                         labelText:
                          //                                             'Pin Code',
                          //                                         fillColor:
                          //                                             Colors
                          //                                                 .white,
                          //                                         filled: true,
                          //                                         prefixIcon: Icon(
                          //                                             Icons
                          //                                                 .pin_drop,
                          //                                             color: Colors
                          //                                                 .grey),
                          //                                         border:
                          //                                             OutlineInputBorder(),
                          //                                         focusedBorder:
                          //                                             OutlineInputBorder(
                          //                                           borderSide:
                          //                                               BorderSide(
                          //                                                   color:
                          //                                                       Colors.grey),
                          //                                         ),
                          //                                         labelStyle:
                          //                                             TextStyle(
                          //                                                 color:
                          //                                                     Colors.grey)),
                          //                               ),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               shippingPostal != null
                          //                                   ? TextFormField(
                          //                                       onTap: () {
                          //                                         showDialog(
                          //                                             context:
                          //                                                 context,
                          //                                             builder:
                          //                                                 (BuildContext
                          //                                                     context) {
                          //                                               return AlertDialog(
                          //                                                   scrollable:
                          //                                                       true,
                          //                                                   title:
                          //                                                       const Text('Post Office'),
                          //                                                   content: shippingPostal!.postOffice != null
                          //                                                       ? ListView.builder(
                          //                                                           shrinkWrap: true,
                          //                                                           itemCount: shippingPostal!.postOffice!.length,
                          //                                                           itemBuilder: (context, ind) {
                          //                                                             return InkWell(
                          //                                                               onTap: () {
                          //                                                                 setState(() {
                          //                                                                   shippingPostOffice.text = shippingPostal!.postOffice![ind].name.toString();
                          //                                                                   Navigator.pop(context, true);
                          //                                                                 });
                          //                                                               },
                          //                                                               child: SizedBox(
                          //                                                                 height: 50,
                          //                                                                 child: Text(
                          //                                                                   shippingPostal!.postOffice![ind].name.toString(),
                          //                                                                   style: const TextStyle(fontSize: 18),
                          //                                                                 ),
                          //                                                               ),
                          //                                                             );
                          //                                                           },
                          //                                                         )
                          //                                                       : const Text('No Post Office Found'));
                          //                                             });
                          //                                       },
                          //                                       maxLines: 1,
                          //                                       readOnly: true,
                          //                                       controller:
                          //                                           shippingPostOffice,
                          //                                       decoration:
                          //                                           const InputDecoration(
                          //                                               contentPadding: EdgeInsets.only(
                          //                                                   left:
                          //                                                       10,
                          //                                                   top:
                          //                                                       2,
                          //                                                   bottom:
                          //                                                       2),
                          //                                               labelText:
                          //                                                   'Post Office',
                          //                                               fillColor:
                          //                                                   Colors
                          //                                                       .white,
                          //                                               filled:
                          //                                                   true,
                          //                                               prefixIcon: Icon(
                          //                                                   Icons
                          //                                                       .arrow_drop_down_circle_outlined,
                          //                                                   color: Colors
                          //                                                       .grey),
                          //                                               border:
                          //                                                   OutlineInputBorder(),
                          //                                               focusedBorder:
                          //                                                   OutlineInputBorder(
                          //                                                 borderSide:
                          //                                                     BorderSide(color: Colors.grey),
                          //                                               ),
                          //                                               labelStyle:
                          //                                                   TextStyle(color: Colors.grey)),
                          //                                     )
                          //                                   : const SizedBox(),
                          //                               const SizedBox(
                          //                                 height: 10,
                          //                               ),
                          //                               GestureDetector(
                          //                                 onTap: () {
                          //                                   Navigator.of(
                          //                                           context)
                          //                                       .pop();
                          //                                 },
                          //                                 child: Container(
                          //                                     decoration: BoxDecoration(
                          //                                         color: Colors
                          //                                             .green,
                          //                                         borderRadius:
                          //                                             BorderRadius
                          //                                                 .circular(
                          //                                                     5)),
                          //                                     child:
                          //                                         const Padding(
                          //                                       padding: EdgeInsets
                          //                                           .only(
                          //                                               top: 10,
                          //                                               bottom:
                          //                                                   10,
                          //                                               left:
                          //                                                   30,
                          //                                               right:
                          //                                                   30),
                          //                                       child: Text(
                          //                                         'Add',
                          //                                         style: TextStyle(
                          //                                             color: Colors
                          //                                                 .white),
                          //                                       ),
                          //                                     )),
                          //                               )
                          //                             ],
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 });
                          //               },
                          //               transitionBuilder:
                          //                   (_, animation1, __, child) {
                          //                 return SlideTransition(
                          //                   position: Tween(
                          //                     begin: const Offset(0, 1),
                          //                     end: const Offset(0, 0),
                          //                   ).animate(animation1),
                          //                   child: child,
                          //                 );
                          //               },
                          //             );
                          //           },
                          //           child: const Icon(
                          //             Icons.edit,
                          //             color: Colors.blue,
                          //             size: 18,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                               Padding(
                                 padding: const EdgeInsets.only(left: 10,right: 10),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                padding: const EdgeInsets.only(left: 10,right: 10),
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
                            height: 5,
                          ),
                          const SizedBox(
                            height: 10,
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
                                                                              .where((item) => item.productName!.toLowerCase().contains(value.toLowerCase()))
                                                                              .toList();
                                                                        });
                                                                      },
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        contentPadding:
                                                                            EdgeInsets.all(8),
                                                                        hintText:
                                                                            'Search',
                                                                        prefixIcon:
                                                                            Icon(Icons.search),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        .3,
                                                                    width: MediaQuery.of(context)
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
                                                                              productName = filteredItems[index].productName!;
                                                                              productId = filteredItems[index].id!;
                                                                              productRate.text = filteredItems[index].sellingPrice!;
                                                                              productTaxPercent.text = filteredItems[index].taxPercent!;
                                                                              productTaxAmount.text = filteredItems[index].taxAmount!;
                                                                              setState(() {});
                                                                              if (context.mounted) {
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                            title:
                                                                                Text(filteredItems[index].productName!));
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
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    16.0,
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
                                                        width: MediaQuery.of(context).size.width *
                                                            0.31,
                                                        child: TextFormField(
                                                          onChanged: (value) {
                                                            if (value == '') {
                                                              value = '0';
                                                            }
                                                            productTaxAmount
                                                                .text = (double.parse(
                                                                        value) *
                                                                double.parse(
                                                                        productTaxPercent
                                                                            .text) /
                                                                    100)
                                                                .toString();
                                                            productTotalAmount
                                                                .text = ((double.parse(
                                                                            value) +
                                                                        double.parse(productTaxAmount
                                                                            .text)) *
                                                                double.parse(
                                                                        productQty
                                                                            .text))
                                                                .toString();
                                                            setState(() {});
                                                          },
                                                          controller:
                                                              productRate,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
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
                                                                            color:
                                                                                Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width *
                                                            0.30,
                                                        child: TextFormField(
                                                          onChanged: (value) {
                                                            if (value == '') {
                                                              value = '0';
                                                            }
                                                            productTotalAmount
                                                                .text = ((double.parse(productRate
                                                                            .text) +
                                                                        double.parse(productTaxAmount
                                                                            .text)) *
                                                                double.parse(
                                                                        value))
                                                                .toString();
                                                            setState(() {});
                                                          },
                                                          controller:
                                                              productQty,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
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
                                                                            color:
                                                                                Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                        width: MediaQuery.of(context).size.width *
                                                            0.30,
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
                                                                .text = ((double.parse(productRate
                                                                            .text) +
                                                                        double.parse(productTaxAmount
                                                                            .text)) *
                                                                double.parse(
                                                                        productQty
                                                                            .text))
                                                                .toString();
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
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width *
                                                            0.31,
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
                                                                          top:
                                                                              2,
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
                                                                      color: Colors
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
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                                      bottom:
                                                                          2),
                                                              labelText:
                                                                  'Total Amount',
                                                              fillColor:
                                                                  Colors.white,
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
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey)),
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
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    5)),
                                                            child:
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
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
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            )),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      GestureDetector(
                                                        onTap: () {
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
                                                                  productRate.text,
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
                                                            totalTaxAmount =
                                                                totalTaxAmount +
                                                                    double.parse(
                                                                        productTaxAmount
                                                                            .text)*double.parse(productQty.text);
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
                                                                color: Colors.green,
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
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 10,
                                          right: 10),
                                      child: Text(
                                        'Add Product Details',
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
                                              0.14), // Using 30%
                                      2: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.14),
                                      3: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.14), // Using 20%
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
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Rate',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Qty',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                0.14), // Using 30%
                                        2: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.14),
                                        3: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.14), // Using 20%
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                products[index]['product_name'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                products[index]['product_rate'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                products[index]['total_amount'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                                    double.parse(products[index]
                                                        ['total_tax_amount'])*double.parse(products[index]
                                                    ['quantity']);

                                                allTotal = subTotal +
                                                    double.parse(shippingCharge
                                                                .text ==
                                                            ''
                                                        ? '0'
                                                        : shippingCharge.text) -
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
                                                            products[index]
                                                                ['product_id'],
                                                        "description":
                                                            products[index]
                                                                ['description'],
                                                        "product_rate":
                                                            products[index][
                                                                'product_rate'],
                                                        "quantity":
                                                            products[index]
                                                                ['quantity'],
                                                        "tax_percent":
                                                            products[index]
                                                                ['tax_percent'],
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                          child: Text(subTotal.toString()),
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                              Text(totalTaxAmount.toString()),
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
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 35,
                                      child: TextFormField(
                                        onTap: (){
                                          if(discount.text=='0.00')
                                            {
                                              discount.clear();
                                            }
                                        },
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
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 35,
                                      child: TextFormField(
                                        onTap: (){
                                          if(shippingCharge.text=='0.00')
                                          {
                                            shippingCharge.clear();
                                          }
                                        },
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
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
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
                              const SizedBox(height: 5,),
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
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        allTotal.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              const Divider(),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: InkWell(
                              onTap: toggleTextFieldVisibility,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Add Remark'),
                                  Icon(isTextFieldVisible==false?Icons.keyboard_arrow_down:Icons.keyboard_arrow_up)
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isTextFieldVisible,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                child: TextFormField(
                                  maxLines: 3,
                                  controller: remarks,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                      hintText: 'Remark',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ),),

                          const SizedBox(
                            height: 20,
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
                                  } else {
                                    print(code);
                                    var body = FormData.fromMap({
                                      'invoice_date': DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                              fromdate.toString())),
                                      'customer_id':
                                          invDetails!.data!.customerId,
                                      'sub_total': subTotal,
                                      'estimated_tax': totalTaxAmount,
                                      'discount_amount': discount.text,
                                      'shipping_amount': shippingCharge.text,
                                      'total_invoice_amount': allTotal,
                                      'remarks': remarks.text,
                                      'billing_name': billingName.text,
                                      'billing_address': billingAddress.text,
                                      'billing_country_code': code,
                                      'billing_contact_no': billingPhone.text,
                                      'billing_gst': billingGstNo.text,
                                      "billing_pincode": billingPinCode.text,
                                      "billing_post_office": billingPostOffice.text,
                                      'shipping_name': shippingName.text,
                                      'shipping_address': shippingAddress.text,
                                      'shipping_contact_no': shippingPhone.text,
                                      'shipping_gst': shippingGstNo.text,
                                      "shipping_pincode": shippingPinCode.text,
                                      "shipping_post_office": shippingPostOffice.text,
                                      "receipt_id":invoiceEditDetails!.data!.receiptId,
                                      "token": widget.token,
                                      "invoice_id":widget.invoiceId,
                                      'product_details': jsonEncode(products),
                                    });

                                    if (context.mounted) {
                                      Common.showProgressDialog(
                                          context, "Loading..");
                                    }
                                    EditInvoiceModel inv =
                                        await HttpService.editInvoice(body);
                                    if (inv.data == true) {
                                      Common.toastMessaage(
                                          inv.message, Colors.green);
                                      if(mounted){
                                        showDialog(
                                            barrierDismissible: false,
                                            barrierColor: Colors.white.withOpacity(.2),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WillPopScope(
                                                onWillPop: () async {
                                                  return false;
                                                },
                                                child: Material(
                                                  type: MaterialType.transparency,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: 50),
                                                    child: Center(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.white,
                                                        ),
                                                         width: MediaQuery.of(context).size.width * 0.9,
                                                        height: 300,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 20, right: 20),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Image.asset(
                                                                'assets/icons/check.png',
                                                                width: 80,
                                                              ),
                                                              const SizedBox(height: 10,),
                                                              const Text('Success',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
                                                              const SizedBox(height: 5,),
                                                              Text(inv.message.toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                                                              const SizedBox(height: 15,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  InkWell(
                                                                    onTap:(){
                                                                      Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                Dashboard(widget.token)),
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                                      //  color: RandomColorModel().getColor(),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.green.shade100,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Column(
                                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(Icons.dashboard,size: 15,),
                                                                            SizedBox(height: 5,),
                                                                            Text('Dashboard',style: TextStyle(fontSize: 13, color: Colors.black),
                                                                                textAlign: TextAlign.center),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:(){
                                                                      Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                InvoiceList(widget.token)),
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.green.shade100,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Column(
                                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(Icons.list_alt,size: 15,),
                                                                            SizedBox(height: 5,),
                                                                            Text('Invoice',style: TextStyle(fontSize: 13, color: Colors.black),
                                                                                textAlign: TextAlign.center),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:(){
                                                                      Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ReceiptAdd(widget.token,widget.clientId,widget.invoiceId)),
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.green.shade100,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Column(
                                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(Icons.currency_rupee,size: 15,),
                                                                            SizedBox(height: 5,),
                                                                            Text('Receipt',style: TextStyle(fontSize: 13, color: Colors.black),
                                                                                textAlign: TextAlign.center),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 8,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  InkWell(
                                                                    onTap:(){
                                                                      Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                HomePage(widget.token)),
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                                      //  color: RandomColorModel().getColor(),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.green.shade100,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Column(
                                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(Icons.home,size: 15,),
                                                                            SizedBox(height: 5,),
                                                                            Text('Home',style: TextStyle(fontSize: 13, color: Colors.black),
                                                                                textAlign: TextAlign.center),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:(){
                                                                      Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ClientList(widget.token)),
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.green.shade100,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Column(
                                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(Icons.person,size: 15,),
                                                                            SizedBox(height: 5,),
                                                                            Text('Clients',style: TextStyle(fontSize: 13, color: Colors.black),
                                                                                textAlign: TextAlign.center),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width * 0.25,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.green.shade100,
                                                                        borderRadius: BorderRadius.circular(10)
                                                                    ),
                                                                    child: const Padding(
                                                                      padding: EdgeInsets.all(5),
                                                                      child: Column(
                                                                        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Icon(Icons.details,size: 15,),
                                                                          SizedBox(height: 5,),
                                                                          Text('Others',style: TextStyle(fontSize: 13, color: Colors.black),
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
                                      // if (mounted) {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => EditInvoice(
                                      //             widget.token,
                                      //             widget.invoiceId,
                                      //             widget.clientId)),
                                      //   );
                                      // }
                                    } else {
                                      Common.toastMessaage(
                                          inv.message, Colors.red);
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
                                          left: 25,
                                          right: 25),
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

  void calculateTotal() {
    setState(() {
      if (discount.text.isNotEmpty) {
        allTotal = allTotal - double.parse(discount.text);
      }

      if (shippingCharge.text.isNotEmpty) {
        allTotal = allTotal + double.parse(shippingCharge.text);
      }
    });
  }

  void calculateTaxAmt() {
    setState(() {
      productTaxAmount.text = (double.parse(productRate.text) *
          double.parse(productQty.text) *
          double.parse(productTaxPercent.text) /
              100)
          .toString();
      if (productTaxAmount.text.isNotEmpty) {
        productTotalAmount.text =
            (double.parse(productRate.text) * double.parse(productQty.text) +
                    double.parse(productTaxAmount.text))
                .toString();
      }
    });
  }
}
