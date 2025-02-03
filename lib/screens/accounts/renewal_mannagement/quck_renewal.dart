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
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/service/service.dart';

class QuickRenewal extends StatefulWidget {
  const QuickRenewal({super.key});

  @override
  State<QuickRenewal> createState() => _QuickRenewalState();
}

class _QuickRenewalState extends State<QuickRenewal> {
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
  bool isPaidExisting = false;
  bool isPaidNew = false;
  bool createInvoiceExisting = false;
  bool createInvoiceNew = false;
  BranchListModel? branchList;
  String multiBranch = "true";
  dynamic branchExisting;
  dynamic branchNew;
  String phCodeNew = "91";
  String whCodeNew = "91";
  List productsExisting = [];
  List productsNew = [];
  List productName = [];
  double totalProductCostExisting = 0;
  double totalProductCostNew = 0;
  bool uploading = false;
  bool isExists = false;
  IsCustomerExistModel? isExist;
  List<Template> filteredTemplates = [];
  String templateIdExisting = "";
  String templateIdNew = "";
  String typeDuration = "";

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
  TextEditingController productCostExisting = TextEditingController();
  TextEditingController productCostNew = TextEditingController();
  TextEditingController remindMeNew = TextEditingController();
  TextEditingController remindMeExisting = TextEditingController();
  TextEditingController remarkExisting = TextEditingController();
  TextEditingController remarkNew = TextEditingController();
  TextEditingController email = TextEditingController();

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
      postExistingResponse = await HttpService.postExistingQuick(
          productsExisting,
          customerIdExisting,
          productCostExisting.text,
          templateIdExisting,
          startDateExisting.text,
          endDateExisting.text,
          remarkExisting.text,
          branchExisting,
          isPaidExisting,
          totalProductCostExisting,
          createInvoiceExisting,
          detailsResponse!.data.checkId);

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
      postNewResponse = await HttpService.postNewQuick(
          isPaidNew,
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
          productCostNew.text,
          email.text,
          totalProductCostNew,
          createInvoiceNew,
          templateIdNew,
          detailsResponse!.data.checkId);
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
            title: const Text("Quick Insert"),
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
                  : SafeArea(
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
                                      return "Please Add Customer";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Customer *',
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                GestureDetector(
                                  onTap: () {
                                    dropDialogExisting(context, "Products");
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: productsExisting.isEmpty
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
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: productName.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 45,
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
                                                                      productName[
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
                                                                              productName.remove(productName[i]);
                                                                              productsExisting.removeAt(i);
                                                                              totalProductCostExisting = 0;

                                                                              for (int ind = 0; ind < productsExisting.length; ind++) {
                                                                                totalProductCostExisting += double.parse((await productsExisting[ind])["product_rate"]);
                                                                              }
                                                                              productCostExisting.text = (totalProductCostExisting).toString();
                                                                              print(productsExisting.length);
                                                                              setState(() {});

                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Yes')),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              height: 45,
                                                              width: 40,
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
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
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
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          labelText: 'Select Branch',
                                          prefixIcon: const Icon(
                                              Icons
                                                  .arrow_drop_down_circle_outlined,
                                              color: Colors.grey),
                                          labelStyle: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 14.0),
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
                                          DateFormat('dd-MM-yyyy')
                                              .format(selectedValue!);
                                      final endValue = selectedValue!.add(
                                          Duration(
                                              days: int.parse(typeDuration)));
                                      endDateExisting.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(endValue);
                                    });
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Select Start Date";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Start Date *',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
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
                                    endDateExisting.text =
                                        DateFormat('dd-MM-yyyy')
                                            .format(selectedEndDate!);
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Select End Date";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  controller: endDateExisting,
                                  decoration: const InputDecoration(
                                      labelText: 'End Date *',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: productCostExisting,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter Project Cost";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Project Cost *',
                                      prefixIcon: Icon(Icons.currency_rupee,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
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
                                      prefixIcon: Icon(Icons.notifications,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: remarkExisting,
                                  decoration: const InputDecoration(
                                      labelText: 'Remarks',
                                      prefixIcon: Icon(Icons.description,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        fillColor: createInvoiceExisting == true
                                            ? const WidgetStatePropertyAll(
                                                Colors.blue)
                                            : const WidgetStatePropertyAll(
                                                Colors.white),
                                        checkColor: Colors.white,
                                        value: createInvoiceExisting,
                                        onChanged: (value) {
                                          setState(() {
                                            createInvoiceExisting = value!;
                                            if (createInvoiceExisting ==
                                                false) {
                                              isPaidExisting = value;
                                            }
                                          });
                                        }),
                                    const Text("Create Invoice")
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        fillColor: isPaidExisting == true
                                            ? const WidgetStatePropertyAll(
                                                Colors.blue)
                                            : const WidgetStatePropertyAll(
                                                Colors.white),
                                        checkColor: Colors.white,
                                        value: isPaidExisting,
                                        onChanged: (value) {
                                          setState(() {
                                            isPaidExisting = value!;
                                            if (isPaidExisting == true) {
                                              createInvoiceExisting = value;
                                            }
                                          });
                                        }),
                                    const Text("Paid")
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  height: 40,
                                  width: double.maxFinite,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3375e0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      if (uploading == false) {
                                        if (existingFormKey.currentState!
                                                .validate() &&
                                            productsExisting.isNotEmpty) {
                                          setState(() {
                                            uploading = true;
                                          });
                                          postExisting();
                                        } else {
                                          Common.toastMessaage(
                                              "Please fill all required fields",
                                              Colors.red);
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                    ),
              isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                      ),
                    )
                  : SafeArea(
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
                                    labelText: 'Customer Name *',
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
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
                                            style: const TextStyle(
                                                color: Colors.black),
                                          )),
                                    ),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
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
                                              style: const TextStyle(
                                                  color: Colors.black))),
                                    ),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                GestureDetector(
                                  onTap: () {
                                    dropDialogNew(context, "Products");
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
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
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: productName.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 45,
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
                                                                      productName[
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
                                                                              productName.remove(productName[i]);
                                                                              productsNew.removeAt(i);
                                                                              totalProductCostNew = 0;

                                                                              for (int ind = 0; ind < productsNew.length; ind++) {
                                                                                totalProductCostNew += double.parse((await productsNew[ind])["product_rate"]);
                                                                              }
                                                                              productCostNew.text = (totalProductCostNew).toString();
                                                                              setState(() {});
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text('Yes')),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              height: 45,
                                                              width: 40,
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
                                      prefixIcon: Icon(Icons.border_color,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                multiBranch == 'true'
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 14.0),
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Select Branch',
                                            prefixIcon: const Icon(
                                                Icons
                                                    .arrow_drop_down_circle_outlined,
                                                color: Colors.grey),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey),
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
                                          DateFormat('dd-MM-yyyy')
                                              .format(selectedValue!);
                                      final endValue = selectedValue!.add(
                                          Duration(
                                              days:
                                                  int.parse(productDuration)));
                                      endDateNew.text = DateFormat('dd-MM-yyyy')
                                          .format(endValue);
                                    });
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Select Start Date";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Start Date *',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
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
                                    endDateNew.text = DateFormat('dd-MM-yyyy')
                                        .format(selectedEndDate!);
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Select End Date";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  controller: endDateNew,
                                  decoration: const InputDecoration(
                                      labelText: 'End Date *',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: productCostNew,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter Project Cost";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Project Cost *',
                                      prefixIcon: Icon(Icons.currency_rupee,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: address1,
                                  decoration: const InputDecoration(
                                    labelText: 'Address Line 1',
                                    prefixIcon:
                                        Icon(Icons.home, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: address2,
                                  decoration: const InputDecoration(
                                    labelText: 'Address Line 2',
                                    prefixIcon:
                                        Icon(Icons.home, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: address3,
                                  decoration: const InputDecoration(
                                    labelText: 'Address Line 3',
                                    prefixIcon:
                                        Icon(Icons.home, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
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
                                    prefixIcon: Icon(Icons.pin_drop,
                                        color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: postOffice,
                                  decoration: const InputDecoration(
                                    labelText: 'Post Office',
                                    prefixIcon: Icon(
                                        Icons.local_post_office_sharp,
                                        color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: gstNumber,
                                  decoration: const InputDecoration(
                                    labelText: 'GST Number',
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
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
                                      prefixIcon: Icon(Icons.notifications,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                TextFormField(
                                  controller: remarkNew,
                                  decoration: const InputDecoration(
                                      labelText: 'Remarks',
                                      prefixIcon: Icon(Icons.description,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(height: 14.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        fillColor: createInvoiceNew == true
                                            ? const WidgetStatePropertyAll(
                                                Colors.blue)
                                            : const WidgetStatePropertyAll(
                                                Colors.white),
                                        checkColor: Colors.white,
                                        value: createInvoiceNew,
                                        onChanged: (value) {
                                          setState(() {
                                            createInvoiceNew = value!;
                                            if (createInvoiceNew == false) {
                                              isPaidNew = value;
                                            }
                                          });
                                        }),
                                    const Text("Create Invoice")
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        fillColor: isPaidNew == true
                                            ? const WidgetStatePropertyAll(
                                                Colors.blue)
                                            : const WidgetStatePropertyAll(
                                                Colors.white),
                                        checkColor: Colors.white,
                                        value: isPaidNew,
                                        onChanged: (value) {
                                          setState(() {
                                            isPaidNew = value!;
                                            if (isPaidNew == true) {
                                              createInvoiceNew = value;
                                            }
                                          });
                                        }),
                                    const Text("Paid")
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  height: 40,
                                  width: double.maxFinite,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3375e0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      if (uploading == false) {
                                        if (newFormKey.currentState!
                                                .validate() &&
                                            productsNew.isNotEmpty) {
                                          setState(() {
                                            uploading = true;
                                          });
                                          postNew();
                                        } else {
                                          Common.toastMessaage(
                                              "Please fill all required fields",
                                              Colors.red);
                                        }
                                      }
                                      if (isExists == true) {
                                        Common.toastMessaage(
                                            "This number is already existed",
                                            Colors.red);
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          )),
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
                                "product_name":
                                    filteredProducts[index].productName,
                                "product_rate":
                                    filteredProducts[index].sellingPrice,
                                "quantity": 1,
                                "tax_percent":
                                    filteredProducts[index].taxPercent,
                                "total_tax_amount":
                                    filteredProducts[index].taxAmount,
                                "total_amount":
                                    filteredProducts[index].sellingPrice,
                                "description": "",
                              });
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            totalProductCostNew = 0;

                            for (int i = 0; i < productsNew.length; i++) {
                              totalProductCostNew += double.parse(
                                  (await productsNew[i])["product_rate"]);
                            }
                            productCostNew.text =
                                (totalProductCostNew).toString();
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
                            typeDuration = filteredProducts[index].noOfDays;

                            if (startDateExisting.text.isNotEmpty) {
                              final endValue = selectedValue!
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDateExisting.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
                            }
                            if (productName.contains(
                                filteredProducts[index].productName)) {
                            } else {
                              productsExisting.add({
                                "product_id": filteredProducts[index].id,
                                "product_name":
                                    filteredProducts[index].productName,
                                "product_rate":
                                    filteredProducts[index].sellingPrice,
                                "quantity": 1,
                                "tax_percent":
                                    filteredProducts[index].taxPercent,
                                "total_tax_amount":
                                    filteredProducts[index].taxAmount,
                                "total_amount":
                                    filteredProducts[index].sellingPrice,
                                "description": "",
                              });
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            totalProductCostExisting = 0;

                            for (int i = 0; i < productsExisting.length; i++) {
                              totalProductCostExisting += double.parse(
                                  (await productsExisting[i])["product_rate"]);
                            }
                            productCostExisting.text =
                                (totalProductCostExisting).toString();
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
}
