// ignore_for_file: must_be_immutable

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/delete_renewal.dart';
import 'package:login2/models/renewal/hidden_list.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/models/renewal/rivert_client.dart';
import 'package:login2/screens/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

class HiddenCilientsScreen extends StatefulWidget {
  const HiddenCilientsScreen({super.key});

  @override
  State<HiddenCilientsScreen> createState() => _HiddenCilientsScreenState();
}

class _HiddenCilientsScreenState extends State<HiddenCilientsScreen> {
  final typesKey = GlobalKey<FormState>();
  TextEditingController type = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController noOfDays = TextEditingController();
  TextEditingController remindMe = TextEditingController();
  TextEditingController customer = TextEditingController();
  HiddenListModel? listResponse;
  RivertModel? rivertResponse;
  DeleteRenewalModel? deleteResponse;
  String clientId = "";
  bool isLoading = true;
  int page = 1;
  int pageSize = 20;
  String daysToExpire = "";
  List filteredNames = [];
  bool search = false;
  RenewalDetailslModel? detailsResponse;
  List items = [];
  String fromDate = "";
  String toDate = "";
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void filterCustomers(
    String query,
  ) {
    filteredNames = detailsResponse!.data.customer
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getDetails() async {
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      filteredNames = detailsResponse!.data.customer;
    }
  }

  rivert(id) async {
    rivertResponse = await HttpService.rivertRenewal(id);
    if (rivertResponse != null && rivertResponse!.status == true) {
      Common.toastMessaage(rivertResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(rivertResponse!.message, Colors.red);
    }
  }

  deleteClient(id) async {
    deleteResponse = await HttpService.deleteRenewalClient(id);
    if (deleteResponse != null && deleteResponse!.status == true) {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    } else {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
    }
  }

  getList() async {
    listResponse = await HttpService.hiddenList(
      page,
      pageSize,
      clientId,
      fromDate,
      toDate,
      daysToExpire,
    );
    if (listResponse != null) {
      items.addAll(listResponse!.data.lists as Iterable);
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
    setState(() {
      isLoading = true;
    });
    getList();
    getDetails();

    super.initState();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index ==
            items.length - 1) {
      getList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RenewalDashboard(),
            ));
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
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
                          "Hidden List",
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
        body: RefreshIndicator(
          onRefresh: (() async {
            getList();
          }),
          child: isLoading == true
              ? buildLoaderListItem()
              : items.isEmpty
                  ? Center(
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset("assets/icons/missed_leads.png")),
                    )
                  : SafeArea(
                      child: listResponse == null
                          ? const Center(
                              child: Text("SomeThing Went Wrong!!!"),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                  if (index == items.length) {
                                    return buildLoaderListItem();
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, top: 8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
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
                                                                .6,
                                                            child: Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              " ${items[index].clientName}",
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
                                                            Icons.phone,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .6,
                                                            child: Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              " ${items[index].contactNo}",
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
                                                            Icons
                                                                .calendar_month,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .6,
                                                            child: Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              " ${items[index].startDate} To ${items[index].endDate}",
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
                                                            Icons
                                                                .shopping_basket,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .6,
                                                            child: Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                                            Icons
                                                                .currency_rupee,
                                                            size: 18,
                                                            color: Colors.black,
                                                          ),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            " ${items[index].cost}/-",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        color: items[index]
                                                                    .isExpired ==
                                                                true
                                                            ? Colors.red
                                                            : Colors.teal,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4.0,
                                                                  horizontal:
                                                                      8.0),
                                                          child: Text(
                                                            items[index].isExpired ==
                                                                    true
                                                                ? "Expired"
                                                                : "Not Expired",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Visibility(
                                                        visible: items[index]
                                                                .isExpired ==
                                                            false,
                                                        child: Container(
                                                          color: Colors.yellow,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4.0,
                                                                    horizontal:
                                                                        8.0),
                                                            child: Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              "${items[index].remainingDays} days",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
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
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              scrollable: true,
                                                              title: const Text(
                                                                  'Rivert'),
                                                              content: const Text(
                                                                  'Are you sure?'),
                                                              actions: [
                                                                // The "Yes" button
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      await rivert(
                                                                          items[index]
                                                                              .id);
                                                                      page = 1;
                                                                      items
                                                                          .clear();
                                                                      getList();
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
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                          color: Colors.grey),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                            Icons.visibility,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              scrollable: true,
                                                              title: const Text(
                                                                  'Delete'),
                                                              content: const Text(
                                                                  'Are you sure?'),
                                                              actions: [
                                                                // The "Yes" button
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      await deleteClient(
                                                                          items[index]
                                                                              .id);
                                                                      page = 1;
                                                                      items
                                                                          .clear();
                                                                      getList();
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
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                          color: Colors.red),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                            Icons.delete,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )),
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

  Widget buildLoaderListItem() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: double.infinity,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: 100.0,
                            height: 10.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: double.infinity,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: 100.0,
                            height: 10.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: double.infinity,
                            height: 10.0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                          ),
                          Container(
                            width: 100.0,
                            height: 10.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
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
