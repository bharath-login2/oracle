// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/renewal_mannagement/add_customer.dart';
import 'package:login2/screens/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/service/service.dart';

class AddNewRenewalScreen extends StatefulWidget {
  const AddNewRenewalScreen({super.key});

  @override
  State<AddNewRenewalScreen> createState() => _AddNewRenewalScreenState();
}

class _AddNewRenewalScreenState extends State<AddNewRenewalScreen> {
  final formKey = GlobalKey<FormState>();
  RenewalDetailslModel? detailsResponse;
  bool isLoading = true;
  List filteredNames = [];
  List filteredProducts = [];
  List filteredTemplates = [];
  String customerId = "";
  String templateId = "";
  List products = [];
  List productName = [];
  double totalProductCost = 0;
  String typeDuration = "";
  DateTime? selectedValue;
  bool isPaid = false;
  bool createInvoice = false;
  BranchListModel? branchList;
  String multiBranch = "true";
  dynamic branch;
  PostRenewalModel? postResponse;
  bool uploading = false;

  TextEditingController customerName = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController productCost = TextEditingController();
  TextEditingController remindMe = TextEditingController();
  TextEditingController remark = TextEditingController();
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
    detailsResponse = await HttpService.getRenewalDetails();

    if (detailsResponse != null && detailsResponse!.status == true) {
      filteredNames = detailsResponse!.data.customers;
      filteredProducts = detailsResponse!.data.renewalProducts;
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
    filteredNames = detailsResponse!.data.customers
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void filterProducts(
    String query,
  ) {
    filteredProducts = detailsResponse!.data.renewalProducts
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

  postRenewal() async {
    postResponse = await HttpService.postRenewal(
        products,
        customerId,
        productCost.text,
        templateId,
        startDate.text,
        endDate.text,
        remark.text,
        branch,
        isPaid,
        totalProductCost,
        createInvoice);

    if (postResponse != null && postResponse!.status == true) {
      Common.toastMessaage(postResponse!.message, Colors.green);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RenewalDashboard(),
          ));
    } else {
      Common.toastMessaage(postResponse!.message, Colors.red);
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
                        "Existing Customer",
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
          : SafeArea(
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
                              return "Please Add Customer";
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
                        GestureDetector(
                          onTap: () {
                            dropDialog(context, "Products");
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 65,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: products.isEmpty
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
                                            fontSize: 16, color: Colors.grey),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .8,
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
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
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
                                                                    .all(10),
                                                            child: Text(
                                                              productName[i],
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
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Please Confirm'),
                                                              content: const Text(
                                                                  'Are you sure to Remove this Number?'),
                                                              actions: [
                                                                // The "Yes" button
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      productName
                                                                          .remove(
                                                                              productName[i]);
                                                                      products
                                                                          .removeAt(
                                                                              i);
                                                                      totalProductCost =
                                                                          0;

                                                                      for (int ind =
                                                                              0;
                                                                          ind <
                                                                              products.length;
                                                                          ind++) {
                                                                        totalProductCost +=
                                                                            double.parse((await products[ind])["prd_cost"]);
                                                                      }
                                                                      productCost
                                                                              .text =
                                                                          (totalProductCost)
                                                                              .toString();
                                                                      print(products
                                                                          .length);
                                                                      setState(
                                                                          () {});

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'Yes')),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
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
                                                              color:
                                                                  Colors.grey,
                                                              width: 0),
                                                          color: Colors
                                                              .grey.shade100,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
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
                                  border: OutlineInputBorder(
                                    // Custom border
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  labelText: 'Select Branch',
                                  prefixIcon: const Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      color: Colors.grey),
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 14.0),
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
                              startDate.text = DateFormat('dd-MM-yyyy')
                                  .format(selectedValue!);
                              final endValue = selectedValue!
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDate.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
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
                            endDate.text = DateFormat('dd-MM-yyyy')
                                .format(selectedEndDate!);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Select End Date";
                            }
                            return null;
                          },
                          readOnly: true,
                          controller: endDate,
                          decoration: const InputDecoration(
                              labelText: 'End Date *',
                              prefixIcon: Icon(Icons.calendar_month,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 14.0),
                        TextFormField(
                          controller: productCost,
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
                          decoration: const InputDecoration(
                              labelText: 'Remind Template *',
                              prefixIcon:
                                  Icon(Icons.notifications, color: Colors.grey),
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
                              labelText: 'Remarks',
                              prefixIcon:
                                  Icon(Icons.description, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 14.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                                fillColor: createInvoice == true
                                    ? const MaterialStatePropertyAll(
                                        Colors.blue)
                                    : const MaterialStatePropertyAll(
                                        Colors.white),
                                checkColor: Colors.white,
                                value: createInvoice,
                                onChanged: (value) {
                                  setState(() {
                                    createInvoice = value!;
                                    if (createInvoice == false) {
                                      isPaid = value;
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
                                fillColor: isPaid == true
                                    ? const MaterialStatePropertyAll(
                                        Colors.blue)
                                    : const MaterialStatePropertyAll(
                                        Colors.white),
                                checkColor: Colors.white,
                                value: isPaid,
                                onChanged: (value) {
                                  setState(() {
                                    isPaid = value!;
                                    if (isPaid == true) {
                                      createInvoice = value;
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
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () {
                              if (uploading == false) {
                                if (formKey.currentState!.validate() &&
                                    products.isNotEmpty) {
                                  setState(() {
                                    uploading = true;
                                  });
                                  postRenewal();
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
            ),
            floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            onPressed: () {
                Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddRenewalCustomerScreen(),
                            ));
            },
            child: const Text("new")),
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
                            templateId = filteredTemplates[index].templateId;
                          } else {
                            typeDuration = filteredProducts[index].noOfDays;

                            if (startDate.text.isNotEmpty) {
                              final endValue = selectedValue!
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDate.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
                            }

                            if (productName.contains(
                                filteredProducts[index].productName)) {
                            } else {
                              products.add({
                                "prd_id": filteredProducts[index].id,
                                "prd_cost": filteredProducts[index].totalAmount
                              });
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            totalProductCost = 0;

                            for (int i = 0; i < products.length; i++) {
                              totalProductCost +=
                                  double.parse((await products[i])["prd_cost"]);
                            }
                            productCost.text = (totalProductCost).toString();
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
