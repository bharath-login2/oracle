// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/renewal_by_id_model.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/service/service.dart';

import '../../models/clients/branchListModel.dart';

class EditCustomRenewal extends StatefulWidget {
  String renId;
  String renewalType;
  EditCustomRenewal(
      {super.key, required this.renId, required this.renewalType});

  @override
  State<EditCustomRenewal> createState() => _EditCustomRenewalState();
}

class _EditCustomRenewalState extends State<EditCustomRenewal> {
  bool isLoading = true;
  bool uploading = false;
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
  dynamic collected;
  double shippingAmt = 0;
  double discountAmt = 0;
  double productTax = 0;
  double parseRate = 0;
  double parseQty = 0;
  double parseTax = 0;
  String customerId = "";
  PostRenewalModel? updateResponse;

  getBranch() async {
    multiBranch = await Common.getSharedPref("multiBranch");
    String token = await Common.getSharedPref("token");
    branchList = await HttpService.getBranchList(token);
    if (branchList != null) {}
  }

  getRenewalDetails() async {
    setState(() {
      isLoading = true;
    });
    renewalDetails = await HttpService.getRenewalDetailsById(
        widget.renId, widget.renewalType);

    if (renewalDetails != null && renewalDetails!.status == true) {
      getBranch();
      invoiceSlNum = renewalDetails!.data.slNumber;
      invoiceNumber.text = renewalDetails!.data.invoiceNumber.toString();
      invoiceDate.text = renewalDetails!.data.invoiceDate;
      filteredNames = renewalDetails!.data.customers;
      filteredProducts = renewalDetails!.data.allProducts;
      filteredTemplates = renewalDetails!.data.renewalTemplate;
      subTotal.text = renewalDetails!.data.subTotal;
      totalTax.text = renewalDetails!.data.estimatedTax;
      discount.text = renewalDetails!.data.discountAmount;
      shippingCharge.text = renewalDetails!.data.shippingAmount;
      totalAmount.text = renewalDetails!.data.totalAmount;
      totalProductCost = double.parse(renewalDetails!.data.totalAmount);
      customerName.text = renewalDetails!.data.customerName;
      customerId = renewalDetails!.data.clientId;
      payStat = renewalDetails!.data.paymentStatus;
      startDate.text = formatDate(renewalDetails!.data.startDate);
      endDate.text = formatDate(renewalDetails!.data.endDate);
      remindMe.text = renewalDetails!.data.templateName;
      templateId = renewalDetails!.data.templateId;
      remark.text = renewalDetails!.data.remarks;
      if (payStat == "unpaid") {
        totalPaidAmount.text = renewalDetails!.data.totalAmount;
      } else {
        totalPaidAmount.text = renewalDetails!.data.paidAmount;
      }
      for (int i = 0; i < renewalDetails!.data.invoiceLists.length; i++) {
        productName.add(renewalDetails!.data.invoiceLists[i].productName);
        products.add({
          "product_id": renewalDetails!.data.invoiceLists[i].productId,
          "product_name": renewalDetails!.data.invoiceLists[i].productName,
          "product_rate": renewalDetails!.data.invoiceLists[i].rate,
          "quantity": renewalDetails!.data.invoiceLists[i].qty,
          "tax_percent": renewalDetails!.data.invoiceLists[i].taxPercentage,
          "total_tax_amount": renewalDetails!.data.invoiceLists[i].taxAmount,
          "total_amount": renewalDetails!.data.invoiceLists[i].amount,
          "description":
              renewalDetails!.data.invoiceLists[i].productDescription,
        });
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  updateRenewal() async {
    try {
      updateResponse = await HttpService.updateCustomRenewal(
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
        collected,
      );

      if (updateResponse != null && updateResponse!.status == true) {
        Common.toastMessaage(updateResponse!.message, Colors.green);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Common.toastMessaage(updateResponse!.message, Colors.red);
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

  @override
  void initState() {
    getRenewalDetails();
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
                        "Edit Renewal",
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
          : EditWidget(context),
    );
  }

  SafeArea EditWidget(BuildContext context) {
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
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: customerName,
                  readOnly: true,
                  onTap: (() {
                    dropDialog(context, "Customers");
                  }),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Add Customer";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                    labelText: 'Customer *',
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: invoiceNumber,
                  readOnly: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                    labelText: 'Invoice Number',
                    prefixIcon: Icon(Icons.receipt, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: invoiceDate,
                  onTap: () async {
                    selectedValue = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      invoiceDate.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue!);
                    });
                  },
                  readOnly: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Invoice date can,t be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                    labelText: 'Invoice Date',
                    prefixIcon: Icon(Icons.calendar_month, color: Colors.grey),
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
                        decoration: InputDecoration(contentPadding: EdgeInsets.all(8),
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
                const Text(
                  "Add Products",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: productNameController,
                  readOnly: true,
                  onTap: (() {
                    dropDialog(context, "Products");
                  }),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
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
                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                            labelText: 'Rate *',
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
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
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
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
                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                            labelText: 'Tax(in %)',
                            prefixIcon: Icon(Icons.percent, color: Colors.grey),
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
                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                            labelText: 'Amount',
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
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
                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                            labelText: 'Details',
                            prefixIcon:
                                Icon(Icons.receipt_long, color: Colors.grey),
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
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade300),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(" ${index + 1}"),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .65,
                                  child: Text(
                                      "Product: ${products[index]["product_name"]}\nQty: ${products[index]["quantity"]} Amount: ${products[index]["total_amount"]}"),
                                ),
                                InkWell(
                                    onTap: () async {
                                      products.removeAt(index);
                                      productName.removeAt(index);
                                      totalProductCost = 0;
                                      totalProductTax = 0;
                                      for (int i = 0;
                                          i < products.length;
                                          i++) {
                                        totalProductCost += double.parse(
                                            (await products[i])[
                                                "total_amount"]);
                                        totalProductTax += double.parse(
                                            (await products[i])[
                                                "total_tax_amount"]);
                                      }
                                      subTotal.text =
                                          totalProductCost.toString();
                                      totalTax.text =
                                          totalProductTax.toString();
                                      shippingAmt = double.parse(
                                          shippingCharge.text == ""
                                              ? "0"
                                              : shippingCharge.text);
                                      totalAmount.text = (totalProductCost -
                                              discountAmt +
                                              shippingAmt)
                                          .toString();
                                      totalPaidAmount.text = totalAmount.text;
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .4,
                            child: const Text(
                              "Sub Total",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: subTotal,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Sub Total',
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .4,
                            child: const Text(
                              "Total Tax",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: totalTax,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Total Tax',
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .4,
                            child: const Text(
                              "Discount",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              onChanged: (val) {
                                discountAmt = double.parse(
                                    discount.text == "" ? "0" : discount.text);
                                totalAmount.text = (totalProductCost -
                                        discountAmt +
                                        shippingAmt)
                                    .toString();
                                totalPaidAmount.text = totalAmount.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: discount,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Discount',
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .4,
                            child: const Text(
                              "Shipping Charge",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              onChanged: (val) {
                                shippingAmt = double.parse(
                                    shippingCharge.text == ""
                                        ? "0"
                                        : shippingCharge.text);
                                totalAmount.text = (totalProductCost -
                                        discountAmt +
                                        shippingAmt)
                                    .toString();
                                totalPaidAmount.text = totalAmount.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: shippingCharge,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Shipping Charge',
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .3,
                            child: const Text(
                              "Total Amount",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: totalAmount,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Total Amount',
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
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Visibility(
                  visible: widget.renewalType == "cart",
                  child: Column(
                    children: [
                      DropdownButtonFormField(
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
                        items:
                            renewalDetails!.data.paymentStatusList.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.paymentStatus.toString(),
                            child: Text(
                              data.displaySts.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'Payment Status',
                          prefixIcon: Icon(
                              Icons.arrow_drop_down_circle_outlined,
                              color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Visibility(
                        visible: payStat == "partial" || payStat == "paid",
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (payStat == "partial") {
                                  double val = double.parse(value!);
                                  if (value == "" || val == 0) {
                                    return "Enter Amount";
                                  } else if (val >= totalProductCost) {
                                    return "Paid amount cannot be greater than or equal to total cost";
                                  }
                                }
                                return null;
                              },
                              readOnly: payStat != "partial" ? true : false,
                              keyboardType: TextInputType.number,
                              controller: totalPaidAmount,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                  labelText: 'Total Amount Paid',
                                  prefixIcon: Icon(Icons.currency_rupee,
                                      color: Colors.grey),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  labelStyle: TextStyle(color: Colors.grey)),
                            ),
                            const SizedBox(height: 14.0),
                            DropdownButtonFormField(
                              validator: (value) {
                                if (payStat == "partial" || payStat == "paid") {
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
                              },
                              items: renewalDetails!.data.paymentMethods
                                  .map((data) {
                                return DropdownMenuItem<String>(
                                  value: data.id.toString(),
                                  child: Text(
                                    data.name.toString(),
                                  ),
                                );
                              }).toList(),
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: 'Payment Methods',
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            DropdownButtonFormField(
                              validator: (value) {
                                if (payStat == "partial" || payStat == "paid") {
                                  if (value == "" || value == null) {
                                    return "Select a staff";
                                  }
                                }
                                return null;
                              },
                              value: collected,
                              onChanged: (value) async {
                                setState(() {
                                  collected = value.toString();
                                });
                              },
                              items: renewalDetails!.data.staff.map((data) {
                                return DropdownMenuItem<String>(
                                  value: data.userId.toString(),
                                  child: Text(
                                    data.staffName.toString(),
                                  ),
                                );
                              }).toList(),
                              decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: 'Collected By',
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 14.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: startDate,
                  readOnly: true,
                  onTap: () async {
                    selectedValue = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      startDate.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue!);
                      final endValue = selectedValue!
                          .add(Duration(days: int.parse(typeDuration)));
                      endDate.text = DateFormat('dd-MM-yyyy').format(endValue);
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select Start Date";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                      labelText: 'Start Date *',
                      prefixIcon:
                          Icon(Icons.calendar_month, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  onTap: () async {
                    DateTime? selectedEndDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    endDate.text =
                        DateFormat('dd-MM-yyyy').format(selectedEndDate!);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select End Date";
                    }
                    return null;
                  },
                  readOnly: true,
                  controller: endDate,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                      labelText: 'End Date *',
                      prefixIcon:
                          Icon(Icons.calendar_month, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  onTap: () {
                    dropDialog(context, "Template");
                  },
                  readOnly: true,
                  controller: remindMe,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
                      labelText: 'Remind Template *',
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
                  decoration: const InputDecoration(contentPadding: EdgeInsets.all(8),
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
                        if (formKey.currentState!.validate() &&
                            products.isNotEmpty) {
                          if (totalProductCost ==
                              double.parse(renewalDetails!.data.totalAmount)) {
                            setState(() {
                              uploading = true;
                            });
                            updateRenewal();
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Invoice amount modified!',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.red),
                                    ),
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: Text(
                                          'The invoice amount has been modified. Receipts have already been generated for this invoice.Previous Amount ₹${renewalDetails!.data.paidAmount} ,New Amount ₹${totalProductCost.toString()}, Do you wish to proceed with the new amount?'),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              uploading = true;
                                            });
                                            updateRenewal();
                                          },
                                          child: const Text('Continue'))
                                    ],
                                  );
                                });
                          }
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
                            "Update",
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
                      ),
                    )
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
                      return ListTile(
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
                            prodTax.text = filteredProducts[index].taxPercent;
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

  addProduct() async {
    if (productName.contains(productNameController.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameController.text != "") {
        products.add({
          "product_id": productId,
          "product_name": productNameController.text,
          "product_rate": prodRate.text,
          "quantity": productQuantity.text,
          "tax_percent": prodTax.text,
          "total_tax_amount": productTax.toString(),
          "total_amount": prodAmount.text,
          "description": prodDetails.text,
        });
        productName.add(productNameController.text);
        productNameController.text = "";
        prodRate.text = "";
        productQuantity.text = "1";
        prodTax.text = "";
        prodAmount.text = "";
        prodDetails.text = "";
        totalProductCost = 0;
        totalProductTax = 0;
        for (int i = 0; i < products.length; i++) {
          totalProductCost += double.parse((await products[i])["total_amount"]);
          totalProductTax +=
              double.parse((await products[i])["total_tax_amount"]);
        }
        subTotal.text = totalProductCost.toString();
        totalTax.text = totalProductTax.toString();
        discountAmt = double.parse(discount.text == "" ? "0" : discount.text);
        shippingAmt =
            double.parse(shippingCharge.text == "" ? "0" : shippingCharge.text);
        totalAmount.text =
            (totalProductCost - discountAmt + shippingAmt).toString();
        totalPaidAmount.text = totalAmount.text;
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
}
