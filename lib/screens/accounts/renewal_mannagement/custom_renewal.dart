// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/add_customer_model.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
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
  List<Staff> filteredStaff = [];
  TextEditingController collectedExisting = TextEditingController();
  TextEditingController collectedNew = TextEditingController();
  String collectedStaffIdExisting = "";
  String collectedStaffIdNew = "";
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
  bool createOrder = false;
  List<TargetGroups> filteredTargets = [];
  List targetGroupsNew = [];
  List targetGroupNamesNew = [];
  List targetGroupsExisting = [];
  List targetGroupNamesExisting = [];

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
  TextEditingController search = TextEditingController();

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
    detailsResponse = await HttpService.getRenewalDetails();

    if (detailsResponse != null && detailsResponse!.status == true) {
      filteredNames = detailsResponse!.data.customer;
      filteredProducts = detailsResponse!.data.products;
      filteredTemplates = detailsResponse!.data.template;
      invoiceSlNum = detailsResponse!.data.slNumber;
      invoiceNumber.text = detailsResponse!.data.invoiceNumber.toString();
      invoiceDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      filteredStaff.addAll(detailsResponse!.data.staff);
      filteredTargets.addAll(detailsResponse!.data.targetGroups);
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
          collectedStaffIdExisting,
          createOrder,
          targetGroupsExisting);
      if (postExistingResponse != null &&
          postExistingResponse!.status == true) {
        Common.toastMessaage(postExistingResponse!.message, Colors.green);
        Navigator.pop(context);
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
          collectedStaffIdNew,
          createOrder,
          targetGroupsNew);
      if (postNewResponse != null && postNewResponse!.status == true) {
        Common.toastMessaage(postNewResponse!.message, Colors.green);
        Navigator.pop(context);
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
            title: const Text(
              "Add Renewal",
              style: TextStyle(fontSize: 16),
            ),
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
                                DateFormat('dd-MM-yyyy').format(selectedValue);
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
                  controller: customerNameExisting,
                  readOnly: true,
                  onTap: (() {
                    if (widget.custId != null) {
                    } else {
                      dropDialogExisting(context, "Customers");
                    }
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
                      "Add Products",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        addProductsDialogExisting(context);
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14.0),
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
                    itemCount: productsExisting.length,
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
                                    productsExisting[index]['product_name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsExisting[index]['product_rate'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsExisting[index]['quantity'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsExisting[index]['total_tax_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsExisting[index]['total_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    productsExisting.removeAt(index);
                                    productNameListExisting.removeAt(index);
                                    totalProductCostExisting = 0;
                                    totalProductTaxExisting = 0;
                                    for (int i = 0;
                                        i < productsExisting.length;
                                        i++) {
                                      totalProductCostExisting += double.parse(
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
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(right: 20.0, top: 4.0),
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
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Sub Total :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 35,
                            child: TextFormField(
                              readOnly: true,
                              controller: subTotalExisting,
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
                          const Text(
                            "Total Tax :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 35,
                            child: TextFormField(
                              readOnly: true,
                              controller: totalTaxExisting,
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
                          const Text(
                            "Discount :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 35,
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
                          const Text(
                            "Shipping Charge :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 35,
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
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total :',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                totalAmountExisting.text,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Create Invoice'),
                    value: createOrder, // initial value of the checkbox
                    onChanged: (bool? value) {
                      setState(() {
                        createOrder = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading),
                Visibility(
                  visible: createOrder,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Pay Status * :'),
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
                            isExpanded: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(right: 5.0, bottom: 10)),
                            hint: const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text('Status'),
                            ),
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
                            items:
                                detailsResponse!.data.paymentStatus.map((data) {
                              return DropdownMenuItem(
                                value: data.paymentStatus.toString(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      data.displaySts.toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                if (createOrder)
                  Visibility(
                    visible: payStatExisting == "partial" ||
                        payStatExisting == "paid",
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
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                validator: (value) {
                                  if (payStatExisting == "partial") {
                                    double val = double.parse(value!);
                                    if (value == "" || val == 0) {
                                      return "Enter Amount";
                                    } else if (val >=
                                        totalProductCostExisting) {
                                      return "Paid amount cannot be greater than or equal to total cost";
                                    }
                                  }
                                  return null;
                                },
                                readOnly:
                                    payStatExisting != "partial" ? true : false,
                                keyboardType: TextInputType.number,
                                controller: totalPaidAmountExisting,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    //labelText: 'Invoice Number',
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Pay Methord * :'),
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
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 8.0, right: 5.0, bottom: 10)),
                                hint: const Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text('Payment Methord'),
                                ),
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
                                items: detailsResponse!.data.paymentMethods
                                    .map((data) {
                                  return DropdownMenuItem<String>(
                                    value: data.id.toString(),
                                    child: Text(
                                      data.name.toString(),
                                    ),
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
                            const Text('Collected By * :'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                readOnly: true,
                                validator: (value) {
                                  if (payStatExisting == "partial" ||
                                      payStatExisting == "paid") {
                                    if (value == "" || value == null) {
                                      return "Select a staff";
                                    }
                                  }
                                  return null;
                                },
                                onTap: () {
                                  collectedStaffDialog(context, "existing")
                                      .then((_) {
                                    setState(() {});
                                  });
                                },
                                controller: collectedExisting,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    //labelText: 'Invoice Number',
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: GestureDetector(
                                  onTap: () {
                                    targetGroupDialog(context, "existing");
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: targetGroupsExisting.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 10),
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
                                                    targetGroupNamesExisting
                                                        .length,
                                                itemBuilder: (context, i) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
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
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    child: Text(
                                                                      targetGroupNamesExisting[
                                                                          i],
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
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
                                                                          const Text(
                                                                              'Are you sure to Remove this Number?'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('No')),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              setState(() {
                                                                                targetGroupNamesExisting.remove(targetGroupNamesExisting[i]);
                                                                                targetGroupsExisting.remove(targetGroupsExisting[i]);
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Yes')),
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
                                                                      width: 0),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              6),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              6))),
                                                              child: const Icon(
                                                                Icons.close,
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
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextFormField(
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
                    ),
                  ],
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
                                DateFormat('dd-MM-yyyy').format(selectedValue);
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
                    contentPadding: const EdgeInsets.all(8),
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
                    contentPadding: const EdgeInsets.all(8),
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
                      "Add Products",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        addProductsDialogNew(context);
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14.0),
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
                    itemCount: productsNew.length,
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
                                    productsNew[index]['product_name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsNew[index]['product_rate'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsNew[index]['quantity'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsNew[index]['total_tax_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productsNew[index]['total_amount'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                GestureDetector(
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
                                    totalAmountNew.text = (totalProductCostNew -
                                            discountAmtNew +
                                            shippingAmtNew)
                                        .toString();
                                    totalPaidAmountNew.text =
                                        totalAmountNew.text;
                                    setState(() {});
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(right: 20.0, top: 4.0),
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
                const SizedBox(height: 15.0),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Sub Total :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            readOnly: true,
                            controller: subTotalNew,
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
                        const Text(
                          "Total Tax :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
                          child: TextFormField(
                            readOnly: true,
                            controller: totalTaxNew,
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
                        const Text(
                          "Discount :",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 35,
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
                            "Shipping Charge :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
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
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Total :',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              totalAmountNew.text,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
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
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Create Invoice'),
                    value: createOrder, // initial value of the checkbox
                    onChanged: (bool? value) {
                      setState(() {
                        createOrder = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading),
                Visibility(
                  visible: createOrder,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Pay Status * :'),
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
                            isExpanded: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(right: 5.0, bottom: 10)),
                            hint: const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text('Status'),
                            ),
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
                            items:
                                detailsResponse!.data.paymentStatus.map((data) {
                              return DropdownMenuItem(
                                value: data.paymentStatus.toString(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      data.displaySts.toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                if (createOrder)
                  Visibility(
                    visible: payStatNew == "partial" || payStatNew == "paid",
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
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
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
                                readOnly:
                                    payStatNew != "partial" ? true : false,
                                keyboardType: TextInputType.number,
                                controller: totalPaidAmountNew,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    //labelText: 'Invoice Number',
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Pay Methord * :'),
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
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 8.0, right: 5.0, bottom: 10)),
                                hint: const Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text('Payment Methord'),
                                ),
                                validator: (value) {
                                  if (payStatNew == "partial" ||
                                      payStatNew == "paid") {
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
                                items: detailsResponse!.data.paymentMethods
                                    .map((data) {
                                  return DropdownMenuItem<String>(
                                    value: data.id.toString(),
                                    child: Text(
                                      data.name.toString(),
                                    ),
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
                            const Text('Collected By * :'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                readOnly: true,
                                validator: (value) {
                                  if (payStatNew == "partial" ||
                                      payStatNew == "paid") {
                                    if (value == "" || value == null) {
                                      return "Select a staff";
                                    }
                                  }
                                  return null;
                                },
                                onTap: () {
                                  collectedStaffDialog(context, "new")
                                      .then((_) {
                                    setState(() {});
                                  });
                                },
                                controller: collectedNew,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    //labelText: 'Invoice Number',
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: GestureDetector(
                                  onTap: () {
                                    targetGroupDialog(context, "new");
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: targetGroupsNew.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 10),
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
                                                    targetGroupNamesNew.length,
                                                itemBuilder: (context, i) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
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
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    child: Text(
                                                                      targetGroupNamesNew[
                                                                          i],
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
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
                                                                          const Text(
                                                                              'Are you sure to Remove this Number?'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('No')),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              setState(() {
                                                                                targetGroupNamesNew.remove(targetGroupNamesNew[i]);
                                                                                targetGroupsNew.remove(targetGroupsNew[i]);
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Yes')),
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
                                                                      width: 0),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              6),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              6))),
                                                              child: const Icon(
                                                                Icons.close,
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
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextFormField(
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
                    ),
                  ],
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
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              search.clear();
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
                                customerNameNew.text =
                                    filteredNames[index].name;
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

  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
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
                                customerNameExisting.text =
                                    filteredNames[index].name;
                                customerIdExisting = filteredNames[index].id;
                              } else if (title == "Template") {
                                remindMeExisting.text =
                                    filteredTemplates[index].templateName;
                                templateIdExisting =
                                    filteredTemplates[index].id;
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
        Navigator.pop(context);
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
        Navigator.pop(context);
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
    }
  }

  Future<dynamic> collectedStaffDialog(BuildContext context, String type) {
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
                            search.clear();
                            filteredStaff.clear();
                            filteredStaff.addAll(detailsResponse!.data.staff);
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
                      controller: search,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = detailsResponse!.data.staff
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
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xFFFCFBFA)),
                            child: ListTile(
                              onTap: () {
                                if (type == "new") {
                                  collectedNew.text =
                                      filteredStaff[index].staffName;
                                  collectedStaffIdNew =
                                      filteredStaff[index].userId;
                                } else {
                                  collectedExisting.text =
                                      filteredStaff[index].staffName;
                                  collectedStaffIdExisting =
                                      filteredStaff[index].userId;
                                }
                                search.clear();
                                filteredStaff.clear();
                                filteredStaff
                                    .addAll(detailsResponse!.data.staff);
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
                              leading: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Text(filteredStaff[index].staffName[0]),
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

  Future<Object?> addProductsDialogExisting(BuildContext context) {
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
                                getRenewalDetails();
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
                      const SizedBox(height: 15.0),
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
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                      productQuantityExisting.text =
                                          (currentValue)
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
                              controller: prodAmountExisting,
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
                              controller: prodDetailsExisting,
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

  Future<Object?> addProductsDialogNew(BuildContext context) {
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
                                getRenewalDetails();
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
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                              controller: prodAmountNew,
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
                              controller: prodDetailsNew,
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

  Future<dynamic> targetGroupDialog(BuildContext context, String type) {
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
                          filteredTargets = detailsResponse!.data.targetGroups
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
                      // physics: const NeverScrollableScrollPhysics(),
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
                          value: type == "new"
                              ? targetGroupsNew.contains(
                                      filteredTargets[ind].id.toString())
                                  ? true
                                  : false
                              : targetGroupsExisting.contains(
                                      filteredTargets[ind].id.toString())
                                  ? true
                                  : false,
                          onChanged: (bool? value) {
                            if (value == true) {
                              setState(() {
                                if (type == "new") {
                                  targetGroupsNew
                                      .add(filteredTargets[ind].id.toString());
                                  targetGroupNamesNew.add(filteredTargets[ind]
                                      .groupName
                                      .toString());
                                } else {
                                  targetGroupsExisting
                                      .add(filteredTargets[ind].id.toString());
                                  targetGroupNamesExisting.add(
                                      filteredTargets[ind]
                                          .groupName
                                          .toString());
                                }

                                Navigator.pop(context, true);
                              });
                            } else {
                              setState(() {
                                if (type == "new") {
                                  targetGroupsNew.remove(
                                      filteredTargets[ind].id.toString());
                                  targetGroupNamesNew.remove(
                                      filteredTargets[ind]
                                          .groupName
                                          .toString());
                                } else {
                                  targetGroupsExisting.remove(
                                      filteredTargets[ind].id.toString());
                                  targetGroupNamesExisting.remove(
                                      filteredTargets[ind]
                                          .groupName
                                          .toString());
                                }

                                Navigator.pop(context, true);
                              });
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredTargets.clear();
                    filteredTargets.addAll(detailsResponse!.data.targetGroups);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Done")),
            ],
          );
        });
      },
    );
  }
}
