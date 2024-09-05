// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/renewal_dashboard_model.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/hidden_clients.dart';
import 'package:login2/screens/accounts/renewal_mannagement/payment_reports.dart';
import 'package:login2/screens/accounts/renewal_mannagement/quck_renewal.dart';
import 'package:login2/widgets/renewal_grid_widget.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RenewalDashboard extends StatefulWidget {
  const RenewalDashboard({super.key});

  @override
  State<RenewalDashboard> createState() => _RenewalDashboardState();
}

class _RenewalDashboardState extends State<RenewalDashboard> {
  RenewalDashboardModel? dashboard;
  bool isLoading = true;
  String token = "";
  List items = [];
  int page = 1;
  int pageSize = 20;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  getDashboard() async {
    setState(() {
      isLoading = true;
    });
    dashboard = await HttpService.renewalDashboard();
    if (dashboard != null && dashboard!.status == true) {
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
    getDashboard();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    super.initState();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index ==
            items.length - 1) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        token = await Common.getSharedPref('token');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(token),
            ));
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              // color: Color(0xFF2a86c9),
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
                          onTap: () async {
                            token = await Common.getSharedPref('token');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Dashboard(token),
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
                          "Renewal Management",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      iconColor: Colors.white,
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == "1") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HiddenCilientsScreen(),
                              ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentReport(),
                              ));
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: '1',
                            child: Text('Hidden Clients'),
                          ),
                          const PopupMenuItem<String>(
                            value: '2',
                            child: Text('Payment Report'),
                          ),
                        ];
                      },
                    ),
                  ]),
            ),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading == true
                ? ShimmerGridView(
                    type: "s",
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GridView(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 1.2,
                        ),
                        shrinkWrap: true,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RenewalList(
                                      title: "Current Month",
                                      searchKey: "current_month",
                                      searchMonth: "",
                                      renewed: int.parse(dashboard!
                                          .data.currentMonthData.paidCount),
                                    ),
                                  ));
                            },
                            child: RenewalGridItem(
                              title: "Current Month",
                              paidAmount: dashboard!
                                  .data.currentMonthData.paidAmount
                                  .toString(),
                              paidCount: dashboard!
                                  .data.currentMonthData.paidCount
                                  .toString(),
                              totalAmount: dashboard!
                                  .data.currentMonthData.totalAmount
                                  .toString(),
                              totalCount: dashboard!
                                  .data.currentMonthData.totalCount
                                  .toString(),
                              color: const Color(0xFF2a86c9),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RenewalList(
                                      title: "Next Month",
                                      searchKey: "next_month",
                                      searchMonth: "",
                                      renewed: int.parse(dashboard!
                                          .data.nextMonthData.paidCount),
                                    ),
                                  ));
                            },
                            child: RenewalGridItem(
                              title: "Next Month",
                              paidAmount: dashboard!
                                  .data.nextMonthData.paidAmount
                                  .toString(),
                              paidCount: dashboard!.data.nextMonthData.paidCount
                                  .toString(),
                              totalAmount: dashboard!
                                  .data.nextMonthData.totalAmount
                                  .toString(),
                              totalCount: dashboard!
                                  .data.nextMonthData.totalCount
                                  .toString(),
                              color: const Color(0xFF2a86c9),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RenewalList(
                                      title: "Current Year",
                                      searchKey: "current_year",
                                      searchMonth: "",
                                      renewed: int.parse(
                                          dashboard!.data.allData.paidCount),
                                    ),
                                  ));
                            },
                            child: RenewalGridItem(
                              title: "Current Year",
                              paidAmount:
                                  dashboard!.data.allData.paidAmount.toString(),
                              paidCount:
                                  dashboard!.data.allData.paidCount.toString(),
                              totalAmount: dashboard!.data.allData.totalAmount
                                  .toString(),
                              totalCount:
                                  dashboard!.data.allData.totalCount.toString(),
                              color: const Color(0xFF2a86c9),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RenewalList(
                                      title: "Expired",
                                      searchMonth: "",
                                      searchKey: "expired",
                                      renewed: int.parse(dashboard!
                                          .data.expiredData.paidCount),
                                    ),
                                  ));
                            },
                            child: RenewalGridItem(
                                title: "Expired",
                                paidAmount: dashboard!
                                    .data.expiredData.paidAmount
                                    .toString(),
                                paidCount: dashboard!.data.expiredData.paidCount
                                    .toString(),
                                totalAmount: dashboard!
                                    .data.expiredData.totalAmount
                                    .toString(),
                                totalCount: dashboard!
                                    .data.expiredData.totalCount
                                    .toString(),
                                color: Colors.red.shade200),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                color: Colors.grey.shade600,
                                offset: const Offset(0, 2.0),
                              )
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade500,
                                  ]),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  )),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Renewal Reports",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0, top: 16.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .9,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: dashboard!.data.monthReport.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RenewalList(
                                                title: dashboard!.data
                                                    .monthReport[index].label,
                                                searchKey: "",
                                                searchMonth: dashboard!
                                                    .data
                                                    .monthReport[index]
                                                    .searchMonth
                                                    .toString(),
                                                renewed: 0,
                                              ),
                                            ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10.0,
                                            left: 20.0,
                                            right: 20.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(dashboard!.data
                                                    .monthReport[index].label),
                                                Text(
                                                  " ${dashboard!.data.monthReport[index].amount.toString()}",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            LinearProgressIndicator(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              backgroundColor: Colors.grey,
                                              value: dashboard!
                                                      .data
                                                      .monthReport[index]
                                                      .percentage /
                                                  100,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue.shade400),
                                              minHeight: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
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
                      // const Text("Expired and Expiring in 30 Days")
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8),
                      //   child: ScrollablePositionedList.builder(
                      //     shrinkWrap: true,
                      //     itemScrollController: itemScrollController,
                      //     itemPositionsListener: itemPositionsListener,
                      //     itemCount: items.length +
                      //         (items.length + 20 == page * pageSize ? 1 : 0),
                      //     initialScrollIndex: 0,
                      //     itemBuilder: (context, index) {
                      //       if (index == items.length) {
                      //         return buildLoaderListItem();
                      //       } else {
                      //         return Padding(
                      //           padding: const EdgeInsets.only(
                      //               bottom: 8.0, top: 8.0),
                      //           child: Container(
                      //             width: MediaQuery.of(context).size.width * .9,
                      //             decoration: BoxDecoration(
                      //                 color: Colors.white,
                      //                 borderRadius: BorderRadius.circular(8)),
                      //             child: Padding(
                      //               padding: const EdgeInsets.all(16.0),
                      //               child: Column(
                      //                 children: [
                      //                   Row(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.spaceBetween,
                      //                     children: [
                      //                       SizedBox(
                      //                         width: MediaQuery.of(context)
                      //                                 .size
                      //                                 .width *
                      //                             .6,
                      //                         child: Column(
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment.start,
                      //                           children: [
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.person,
                      //                                   size: 18,
                      //                                 ),
                      //                                 Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   " ${items[index].clientName}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.phone,
                      //                                   size: 18,
                      //                                 ),
                      //                                 Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   " ${items[index].contactNo}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.calendar_month,
                      //                                   size: 18,
                      //                                 ),
                      //                                 Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   "${items[index].startDate} To ${items[index].endDate}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.settings,
                      //                                   size: 18,
                      //                                 ),
                      //                                 Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   " ${items[index].typeName}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.currency_rupee,
                      //                                   size: 18,
                      //                                 ),
                      //                                 Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   " ${items[index].cost}/-",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       Column(
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.end,
                      //                         children: [
                      //                           Container(
                      //                             color:
                      //                                 items[index].isExpired ==
                      //                                         true
                      //                                     ? Colors.red
                      //                                     : Color(0xFF2a86c9),
                      //                             child: Padding(
                      //                               padding: const EdgeInsets
                      //                                   .symmetric(
                      //                                   vertical: 4.0,
                      //                                   horizontal: 8.0),
                      //                               child: Text(
                      //                                 items[index].isExpired ==
                      //                                         true
                      //                                     ? "Expired"
                      //                                     : "Not Expired",
                      //                                 style: const TextStyle(
                      //                                     color: Colors.white),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           const SizedBox(
                      //                             height: 10,
                      //                           ),
                      //                           Visibility(
                      //                             visible:
                      //                                 items[index].isExpired ==
                      //                                     false,
                      //                             child: Container(
                      //                               color: Colors.yellow,
                      //                               child: Padding(
                      //                                 padding: const EdgeInsets
                      //                                     .symmetric(
                      //                                     vertical: 4.0,
                      //                                     horizontal: 8.0),
                      //                                 child: Text(
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   "${items[index].remainingDays} days",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 14),
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           )
                      //                         ],
                      //                       )
                      //                     ],
                      //                   ),
                      //                   Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.end,
                      //                     children: [
                      //                       InkWell(
                      //                         onTap: () {
                      //                           startDate.clear();
                      //                           endDate.clear();
                      //                           projectCost.clear();
                      //                           remarks.clear();
                      //                           renewalBottomSheet(
                      //                               items[index].id,
                      //                               "Renew Details",
                      //                               items[index].noOfDays,
                      //                               items[index].cost);
                      //                         },
                      //                         child: Container(
                      //                           decoration: BoxDecoration(
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       2),
                      //                               color: Colors.green),
                      //                           child: const Padding(
                      //                             padding: EdgeInsets.all(8.0),
                      //                             child: Icon(Icons.restart_alt,
                      //                                 color: Colors.white),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       const SizedBox(
                      //                         width: 10,
                      //                       ),
                      //                       InkWell(
                      //                         onTap: () {
                      //                           Navigator.push(
                      //                               context,
                      //                               MaterialPageRoute(
                      //                                   builder: (context) =>
                      //                                       EditRenewalScreen(
                      //                                         callback: (() {
                      //                                           getList();
                      //                                         }),
                      //                                         id: items[index]
                      //                                             .id,
                      //                                         custId:
                      //                                             items[index]
                      //                                                 .clientId,
                      //                                         custName: items[
                      //                                                 index]
                      //                                             .clientName,
                      //                                         typeId:
                      //                                             items[index]
                      //                                                 .typeId,
                      //                                         typeName:
                      //                                             items[index]
                      //                                                 .typeName,
                      //                                         startDate: items[
                      //                                                 index]
                      //                                             .startDate,
                      //                                         endDate:
                      //                                             items[index]
                      //                                                 .endDate,
                      //                                         projectCost:
                      //                                             items[index]
                      //                                                 .cost,
                      //                                         remindMe: items[
                      //                                                 index]
                      //                                             .remindBefore,
                      //                                         remark:
                      //                                             items[index]
                      //                                                 .remarks,
                      //                                         // branch: items[index]
                      //                                         // .,
                      //                                       )));
                      //                         },
                      //                         child: Container(
                      //                           decoration: BoxDecoration(
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       2),
                      //                               color: Colors.blueAccent),
                      //                           child: const Padding(
                      //                             padding: EdgeInsets.all(8.0),
                      //                             child: Icon(Icons.edit,
                      //                                 color: Colors.white),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       const SizedBox(
                      //                         width: 10,
                      //                       ),
                      //                       InkWell(
                      //                         onTap: () {
                      //                           showDialog(
                      //                               context: context,
                      //                               builder:
                      //                                   (BuildContext context) {
                      //                                 return AlertDialog(
                      //                                   scrollable: true,
                      //                                   title: const Text(
                      //                                       'Please Confirm'),
                      //                                   content: const Text(
                      //                                       'Are you sure to Hide?'),
                      //                                   actions: [
                      //                                     TextButton(
                      //                                         onPressed:
                      //                                             () async {
                      //                                           Navigator.pop(
                      //                                               context);
                      //                                           await hide(
                      //                                               items[index]
                      //                                                   .id);
                      //                                           page = 1;
                      //                                           items.clear();
                      //                                           getList();
                      //                                         },
                      //                                         child: const Text(
                      //                                             'Yes')),
                      //                                     TextButton(
                      //                                         onPressed: () {
                      //                                           Navigator.of(
                      //                                                   context)
                      //                                               .pop();
                      //                                         },
                      //                                         child: const Text(
                      //                                             'No'))
                      //                                   ],
                      //                                 );
                      //                               });
                      //                         },
                      //                         child: Container(
                      //                           decoration: BoxDecoration(
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                       2),
                      //                               color: Colors.grey),
                      //                           child: const Padding(
                      //                             padding: EdgeInsets.all(8.0),
                      //                             child: Icon(
                      //                                 Icons.visibility_off,
                      //                                 color: Colors.white),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       }
                      //     },
                      //   ),
                      // )
                    ],
                  ),
          ),
        )),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  CustomRenewal(),
                  ));
              // renewalAddDialog(context);
            },
            label: const Row(
              children: [Icon(Icons.add), Text(" Renewal")],
            )),
      ),
    );
  }

  Future<dynamic> renewalAddDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            content: Column(
              children: [
                SizedBox(
                    height: 100,
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset("assets/main/bill_logo.png"),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuickRenewal(),
                              ));
                        },
                        child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Text('Quick\nInsert')))),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomRenewal(),
                              ));
                        },
                        child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                const Center(child: Text('Custom\nRenewal'))))
                  ],
                )
              ],
            ),
          );
        });
  }
}
