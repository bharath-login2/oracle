// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/deleteMainClientModel.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/mainClientListModel.dart';
import '../../../service/service.dart';
import 'addClients.dart';
import 'editClient.dart';

class ClientList extends StatefulWidget {
  String token;

  ClientList(this.token, {Key? key}) : super(key: key);

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  MainClientListModel? mainClients;
  bool result = true;
  TextEditingController searchController = TextEditingController();

  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isSearch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

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

    mainClients = await HttpService.mainClients(
        widget.token, searchController.text, fDate, tDate);
    if (mainClients != null) {
      setState(() {
        isSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? WillPopScope(
            onWillPop: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Dashboard(widget.token)),
              );
              return true;
            },
            child: Scaffold(
                backgroundColor: Colors.grey.shade300,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.08),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0),
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
                                            Dashboard(widget.token)),
                                  );
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
                                'Customer List',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddClients(widget.token)),
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: mainClients != null && isSearch == false
                    ? SingleChildScrollView(
                        child: Container(
                          color: Colors.grey[300],
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final selctedDatetimetemp =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                1),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          fDate = DateFormat('dd-MM-yyyy')
                                              .format(selctedDatetimetemp!);
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  fDate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  color: Colors.white,
                                                ),
                                                child: const Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final toDateSelectTemp =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          tDate = DateFormat('dd-MM-yyyy')
                                              .format(toDateSelectTemp!);
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  tDate,
                                                ),
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.white,
                                                ),
                                                child: const Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: TextFormField(
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(8),
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          hintText: 'search',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                        setState(() {
                                          isSearch = true;
                                          getData();
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.31,
                                            height: 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: const Color(0xff2590cf)),
                                            child: const Center(
                                              child: Text("Submit",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                            ),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: mainClients!.data!.isNotEmpty
                                    ? ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: mainClients!.data!.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClientDetails(
                                                              widget.token,
                                                              mainClients!
                                                                  .data![index]
                                                                  .id
                                                                  .toString())),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(1, 1),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      14.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            child: Text(
                                                                mainClients!
                                                                    .data![
                                                                        index]
                                                                    .clientName
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                )),
                                                          ),
                                                          mainClients!
                                                                      .data![
                                                                          index]
                                                                      .totalDue !=
                                                                  ''
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: mainClients!.data![index].totalDue ==
                                                                              'Paid'
                                                                          ? const Color(
                                                                              0xffe6fbec)
                                                                          : const Color(
                                                                              0xfffcbcbc)),
                                                                  child: Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              12,
                                                                          right:
                                                                              12,
                                                                          top:
                                                                              6,
                                                                          bottom:
                                                                              6),
                                                                      child: Text(
                                                                          mainClients!
                                                                              .data![
                                                                                  index]
                                                                              .totalDue
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            color: mainClients!.data![index].totalDue == 'Paid'
                                                                                ? Colors.green
                                                                                : Colors.red,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox()
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          mainClients!
                                                                              .data![
                                                                                  index]
                                                                              .phoneNumber
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                          mainClients!
                                                                      .data![
                                                                          index]
                                                                      .totalInvoiceCount !=
                                                                  ''
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: const Color(
                                                                          0xff80D1FF)),
                                                                  child: Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              12,
                                                                          right:
                                                                              12,
                                                                          top:
                                                                              6,
                                                                          bottom:
                                                                              6),
                                                                      child: Text(
                                                                          mainClients!
                                                                              .data![
                                                                                  index]
                                                                              .totalInvoiceCount
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox()
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          mainClients!
                                                                              .data![
                                                                                  index]
                                                                              .location
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .person,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.38,
                                                                        child: Text(
                                                                            'Created by:${mainClients!.data![index].createdBy}',
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .calendar_month,
                                                                        color: Colors
                                                                            .grey,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          mainClients!
                                                                              .data![
                                                                                  index]
                                                                              .createdAt
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => AddInvoice(
                                                                            widget.token,
                                                                            mainClients!.data![index].id.toString())),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xffceffe1)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .currency_rupee,
                                                                        color: Colors
                                                                            .green),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => EditClients(
                                                                            widget.token,
                                                                            mainClients!.data![index].id.toString())),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xffaedcf4)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .mode_edit_outlined,
                                                                        color: Colors
                                                                            .blue),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
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
                                                                          scrollable:
                                                                              true,
                                                                          title:
                                                                              const Text('Please Confirm'),
                                                                          content:
                                                                              const Text('Are you sure to Delete?'),
                                                                          actions: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: const Text('No')),
                                                                            TextButton(
                                                                                onPressed: () async {
                                                                                  Common.showProgressDialog(context, "Loading..");
                                                                                  DeleteMainClientModel deleteClients = await HttpService.deleteMainClients(widget.token, mainClients!.data![index].id.toString());
                                                                                  if (deleteClients.data == true) {
                                                                                    Common.toastMessaage(deleteClients.message, Colors.green);
                                                                                    if (context.mounted) {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) => ClientList(widget.token)),
                                                                                      );
                                                                                    }
                                                                                  } else {
                                                                                    Common.toastMessaage(deleteClients.message, Colors.red);
                                                                                    if (context.mounted) {
                                                                                      Navigator.of(context).pop();
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: const Text('Yes')),
                                                                          ],
                                                                        );
                                                                      });
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2),
                                                                      color: const Color(
                                                                          0xfffcbcbc)),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .delete_outline,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 180,
                                              height: 180,
                                              child: Image.asset(
                                                "assets/icons/nodatafound.png",
                                              ),
                                            ),
                                            const Text(
                                              'No Data Found',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Lottie.asset('assets/main/loading.json',
                            fit: BoxFit.fill),
                      )),
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
}
