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
  const CustomRenewal({super.key});

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
  DateTime? selectedValue;
  double parseRateExisting = 0;
  double parseQtyExisting = 0;
  double parseTaxExisting = 0;
  double productTaxExisting = 0;
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
  List productName = [];
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
  TextEditingController startDateExisting = TextEditingController();
  TextEditingController startDateNew = TextEditingController();
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
          totalAmountExisting.text,
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
          detailsResponse!.data.checkId);
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
            title: const Text("Custom Renewal"),
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
            bottom: const TabBar(
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
          body: TabBarView(
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
                      return "Enter Customer Name";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
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
                      return "Enter Customer Number";
                    } else if (isExists == true) {
                      return "This number is Already Exists";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
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
                GestureDetector(
                  onTap: () {
                    dropDialogNew(context, "Products");
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: productsNew.isEmpty
                        ? const Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Products *',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 45,
                                width: MediaQuery.of(context).size.width * .8,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: productName.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0),
                                                color: Colors.white,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    topLeft: Radius.circular(6),
                                                    bottomLeft:
                                                        Radius.circular(6))),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      productName[i],
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
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm'),
                                                      content: const Text(
                                                          'Are you sure to Remove this Number?'),
                                                      actions: [
                                                        // The "Yes" button
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              productName.remove(
                                                                  productName[
                                                                      i]);
                                                              productsNew
                                                                  .removeAt(i);
                                                              totalProductCostNew =
                                                                  0;

                                                              for (int ind = 0;
                                                                  ind <
                                                                      productsNew
                                                                          .length;
                                                                  ind++) {
                                                                totalProductCostNew +=
                                                                    double.parse(
                                                                        (await productsNew[ind])[
                                                                            "prd_cost"]);
                                                              }

                                                              print(productsNew
                                                                  .length);
                                                              setState(() {});

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Yes')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'No'))
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Container(
                                              height: 45,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 0),
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  6),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  6))),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                            ),
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
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.border_color, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                multiBranch == 'true'
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: DropdownButtonFormField(
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
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 14.0),
                TextFormField(
                  controller: startDateNew,
                  readOnly: true,
                  onTap: () async {
                    selectedValue = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      startDateNew.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue!);
                      final endValue = selectedValue!
                          .add(Duration(days: int.parse(productDuration)));
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
                  controller: address1,
                  decoration: const InputDecoration(
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
                    labelText: 'GST Number',
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
                  onTap: () {
                    dropDialogNew(context, "Template");
                  },
                  readOnly: true,
                  controller: remindMeNew,
                  decoration: const InputDecoration(
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
                  controller: remarkNew,
                  decoration: const InputDecoration(
                      labelText: 'productsExisting',
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
                        } else {
                          Common.toastMessaage(
                              "Fill all required fields", Colors.red);
                        }
                      }
                      if (isExists == true) {
                        Common.toastMessaage(
                            "This number is already existed", Colors.red);
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
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
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
                  decoration: const InputDecoration(
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
                                    horizontal: 8.0, vertical: 14),
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
                                    onTap: () {
                                      productsExisting.removeAt(index);
                                      setState(() {});
                                      productName.removeAt(index);
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
                const SizedBox(height: 25.0),
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
                              },
                              keyboardType: TextInputType.number,
                              controller: discountExisting,
                              decoration: const InputDecoration(
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
                              },
                              keyboardType: TextInputType.number,
                              controller: shippingChargeExisting,
                              decoration: const InputDecoration(
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
                const SizedBox(height: 25.0),
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
                            if (value == "") {
                              return "Enter Amount";
                            }
                          }
                          return null;
                        },
                        readOnly: payStatExisting != "partial" ? true : false,
                        keyboardType: TextInputType.number,
                        controller: totalPaidAmountExisting,
                        decoration: const InputDecoration(
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
                    selectedValue = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      startDateExisting.text =
                          DateFormat('dd-MM-yyyy').format(selectedValue!);
                      final endValue = selectedValue!
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
                  controller: remarkExisting,
                  decoration: const InputDecoration(
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
                          setState(() {
                            if (title == "Template") {
                              setState(() {
                                filterTemplates(value);
                              });
                            } else {
                              filterProducts(value);
                            }
                          });
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .32,
                  width: MediaQuery.of(context).size.height * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "Template"
                        ? filteredTemplates.length
                        : filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (() async {
                          if (title == "Template") {
                            remindMeNew.text =
                                filteredTemplates[index].templateName;
                            templateIdNew = filteredTemplates[index].id;
                          } else {
                            productDuration = filteredProducts[index].noOfDays;

                            if (startDateNew.text.isNotEmpty) {
                              final endValue = selectedValue!.add(
                                  Duration(days: int.parse(productDuration)));
                              endDateNew.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
                            }

                            if (productName.contains(
                                filteredProducts[index].productName)) {
                            } else {
                              productsNew.add({
                                "product_id": filteredProducts[index].id,
                                "prd_cost": filteredProducts[index].sellingPrice
                              });
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            totalProductCostNew = 0;

                            for (int i = 0; i < productsNew.length; i++) {
                              totalProductCostNew += double.parse(
                                  (await productsNew[i])["prd_cost"]);
                            }
                          }

                          Navigator.pop(context);
                          setState(() {});
                          filterProducts("");
                        }),
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            title == "Template"
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
                            productNameExisting.text =
                                filteredProducts[index].productName;
                            prodRateExisting.text =
                                filteredProducts[index].sellingPrice;
                            prodTaxExisting.text =
                                filteredProducts[index].taxPercent;
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
    if (productName.contains(productNameExisting.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameExisting.text != "") {
        [
          {
            "product_id": "36",
            "description": "BUDDHA PAINTING Canvas 10'*10",
            "product_rate": "1999",
            "quantity": "1",
            "tax_percent": "0",
            "total_tax_amount": "0",
            "total_amount": "1999"
          }
        ];
        productsExisting.add({
          "product_id": productNameExisting,
          "product_name": productNameExisting.text,
          "product_rate": prodRateExisting.text,
          "quantity": productQuantityExisting.text,
          "tax_percent": prodTaxExisting.text,
          "tax_percent_amount": productTaxExisting.toString(),
          "total_amount": prodAmountExisting.text,
          "description": prodDetailsExisting.text,
        });
        productName.add(productNameExisting.text);
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
              double.parse((await productsExisting[i])["tax_percent_amount"]);
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
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
    }
  }
}
