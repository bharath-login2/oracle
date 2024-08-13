import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:login2/models/lead_management/addLeadFollowupModel.dart';
import 'package:login2/models/renewal/renewal_followup_details.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RenewalFollowup extends StatefulWidget {
  String renewalId;
  DateTime callingDate;

  RenewalFollowup(
    this.renewalId,
    this.callingDate, {
    super.key,
  });

  @override
  State<RenewalFollowup> createState() => _RenewalFollowupState();
}

class _RenewalFollowupState extends State<RenewalFollowup> {
  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController search = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController invoiceRemarks = TextEditingController();
  TextEditingController renewalRemarks = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  TextEditingController productCost = TextEditingController();
  RenewalFollowupDetailsModel? detailsResponse;
  Color paidColor = Colors.black;
  String templateId = "";
  List<RenewalTemplate> filteredTemplates = [];
  String invoiceNumber = '';
  var invoiceDate = DateTime.now();
  List<Map<String, dynamic>> products = [];
  List productNames = [];
  double totalProductCost = 0;
  bool isLoading = true;
  double subTotal = 0.00;
  double totalTaxAmount = 00;
  double allTotal = 0.00;
  bool isPaying = false;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic collectedStaff;
  List<AllProduct> items = [];
  List<AllProduct> filteredItems = [];
  String productId = "";
  String productName = "Choose Product";
  bool createRenewal = false;
  bool createOrder = false;
  String leadStatus = 'Followup';
  String leadStatusId = '2';
  String callResponse = 'Call Response';
  String callResponseId = '';
  String? nextFollowupDate = '';
  String callResultReasonName = 'Reason';
  String callResultReasonId = '';
  TextEditingController remarks = TextEditingController();
  TextEditingController calledDate1 = TextEditingController();
  TextEditingController nextFollowupDate1 = TextEditingController();
  TextEditingController callResultVal = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController timeBefore = TextEditingController(text: '10');
  TextEditingController callReasonVal = TextEditingController();
  bool? result = true;
  bool? result1 = true;
  bool checked = false;
  bool addClient = false;
  bool isExpand = false;
  bool isChecked = false;
  bool timeOut = false;
  String token = "";
  void toggleTextFieldVisibility() {
    setState(() {
      checked = !checked;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
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
      token = await Common.getSharedPref("token");
      detailsResponse =
          await HttpService.getAddRenewalFollowUpDetails(widget.renewalId);
      if (detailsResponse != null) {
        invoiceNumber = detailsResponse!.data.invoiceId.toString();
        items = detailsResponse!.data.allProducts;
        filteredTemplates = detailsResponse!.data.renewalTemplate;
        filteredItems.addAll(items);
      }
      setState(() {});
    } catch (e) {
      setState(() {
        timeOut = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  @override
  Widget build(BuildContext context) {
    callResultVal.text = leadStatus;
    callReasonVal.text = callResultReasonName;
    callResponseVal.text = callResponse;
    calledDate1.text = DateFormat('dd-MM-yyyy HH:mm')
        .format(DateTime.parse(widget.callingDate.toString()));

    return result == true && timeOut == false
        ? Scaffold(
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
                            'Add Followup',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: isLoading == false
                ? SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: const Text('Called Date : ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ))),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextFormField(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  controller: calledDate1,
                                  readOnly: true,
                                  onTap: () async {
                                    await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100))
                                        .then((selectedDate) {
                                      if (selectedDate != null) {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((selectedTime) {
                                          String newDate =
                                              selectedDate.toString();
                                          newDate = newDate.substring(
                                              0, newDate.indexOf(" "));
                                          String convertedNewDate =
                                              getYmdFromDmy(newDate);
                                          if (selectedTime != null) {
                                            calledDate1.text =
                                                "$convertedNewDate ${selectedTime.format(context)}";
                                          } else {}
                                        });
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onTap: () {
                              callResultDialog(context);
                            },
                            maxLines: 1,
                            readOnly: true,
                            controller: callResultVal,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Lead Status',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          leadStatusId == '3'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: TextFormField(
                                    onTap: () {
                                      reasonDialog(context);
                                    },
                                    maxLines: 1,
                                    readOnly: true,
                                    controller: callReasonVal,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Reason',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(Icons.reply_all_sharp,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              : const SizedBox(),
                          if (leadStatusId == '2')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: checked == true
                                      ? MediaQuery.of(context).size.width * 0.55
                                      : MediaQuery.of(context).size.width * 0.8,
                                  child: TextFormField(
                                    controller: nextFollowupDate1,
                                    readOnly: true,
                                    onTap: () async {
                                      await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2100))
                                          .then((selectedDate) {
                                        if (selectedDate != null) {
                                          showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now())
                                              .then((selectedTime) {
                                            String newDate =
                                                selectedDate.toString();
                                            newDate = newDate.substring(
                                                0, newDate.indexOf(" "));
                                            String convertedNewDate =
                                                getYmdFromDmy(newDate);
                                            if (selectedTime != null) {
                                              nextFollowupDate1.text =
                                                  "$convertedNewDate ${selectedTime.format(context)}";
                                            } else {}
                                          });
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Next Followup Date',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons.calendar_month_sharp,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                Visibility(
                                  visible: checked,
                                  child: SizedBox(
                                    width: 90,
                                    child: Container(
                                      width: 80,
                                      foregroundDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: Colors.blueGrey,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.all(8.0),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              controller: timeBefore,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: false,
                                                signed: true,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 38.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.arrow_drop_up,
                                                      size: 18.0,
                                                    ),
                                                    onTap: () {
                                                      int currentValue =
                                                          int.parse(
                                                              timeBefore.text);
                                                      setState(() {
                                                        currentValue++;
                                                        timeBefore.text =
                                                            (currentValue)
                                                                .toString(); // incrementing value
                                                      });
                                                    },
                                                  ),
                                                ),
                                                InkWell(
                                                  child: const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18.0,
                                                  ),
                                                  onTap: () {
                                                    int currentValue =
                                                        int.parse(
                                                            timeBefore.text);
                                                    setState(() {
                                                      currentValue--;
                                                      timeBefore
                                                          .text = (currentValue >
                                                                  0
                                                              ? currentValue
                                                              : 0)
                                                          .toString(); // decrementing value
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (leadStatusId == '2')
                                  InkWell(
                                    onTap: toggleTextFieldVisibility,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: SizedBox(
                                        width: 10,
                                        child: Icon(Icons.notifications,
                                            color: checked == false
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          if (leadStatusId == '2')
                            const SizedBox(
                              height: 15,
                            ),
                          TextFormField(
                            onTap: () {
                              callResponseDialog(context);
                            },
                            maxLines: 1,
                            readOnly: true,
                            controller: callResponseVal,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Call Response',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.add_call, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (leadStatusId == '2')
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    productDialog(context, "1");
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: productNames.isEmpty
                                        ? const Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.shopping_cart,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Products',
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
                                                  itemCount:
                                                      productNames.length,
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
                                                                      productNames[
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
                                                                              'Are you sure to Remove this product?'),
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
                                                                              productNames.removeAt(i);
                                                                              products.removeAt(i);
                                                                              totalProductCost = 0;
                                                                              for (int ind = 0; ind < products.length; ind++) {
                                                                                totalProductCost += double.parse(await products[ind]["total_amount"]);
                                                                              }
                                                                              productCost.text = (totalProductCost).toString();
                                                                              setState(() {});

                                                                              if (context.mounted) {
                                                                                Navigator.of(context).pop();
                                                                              }
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
                                const SizedBox(height: 15.0),
                                TextFormField(
                                  controller: productCost,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter Cost";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'Cost',
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
                                const SizedBox(height: 15.0),
                              ],
                            ),
                          TextFormField(
                            controller: remarks,
                            maxLines: 2,
                            decoration: const InputDecoration(
                                labelText: 'Remarks',
                                fillColor: Colors.white,
                                filled: true,
                                //prefixIcon: Icon(myIcon, color: prefixIconColor),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (leadStatusId == '4')
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Order'),
                                value:
                                    createOrder, // initial value of the checkbox
                                onChanged: (bool? value) {
                                  setState(() {
                                    createOrder = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          Visibility(
                            visible: createOrder && leadStatusId == '4',
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            initialValue:
                                                invoiceDate.toString(),
                                            type: DateTimePickerType.date,
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
                                                  invoiceDate =
                                                      DateTime.parse(value);
                                                });
                                              }
                                            },
                                            // We can also use onSaved
                                            onSaved: (value) {
                                              if (value!.isNotEmpty) {
                                                invoiceDate = value as DateTime;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        addProductsDialog(context).then((_) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                                top: 5,
                                                bottom: 5,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              '+ Add Product',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2), // Using 10%
                                          1: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14), // Using 30%
                                          2: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14),
                                          3: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14), // Using 20%
                                          4: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20),
                                          5: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Rate',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Qty',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
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
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                products.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "No Products !",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: products.length,
                                          itemBuilder: (context, index) {
                                            Color color = index % 2 == 0
                                                ? const Color(0xFFF3F3F3)
                                                : const Color(0xFFece9fd);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Table(
                                                columnWidths: {
                                                  0: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.2), // Using 10%
                                                  1: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14), // Using 30%
                                                  2: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14),
                                                  3: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.14), // Using 20%
                                                  4: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.20),
                                                  5: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10),
                                                },
                                                children: [
                                                  // Each TableRow represents a row in the Table
                                                  TableRow(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1),
                                                      color: color,
                                                    ),
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_name'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_rate'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['quantity'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index][
                                                              'total_tax_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['total_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          subTotal = subTotal -
                                                              double.parse(
                                                                products[index][
                                                                    'total_amount'],
                                                              );
                                                          totalTaxAmount = totalTaxAmount -
                                                              double.parse(products[
                                                                          index]
                                                                      [
                                                                      'total_tax_amount']) *
                                                                  double.parse(products[
                                                                          index]
                                                                      [
                                                                      'quantity']);

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
                                                          products.removeWhere(
                                                            (item) => mapEquals(
                                                                item,
                                                                ({
                                                                  "product_name":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_name'],
                                                                  "product_id":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_id'],
                                                                  "description":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'description'],
                                                                  "product_rate":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'product_rate'],
                                                                  "quantity": products[
                                                                          index]
                                                                      [
                                                                      'quantity'],
                                                                  "tax_percent":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'tax_percent'],
                                                                  "total_tax_amount":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'total_tax_amount'],
                                                                  "total_amount":
                                                                      products[
                                                                              index]
                                                                          [
                                                                          'total_amount'],
                                                                })),
                                                          );
                                                          if (products
                                                              .isEmpty) {
                                                            discount.clear();
                                                            shippingCharge
                                                                .clear();
                                                            allTotal = 0.00;
                                                          }

                                                          setState(() {});
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons
                                                                .delete_outline,
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Sub Total :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                                                child: Text(subTotal
                                                    .toStringAsFixed(2)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Tax Amount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                                                child: Text(totalTaxAmount
                                                    .toStringAsFixed(2)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Discount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }
                                                  allTotal = subTotal +
                                                      double.parse(
                                                          shippingCharge.text ==
                                                                  ''
                                                              ? '0'
                                                              : shippingCharge
                                                                  .text) -
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
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  // border: const OutlineInputBorder(),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Shipping Charge:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }

                                                  allTotal = subTotal +
                                                      double.parse(value) -
                                                      double.parse(
                                                          discount.text == ''
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
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
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
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              allTotal.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Divider(),

                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Pay Status * :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 35,
                                            child: FormField<String>(
                                              builder: (FormFieldState<String>
                                                  state) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5))),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      isExpanded: true,
                                                      hint: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                        child: Text('Status'),
                                                      ),
                                                      value: paymentStatus,
                                                      items: detailsResponse!
                                                          .data
                                                          .paymentStatusList
                                                          .map((data) {
                                                        return DropdownMenuItem(
                                                          value: data
                                                              .paymentStatus
                                                              .toString(),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              child: Text(
                                                                data.displaySts
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          paymentStatus =
                                                              newValue;
                                                          if (paymentStatus ==
                                                              "paid") {
                                                            paidAmount.text =
                                                                allTotal
                                                                    .toString();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Paid Amount * :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 35,
                                            child: TextFormField(
                                              readOnly: paymentStatus == "paid",
                                              style:
                                                  TextStyle(color: paidColor),
                                              onChanged: (val) {
                                                if (double.parse(val) >
                                                    allTotal) {
                                                  Common.toastMessaage(
                                                      'Enter valid amount',
                                                      Colors.red);
                                                  paidColor = Colors.red;
                                                } else {
                                                  paidColor = Colors.black;
                                                }
                                                setState(() {});
                                              },
                                              controller: paidAmount,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
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
                                    Visibility(
                                      visible: paymentStatus == "paid" ||
                                          paymentStatus == "partial",
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Pay Method * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: FormField<String>(
                                                    builder:
                                                        (FormFieldState<String>
                                                            state) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            isExpanded: true,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child: Text(
                                                                  'Method'),
                                                            ),
                                                            value:
                                                                paymentMethod,
                                                            items: detailsResponse!
                                                                .data
                                                                .paymentMethods
                                                                .map((data) {
                                                              return DropdownMenuItem(
                                                                value: data.id
                                                                    .toString(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      data.name
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged:
                                                                (newValue) {
                                                              setState(() {
                                                                paymentMethod =
                                                                    newValue;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Collected By * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: FormField<String>(
                                                    builder:
                                                        (FormFieldState<String>
                                                            state) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            isExpanded: true,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child:
                                                                  Text('Staff'),
                                                            ),
                                                            value:
                                                                collectedStaff,
                                                            items:
                                                                detailsResponse!
                                                                    .data.staff
                                                                    .map(
                                                                        (data) {
                                                              return DropdownMenuItem(
                                                                value: data
                                                                    .accountId
                                                                    .toString(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      data.accountName
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged:
                                                                (newValue) {
                                                              setState(() {
                                                                collectedStaff =
                                                                    newValue;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    // paymentMethod == '2'
                                    //     ? Container(
                                    //         child: templateImage == null
                                    //             ? Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.only(
                                    //                         right: 10),
                                    //                 child: Align(
                                    //                   alignment:
                                    //                       Alignment.topRight,
                                    //                   child: InkWell(
                                    //                     onTap: _selectFile,
                                    //                     child: Container(
                                    //                         width: MediaQuery.of(
                                    //                                     context)
                                    //                                 .size
                                    //                                 .width *
                                    //                             0.4,
                                    //                         height: 35,
                                    //                         decoration: BoxDecoration(
                                    //                             color: Colors
                                    //                                 .grey
                                    //                                 .shade300,
                                    //                             borderRadius:
                                    //                                 BorderRadius
                                    //                                     .circular(
                                    //                                         5)),
                                    //                         child:
                                    //                             const Padding(
                                    //                           padding: EdgeInsets
                                    //                               .only(
                                    //                                   left: 10,
                                    //                                   right: 10,
                                    //                                   top: 5,
                                    //                                   bottom:
                                    //                                       5),
                                    //                           child: Center(
                                    //                               child: Text(
                                    //                                   'Choose File')),
                                    //                         )),
                                    //                   ),
                                    //                 ),
                                    //               )
                                    //             : Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.only(
                                    //                         right: 10),
                                    //                 child: Stack(
                                    //                   children: [
                                    //                     Align(
                                    //                       alignment: Alignment
                                    //                           .topRight,
                                    //                       child: InkWell(
                                    //                         onTap: _selectFile,
                                    //                         child: Container(
                                    //                             width: MediaQuery.of(
                                    //                                         context)
                                    //                                     .size
                                    //                                     .width *
                                    //                                 0.6,
                                    //                             height: 80,
                                    //                             decoration: BoxDecoration(
                                    //                                 color: Colors
                                    //                                     .grey
                                    //                                     .shade300,
                                    //                                 borderRadius:
                                    //                                     BorderRadius.circular(
                                    //                                         5)),
                                    //                             child: Padding(
                                    //                               padding:
                                    //                                   const EdgeInsets
                                    //                                       .only(
                                    //                                 right: 10,
                                    //                               ),
                                    //                               child: Row(
                                    //                                 children: [
                                    //                                   Container(
                                    //                                     height:
                                    //                                         80,
                                    //                                     width:
                                    //                                         90,
                                    //                                     decoration:
                                    //                                         BoxDecoration(
                                    //                                       image:
                                    //                                           DecorationImage(
                                    //                                         fit:
                                    //                                             BoxFit.fitWidth,
                                    //                                         image:
                                    //                                             FileImage(
                                    //                                           File(templateImage!),
                                    //                                         ),
                                    //                                       ),
                                    //                                     ),
                                    //                                     // Add your image widget here
                                    //                                   ),
                                    //                                   const SizedBox(
                                    //                                     width:
                                    //                                         20,
                                    //                                   ),
                                    //                                   const Center(
                                    //                                       child:
                                    //                                           Text('Change File')),
                                    //                                 ],
                                    //                               ),
                                    //                             )),
                                    //                       ),
                                    //                     ),
                                    //                     Positioned(
                                    //                       right: 0.0,
                                    //                       top: 0.0,
                                    //                       child: InkWell(
                                    //                         onTap: () {
                                    //                           templateImage =
                                    //                               null;
                                    //                           setState(() {});
                                    //                         },
                                    //                         child: const Icon(
                                    //                           Icons
                                    //                               .remove_circle,
                                    //                           color: Colors.red,
                                    //                         ),
                                    //                       ),
                                    //                     )
                                    //                   ],
                                    //                 ),
                                    //               ))
                                    //     : const SizedBox(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          if (leadStatusId == '4' && createOrder)
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Renewal'),
                                value:
                                    createRenewal, // initial value of the checkbox
                                onChanged: (bool? value) {
                                  setState(() {
                                    createRenewal = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          Visibility(
                              visible: createRenewal && createOrder,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: startDate,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? selectedValue =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      setState(() {
                                        startDate.text =
                                            DateFormat('dd-MM-yyyy')
                                                .format(selectedValue!);
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
                                      endDate.text = DateFormat('dd-MM-yyyy')
                                          .format(selectedEndDate!);
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
                                    onTap: () {
                                      dropDialog(context);
                                    },
                                    readOnly: true,
                                    controller: reminderTemplate,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        labelText: 'Remind Template ',
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
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              final connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if (connectivityResult ==
                                      ConnectivityResult.mobile ||
                                  connectivityResult ==
                                      ConnectivityResult.wifi) {
                                if (leadStatusId == '') {
                                  Common.toastMessaage(
                                      'Choose any Status', Colors.red);
                                } else if (leadStatusId == '2' &&
                                    nextFollowupDate1.text.isEmpty) {
                                  Common.toastMessaage(
                                      'Choose next followup date', Colors.red);
                                } else {
                                  if (context.mounted) {
                                    Common.showProgressDialog(
                                        context, "Loading..");
                                  }
                                  AddLeadFollowupModel object1 =
                                      await HttpService.postRenewalFollowup(
                                          token,
                                          leadStatusId,
                                          nextFollowupDate1.text,
                                          productCost.text,
                                          detailsResponse!.data.leadId,
                                          remarks.text,
                                          widget.renewalId,
                                          calledDate1.text,
                                          detailsResponse!.data.clientId,
                                          checked,
                                          timeBefore.text,
                                          callResponseId,
                                          callResultReasonId,
                                          createOrder,
                                          invoiceDate,
                                          products,
                                          reminderTemplate.text,
                                          allTotal,
                                          startDate.text,
                                          endDate.text,
                                          paymentStatus,
                                          subTotal,
                                          totalTaxAmount,
                                          discount.text,
                                          shippingCharge.text,
                                          paymentMethod,
                                          paidAmount.text,
                                          collectedStaff);
                                  if (object1.status == true) {
                                    Common.toastMessaage(
                                        object1.message, Colors.green);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    Common.toastMessaage(
                                        object1.message, Colors.red);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              } else {
                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No Network Found..Try Again Later..'),
                                      backgroundColor: Colors.redAccent,
                                      elevation: 10,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  );
                                });
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('Submit',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
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
                  Text(
                    timeOut == true
                        ? "There seems to be a temporary issue, \n Please retry to continue"
                        : 'No Network Found !',
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
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Product Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "2");
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    productName,
                                    overflow: TextOverflow.ellipsis,
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
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value == '') {
                                value = '0';
                              }
                              productTaxAmount.text = (double.parse(value) *
                                      double.parse(productTaxPercent.text) /
                                      100)
                                  .toString();
                              productTotalAmount.text = ((double.parse(value) +
                                          double.parse(productTaxAmount.text)) *
                                      double.parse(productQty.text))
                                  .toString();

                              productTotalAmount.text =
                                  double.parse(productTotalAmount.text)
                                      .toStringAsFixed(2);

                              setState(() {});
                            },
                            controller: productRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
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
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value == '') {
                                value = '0';
                              }
                              productTotalAmount
                                  .text = ((double.parse(productRate.text) +
                                          double.parse(productTaxAmount.text)) *
                                      double.parse(value))
                                  .toString();
                              productTotalAmount.text =
                                  double.parse(productTotalAmount.text)
                                      .toStringAsFixed(2);
                              setState(() {});
                            },
                            controller: productQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
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
                      height: 15,
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value == '') {
                                value = '0';
                              }
                              productTaxAmount.text =
                                  (double.parse(productRate.text) *
                                          double.parse(value) /
                                          100)
                                      .toString();
                              productTotalAmount
                                  .text = ((double.parse(productRate.text) +
                                          double.parse(productTaxAmount.text)) *
                                      double.parse(productQty.text))
                                  .toString();
                              productTotalAmount.text =
                                  double.parse(productTotalAmount.text)
                                      .toStringAsFixed(2);
                              setState(() {});
                            },
                            controller: productTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
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
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: productTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
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
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: productTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon:
                                Icon(Icons.arrow_right, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
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
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (productRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (productQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (productTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (productTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (productTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else {
                              products.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });

                              subTotal = subTotal +
                                  double.parse(productTotalAmount.text);
                              totalTaxAmount = totalTaxAmount +
                                  double.parse(productTaxAmount.text) *
                                      double.parse(productQty.text);
                              allTotal = subTotal +
                                  double.parse(shippingCharge.text == ''
                                      ? '0'
                                      : shippingCharge.text) -
                                  double.parse(discount.text == ''
                                      ? '0'
                                      : discount.text);
                              productName = "Choose Product";
                              productId = "";
                              productDescription.clear();
                              productRate.clear();
                              productQty.clear();
                              productTaxPercent.clear();
                              productTaxAmount.clear();
                              productTotalAmount.clear();
                              Navigator.of(context).pop();
                              setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25, right: 25),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
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

  Future<dynamic> productDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: search,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredItems = items
                            .where((item) => item.productName
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
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () async {
                            if (type == "2") {
                              productName = filteredItems[index].productName;
                              productId = filteredItems[index].id;
                              productQty.text = "1";
                              productRate.text =
                                  filteredItems[index].sellingPrice;
                              productTaxPercent.text =
                                  filteredItems[index].taxPercent;
                              productTaxAmount.text =
                                  filteredItems[index].taxAmount;
                              productTotalAmount
                                  .text = ((double.parse(productRate.text) +
                                          double.parse(productTaxAmount.text)) *
                                      double.parse(productQty.text))
                                  .toString();
                              productTotalAmount.text =
                                  double.parse(productTotalAmount.text)
                                      .toStringAsFixed(2);
                              setState(() {});
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              products.add({
                                "prd_id": filteredItems[index].id,
                                "total_amount":
                                    filteredItems[index].sellingPrice,
                              });
                              productNames
                                  .add(filteredItems[index].productName);
                              totalProductCost = 0;
                              for (int i = 0; i < products.length; i++) {
                                totalProductCost += double.parse(
                                    await products[i]["total_amount"]);
                              }
                              productCost.text = (totalProductCost).toString();
                              setState(() {});
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          title: Text(filteredItems[index].productName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> callResponseDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Call Response'),
            content: SizedBox(
              width: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: detailsResponse!.data.callResponse.length,
                itemBuilder: (context, ind) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        callResponse = detailsResponse!
                            .data.callResponse[ind].callResponse
                            .toString();

                        callResponseId = detailsResponse!
                            .data.callResponse[ind].callResponseId
                            .toString();
                        Navigator.pop(context, true);
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        detailsResponse!.data.callResponse[ind].callResponse
                            .toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<dynamic> reasonDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Reason'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * .32,
              width: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: detailsResponse!.data.reasonList.length,
                itemBuilder: (context, ind) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        callResultReasonName = detailsResponse!
                            .data.reasonList[ind].reason
                            .toString();
                        callResultReasonId =
                            detailsResponse!.data.reasonList[ind].id.toString();

                        Navigator.pop(context, true);
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        detailsResponse!.data.reasonList[ind].reason.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<dynamic> callResultDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Status'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * .24,
              width: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: detailsResponse!.data.callResult.length,
                itemBuilder: (context, ind) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        leadStatus = detailsResponse!
                            .data.callResult[ind].callResult
                            .toString();
                        leadStatusId = detailsResponse!
                            .data.callResult[ind].callResultId
                            .toString();
                        if (leadStatusId != '2') {
                          nextFollowupDate = '';
                          checked = false;
                        }
                        Navigator.pop(context, true);
                      });
                      products.clear();
                      productNames.clear();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        detailsResponse!.data.callResult[ind].callResult
                            .toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<dynamic> dropDialog(BuildContext context) {
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
                            filterTemplates(value);
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
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          reminderTemplate.text =
                              filteredTemplates[index].templateName;
                          templateId = filteredTemplates[index].id;
                          Navigator.pop(context);
                          filterTemplates("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            filteredTemplates[index].templateName.toString(),
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

  void filterTemplates(
    String query,
  ) {
    filteredTemplates = detailsResponse!.data.renewalTemplate
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
