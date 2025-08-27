import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/renewal_by_id_model.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/service/service.dart';

// ignore: must_be_immutable
class RenewCustomRenewal extends StatefulWidget {
  String renId;
  String renewalType;
  RenewCustomRenewal(
      {super.key, required this.renId, required this.renewalType});

  @override
  State<RenewCustomRenewal> createState() => _RenewCustomRenewalState();
}

class _RenewCustomRenewalState extends State<RenewCustomRenewal> {
  bool isLoading = true;
  bool uploading = false;
  bool _formSubmitted = false;
  final formKey = GlobalKey<FormState>();
  List filteredProducts = [];
  List filteredNames = [];
  List productName = [];
  RenewalByIdModel? renewalDetails;
  TextEditingController subTotal = TextEditingController();
  TextEditingController totalTax = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController totalAmount = TextEditingController();
  TextEditingController totalPaidAmount = TextEditingController();
  TextEditingController productQuantity = TextEditingController(text: '1');
  TextEditingController prodDetails = TextEditingController();
  TextEditingController prodAmount = TextEditingController();
  TextEditingController prodTax = TextEditingController();
  TextEditingController prodRate = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController remindMe = TextEditingController();
  TextEditingController remark = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController invoiceDate = TextEditingController();
  TextEditingController invoiceNumber = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController staffName = TextEditingController();
  TextEditingController search = TextEditingController();

  DateTime? selectedValue;
  BranchListModel? branchList;
  String multiBranch = "false";
  dynamic branch;
  dynamic branchNew;
  String typeDuration = "";
  String invoiceSlNum = "";
  String productId = "";
  IsCustomerExistModel? isExist;
  List filteredTemplates = [];
  String templateId = "";
  double totalProductTax = 0;
  double totalProductCost = 0;
  List products = [];
  dynamic payStat;
  dynamic payMethod;
  double shippingAmt = 0;
  double discountAmt = 0;
  double productTax = 0;
  double parseRate = 0;
  double parseQty = 0;
  double parseTax = 0;
  String customerId = "";
  PostRenewalModel? renewResponse;
  List<Staff> filteredStaff = [];
  String staffId = "";
  List<TargetGroup> targets = [];
  List<TargetGroup> filteredTargets = [];
  List targetGroups = [];
  List targetGroupNames = [];

  getBranch() async {
    multiBranch = await Common.getSharedPref("multiBranch");
    String token = await Common.getSharedPref("token");
    branchList = await HttpService.getBranchList(token);
    if (branchList != null) {}
  }

  postRenewal() async {
    try {
      renewResponse = await HttpService.postRenewCustom(
          renewalDetails!.data.renewalId,
          customerId,
          branch,
          startDate.text,
          endDate.text,
          widget.renewalType,
          products,
          templateId,
          remark.text,
          renewalDetails!.data.invoicelId,
          payStat,
          payMethod,
          renewalDetails!.data.cartId,
          subTotal.text,
          totalTax.text,
          discount.text,
          shippingCharge.text,
          totalAmount.text,
          totalPaidAmount.text,
          invoiceDate.text,
          staffId,
          targetGroups);
      if (renewResponse != null && renewResponse!.status == true) {
        Common.toastMessaage(renewResponse!.message, Colors.green);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Common.toastMessaage(renewResponse!.message, Colors.red);
        setState(() {
          uploading = false;
        });
      }
    } catch (e) {
      log("error: $e");
      Common.toastMessaage("Something went wrong..!", Colors.red);
      setState(() {
        uploading = false;
      });
    }
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    renewalDetails = await HttpService.getRenewalDetailsById(
        widget.renId, widget.renewalType);

    if (renewalDetails != null && renewalDetails!.status == true) {
      getBranch();
      invoiceSlNum = renewalDetails!.data.slNumber;
      invoiceNumber.text = renewalDetails!.data.invoiceNumber.toString();
      invoiceDate.text = formatDate(DateTime.now());
      filteredNames = renewalDetails!.data.customers;
      filteredProducts = renewalDetails!.data.allProducts;
      filteredTemplates = renewalDetails!.data.renewalTemplate;
      subTotal.text = renewalDetails!.data.subTotal;
      totalTax.text = renewalDetails!.data.estimatedTax;
      discount.text = renewalDetails!.data.discountAmount;
      shippingCharge.text = renewalDetails!.data.shippingAmount;
      totalAmount.text = renewalDetails!.data.totalAmount;
      customerName.text = renewalDetails!.data.customerName;
      customerId = renewalDetails!.data.clientId;
      totalPaidAmount.text = renewalDetails!.data.totalAmount;
      startDate.text = renewalDetails!.data.nextStartDate;
      endDate.text = renewalDetails!.data.nextEndDate;
      remindMe.text = renewalDetails!.data.templateName;
      templateId = renewalDetails!.data.templateId;
      remark.text = renewalDetails!.data.remarks;
      typeDuration = renewalDetails!.data.noOfDays;
      filteredStaff.addAll(renewalDetails!.data.staff);
      targets = renewalDetails!.data.targetGroups;
      filteredTargets.addAll(targets);

      for (int i = 0; i < renewalDetails!.data.invoiceLists.length; i++) {
        double rate = double.parse(renewalDetails!.data.invoiceLists[i].rate);
        double qty = double.parse(renewalDetails!.data.invoiceLists[i].qty);
        double rateTotal = rate * qty;

        productName.add(renewalDetails!.data.invoiceLists[i].productName);
        products.add({
          "product_id": renewalDetails!.data.invoiceLists[i].productId,
          "product_name": renewalDetails!.data.invoiceLists[i].productName,
          "product_rate": renewalDetails!.data.invoiceLists[i].rate,
          "quantity": renewalDetails!.data.invoiceLists[i].qty,
          "tax_percent": renewalDetails!.data.invoiceLists[i].taxPercentage,
          "total_tax_amount": renewalDetails!.data.invoiceLists[i].taxAmount,
          "total_amount": renewalDetails!.data.invoiceLists[i].amount,
          "rate_total": rateTotal.toString(),
          "description":
              renewalDetails!.data.invoiceLists[i].productDescription,
        });
      }

      // Recalculate totals based on the new logic
      recalculateTotals();

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void recalculateTotals() {
    totalProductCost = 0;
    totalProductTax = 0;
    double totalRate = 0;

    for (int i = 0; i < products.length; i++) {
      totalProductCost += double.parse(products[i]["total_amount"]);
      totalProductTax += double.parse(products[i]["total_tax_amount"]);
      totalRate += double.parse(products[i]["rate_total"] ?? "0");
    }

    subTotal.text = totalRate.toStringAsFixed(2);
    totalTax.text = totalProductTax.toStringAsFixed(2);
    discountAmt = double.parse(discount.text.isEmpty ? "0.0" : discount.text);
    shippingAmt =
        double.parse(shippingCharge.text.isEmpty ? "0" : shippingCharge.text);

    // Total = Subtotal + Tax - Discount + Shipping
    totalAmount.text = (totalRate + totalProductTax - discountAmt + shippingAmt)
        .toStringAsFixed(2);
    totalPaidAmount.text = totalAmount.text;
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
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
                        "RENEW PRODUCT",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : FormWidget(context),
    );
  }

  SafeArea FormWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 20),
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
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Invoice Date : ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          )),
                      InkWell(
                        onTap: () async {
                          selectedValue = (await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ))!;
                          setState(() {
                            invoiceDate.text =
                                DateFormat('dd-MM-yyyy').format(selectedValue!);
                          });
                        },
                        child: Center(
                          child: Text(invoiceDate.text,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: customerName,
                  readOnly: true,
                  onTap: (() {
                    // dropDialog(context, "Customers");
                  }),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Add Customer";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Customer *',
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                multiBranch == 'true'
                    ? DropdownButtonFormField(
                        value: branch,
                        onChanged: (value) async {
                          setState(() {
                            branch = value.toString();
                          });
                        },
                        items: branchList!.data!.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.branchId.toString(),
                            child: Text(
                              data.branchName.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            // Custom border
                            borderRadius: BorderRadius.circular(5),
                          ),
                          labelText: 'Select Branch',
                          prefixIcon: const Icon(
                              Icons.arrow_drop_down_circle_outlined,
                              color: Colors.grey),
                          labelStyle: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 14.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Products",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        addProductsDialog(context);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                                MediaQuery.of(context).size.width * 0.10),
                            3: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.16), // Using 20%
                            4: FixedColumnWidth(
                                MediaQuery.of(context).size.width * 0.22),
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
                ),
                SingleChildScrollView(
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
                                MediaQuery.of(context).size.width * 0.10),
                            3: FixedColumnWidth(
                                MediaQuery.of(context).size.width *
                                    0.16), // Using 20%
                            4: FixedColumnWidth(
                                MediaQuery.of(context).size.width * 0.22),
                            5: FixedColumnWidth(
                                MediaQuery.of(context).size.width * 0.10),
                          },
                          children: [
                            // Each TableRow represents a row in the Table
                            TableRow(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                color: color,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index]['product_name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index]['product_rate'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index]['quantity'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index]['total_tax_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    products[index]['total_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _editProduct(context, index);
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: const Text(
                                              "Are you sure you want to delete this product?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        products.removeAt(index);
                                        productName.removeAt(index);
                                        recalculateTotals();
                                        setState(() {});
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(
                                        value: 'delete', child: Text('Delete')),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          child: Text(
                            "Total :",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            readOnly: true,
                            controller: subTotal,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                //labelText: 'Invoice Number',
                                fillColor: Colors.grey[300],
                                filled: true,
                                // border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          child: Text(
                            "Tax  :",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            readOnly: true,
                            controller: totalTax,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                //labelText: 'Invoice Number',
                                fillColor: Colors.grey[300],
                                filled: true,
                                // border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     const SizedBox(
                    //       child: Text(
                    //         "Discount :",
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w500),
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     SizedBox(
                    //       width: MediaQuery.of(context).size.width * 0.3,
                    //       height: 35,
                    //       child: TextFormField(
                    //         onChanged: (val) {
                    //           discountAmt = double.parse(
                    //               discount.text == "" ? "0.0" : discount.text);
                    //           recalculateTotals();
                    //         },
                    //         keyboardType: TextInputType.number,
                    //         controller: discount,
                    //         decoration: InputDecoration(
                    //             border: const OutlineInputBorder(
                    //               // width: 0.0 produces a thin "hairline" border
                    //               borderRadius:
                    //                   BorderRadius.all(Radius.circular(5)),
                    //               borderSide: BorderSide.none,
                    //             ),
                    //             contentPadding: const EdgeInsets.only(
                    //                 left: 10, top: 2, bottom: 2),
                    //             //labelText: 'Invoice Number',
                    //             fillColor: Colors.grey[300],
                    //             filled: true,
                    //             // border: const OutlineInputBorder(),
                    //             focusedBorder: OutlineInputBorder(
                    //               borderSide:
                    //                   BorderSide(color: Colors.grey.shade300),
                    //             ),
                    //             labelStyle:
                    //                 const TextStyle(color: Colors.black)),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          child: Text(
                            "Discount :",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            onChanged: (val) {
                              discountAmt = double.tryParse(val) ?? 0.0;
                              recalculateTotals();
                              setState(() {});
                            },
                            keyboardType: TextInputType.number,
                            controller: discount,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                fillColor: Colors.grey[300],
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          child: Text(
                            "Shipping Charge :",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            onChanged: (val) {
                              shippingAmt = double.parse(
                                  shippingCharge.text == ""
                                      ? "0"
                                      : shippingCharge.text);
                              recalculateTotals();
                            },
                            keyboardType: TextInputType.number,
                            controller: shippingCharge,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                //labelText: 'Invoice Number',
                                fillColor: Colors.grey[300],
                                filled: true,
                                // border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
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
                    const Divider(),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 95),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Grand Total :',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              totalAmount.text,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Payment Status * :'),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonFormField(
                            validator: (val) {
                              if (val == "" || val == null) {
                                return "Add payment status";
                              }
                              return null;
                            },
                            value: payStat,
                            onChanged: (value) async {
                              payStat = value.toString();
                              setState(() {});
                            },
                            items: renewalDetails!.data.paymentStatusList
                                .map((data) {
                              return DropdownMenuItem<String>(
                                value: data.paymentStatus.toString(),
                                child: Text(
                                  data.displaySts.toString(),
                                ),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 8.0, right: 5.0, bottom: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Visibility(
                      visible: payStat == "partial" || payStat == "paid",
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Paid Amount * :'),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: (totalPaidAmount.text.isNotEmpty &&
                                        double.tryParse(totalAmount.text) !=
                                            null &&
                                        double.tryParse(
                                                totalPaidAmount.text)! >=
                                            double.tryParse(totalAmount.text)!)
                                    ? 80
                                    : 55,
                                child: TextFormField(
                                  validator: (value) {
                                    if (payStat == "partial") {
                                      final val = double.tryParse(value ?? "");
                                      final total =
                                          double.tryParse(totalAmount.text);
                                      if (val == null || val == 0) {
                                        return "Enter Amount";
                                      } else if (total != null &&
                                          val >= total) {
                                        return "Paid amount cannot be greater than or equal to Sub Total";
                                      }
                                    }
                                    return null;
                                  },
                                  readOnly: payStat != "partial" ? true : false,
                                  keyboardType: TextInputType.number,
                                  controller: totalPaidAmount,
                                  onChanged: (value) {
                                    if (formKey.currentState != null) {
                                      formKey.currentState!.validate();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    errorMaxLines: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Pay Method * :'),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                ),
                                child: DropdownButtonFormField(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 8.0, right: 5.0, bottom: 10)),
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text('Payment Method'),
                                  ),
                                  validator: (value) {
                                    if (payStat == "partial" ||
                                        payStat == "paid") {
                                      if (value == "" || value == null) {
                                        return "Select a payment method";
                                      }
                                    }
                                    return null;
                                  },
                                  value: payMethod,
                                  onChanged: (value) async {
                                    setState(() {
                                      payMethod = value.toString();
                                    });
                                    if (formKey.currentState != null) {
                                      formKey.currentState!.validate();
                                    }
                                  },
                                  items: renewalDetails!.data.paymentMethods
                                      .map((data) {
                                    return DropdownMenuItem<String>(
                                      value: data.id.toString(),
                                      child: Text(data.name.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Account Head * :'),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 55,
                                      child: TextFormField(
                                        readOnly: true,
                                        validator: (value) {
                                          if (_formSubmitted &&
                                              (payStat == "partial" ||
                                                  payStat == "paid")) {
                                            if (value == "" || value == null) {
                                              return "Select Account Head";
                                            }
                                          }
                                          return null;
                                        },
                                        onTap: () {
                                          collectedStaffDialog(context)
                                              .then((_) {
                                            if (formKey.currentState != null) {
                                              formKey.currentState!.validate();
                                            }
                                          });
                                        },
                                        controller: staffName,
                                        onChanged: (value) {
                                          if (formKey.currentState != null) {
                                            formKey.currentState!.validate();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          fillColor: Colors.grey[300],
                                          filled: true,
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    // Add space for validation message without affecting layout
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Target Group :',
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: GestureDetector(
                                    onTap: () {
                                      targetGroupDialog(context);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey.shade300,
                                      ),
                                      child: targetGroups.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  top: 15,
                                                  bottom: 10),
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
                                                              left: 5,
                                                              right: 5),
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
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      child:
                                                                          Text(
                                                                        targetGroupNames[
                                                                            i],
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black,
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
                                                                            const Text('Are you sure to Remove this Number?'),
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
                                                              child: Container(
                                                                height: 35,
                                                                width: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            0),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade100,
                                                                    borderRadius: const BorderRadius
                                                                        .only(
                                                                        topRight:
                                                                            Radius.circular(
                                                                                6),
                                                                        bottomRight:
                                                                            Radius.circular(6))),
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .red,
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
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startDate,
                        readOnly: true,
                        onTap: () async {
                          DateTime initialDate = DateTime.now();
                          if (startDate.text.isNotEmpty) {
                            try {
                              initialDate = DateFormat('dd-MM-yyyy')
                                  .parse(startDate.text);
                            } catch (e) {
                              initialDate = DateTime.now(); // fallback
                            }
                          }

                          selectedValue = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (selectedValue != null) {
                            setState(() {
                              startDate.text = formatDate(selectedValue!);
                              final endValue = selectedValue!
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDate.text = formatDate(endValue);
                            });
                          }
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
                          prefixIcon:
                              Icon(Icons.calendar_month, color: Colors.grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          DateTime initial = DateTime.now();
                          if (endDate.text.isNotEmpty) {
                            try {
                              initial =
                                  DateFormat('dd-MM-yyyy').parse(endDate.text);
                            } catch (e) {
                              initial = DateTime
                                  .now(); // fallback in case of parse error
                            }
                          }

                          DateTime? selectedEndDate = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          endDate.text = formatDate(selectedEndDate!);
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
                          prefixIcon:
                              Icon(Icons.calendar_month, color: Colors.grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  onTap: () {
                    dropDialog(context, "Template");
                  },
                  readOnly: true,
                  controller: remindMe,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      labelText: 'Remind Template',
                      prefixIcon: Icon(Icons.notifications, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: remark,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      labelText: 'Remarks',
                      prefixIcon: Icon(Icons.description, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
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
                    onPressed: () {
                      if (uploading == false) {
                        setState(() {
                          _formSubmitted = true;
                        });

                        if (formKey.currentState!.validate() &&
                            products.isNotEmpty) {
                          setState(() {
                            uploading = true;
                          });
                          postRenewal();
                        } else if (products.isEmpty) {
                          Common.toastMessaage(
                              "Add a product to continue", Colors.red);
                        } else {
                          Common.toastMessaage(
                              "Fill all required fields", Colors.red);
                        }
                      }
                    },
                    child: uploading == true
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          )
                        : const Text(
                            "Renew",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> dropDialog(BuildContext context, String title) {
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
                              search.clear();
                              filteredStaff.clear();
                              filteredStaff.addAll(renewalDetails!.data.staff);
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
                        controller: search,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        autofocus: true,
                        onChanged: ((value) {
                          if (title == "Customers") {
                            setState(() {
                              filterCustomers(value);
                            });
                          } else if (title == "Template") {
                            setState(() {
                              filterTemplates(value);
                            });
                          } else {
                            setState(() {
                              filterProducts(value);
                            });
                          }
                        }),
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
                    itemCount: title == "Customers"
                        ? filteredNames.length
                        : title == "Template"
                            ? filteredTemplates.length
                            : filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFFCFBFA)),
                          child: ListTile(
                            onTap: () async {
                              if (title == "Customers") {
                                customerName.text = filteredNames[index].name;
                                customerId = filteredNames[index].id;
                              } else if (title == "Template") {
                                remindMe.text =
                                    filteredTemplates[index].templateName;
                                templateId = filteredTemplates[index].id;
                              } else {
                                productId = filteredProducts[index].id;
                                productNameController.text =
                                    filteredProducts[index].productName;
                                prodRate.text =
                                    filteredProducts[index].sellingPrice;
                                prodTax.text =
                                    filteredProducts[index].taxPercent;
                                typeDuration = filteredProducts[index].noOfDays;
                                calculateTotal();
                              }
                              Navigator.pop(context);
                              setState(() {});
                              filterCustomers("");
                              filteredProducts;
                              filteredTemplates;
                            },
                            title: SizedBox(
                              width: 200,
                              child: Text(
                                title == "Customers"
                                    ? filteredNames[index].name.toString()
                                    : title == "Template"
                                        ? filteredTemplates[index].templateName
                                        : filteredProducts[index]
                                            .productName
                                            .toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            ),
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Text(title == "Customers"
                                  ? filteredNames[index].name[0]
                                  : title == "Template"
                                      ? filteredTemplates[index].templateName[0]
                                      : filteredProducts[index].productName[0]),
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

  calculateTotal() {
    parseRate = double.parse(prodRate.text);
    parseQty = double.parse(productQuantity.text);
    parseTax = double.parse(prodTax.text);
    productTax = ((parseRate * parseQty) * parseTax / 100);
    prodAmount.text = (productTax + (parseRate * parseQty)).toString();
  }

  // addProduct() async {
  //   if (productName.contains(productNameController.text)) {
  //     Common.toastMessaage('Already Added', Colors.red);
  //   } else {
  //     if (productNameController.text != "") {
  //       products.add({
  //         "product_id": productId,
  //         "product_name": productNameController.text,
  //         "product_rate": prodRate.text,
  //         "quantity": productQuantity.text,
  //         "tax_percent": prodTax.text,
  //         "total_tax_amount": productTax.toString(),
  //         "total_amount": prodAmount.text,
  //         "description": prodDetails.text,
  //       });
  //       productName.add(productNameController.text);
  //       productNameController.text = "";
  //       prodRate.text = "";
  //       productQuantity.text = "1";
  //       prodTax.text = "";
  //       prodAmount.text = "";
  //       prodDetails.text = "";
  //       totalProductCost = 0;
  //       totalProductTax = 0;
  //       for (int i = 0; i < products.length; i++) {
  //         totalProductCost += double.parse((await products[i])["total_amount"]);
  //         totalProductTax +=
  //             double.parse((await products[i])["total_tax_amount"]);
  //       }
  //       subTotal.text = totalProductCost.toString();
  //       totalTax.text = totalProductTax.toString();
  //       discountAmt = double.parse(discount.text == "" ? "0.0" : discount.text);
  //       shippingAmt =
  //           double.parse(shippingCharge.text == "" ? "0" : shippingCharge.text);
  //       totalAmount.text =
  //           (totalProductCost - discountAmt + shippingAmt).toString();
  //       totalPaidAmount.text = totalAmount.text;
  //       Navigator.pop(context);
  //       setState(() {});
  //     } else {
  //       Common.toastMessaage('Add a product', Colors.red);
  //     }
  //   }
  // }
  addProduct() async {
    if (productName.contains(productNameController.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameController.text != "") {
        double rateTotal = parseRate * parseQty;
        double taxTotal = ((parseRate * parseQty) * parseTax / 100);

        products.add({
          "product_id": productId,
          "product_name": productNameController.text,
          "product_rate": prodRate.text,
          "quantity": productQuantity.text,
          "tax_percent": prodTax.text,
          "total_tax_amount": taxTotal.toString(),
          "total_amount": (rateTotal + taxTotal).toString(),
          "rate_total": rateTotal.toString(),
          "description": prodDetails.text,
        });

        productName.add(productNameController.text);
        productNameController.text = "";
        prodRate.text = "";
        productQuantity.text = "1";
        prodTax.text = "";
        prodAmount.text = "";
        prodDetails.text = "";

        // Recalculate totals
        totalProductCost = 0;
        totalProductTax = 0;
        double totalRate = 0;

        for (int i = 0; i < products.length; i++) {
          totalProductCost += double.parse(products[i]["total_amount"]);
          totalProductTax += double.parse(products[i]["total_tax_amount"]);
          totalRate += double.parse(products[i]["rate_total"] ?? "0");
        }

        subTotal.text = totalRate.toString();
        totalTax.text = totalProductTax.toString();
        discountAmt = double.parse(discount.text == "" ? "0.0" : discount.text);
        shippingAmt =
            double.parse(shippingCharge.text == "" ? "0" : shippingCharge.text);
        totalAmount.text =
            (totalRate - discountAmt + shippingAmt + totalProductTax)
                .toString();
        totalPaidAmount.text = totalAmount.text;

        Navigator.pop(context);
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
    }
  }

  void filterCustomers(
    String query,
  ) {
    filteredNames = renewalDetails!.data.customers
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterProducts(
    String query,
  ) {
    filteredProducts = renewalDetails!.data.allProducts
        .where((map) =>
            map.productName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterTemplates(
    String query,
  ) {
    filteredTemplates = renewalDetails!.data.renewalTemplate
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  formatDate(DateTime date) {
    String formated = "";
    formated = DateFormat('dd-MM-yyyy').format(date);
    return formated;
  }

  // void _editProduct(BuildContext context, int index) {
  //   double ratePerUnit = double.tryParse(products[index]['product_rate']) ?? 0;
  //   double qty = double.tryParse(products[index]['quantity']) ?? 0;
  //   double taxPerUnit =
  //       double.tryParse(products[index]['total_tax_amount']) ?? 0;

  //   final TextEditingController rateController =
  //       TextEditingController(text: (ratePerUnit * qty).toStringAsFixed(2));
  //   final TextEditingController qtyController =
  //       TextEditingController(text: qty.toStringAsFixed(0));
  //   final TextEditingController taxController =
  //       TextEditingController(text: (taxPerUnit * qty).toStringAsFixed(2));

  //   void recalcFields() {
  //     double newQty = double.tryParse(qtyController.text) ?? 0;
  //     rateController.text = (ratePerUnit * newQty).toStringAsFixed(2);
  //     taxController.text = (taxPerUnit * newQty).toStringAsFixed(2);
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Product'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: rateController,
  //               readOnly: false,
  //               decoration: const InputDecoration(labelText: 'Total Rate'),
  //               keyboardType: TextInputType.number,
  //             ),
  //             Row(
  //               children: [
  //                 IconButton(
  //                   icon: const Icon(Icons.remove),
  //                   onPressed: () {
  //                     int currentQty = int.tryParse(qtyController.text) ?? 0;
  //                     if (currentQty > 1) {
  //                       qtyController.text = (currentQty - 1).toString();
  //                       recalcFields();
  //                     }
  //                   },
  //                 ),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: qtyController,
  //                     decoration: const InputDecoration(labelText: 'Quantity'),
  //                     keyboardType: TextInputType.number,
  //                     onChanged: (_) => recalcFields(),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.add),
  //                   onPressed: () {
  //                     int currentQty = int.tryParse(qtyController.text) ?? 0;
  //                     qtyController.text = (currentQty + 1).toString();
  //                     recalcFields();
  //                   },
  //                 ),
  //               ],
  //             ),
  //             TextField(
  //               controller: taxController,
  //               readOnly: true,
  //               decoration: const InputDecoration(labelText: 'Total Tax'),
  //               keyboardType: TextInputType.number,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel')),
  //           TextButton(
  //               onPressed: () {
  //                 double finalQty = double.tryParse(qtyController.text) ?? 0;
  //                 double finalRate = double.tryParse(rateController.text) ?? 0;
  //                 double finalTax = double.tryParse(taxController.text) ?? 0;

  //                 products[index]['quantity'] = finalQty.toStringAsFixed(0);
  //                 products[index]['product_rate'] =
  //                     ratePerUnit.toStringAsFixed(2); // keep per-unit rate
  //                 products[index]['total_tax_amount'] =
  //                     finalTax.toStringAsFixed(2);
  //                 products[index]['total_amount'] =
  //                     (finalRate + finalTax).toStringAsFixed(2);

  //                 // Recalculate totals
  //                 totalProductCost = 0;
  //                 totalProductTax = 0;
  //                 for (int i = 0; i < products.length; i++) {
  //                   totalProductCost +=
  //                       double.parse(products[i]["total_amount"]);
  //                   totalProductTax +=
  //                       double.parse(products[i]["total_tax_amount"]);
  //                 }
  //                 subTotal.text = totalProductCost.toString();
  //                 totalTax.text = totalProductTax.toString();
  //                 shippingAmt = double.parse(
  //                     shippingCharge.text.isEmpty ? "0" : shippingCharge.text);
  //                 totalAmount.text =
  //                     (totalProductCost - discountAmt + shippingAmt).toString();
  //                 totalPaidAmount.text = totalAmount.text;

  //                 setState(() {});
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('Update')),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _editProduct(BuildContext context, int index) {
  //   double ratePerUnit = double.tryParse(products[index]['product_rate']) ?? 0;
  //   double qty = double.tryParse(products[index]['quantity']) ?? 0;
  //   double taxPercent = double.tryParse(products[index]['tax_percent']) ?? 0;

  //   final TextEditingController rateController =
  //       TextEditingController(text: (ratePerUnit * qty).toStringAsFixed(2));
  //   final TextEditingController qtyController =
  //       TextEditingController(text: qty.toStringAsFixed(0));
  //   final TextEditingController taxController =
  //       TextEditingController(text: taxPercent.toStringAsFixed(2));

  //   void recalcFields() {
  //     double newQty = double.tryParse(qtyController.text) ?? 0;
  //     double newTaxPercent = double.tryParse(taxController.text) ?? 0;
  //     rateController.text = (ratePerUnit * newQty).toStringAsFixed(2);
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Product'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: rateController,
  //               readOnly: false,
  //               decoration: const InputDecoration(labelText: 'Total Rate'),
  //             ),
  //             Row(
  //               children: [
  //                 IconButton(
  //                   icon: const Icon(Icons.remove),
  //                   onPressed: () {
  //                     int currentQty = int.tryParse(qtyController.text) ?? 0;
  //                     if (currentQty > 1) {
  //                       qtyController.text = (currentQty - 1).toString();
  //                       recalcFields();
  //                     }
  //                   },
  //                 ),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: qtyController,
  //                     decoration: const InputDecoration(labelText: 'Quantity'),
  //                     keyboardType: TextInputType.number,
  //                     onChanged: (_) => recalcFields(),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.add),
  //                   onPressed: () {
  //                     int currentQty = int.tryParse(qtyController.text) ?? 0;
  //                     qtyController.text = (currentQty + 1).toString();
  //                     recalcFields();
  //                   },
  //                 ),
  //               ],
  //             ),
  //             TextField(
  //               controller: taxController,
  //               decoration: const InputDecoration(labelText: 'Tax %'),
  //               keyboardType: TextInputType.number,
  //               onChanged: (_) => recalcFields(),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel')),
  //           TextButton(
  //               onPressed: () {
  //                 double finalQty = double.tryParse(qtyController.text) ?? 0;
  //                 double finalTaxPercent =
  //                     double.tryParse(taxController.text) ?? 0;
  //                 double rateTotal = ratePerUnit * finalQty;
  //                 double taxTotal = (rateTotal * finalTaxPercent) / 100;

  //                 products[index]['quantity'] = finalQty.toStringAsFixed(0);
  //                 products[index]['tax_percent'] =
  //                     finalTaxPercent.toStringAsFixed(2);
  //                 products[index]['total_tax_amount'] =
  //                     taxTotal.toStringAsFixed(2);
  //                 products[index]['rate_total'] = rateTotal.toStringAsFixed(2);
  //                 products[index]['total_amount'] =
  //                     (rateTotal + taxTotal).toStringAsFixed(2);

  //                 // Recalculate totals
  //                 totalProductCost = 0;
  //                 totalProductTax = 0;
  //                 double totalRate = 0;

  //                 for (int i = 0; i < products.length; i++) {
  //                   totalProductCost +=
  //                       double.parse(products[i]["total_amount"]);
  //                   totalProductTax +=
  //                       double.parse(products[i]["total_tax_amount"]);
  //                   totalRate += double.parse(products[i]["rate_total"] ?? "0");
  //                 }

  //                 subTotal.text = totalRate.toString();
  //                 totalTax.text = totalProductTax.toString();
  //                 shippingAmt = double.parse(
  //                     shippingCharge.text.isEmpty ? "0" : shippingCharge.text);
  //                 totalAmount.text =
  //                     (totalRate - discountAmt + shippingAmt + totalProductTax)
  //                         .toString();
  //                 totalPaidAmount.text = totalAmount.text;

  //                 setState(() {});
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('Update')),
  //         ],
  //       );
  //     },
  //   );
  // }
void _editProduct(BuildContext context, int index) {
  double ratePerUnit = double.tryParse(products[index]['product_rate']) ?? 0;
  double qty = double.tryParse(products[index]['quantity']) ?? 0;
  double taxPercent = double.tryParse(products[index]['tax_percent']) ?? 0;

  // Controllers
  final TextEditingController rateController =
      TextEditingController(text: ratePerUnit.toStringAsFixed(2));
  final TextEditingController qtyController =
      TextEditingController(text: qty.toStringAsFixed(0));
  final TextEditingController taxController =
      TextEditingController(text: taxPercent.toStringAsFixed(2));
  final TextEditingController totalController =
      TextEditingController(text: (ratePerUnit * qty).toStringAsFixed(2));

  void recalcFields() {
    double newQty = double.tryParse(qtyController.text) ?? 0;
    double newRate = double.tryParse(rateController.text) ?? 0;
    totalController.text = (newRate * newQty).toStringAsFixed(2);
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rate per unit
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate per Unit',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => recalcFields(),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {
                              int currentQty = int.tryParse(qtyController.text) ?? 0;
                              if (currentQty > 1) {
                                qtyController.text = (currentQty - 1).toString();
                                recalcFields();
                              }
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: qtyController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => recalcFields(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              int currentQty = int.tryParse(qtyController.text) ?? 0;
                              qtyController.text = (currentQty + 1).toString();
                              recalcFields();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax %',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => recalcFields(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total
              TextField(
                controller: totalController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Total Rate',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              double finalQty = double.tryParse(qtyController.text) ?? 0;
              double finalRatePerUnit = double.tryParse(rateController.text) ?? 0;
              double finalTaxPercent = double.tryParse(taxController.text) ?? 0;
              double rateTotal = finalRatePerUnit * finalQty;
              double taxTotal = (rateTotal * finalTaxPercent) / 100;

              products[index]['product_rate'] = finalRatePerUnit.toStringAsFixed(2);
              products[index]['quantity'] = finalQty.toStringAsFixed(0);
              products[index]['tax_percent'] = finalTaxPercent.toStringAsFixed(2);
              products[index]['total_tax_amount'] = taxTotal.toStringAsFixed(2);
              products[index]['rate_total'] = rateTotal.toStringAsFixed(2);
              products[index]['total_amount'] = (rateTotal + taxTotal).toStringAsFixed(2);

              totalProductCost = 0;
              totalProductTax = 0;
              double totalRate = 0;
              for (int i = 0; i < products.length; i++) {
                totalProductCost += double.parse(products[i]["total_amount"]);
                totalProductTax += double.parse(products[i]["total_tax_amount"]);
                totalRate += double.tryParse(products[i]["rate_total"] ?? "0") ?? 0;
              }

              subTotal.text = totalRate.toStringAsFixed(2);
              totalTax.text = totalProductTax.toStringAsFixed(2);
              shippingAmt = double.parse(shippingCharge.text.isEmpty ? "0" : shippingCharge.text);
              totalAmount.text = (totalRate + totalProductTax - discountAmt + shippingAmt).toStringAsFixed(2);
              totalPaidAmount.text = totalAmount.text;

              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}


  Future<dynamic> collectedStaffDialog(BuildContext context) {
    TextEditingController localSearchController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () {
                            localSearchController.clear();
                            filteredStaff.clear();
                            filteredStaff.addAll(renewalDetails!.data.staff);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Icon(Icons.close)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: localSearchController,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = renewalDetails!.data.staff
                              .where((item) => item.staffName
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .3,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ListView.builder(
                      itemCount: filteredStaff.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFFCFBFA)),
                            child: ListTile(
                              onTap: () {
                                staffName.text = filteredStaff[index].staffName;
                                staffId = filteredStaff[index].userId;
                                search.clear();
                                filteredStaff
                                    .addAll(renewalDetails!.data.staff);
                                setState(() {});
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              title: Text(
                                filteredStaff[index].staffName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              // trailing: Text(filteredStaff[index].userId),
                              leading: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                child: Icon(Icons.person),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
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
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  height: MediaQuery.of(context).size.height * .4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add Products",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddProducts(),
                                  )).then((_) {
                                getDetails();
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
                        height: 10,
                      ),
                      TextFormField(
                        controller: productNameController,
                        readOnly: true,
                        onTap: (() {
                          dropDialog(context, "Products");
                        }),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          labelText: 'Product *',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: prodRate,
                              onChanged: (val) {
                                calculateTotal();
                              },
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  labelText: 'Rate *',
                                  prefixIcon: Icon(Icons.currency_rupee,
                                      color: Colors.grey),
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
                          Expanded(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    int currentValue =
                                        int.parse(productQuantity.text);
                                    setState(() {
                                      currentValue--;
                                      productQuantity.text =
                                          (currentValue > 0 ? currentValue : 0)
                                              .toString(); // decrementing value
                                    });
                                    calculateTotal();
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            topLeft: Radius.circular(8))),
                                    child: const Center(
                                        child: Icon(
                                      Icons.arrow_left,
                                      size: 30,
                                    )),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    onChanged: (val) {
                                      calculateTotal();
                                    },
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      labelText: "Quantity",
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    controller: productQuantity,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: false,
                                      signed: true,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    int currentValue =
                                        int.parse(productQuantity.text);
                                    setState(() {
                                      currentValue++;
                                      productQuantity.text = (currentValue)
                                          .toString(); // incrementing value
                                    });
                                    calculateTotal();
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(8),
                                            topRight: Radius.circular(8))),
                                    child: const Center(
                                        child: Icon(
                                      Icons.arrow_right,
                                      size: 30,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onChanged: (val) {
                                calculateTotal();
                              },
                              keyboardType: TextInputType.number,
                              controller: prodTax,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  labelText: 'Tax(in %)',
                                  prefixIcon:
                                      Icon(Icons.percent, color: Colors.grey),
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
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: prodAmount,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  labelText: 'Amount',
                                  prefixIcon: Icon(Icons.currency_rupee,
                                      color: Colors.grey),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  labelStyle: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLines: 2,
                              controller: prodDetails,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  labelText: 'Details',
                                  prefixIcon: Icon(Icons.receipt_long,
                                      color: Colors.grey),
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
                          GestureDetector(
                            onTap: () async {
                              addProduct();
                            },
                            child: Container(
                              height: 50,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    " Add",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 14.0),
                    ],
                  ),
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
