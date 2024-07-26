import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/service/service.dart';

class RenewCustomRenewal extends StatefulWidget {
  const RenewCustomRenewal({super.key});

  @override
  State<RenewCustomRenewal> createState() => _RenewCustomRenewalState();
}

class _RenewCustomRenewalState extends State<RenewCustomRenewal> {
  bool isLoading = true;
  bool uploading =false;
  final formKey = GlobalKey<FormState>();
  List<Product> filteredProducts = [];
  List filteredNames = [];
  List productName = [];
  RenewalDetailslModel? detailsResponse;
  TextEditingController subTotalExisting = TextEditingController();
  TextEditingController totalTaxExisting = TextEditingController();
  TextEditingController discountExisting = TextEditingController();
  TextEditingController shippingChargeExisting = TextEditingController();
  TextEditingController totalAmountExisting = TextEditingController();
  TextEditingController totalPaidAmountExisting = TextEditingController();
  TextEditingController productQuantityExisting =
      TextEditingController(text: '1');
  TextEditingController prodDetailsExisting = TextEditingController();
  TextEditingController prodAmountExisting = TextEditingController();
  TextEditingController prodTaxExisting = TextEditingController();
  TextEditingController prodRateExisting = TextEditingController();
  TextEditingController productNameExisting = TextEditingController();
  TextEditingController remindMeExisting = TextEditingController();
  TextEditingController remarkExisting = TextEditingController();
  TextEditingController endDateExisting = TextEditingController();
  TextEditingController customerNameExisting = TextEditingController();
  TextEditingController invoiceDate = TextEditingController();
  TextEditingController invoiceNumber = TextEditingController();
  TextEditingController startDateExisting = TextEditingController();

  DateTime? selectedValue;
  BranchListModel? branchList;
  String multiBranch = "true";
  dynamic branchExisting;
  dynamic branchNew;
  String typeDuration = "";
  String invoiceSlNum = "";
  String productIdExisting = "";
  IsCustomerExistModel? isExist;
  List<Template> filteredTemplates = [];
  String templateIdExisting = "";
  double totalProductTaxExisting = 0;
  double totalProductCostExisting = 0;
  List productsExisting = [];
  dynamic payStatExisting;
  dynamic payMethodExisting;
  dynamic collectedExisting;
  double shippingAmtExisting = 0;
  double discountAmtExisting = 0;
  double productTaxExisting = 0;
  double parseRateExisting = 0;
  double parseQtyExisting = 0;
  double parseTaxExisting = 0;
  String customerIdExisting = "";

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
                        "Renew",
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
          : existingWidget(context),
    );
  }

  SafeArea existingWidget(BuildContext context) {
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
                                    onTap: () async {
                                      productsExisting.removeAt(index);
                                      productName.removeAt(index);
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
                                                "tax_percent_amount"]);
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
                                totalPaidAmountExisting.text =
                                    totalAmountExisting.text;
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
                                totalPaidAmountExisting.text =
                                    totalAmountExisting.text;
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
                        if (formKey.currentState!.validate() &&
                            productsExisting.isNotEmpty) {
                          setState(() {
                            uploading = true;
                          });
                          // postExisting();
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
    if (productName.contains(productNameExisting.text)) {
      Common.toastMessaage('Already Added', Colors.red);
    } else {
      if (productNameExisting.text != "") {
        productsExisting.add({
          "product_id": productIdExisting,
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
        totalPaidAmountExisting.text = totalAmountExisting.text;
        setState(() {});
      } else {
        Common.toastMessaage('Add a product', Colors.red);
      }
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
}