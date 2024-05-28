import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/payment_report.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/clients/addReceipt.dart';
import 'package:login2/screens/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/renewal_mannagement/renewal_list.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PaymentReport extends StatefulWidget {
  const PaymentReport({super.key});

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends State<PaymentReport> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int page = 1;
  int pageSize = 20;
  List items = [];
  bool isLoading = true;
  String daysToExpire = "";
  String fromDate = "";
  String toDate = "";
  String clientId = "";
  bool search = false;
  PaymentReportModel? listResponse;
  List filteredNames = [];
  RenewalDetailslModel? detailsResponse;
  TextEditingController customer = TextEditingController();

  void filterCustomers(
    String query,
  ) {
    filteredNames = detailsResponse!.data.customers
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getDetails() async {
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      filteredNames = detailsResponse!.data.customers;
    }
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index ==
            items.length - 1) {
      getList();
    }
  }

  getList() async {
    listResponse = await HttpService.paymentReport(
      page,
      pageSize,
      clientId,
      fromDate,
      toDate,
      daysToExpire,
    );
    if (listResponse != null) {
      items.addAll(listResponse!.data.lists);
      page++;
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
    super.initState();
    getList();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RenewalDashboard(),
            ));
      }),
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RenewalDashboard(),
                                ));
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
                          "Payment Report",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        filtration(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: const Color(0xFFd5f5f4),
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: Image.asset("assets/icons/filter.png",
                                width: 20)),
                      ),
                    )
                  ]),
            ),
          ),
        ),
        body: isLoading == true
            ? buildLoaderListItem()
            : items.isEmpty
                ? Center(
                    child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Image.asset("assets/icons/missed_leads.png")),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Color(0xFF2a86c9),
                            Color(0xFF406dbe)
                          ])),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Amount : ${listResponse!.data.totalAmount}/-",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Total Paid : ${listResponse!.data.totalPaid}/-",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Balance Amount : ${listResponse!.data.balanceAmount}/-",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ScrollablePositionedList.builder(
                              shrinkWrap: true,
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              itemCount: items.length +
                                  (items.length + 20 == page * pageSize
                                      ? 1
                                      : 0),
                              initialScrollIndex: 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, top: 8.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .55,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.receipt,
                                                          size: 18,
                                                        ),
                                                        Text(
                                                          " ${items[index].invoiceNumber}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.person,
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          child: Text(
                                                            " ${items[index].customerName}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.calendar_month,
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          child: Text(
                                                            " ${items[index].startDate} To ${items[index].endDate}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Icons.shopping_cart,
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          child: Text(
                                                            " ${items[index].products}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.currency_rupee,
                                                          size: 20,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .45,
                                                          child: Text(
                                                            " ${items[index].totalInvoiceAmount} /-",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    color:
                                                        items[index].isPaid ==
                                                                false
                                                            ? Colors.red
                                                            : Colors.teal,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0),
                                                      child: Text(
                                                        items[index].isPaid ==
                                                                true
                                                            ? "Paid"
                                                            : "Un Paid",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        items[index].isPaid ==
                                                            true,
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              Color(0xFF2a86c9),
                                                              Color(0xFF406dbe)
                                                            ]),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    8.0),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .28,
                                                          child: Center(
                                                            child: Text(
                                                              items[index]
                                                                  .paymentMode,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  String token = await Common
                                                      .getSharedPref("token");
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReceiptAdd(
                                                                token,
                                                                items[index]
                                                                    .customerId,
                                                                items[index]
                                                                    .invoiceId),
                                                      ));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      color: Colors.teal),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                        Icons.receipt_long,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<dynamic> filtration(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Material(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Filtration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          //<-- SEE HERE
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'From Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: fromDate.toString(),
                                      type: DateTimePickerType.date,

                                      //controller: fromDate,
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
                                            String formattedDate =
                                                DateFormat('dd-MM-yyyy').format(
                                                    DateTime.parse(value));
                                            fromDate = formattedDate;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          //<-- SEE HERE
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'From Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: toDate.toString(),
                                      type: DateTimePickerType.date,

                                      //controller: fromDate,
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
                                            String formattedDate =
                                                DateFormat('dd-MM-yyyy').format(
                                                    DateTime.parse(value));
                                            toDate = formattedDate;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: customer,
                          readOnly: true,
                          onTap: (() {
                            dropDialog(context, "Customers");
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Customer',
                            prefixIcon: Icon(Icons.person, color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () {
                              items.clear();
                              page = 1;
                              getList();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Continue",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
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
                    search == true
                        ? SizedBox(
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
                                  filterCustomers(value);
                                });
                              }),
                            ),
                          )
                        : Text(
                            title,
                            style: const TextStyle(fontSize: 16),
                          ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            search = !search;
                          });
                        },
                        child: const Icon(Icons.search))
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (() {
                          clientId = filteredNames[index].id;
                          customer.text = filteredNames[index].name;

                          Navigator.pop(context);
                          setState(() {});
                          filterCustomers("");
                        }),
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            filteredNames[index].name.toString(),
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
