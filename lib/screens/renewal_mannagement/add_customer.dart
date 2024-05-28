// ignore_for_file: use_build_context_synchronously

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/add_customer_model.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/service/service.dart';

class AddRenewalCustomerScreen extends StatefulWidget {
  const AddRenewalCustomerScreen({super.key});

  @override
  State<AddRenewalCustomerScreen> createState() =>
      _AddRenewalCustomerScreenState();
}

class _AddRenewalCustomerScreenState extends State<AddRenewalCustomerScreen> {
  final formKey = GlobalKey<FormState>();
  RenewalDetailslModel? detailsResponse;
  AddCustomerModel? postResponse;
  bool isLoading = true;
  List filteredProducts = [];
  String customerId = "";
  String productDuration = "";
  DateTime? selectedValue;
  bool isPaid = false;
  bool createInvoice = false;
  BranchListModel? branchList;
  String multiBranch = "true";
  dynamic branch;
  String phCode = "91";
  String whCode = "91";
  List products = [];
  List productName = [];
  double totalProductCost = 0;
  bool uploading = false;
  bool isExists = false;
  IsCustomerExistModel? isExist;
  List filteredTemplates = [];
  String templateId = "";

  TextEditingController customerName = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController whatsappNumber = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController typeName = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController productCost = TextEditingController();
  TextEditingController remindMe = TextEditingController();
  TextEditingController remark = TextEditingController();
  TextEditingController email = TextEditingController();

  getBranch() async {
    multiBranch = await Common.getSharedPref("multiBranch");
    String token = await Common.getSharedPref("token");
    branchList = await HttpService.getBranchList(token);
    if (branchList != null) {}
  }

  isCustomerExists() async {
    isExist = await HttpService.isCustomerExists("", number.text);
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

  postCustomer() async {
    postResponse = await HttpService.postCustomer(
        isPaid,
        branch,
        phCode,
        number.text,
        whCode,
        whatsappNumber.text,
        customerName.text,
        address1.text,
        address2.text,
        address3.text,
        postOffice.text,
        pinCode.text,
        gstNumber.text,
        remark.text,
        products,
        startDate.text,
        endDate.text,
        productCost.text,
        email.text,
        totalProductCost,
        createInvoice,
        templateId);

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
            // color: Colors.teal,
            // image: DecorationImage(
            //   fit: BoxFit.cover,
            //   image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxm1-0D3a3KOSC29gIUrre2R8sMnYVr-_6rA&usqp=CAU")),
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
                        "New Customer",
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
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: customerName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Customer Name";
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
                          controller: number,
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
                                          phCode = country.phoneCode;
                                        });
                                      },
                                    );
                                  },
                                  child: Text(
                                    "+ $phCode",
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
                                          whCode = country.phoneCode;
                                        });
                                      },
                                    );
                                  },
                                  child: Text("+ $whCode",
                                      style: const TextStyle(
                                          color: Colors.black))),
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
                              prefixIcon:
                                  Icon(Icons.border_color, color: Colors.grey),
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
                              final endValue = selectedValue!.add(
                                  Duration(days: int.parse(productDuration)));
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
                            prefixIcon:
                                Icon(Icons.pin_drop, color: Colors.grey),
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
                            prefixIcon: Icon(Icons.local_post_office_sharp,
                                color: Colors.grey),
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
                            dropDialog(context, "Template");
                          },
                          readOnly: true,
                          controller: remindMe,
                          decoration: const InputDecoration(
                              labelText: 'Remind Template', 
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
                                  postCustomer();
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
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "Template"
                        ? filteredTemplates.length
                        : filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (() async {
                          if (title == "Template") {
                            remindMe.text =
                                filteredTemplates[index].templateName;
                            templateId = filteredTemplates[index].templateId;
                          } else {
                            productDuration = filteredProducts[index].noOfDays;
                            
                            if (startDate.text.isNotEmpty) {
                              final endValue = selectedValue!.add(
                                  Duration(days: int.parse(productDuration)));
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
}
