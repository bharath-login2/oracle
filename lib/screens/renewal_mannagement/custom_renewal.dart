// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/add_customer_model.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/service/service.dart';

class CustomRenewal extends StatefulWidget {
  CustomRenewal({super.key, this.custId, this.custName});
  String? custId;
  String? custName;
  @override
  State<CustomRenewal> createState() => _CustomRenewalState();
}

class _CustomRenewalState extends State<CustomRenewal> {
  final existingFormKey = GlobalKey<FormState>();
  final newFormKey = GlobalKey<FormState>();
  RenewalDetailslModel? detailsResponse;
  PostRenewalModel? postExistingResponse;
  AddCustomerModel? postNewResponse;
  bool isLoading = true;
  List<Product> filteredProducts = [];
  List filteredNames = [];
  String customerIdExisting = "";
  String customerIdNew = "";
  String productDuration = "";
  DateTime selectedValue = DateTime.now();
  double parseRateExisting = 0;
  double parseQtyExisting = 0;
  double parseTaxExisting = 0;
  double parseRateNew = 0;
  double parseQtyNew = 0;
  double parseTaxNew = 0;
  double productTaxExisting = 0;
  double productTaxNew = 0;
  double discountAmtExisting = 0;
  double discountAmtNew = 0;
  double shippingAmtExisting = 0;
  double shippingAmtNew = 0;
  BranchListModel? branchList;
  String multiBranch = "true";
  dynamic branchExisting;
  dynamic payStatExisting;
  dynamic payMethodExisting;
  dynamic collectedExisting;
  dynamic collectedNew;
  dynamic payMethodNew;
  dynamic payStatNew;
  dynamic branchNew;
  String phCodeNew = "91";
  String whCodeNew = "91";
  List productsExisting = [];
  List productsNew = [];
  List productNameListExisting = [];
  List productNameListNew = [];
  double totalProductCostExisting = 0;
  double totalProductCostNew = 0;
  double totalProductTaxExisting = 0;
  double totalProductTaxNew = 0;
  bool uploading = false;
  bool isExists = false;
  IsCustomerExistModel? isExist;
  List<Template> filteredTemplates = [];
  String templateIdExisting = "";
  String templateIdNew = "";
  String typeDuration = "";
  String invoiceSlNum = "";
  String productIdExisting = "";
  String productIdNew = "";

  TextEditingController customerNameNew = TextEditingController();
  TextEditingController customerNameExisting = TextEditingController();
  TextEditingController numberNew = TextEditingController();
  TextEditingController whatsappNumber = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController typeName = TextEditingController();
  TextEditingController startDateExisting = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController startDateNew = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController endDateExisting = TextEditingController();
  TextEditingController endDateNew = TextEditingController();
  TextEditingController remindMeNew = TextEditingController();
  TextEditingController remindMeExisting = TextEditingController();
  TextEditingController remarkExisting = TextEditingController();
  TextEditingController remarkNew = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController invoiceDate = TextEditingController();
  TextEditingController invoiceNumber = TextEditingController();
  TextEditingController productNameExisting = TextEditingController();
  TextEditingController productNameNew = TextEditingController();
  TextEditingController prodRateExisting = TextEditingController();
  TextEditingController prodTaxExisting = TextEditingController();
  TextEditingController prodAmountExisting = TextEditingController();
  TextEditingController prodRateNew = TextEditingController();
  TextEditingController prodTaxNew = TextEditingController();
  TextEditingController prodAmountNew = TextEditingController();
  TextEditingController prodDetailsExisting = TextEditingController();
  TextEditingController prodDetailsNew = TextEditingController();
  TextEditingController productQuantityExisting =
      TextEditingController(text: '1');
  TextEditingController productQuantityNew = TextEditingController(text: '1');
  TextEditingController subTotalNew = TextEditingController();
  TextEditingController totalTaxNew = TextEditingController();
  TextEditingController discountNew = TextEditingController();
  TextEditingController shippingChargeNew = TextEditingController();
  TextEditingController totalAmountNew = TextEditingController();
  TextEditingController totalPaidAmountNew = TextEditingController();
  TextEditingController subTotalExisting = TextEditingController();
  TextEditingController totalTaxExisting = TextEditingController();
  TextEditingController discountExisting = TextEditingController();
  TextEditingController shippingChargeExisting = TextEditingController();
  TextEditingController totalAmountExisting = TextEditingController();
  TextEditingController totalPaidAmountExisting = TextEditingController();

  getBranch() async {
    multiBranch = await Common.getSharedPref("multiBranch");
    String token = await Common.getSharedPref("token");
    branchList = await HttpService.getBranchList(token);
    if (branchList != null) {}
  }

  isCustomerExists() async {
    isExist = await HttpService.isCustomerExists("", numberNew.text);
    if (isExist != null) {
      isExists = isExist!.data;
    }
  }

  getRenewalDetails() async {
    if (widget.custId != null && widget.custName != null) {
      customerIdExisting = widget.custId!;
      customerNameExisting.text = widget.custName!;
    }
    setState(() {
      isLoading = true;
    });
    detailsResponse = await HttpService.getRenewalDetails();

    if (detailsResponse != null && detailsResponse!.status == true) {
      filteredNames = detailsResponse!.data.customer;
      filteredProducts = detailsResponse!.data.products;
      filteredTemplates = detailsResponse!.data.template;
      invoiceSlNum = detailsResponse!.data.slNumber;
      invoiceNumber.text = detailsResponse!.data.invoiceNumber.toString();
      invoiceDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      await getBranch();
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCustomers(
    String query,
  ) {
    filteredNames = detailsResponse!.data.customer
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterProducts(
    String query,
  ) {
    filteredProducts = detailsResponse!.data.products
        .where((map) =>
            map.productName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterTemplates(
    String query,
  ) {
    filteredTemplates = detailsResponse!.data.template
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  postExisting() async {
    try {
      postExistingResponse = await HttpService.postExistingCustom(
          productsExisting,
          customerIdExisting,
          templateIdExisting,
          startDateExisting.text,
          endDateExisting.text,
          remarkExisting.text,
          branchExisting,
          totalProductCostExisting,
          detailsResponse!.data.checkId,
          invoiceNumber.text,
          invoiceDate.text,
          invoiceSlNum,
          subTotalExisting.text,
          totalTaxExisting.text,
          discountExisting.text,
          shippingChargeExisting.text,
          totalAmountExisting.text,
          totalPaidAmountExisting.text,
          payStatExisting,
          payMethodExisting,
          collectedExisting);

      if (postExistingResponse != null &&
          postExistingResponse!.status == true) {
        Common.toastMessaage(postExistingResponse!.message, Colors.green);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RenewalDashboard(),
            ));
      } else {
        Common.toastMessaage(postExistingResponse!.message, Colors.red);
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

  postNew() async {
    try {
      postNewResponse = await HttpService.postNewCustom(
          branchNew,
          phCodeNew,
          numberNew.text,
          whCodeNew,
          whatsappNumber.text,
          customerNameNew.text,
          address1.text,
          address2.text,
          address3.text,
          postOffice.text,
          pinCode.text,
          gstNumber.text,
          remarkNew.text,
          productsNew,
          startDateNew.text,
          endDateNew.text,
          totalAmountNew.text,
          email.text,
          totalProductCostNew,
          templateIdNew,
          detailsResponse!.data.checkId,
          invoiceNumber.text,
          invoiceDate.text,
          invoiceSlNum,
          subTotalNew.text,
          totalTaxNew.text,
          discountNew.text,
          shippingChargeNew.text,
          totalAmountNew.text,
          totalPaidAmountNew.text,
          payStatNew,
          payMethodNew,
          collectedNew);
      if (postNewResponse != null && postNewResponse!.status == true) {
        Common.toastMessaage(postNewResponse!.message, Colors.green);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RenewalDashboard(),
            ));
      } else {
        Common.toastMessaage(postNewResponse!.message, Colors.red);
        setState(() {
          uploading = false;
        });
      }
    } catch (e) {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF3375e0),
            foregroundColor: Colors.white,
            title: const Text("Add Renewal"),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Container(
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
            ),
            bottom: widget.custId != null && widget.custName != null
                ? null
                : const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    tabs: [
                      Tab(
                        text: 'Existing',
                      ), // Define tabs
                      Tab(text: 'New'),
                    ],
                  ),
          ),
          body: widget.custId != null && widget.custName != null
              ? isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                      ),
                    )
                  : existingWidget(context)
              : TabBarView(
                  children: [
                    isLoading == true
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                            ),
                          )
                        : existingWidget(context),
                    isLoading == true
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                            ),
                          )
                        : newWidget(context),
                  ],
                )),
    );
  }

  SafeArea existingWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: existingFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: customerNameExisting,
                  readOnly: true,
                  onTap: (() {
                    dropDialogExisting(context, "Customers");
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
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: invoiceNumber,
                  readOnly: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
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
                    selectedValue = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ))!;
                    setState(() {
                      invoiceDate.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue);
                    });
                  },
                  readOnly: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Invoice date can,t be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
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
                        value: branchExisting,
                        onChanged: (value) async {
                          setState(() {
                            branchExisting = value.toString();
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
                          contentPadding: EdgeInsets.all(8),
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
                  controller: productNameExisting,
                  readOnly: true,
                  onTap: (() {
                    dropDialogExisting(context, "Products");
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
                        controller: prodRateExisting,
                        onChanged: (val) {
                          calculateTotalExisting();
                        },
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              int currentValue =
                                  int.parse(productQuantityExisting.text);
                              setState(() {
                                currentValue--;
                                productQuantityExisting.text =
                                    (currentValue > 0 ? currentValue : 0)
                                        .toString(); // decrementing value
                              });
                              calculateTotalExisting();
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
                                calculateTotalExisting();
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              controller: productQuantityExisting,
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
                                  int.parse(productQuantityExisting.text);
                              setState(() {
                                currentValue++;
                                productQuantityExisting.text = (currentValue)
                                    .toString(); // incrementing value
                              });
                              calculateTotalExisting();
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
                          calculateTotalExisting();
                        },
                        keyboardType: TextInputType.number,
                        controller: prodTaxExisting,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        controller: prodAmountExisting,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        controller: prodDetailsExisting,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        addProductExisting();
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
                    itemCount: productsExisting.length,
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
                                      "Product: ${productsExisting[index]["product_name"]}\nQty: ${productsExisting[index]["quantity"]} Amount: ${productsExisting[index]["total_amount"]}"),
                                ),
                                InkWell(
                                    onTap: () async {
                                      productsExisting.removeAt(index);
                                      productNameListExisting.removeAt(index);
                                      totalProductCostExisting = 0;
                                      totalProductTaxExisting = 0;
                                      for (int i = 0;
                                          i < productsExisting.length;
                                          i++) {
                                        totalProductCostExisting +=
                                            double.parse(
                                                (await productsExisting[i])[
                                                    "total_amount"]);
                                        totalProductTaxExisting += double.parse(
                                            (await productsExisting[i])[
                                                "total_tax_amount"]);
                                      }
                                      subTotalExisting.text =
                                          totalProductCostExisting.toString();
                                      totalTaxExisting.text =
                                          totalProductTaxExisting.toString();
                                      shippingAmtExisting = double.parse(
                                          shippingChargeExisting.text == ""
                                              ? "0"
                                              : shippingChargeExisting.text);
                                      totalAmountExisting.text =
                                          (totalProductCostExisting -
                                                  discountAmtExisting +
                                                  shippingAmtExisting)
                                              .toString();
                                      totalPaidAmountExisting.text =
                                          totalAmountExisting.text;
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
                              controller: subTotalExisting,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                              controller: totalTaxExisting,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                                discountAmtExisting = double.parse(
                                    discountExisting.text == ""
                                        ? "0"
                                        : discountExisting.text);
                                totalAmountExisting.text =
                                    (totalProductCostExisting -
                                            discountAmtExisting +
                                            shippingAmtExisting)
                                        .toString();
                                totalPaidAmountExisting.text =
                                    totalAmountExisting.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: discountExisting,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                                shippingAmtExisting = double.parse(
                                    shippingChargeExisting.text == ""
                                        ? "0"
                                        : shippingChargeExisting.text);
                                totalAmountExisting.text =
                                    (totalProductCostExisting -
                                            discountAmtExisting +
                                            shippingAmtExisting)
                                        .toString();
                                totalPaidAmountExisting.text =
                                    totalAmountExisting.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: shippingChargeExisting,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                              controller: totalAmountExisting,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                DropdownButtonFormField(
                  validator: (val) {
                    if (val == "" || val == null) {
                      return "Add payment status";
                    }
                    return null;
                  },
                  value: payStatExisting,
                  onChanged: (value) async {
                    payStatExisting = value.toString();
                    setState(() {});
                  },
                  items: detailsResponse!.data.paymentStatus.map((data) {
                    return DropdownMenuItem<String>(
                      value: data.paymentStatus.toString(),
                      child: Text(
                        data.displaySts.toString(),
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Payment Status',
                    prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: Colors.grey),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                Visibility(
                  visible:
                      payStatExisting == "partial" || payStatExisting == "paid",
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (payStatExisting == "partial") {
                            double val = double.parse(value!);
                            if (value == "" || val == 0) {
                              return "Enter Amount";
                            } else if (val >= totalProductCostExisting) {
                              return "Paid amount cannot be greater than or equal to total cost";
                            }
                          }
                          return null;
                        },
                        readOnly: payStatExisting != "partial" ? true : false,
                        keyboardType: TextInputType.number,
                        controller: totalPaidAmountExisting,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            labelText: 'Total Amount Paid',
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 14.0),
                      DropdownButtonFormField(
                        validator: (value) {
                          if (payStatExisting == "partial" ||
                              payStatExisting == "paid") {
                            if (value == "" || value == null) {
                              return "Select a payment method";
                            }
                          }
                          return null;
                        },
                        value: payMethodExisting,
                        onChanged: (value) async {
                          setState(() {
                            payMethodExisting = value.toString();
                          });
                        },
                        items: detailsResponse!.data.paymentMethods.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.id.toString(),
                            child: Text(
                              data.name.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
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
                          if (payStatExisting == "partial" ||
                              payStatExisting == "paid") {
                            if (value == "" || value == null) {
                              return "Select a staff";
                            }
                          }
                          return null;
                        },
                        value: collectedExisting,
                        onChanged: (value) async {
                          setState(() {
                            collectedExisting = value.toString();
                          });
                        },
                        items: detailsResponse!.data.staff.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.userId.toString(),
                            child: Text(
                              data.staffName.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
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
                TextFormField(
                  controller: startDateExisting,
                  readOnly: true,
                  onTap: () async {
                    selectedValue = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ))!;
                    setState(() {
                      startDateExisting.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue);
                      final endValue = selectedValue
                          .add(Duration(days: int.parse(typeDuration)));
                      endDateExisting.text =
                          DateFormat('dd-MM-yyyy').format(endValue);
                    });
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
                    endDateExisting.text =
                        DateFormat('dd-MM-yyyy').format(selectedEndDate!);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select End Date";
                    }
                    return null;
                  },
                  readOnly: true,
                  controller: endDateExisting,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
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
                    dropDialogExisting(context, "Template");
                  },
                  readOnly: true,
                  controller: remindMeExisting,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      labelText: 'Remind Template ',
                      prefixIcon: Icon(Icons.notifications, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: remarkExisting,
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
                        if (existingFormKey.currentState!.validate() &&
                            productsExisting.isNotEmpty) {
                          setState(() {
                            uploading = true;
                          });
                          postExisting();
                        } else if (productsExisting.isEmpty) {
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
                            "Submit",
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

  SafeArea newWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: newFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: customerNameNew,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Customer Name";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Customer Name *',
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
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
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
                    selectedValue = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ))!;
                    setState(() {
                      invoiceDate.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue);
                    });
                  },
                  readOnly: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Invoice date can,t be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Invoice Date',
                    prefixIcon: Icon(Icons.calendar_month, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: numberNew,
                  onChanged: ((value) {
                    if (value.length == 10) {
                      isCustomerExists();
                    }
                  }),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Customer Number";
                    } else if (isExists == true) {
                      return "This number is Already Exists";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Number *',
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              searchAutofocus: false,
                              showPhoneCode: true,
                              // optional. Shows phone code before the country name.
                              onSelect: (Country country) {
                                setState(() {
                                  phCodeNew = country.phoneCode;
                                });
                              },
                            );
                          },
                          child: Text(
                            "+ $phCodeNew",
                            style: const TextStyle(color: Colors.black),
                          )),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: whatsappNumber,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'WhatsApp Number',
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              searchAutofocus: false,
                              showPhoneCode: true,
                              // optional. Shows phone code before the country name.
                              onSelect: (Country country) {
                                setState(() {
                                  whCodeNew = country.phoneCode;
                                });
                              },
                            );
                          },
                          child: Text("+ $whCodeNew",
                              style: const TextStyle(color: Colors.black))),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      if (!regex.hasMatch(value)) {
                        return "Enter valid emailformat";
                      }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.border_color, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: address1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Address Line 1',
                    prefixIcon: Icon(Icons.home, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: address2,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Address Line 2',
                    prefixIcon: Icon(Icons.home, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: address3,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Address Line 3',
                    prefixIcon: Icon(Icons.home, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: pinCode,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Pincode',
                    prefixIcon: Icon(Icons.pin_drop, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: postOffice,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'Post Office',
                    prefixIcon:
                        Icon(Icons.local_post_office_sharp, color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: gstNumber,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    labelText: 'GST Number',
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
                        value: branchNew,
                        onChanged: (value) async {
                          setState(() {
                            branchNew = value.toString();
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
                          contentPadding: EdgeInsets.all(8),
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
                  controller: productNameNew,
                  readOnly: true,
                  onTap: (() {
                    dropDialogNew(context, "Products");
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
                        controller: prodRateNew,
                        onChanged: (val) {
                          calculateTotalNew();
                        },
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              int currentValue =
                                  int.parse(productQuantityNew.text);
                              setState(() {
                                currentValue--;
                                productQuantityNew.text =
                                    (currentValue > 0 ? currentValue : 0)
                                        .toString(); // decrementing value
                              });
                              calculateTotalNew();
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
                                calculateTotalNew();
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              controller: productQuantityNew,
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
                                  int.parse(productQuantityNew.text);
                              setState(() {
                                currentValue++;
                                productQuantityNew.text = (currentValue)
                                    .toString(); // incrementing value
                              });
                              calculateTotalNew();
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
                          calculateTotalNew();
                        },
                        keyboardType: TextInputType.number,
                        controller: prodTaxNew,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        controller: prodAmountNew,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        controller: prodDetailsNew,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
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
                        addProductNew();
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
                    itemCount: productsNew.length,
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
                                      "Product: ${productsNew[index]["product_name"]}\nQty: ${productsNew[index]["quantity"]} Amount: ${productsNew[index]["total_amount"]}"),
                                ),
                                InkWell(
                                    onTap: () async {
                                      productsNew.removeAt(index);
                                      productNameListNew.removeAt(index);
                                      totalProductCostNew = 0;
                                      totalProductTaxNew = 0;
                                      for (int i = 0;
                                          i < productsNew.length;
                                          i++) {
                                        totalProductCostNew += double.parse(
                                            (await productsNew[i])[
                                                "total_amount"]);
                                        totalProductTaxNew += double.parse(
                                            (await productsNew[i])[
                                                "total_tax_amount"]);
                                      }
                                      subTotalNew.text =
                                          totalProductCostNew.toString();
                                      totalTaxNew.text =
                                          totalProductTaxNew.toString();
                                      shippingAmtNew = double.parse(
                                          shippingChargeNew.text == ""
                                              ? "0"
                                              : shippingChargeNew.text);
                                      totalAmountNew.text =
                                          (totalProductCostNew -
                                                  discountAmtNew +
                                                  shippingAmtNew)
                                              .toString();
                                      totalPaidAmountNew.text =
                                          totalAmountNew.text;
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
                              controller: subTotalNew,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                              controller: totalTaxNew,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                                discountAmtNew = double.parse(
                                    discountNew.text == ""
                                        ? "0"
                                        : discountNew.text);
                                totalAmountNew.text = (totalProductCostNew -
                                        discountAmtNew +
                                        shippingAmtNew)
                                    .toString();
                                totalPaidAmountNew.text = totalAmountNew.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: discountNew,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                                shippingAmtNew = double.parse(
                                    shippingChargeNew.text == ""
                                        ? "0"
                                        : shippingChargeNew.text);
                                totalAmountNew.text = (totalProductCostNew -
                                        discountAmtNew +
                                        shippingAmtNew)
                                    .toString();
                                totalPaidAmountNew.text = totalAmountNew.text;
                              },
                              keyboardType: TextInputType.number,
                              controller: shippingChargeNew,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                              controller: totalAmountNew,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
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
                DropdownButtonFormField(
                  validator: (val) {
                    if (val == "" || val == null) {
                      return "Add payment status";
                    }
                    return null;
                  },
                  value: payStatNew,
                  onChanged: (value) async {
                    payStatNew = value.toString();
                    setState(() {});
                  },
                  items: detailsResponse!.data.paymentStatus.map((data) {
                    return DropdownMenuItem<String>(
                      value: data.paymentStatus.toString(),
                      child: Text(
                        data.displaySts.toString(),
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Payment Status',
                    prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: Colors.grey),
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                Visibility(
                  visible: payStatNew == "partial" || payStatNew == "paid",
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (payStatNew == "partial") {
                            double val = double.parse(value!);
                            if (value == "" || val == 0) {
                              return "Enter Amount";
                            } else if (val >= totalProductCostNew) {
                              return "Paid amount cannot be greater than or equal to total cost";
                            }
                          }
                          return null;
                        },
                        readOnly: payStatNew != "partial" ? true : false,
                        keyboardType: TextInputType.number,
                        controller: totalPaidAmountNew,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            labelText: 'Total Amount Paid',
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 14.0),
                      DropdownButtonFormField(
                        validator: (value) {
                          if (payStatNew == "partial" || payStatNew == "paid") {
                            if (value == "" || value == null) {
                              return "Select a payment method";
                            }
                          }
                          return null;
                        },
                        value: payMethodNew,
                        onChanged: (value) async {
                          setState(() {
                            payMethodNew = value.toString();
                          });
                        },
                        items: detailsResponse!.data.paymentMethods.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.id.toString(),
                            child: Text(
                              data.name.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
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
                          if (payStatNew == "partial" || payStatNew == "paid") {
                            if (value == "" || value == null) {
                              return "Select a staff";
                            }
                          }
                          return null;
                        },
                        value: collectedNew,
                        onChanged: (value) async {
                          setState(() {
                            collectedNew = value.toString();
                          });
                        },
                        items: detailsResponse!.data.staff.map((data) {
                          return DropdownMenuItem<String>(
                            value: data.userId.toString(),
                            child: Text(
                              data.staffName.toString(),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
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
                TextFormField(
                  controller: startDateNew,
                  readOnly: true,
                  onTap: () async {
                    selectedValue = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ))!;
                    setState(() {
                      startDateNew.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue);
                      final endValue = selectedValue
                          .add(Duration(days: int.parse(typeDuration)));
                      endDateNew.text =
                          DateFormat('dd-MM-yyyy').format(endValue);
                    });
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
                    endDateNew.text =
                        DateFormat('dd-MM-yyyy').format(selectedEndDate!);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select End Date";
                    }
                    return null;
                  },
                  readOnly: true,
                  controller: endDateNew,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
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
                    dropDialogNew(context, "Template");
                  },
                  readOnly: true,
                  controller: remindMeNew,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      labelText: 'Remind Template ',
                      prefixIcon: Icon(Icons.notifications, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: remarkNew,
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
                        if (newFormKey.currentState!.validate() &&
                            productsNew.isNotEmpty) {
                          setState(() {
                            uploading = true;
                          });
                          postNew();
                        } else if (productsNew.isEmpty) {
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
                            "Submit",
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

  Future<dynamic> dropDialogNew(BuildContext context, String title) {
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
                            customerNameNew.text = filteredNames[index].name;
                            customerIdNew = filteredNames[index].id;
                          } else if (title == "Template") {
                            remindMeNew.text =
                                filteredTemplates[index].templateName;
                            templateIdNew = filteredTemplates[index].id;
                          } else {
                            productIdNew = filteredProducts[index].id;
                            productNameNew.text =
                                filteredProducts[index].productName;
                            prodRateNew.text =
                                filteredProducts[index].sellingPrice;
                            prodTaxNew.text =
                                filteredProducts[index].taxPercent;
                            typeDuration = filteredProducts[index].noOfDays;
                            calculateTotalNew();
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

  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
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
                            customerNameExisting.text =
                                filteredNames[index].name;
                            customerIdExisting = filteredNames[index].id;
                          } else if (title == "Template") {
                            remindMeExisting.text =
                                filteredTemplates[index].templateName;
                            templateIdExisting = filteredTemplates[index].id;
                          } else {
                            productIdExisting = filteredProducts[index].id;
                            productNameExisting.text =
                                filteredProducts[index].productName;
                            prodRateExisting.text =
                                filteredProducts[index].sellingPrice;
                            prodTaxExisting.text =
                                filteredProducts[index].taxPercent;
                            typeDuration = filteredProducts[index].noOfDays;
                            calculateTotalExisting();
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

  calculateTotalExisting() {
    parseRateExisting = double.parse(prodRateExisting.text);
    parseQtyExisting = double.parse(productQuantityExisting.text);
    parseTaxExisting = double.parse(prodTaxExisting.text);

    productTaxExisting =
        ((parseRateExisting * parseQtyExisting) * parseTaxExisting / 100);
    prodAmountExisting.text =
        (productTaxExisting + (parseRateExisting * parseQtyExisting))
            .toString();
  }

  addProductExisting() async {
    if (productNameListExisting.contains(productNameExisting.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameExisting.text != "") {
        productsExisting.add({
          "product_id": productIdExisting,
          "product_name": productNameExisting.text,
          "product_rate": prodRateExisting.text,
          "quantity": productQuantityExisting.text,
          "tax_percent": prodTaxExisting.text,
          "total_tax_amount": productTaxExisting.toString(),
          "total_amount": prodAmountExisting.text,
          "description": prodDetailsExisting.text,
        });
        productNameListExisting.add(productNameExisting.text);
        productNameExisting.text = "";
        prodRateExisting.text = "";
        productQuantityExisting.text = "1";
        prodTaxExisting.text = "";
        prodAmountExisting.text = "";
        prodDetailsExisting.text = "";
        totalProductCostExisting = 0;
        totalProductTaxExisting = 0;
        for (int i = 0; i < productsExisting.length; i++) {
          totalProductCostExisting +=
              double.parse((await productsExisting[i])["total_amount"]);
          totalProductTaxExisting +=
              double.parse((await productsExisting[i])["total_tax_amount"]);
        }
        subTotalExisting.text = totalProductCostExisting.toString();
        totalTaxExisting.text = totalProductTaxExisting.toString();
        discountAmtExisting = double.parse(
            discountExisting.text == "" ? "0" : discountExisting.text);
        shippingAmtExisting = double.parse(shippingChargeExisting.text == ""
            ? "0"
            : shippingChargeExisting.text);
        totalAmountExisting.text = (totalProductCostExisting -
                discountAmtExisting +
                shippingAmtExisting)
            .toString();
        totalPaidAmountExisting.text = totalAmountExisting.text;
        final endValue =
            selectedValue.add(Duration(days: int.parse(typeDuration)));
        endDateExisting.text = DateFormat('dd-MM-yyyy').format(endValue);
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
    }
  }

  calculateTotalNew() {
    parseRateNew = double.parse(prodRateNew.text);
    parseQtyNew = double.parse(productQuantityNew.text);
    parseTaxNew = double.parse(prodTaxNew.text);

    productTaxNew = ((parseRateNew * parseQtyNew) * parseTaxNew / 100);
    prodAmountNew.text =
        (productTaxNew + (parseRateNew * parseQtyNew)).toString();
  }

  addProductNew() async {
    if (productNameListNew.contains(productNameNew.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameNew.text != "") {
        productsNew.add({
          "product_id": productIdNew,
          "product_name": productNameNew.text,
          "product_rate": prodRateNew.text,
          "quantity": productQuantityNew.text,
          "tax_percent": prodTaxNew.text,
          "total_tax_amount": productTaxNew.toString(),
          "total_amount": prodAmountNew.text,
          "description": prodDetailsNew.text,
        });
        productNameListNew.add(productNameNew.text);
        productNameNew.text = "";
        prodRateNew.text = "";
        productQuantityNew.text = "1";
        prodTaxNew.text = "";
        prodAmountNew.text = "";
        prodDetailsNew.text = "";
        totalProductCostNew = 0;
        totalProductTaxNew = 0;
        for (int i = 0; i < productsNew.length; i++) {
          totalProductCostNew +=
              double.parse((await productsNew[i])["total_amount"]);
          totalProductTaxNew +=
              double.parse((await productsNew[i])["total_tax_amount"]);
        }
        subTotalNew.text = totalProductCostNew.toString();
        totalTaxNew.text = totalProductTaxNew.toString();
        discountAmtNew =
            double.parse(discountNew.text == "" ? "0" : discountNew.text);
        shippingAmtNew = double.parse(
            shippingChargeNew.text == "" ? "0" : shippingChargeNew.text);
        totalAmountNew.text =
            (totalProductCostNew - discountAmtNew + shippingAmtNew).toString();
        totalPaidAmountNew.text = totalAmountNew.text;
        final endValue =
            selectedValue.add(Duration(days: int.parse(typeDuration)));
        endDateNew.text = DateFormat('dd-MM-yyyy').format(endValue);
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
    }
  }
}
