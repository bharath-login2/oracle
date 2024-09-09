// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:login2/service/service.dart';

import '../../models/lead_management/cloudCallModel.dart';

class Search extends StatefulWidget {
  String token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  Search({
    super.key,
    required this.cloudCall,
    required this.editLead,
    required this.deleteLead,
    required this.token,
  });

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  SearchDataModel? response;
  bool result = true;
  bool isLoading = false;
  bool custSwitch = true;
  bool leadSwitch = true;
  final List<Color> _colors = [
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
  ];
  getData() async {
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
    // getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    response = await HttpService.getSearchData(searchController.text);
    if (response != null && response!.status == true) {
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
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
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
                            'Search',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextFormField(
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            controller: searchController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(8),
                              hintStyle: const TextStyle(color: Colors.grey),
                              hintText: 'Search',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide
                                    .none, // Set the border color to none
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              getList();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.31,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xff2590cf)),
                            child: const Center(
                              child: Text("Search",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  isLoading == true
                      ? LinearProgressIndicator(
                          color: Colors.blue.shade600,
                        )
                      : response == null
                          ? noResultWidget()
                          : response!.data.customers.isEmpty &&
                                  response!.data.leadData.isEmpty
                              ? noResultWidget()
                              : Column(
                                  children: [
                                    if (response!.data.customers.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              custSwitch = !custSwitch;
                                            });
                                          },
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.white,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Customers",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(Icons
                                                        .arrow_drop_down_circle_outlined)
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                    Visibility(
                                      visible: custSwitch,
                                      child: ListView.builder(
                                        itemCount:
                                            response!.data.customers.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0, vertical: 0),
                                            child: Card(
                                              color: Colors.white,
                                              child: ListTile(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ClientDetails(
                                                                widget.token,
                                                                response!
                                                                    .data
                                                                    .customers[
                                                                        index]
                                                                    .id),
                                                      ));
                                                },
                                                leading: const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.teal,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    )),
                                                title: Text(response!.data
                                                    .customers[index].name),
                                                subtitle: Text(response!
                                                    .data
                                                    .customers[index]
                                                    .contactNo),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (response!.data.leadData.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              leadSwitch = !leadSwitch;
                                            });
                                          },
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.white,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Leads",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(Icons
                                                        .arrow_drop_down_circle_outlined)
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                    Visibility(
                                      visible: leadSwitch,
                                      child: ListView.builder(
                                        itemCount:
                                            response!.data.leadData.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return leadListWidget(context, index);
                                        },
                                      ),
                                    ),
                                  ],
                                )
                ],
              ),
            ),
          )
        : noInternetWidget(context);
  }

  Center noResultWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              "assets/icons/nodatafound.png",
            ),
          ),
          const Text(
            'No Result Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Scaffold noInternetWidget(BuildContext context) {
    return Scaffold(
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
              const Text(
                'No Network Found !',
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

  Padding leadListWidget(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeadDetails(
                      widget.token,
                      widget.editLead,
                      widget.deleteLead,
                      widget.cloudCall,
                      response!.data.leadData[index].callMasterId,
                      pageName: "",
                    )),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            color: response!.data.leadData[index].isSelected == false
                ? Colors.white
                : Colors.blue.shade100,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .88,
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                if (response!.data.leadData[index].priority ==
                                    '1')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (response!.data.leadData[index].priority ==
                                    '2')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (response!.data.leadData[index].priority ==
                                    '3')
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .46,
                                  child: Text(
                                    response!.data.leadData[index].clientName
                                        .toString(),
                                    // response!.data.leadData.length.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: response!
                                                .data.leadData[index].isCustomer
                                            ? Colors.green
                                            : Colors.black,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.pink.shade100,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 2, bottom: 2),
                                      child: Text(
                                        response!
                                            .data.leadData[index].leadCategory
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: response!.data.leadData[index]
                                              .categoryCount
                                              .toString() !=
                                          "1" &&
                                      response!.data.leadData[index]
                                              .categoryCount
                                              .toString() !=
                                          "",
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        response!
                                            .data.leadData[index].categoryCount
                                            .toString(),
                                        // response!.data.leadData.length.toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.68,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      response!
                                          .data.leadData[index].contactNumber1
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            'Assigned to : ${response!.data.leadData[index].staffName}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: _colors[response!
                                                  .data
                                                  .leadData[index]
                                                  .callResultId],
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                top: 2,
                                                bottom: 2),
                                            child: Text(
                                              response!.data.leadData[index]
                                                  .callResult
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    response!.data.leadData[index]
                                                .callResultId ==
                                            1
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFd5f5f4),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 5,
                                                  bottom: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      "assets/icons/calendar.png",
                                                      width: 20),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Created Time',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        response!
                                                            .data
                                                            .leadData[index]
                                                            .createdDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFd5f5f4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/icons/calendar.png",
                                                          width: 20),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            'Called Date',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            response!
                                                                        .data
                                                                        .leadData[
                                                                            index]
                                                                        .isCalled ==
                                                                    false
                                                                ? '--'
                                                                : response!
                                                                    .data
                                                                    .leadData[
                                                                        index]
                                                                    .calledDate
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFd5f5f4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/icons/calendar.png",
                                                          width: 20),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            'Followup Date',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            response!
                                                                .data
                                                                .leadData[index]
                                                                .scheduledDate
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 60,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 20,
                                  minWidth: 20,
                                  maxHeight: 50,
                                  maxWidth: 50,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 0),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(response!
                                          .data.leadData[index].profilePic
                                          .toString())),
                                  // image: AssetImage(
                                  //     'assets/images/img.jpeg')),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () async {
                                if (response!.data.callPermission == false) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Alert !!!'),
                                          content: Text(response!
                                              .data.warningMessage
                                              .toString()),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Close')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LeadDetails(
                                                              widget.token,
                                                              widget.editLead,
                                                              widget.deleteLead,
                                                              widget.cloudCall,
                                                              response!
                                                                  .data
                                                                  .leadData[
                                                                      index]
                                                                  .callMasterId,
                                                              pageName: "",
                                                            )),
                                                  );
                                                },
                                                child: const Text('followup')),
                                          ],
                                        );
                                      });
                                } else {
                                  if (widget.cloudCall == true) {
                                    chooseCallDialog(context, index);
                                  } else {
                                    // String
                                    // url =
                                    //     'tel:+${response!.data.leadData[index].contactNumber1}';
                                    // await launchUrl(
                                    //     Uri.parse(url));
                                    Common.directCall(
                                        '+${response!.data.leadData[index].contactNumber1}');
                                  }
                                }
                              },
                              child: Container(
                                width: 65,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Call',
                                          style: TextStyle(
                                              fontFamily: "MontserratMedium",
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Choose Call Type'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    Common.showProgressDialog(context, "Loading..");
                    CloudCallModel object1 = await HttpService.addCloudCall(
                        widget.token,
                        response!.data.leadData[index].callMasterId.toString(),
                        response!.data.leadData[index].contactNumber1);
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, Colors.green);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      Common.toastMessaage(object1.message, Colors.red);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(
                            Icons.cloud_circle_rounded,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Cloud Call',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    Common.directCall(
                        '+${response!.data.leadData[index].contactNumber1}');
                  },
                  child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5)),
                            child: const Icon(
                              Icons.call,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text(
                            'Phone Call',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }
}
