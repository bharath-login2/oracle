import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:login2/screens/leadManagement/add_followup.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/deleteLeadModel.dart';
import '../../models/lead_management/searchModel.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/leadManagement/leadDetails.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String searchKeyData;
  SearchPage(this.token, this.editLead, this.deleteLead, this.cloudCall,
      this.searchKeyData,
      {super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel? search;
  bool? result = true;
  bool? result1 = true;
  TextEditingController searchkey = TextEditingController();
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
  bool isSearch = true;
  bool resultFoundSts = false;

  @override
  void initState() {
    searchkey.text = widget.searchKeyData;
    // TODO: implement initState
    super.initState();
    getData(resultFoundSts);
  }

  getData(resultFoundSts1) async {
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
    search = await HttpService.searchLead(widget.token, searchkey.text);
    if (search != null) {
      setState(() {
        isSearch = false;
        resultFoundSts = resultFoundSts1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getData(true);
        return;
      },
      child: result == true
          ? Scaffold(
              backgroundColor: Colors.grey.shade200,
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: search != null && isSearch == false
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 10,
                                ),
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 40,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white),
                                child: TextField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: searchkey,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Search',
                                        filled: true,
                                        border: InputBorder.none,
                                        prefixIcon: const Icon(Icons.search,
                                            color: Colors.black),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            searchkey.clear();
                                          },
                                        ))),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isSearch = true;
                                    getData(true);
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text('Search',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('Total Leads : ${search!.data.totalLeads}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          search!.data.details.isNotEmpty
                              ? ListView.builder(
                                  itemCount: search!.data.details.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Dismissible(
                                      key: const Key('0'),
                                      background: Container(
                                        color: Colors.green,
                                        child: const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Icon(
                                                Icons.call,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                " Call",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      secondaryBackground: Container(
                                        color: Colors.blue,
                                        child: const Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                " Add Followup",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.endToStart) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddFollowup(
                                                      widget.token,
                                                      widget.editLead,
                                                      widget.deleteLead,
                                                      widget.cloudCall,
                                                      search!.data.details[i]
                                                          .callMasterId,
                                                      leadType: search!
                                                          .data
                                                          .details[i]
                                                          .leadCategory,
                                                      leadTypeId: search!
                                                          .data
                                                          .details[i]
                                                          .leadCategoryId,
                                                      leadSubType: search!
                                                          .data
                                                          .details[i]
                                                          .leadSubCategory,
                                                      leadSubTypeId: search!
                                                          .data
                                                          .details[i]
                                                          .leadSubCategoryId,
                                                      priorityId: search!.data
                                                          .details[i].priority,
                                                      priority: search!
                                                          .data
                                                          .details[i]
                                                          .priorityName,
                                                      cost: search!
                                                          .data.details[i].cost,
                                                      address: search!.data
                                                          .details[i].address,
                                                    )),
                                          ).then((value) {
                                            getData(resultFoundSts);
                                          });
                                          // final bool res = await showDialog(
                                          //     context: context,
                                          //     builder: (BuildContext context) {
                                          //       return AlertDialog(
                                          //         title: const Text(
                                          //             'Please Confirm'),
                                          //         content: const Text(
                                          //             'Are you sure to Delete?'),
                                          //         actions: [
                                          //           // The "Yes" button
                                          //           TextButton(
                                          //               onPressed: () async {
                                          //                 DeleteLeadModel
                                          //                     delete =
                                          //                     await HttpService.deleteLead(
                                          //                         widget.token,
                                          //                         search!
                                          //                             .data!
                                          //                             .details![
                                          //                                 i]
                                          //                             .callMasterId);
                                          //                 if (delete.data ==
                                          //                     true) {
                                          //                   Common.toastMessaage(
                                          //                       delete.message,
                                          //                       Colors.green);
                                          //                   if (context
                                          //                       .mounted) {
                                          //                     Navigator.push(
                                          //                       context,
                                          //                       MaterialPageRoute(
                                          //                           builder: (context) => SearchPage(
                                          //                               widget
                                          //                                   .token!,
                                          //                               widget
                                          //                                   .editLead,
                                          //                               widget
                                          //                                   .deleteLead,
                                          //                               widget
                                          //                                   .cloudCall,
                                          //                               searchkey
                                          //                                   .text)),
                                          //                     );
                                          //                   }
                                          //                 } else {
                                          //                   Common.toastMessaage(
                                          //                       delete.message,
                                          //                       Colors.red);
                                          //                   if (context
                                          //                       .mounted) {
                                          //                     Navigator.of(
                                          //                             context)
                                          //                         .pop();
                                          //                   }
                                          //                 }
                                          //               },
                                          //               child:
                                          //                   const Text('Yes')),
                                          //           TextButton(
                                          //               onPressed: () {
                                          //                 Navigator.of(context)
                                          //                     .pop();
                                          //               },
                                          //               child: const Text('No'))
                                          //         ],
                                          //       );
                                          //     });
                                          // return res;
                                        } else {
                                          if (search!.data.callPermission ==
                                              false) {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext ctx) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Alert !!!'),
                                                    content: Text(search!
                                                        .data.warningMessage
                                                        .toString()),
                                                    actions: [
                                                      // The "Yes" button
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Close')),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          LeadDetails(
                                                                            widget.token!,
                                                                            widget.editLead,
                                                                            widget.deleteLead,
                                                                            widget.cloudCall,
                                                                            search!.data.callLeadId.toString(),
                                                                            pageName:
                                                                                'search',
                                                                            searchKey:
                                                                                searchkey.text,
                                                                          )),
                                                            ).then(getData(
                                                                resultFoundSts));
                                                          },
                                                          child: const Text(
                                                              'followup')),
                                                    ],
                                                  );
                                                });
                                          } else {
                                            if (widget.cloudCall == true) {
                                              chooseCallDialog(context, i);
                                            } else {
                                              String url =
                                                  'tel:${search!.data.details[i].contactNumber1}';
                                              await launch(url);
                                            }
                                          }
                                        }
                                        return null;
                                      },
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LeadDetails(
                                                        widget.token!,
                                                        widget.editLead,
                                                        widget.deleteLead,
                                                        widget.cloudCall,
                                                        search!.data.details[i]
                                                            .callMasterId
                                                            .toString(),
                                                        pageName: 'search',
                                                        searchKey:
                                                            searchkey.text,
                                                      )),
                                            ).then((res) {
                                              getData(resultFoundSts);
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10, top: 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(2.0, 2.0),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .88,
                                                      child: Stack(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              if (search!
                                                                      .data
                                                                      .details[
                                                                          i]
                                                                      .priority ==
                                                                  '1')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (search!
                                                                      .data
                                                                      .details[
                                                                          i]
                                                                      .priority ==
                                                                  '2')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (search!
                                                                      .data
                                                                      .details[
                                                                          i]
                                                                      .priority ==
                                                                  '3')
                                                                Container(
                                                                  width: 10.0,
                                                                  height: 10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .46,
                                                                child: Text(
                                                                  search!
                                                                      .data
                                                                      .details[
                                                                          i]
                                                                      .clientName
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .pink
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: 5,
                                                                        right:
                                                                            5,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                    child: Text(
                                                                      search!
                                                                          .data
                                                                          .details[
                                                                              i]
                                                                          .leadCategory
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Visibility(
                                                                visible: search!
                                                                            .data
                                                                            .details[
                                                                                i]
                                                                            .categoryCount !=
                                                                        "1" &&
                                                                    search!
                                                                            .data
                                                                            .details[i]
                                                                            .categoryCount
                                                                            .toString() !=
                                                                        "",
                                                                child:
                                                                    Container(
                                                                  height: 20,
                                                                  width: 20,
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                  child: Center(
                                                                    child: Text(
                                                                      search!
                                                                          .data
                                                                          .details[
                                                                              i]
                                                                          .categoryCount
                                                                          .toString(),
                                                                      // items.length.toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.68,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    search!
                                                                        .data
                                                                        .details[
                                                                            i]
                                                                        .contactNumber1
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Text(
                                                                          'Assigned to : ${search!.data.details[i].staffName}',
                                                                          style: const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.black54,
                                                                              fontWeight: FontWeight.w500),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                _colors[search!.data.details[i].callResultId],
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 2,
                                                                              bottom: 2),
                                                                          child:
                                                                              Text(
                                                                            search!.data.details[i].callResult.toString(),
                                                                            style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                const Color(0xFFd5f5f4),
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 5,
                                                                              bottom: 5),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Image.asset("assets/icons/calendar.png", width: 20),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Column(
                                                                                children: [
                                                                                  const Text(
                                                                                    'Called Date',
                                                                                    style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 3,
                                                                                  ),
                                                                                  Text(
                                                                                    search!.data.details[i].isCalled == false ? '--' : search!.data.details[i].calledDate.toString(),
                                                                                    style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
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
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 5,
                                                                              bottom: 5),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Image.asset("assets/icons/calendar.png", width: 20),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Column(
                                                                                children: [
                                                                                  const Text(
                                                                                    'Followup Date',
                                                                                    style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 3,
                                                                                  ),
                                                                                  Text(
                                                                                    search!.data.details[i].scheduledDate.toString(),
                                                                                    style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
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
                                                            constraints:
                                                                const BoxConstraints(
                                                              maxHeight: 60,
                                                            ),
                                                            child: Container(
                                                              constraints:
                                                                  const BoxConstraints(
                                                                minHeight: 20,
                                                                minWidth: 20,
                                                                maxHeight: 50,
                                                                maxWidth: 50,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 0),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey,
                                                                      blurRadius:
                                                                          5,
                                                                      offset:
                                                                          Offset(
                                                                              1,
                                                                              1)),
                                                                ],
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: NetworkImage(search!
                                                                        .data
                                                                        .details[
                                                                            i]
                                                                        .profilePic
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
                                                              if (search!.data
                                                                      .callPermission ==
                                                                  false) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            ctx) {
                                                                      return AlertDialog(
                                                                        title: const Text(
                                                                            'Alert !!!'),
                                                                        content: Text(search!
                                                                            .data
                                                                            .warningMessage
                                                                            .toString()),
                                                                        actions: [
                                                                          // The "Yes" button
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
                                                                                      builder: (context) => LeadDetails(
                                                                                            widget.token!,
                                                                                            widget.editLead,
                                                                                            widget.deleteLead,
                                                                                            widget.cloudCall,
                                                                                            search!.data.callLeadId.toString(),
                                                                                            pageName: 'search',
                                                                                            searchKey: searchkey.text,
                                                                                          )),
                                                                                ).then(getData(resultFoundSts));
                                                                              },
                                                                              child: const Text('followup')),
                                                                        ],
                                                                      );
                                                                    });
                                                              } else {
                                                                if (widget
                                                                        .cloudCall ==
                                                                    true) {
                                                                  chooseCallDialog(
                                                                      context,
                                                                      i);
                                                                } else {
                                                                  String url =
                                                                      'tel:${search!.data.details[i].contactNumber1}';
                                                                  await launch(
                                                                      url);
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 65,
                                                              height: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child:
                                                                  const Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .call,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 15,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text('Call',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                "MontserratMedium",
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white,
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
                                          )),
                                    );
                                  },
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: Image.asset(
                                          "assets/icons/nodatafound.png",
                                        ),
                                      ),
                                      searchkey.text != '' &&
                                              resultFoundSts == true
                                          ? const Text(
                                              'No Result Found',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      searchkey.text != '' &&
                                              resultFoundSts == true
                                          ? const Text(
                                              'Whoops... this information is \n not available for a moment',
                                              style: TextStyle(fontSize: 15),
                                            )
                                          : const SizedBox(),
                                      searchkey.text != '' &&
                                              resultFoundSts == true
                                          ? const SizedBox(
                                              height: 25,
                                            )
                                          : const SizedBox(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Dashboard(widget.token)),
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text('Go Back',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ],
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
                    const Text(
                      'No Network Found !',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        getData(false);
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
              )),
    );
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int i) {
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
                        search!.data.details[i].callMasterId.toString(),
                        search!.data.details[i].contactNumber1);
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, Colors.green);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      Common.toastMessaage(object1.message, Colors.red);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
                    // String url = 'tel:+${search!.data!.details![i]
                    //     .contactNumber1}';
                    // await launch(url);
                    bool? res = await FlutterPhoneDirectCaller.callNumber(
                        '+${search!.data.details[i].contactNumber1}');
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
