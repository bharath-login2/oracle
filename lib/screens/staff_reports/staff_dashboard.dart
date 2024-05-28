// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/staff_report/staff_call_details_model.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/service/service.dart';
import 'package:pie_chart/pie_chart.dart';

class StaffReportDashboard extends StatefulWidget {
  String id;
  StaffReportDashboard({super.key, required this.id});

  @override
  State<StaffReportDashboard> createState() => _StaffReportDashboardState();
}

class _StaffReportDashboardState extends State<StaffReportDashboard> {
  Map<String, double> data = {};
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.black,
    Colors.amber,
    Colors.deepOrange,
    Colors.green,
    Colors.purple,
    Colors.grey,
  ];
  final List<Color> _colorsTable = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.redAccent,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
  ];
  String fDate = DateFormat('dd-MM-yyyy').format(DateTime(
      DateTime.now().year, DateTime.now().month - 1, DateTime.now().day));
  String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  UserDashboardModel? staffDetails;
  StaffCalldetailsModel? callDetails;
  bool isLoading = true;
  String selectedType = "Today";
  String selectedTypeValue = "day";

  getStaffDetails() async {
    staffDetails =
        await HttpService.getStaffDashboard(widget.id, selectedTypeValue);

    if (staffDetails != null && staffDetails!.status == true) {
      setState(() {});
    } else {}
  }

  getCallDetails() async {
    callDetails =
        await HttpService.getStaffCallDetails(widget.id, fDate, tDate);

    if (callDetails != null && callDetails!.status == true) {
      for (int i = 0; i < callDetails!.data.leadStatusGraph.length; i++) {
        data.addAll({
          callDetails!.data.leadStatusGraph[i].callResult:
              double.parse(callDetails!.data.leadStatusGraph[i].resCount)
        });
      }
      setState(() {});
    } else {}
  }

  initData() async {
    setState(() {
      isLoading = true;
    });
    await getStaffDetails();
    await getCallDetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .25,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    "assets/main/staff_dash.jpg")),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40))),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        staffDetails!.data.userData.profilePic,),
                                    radius: 50,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staffDetails!.data.userData.staffName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          staffDetails!
                                              .data.userData.designation,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          staffDetails!.data.userData.address,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 16.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       Container(
                              //         decoration: BoxDecoration(
                              //             color: Colors.purple,
                              //             borderRadius:
                              //                 BorderRadius.circular(12)),
                              //         child: Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               vertical: 4.0, horizontal: 8.0),
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.spaceEvenly,
                              //             children: [
                              //               const Text("Start Time: ",
                              //                   style: TextStyle(
                              //                       color: Colors.white,
                              //                       fontSize: 16)),
                              //               Container(
                              //                 decoration: BoxDecoration(
                              //                     color: Colors.black,
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                             12)),
                              //                 child: const Padding(
                              //                   padding: EdgeInsets.symmetric(
                              //                       vertical: 2.0,
                              //                       horizontal: 6.0),
                              //                   child: Text(staffDetails!.data.userData.,
                              //                       style: TextStyle(
                              //                           color: Colors.white,
                              //                           fontSize: 16)),
                              //                 ),
                              //               )
                              //             ],
                              //           ),
                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Target",
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 20)),
                                    PopupMenuButton(
                                      itemBuilder: (context) {
                                        return [
                                          const PopupMenuItem(
                                              value: 0, child: Text("Today")),
                                          const PopupMenuItem(
                                              value: 1,
                                              child: Text("This Month")),
                                        ];
                                      },
                                      onSelected: ((value) async {
                                        if (value == 0) {
                                          setState(() {
                                            selectedType = "Today";
                                            selectedTypeValue = "day";
                                          });
                                        } else {
                                          setState(() {
                                            selectedType = "This Month";
                                            selectedTypeValue = "month";
                                          });
                                        }
                                        getStaffDetails();
                                      }),
                                      child: Row(
                                        children: [
                                          Text(selectedType,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                          const Icon(Icons.arrow_drop_down)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 131, 123, 205),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                const Text("Cost Achived :",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                                Text(
                                                    staffDetails!.data
                                                        .userTarget.achievedCost
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                                const Text("Cost Target :",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                                Text(
                                                    staffDetails!.data
                                                        .userTarget.targetCost
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              ],
                                            ),
                                            const CircleAvatar(
                                              radius: 20,
                                              child: Icon(Icons.bar_chart),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 44, 131, 80),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                const Text("Call Achived :",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                                Text(
                                                    staffDetails!
                                                        .data
                                                        .userTarget
                                                        .achievedCalls
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                                const Text("Call Target :",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                                Text(
                                                    staffDetails!
                                                        .data
                                                        .userTarget
                                                        .targetCallCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              ],
                                            ),
                                            const CircleAvatar(
                                              radius: 20,
                                              child: Icon(Icons.phone),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Information",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20)),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          child: const Text("Name:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text(
                                              staffDetails!
                                                  .data.userData.staffName,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          child: const Text("Mobile:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text(
                                              staffDetails!
                                                  .data.userData.phoneNo,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          child: const Text("Email:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text(
                                              staffDetails!.data.userData.email,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          child: const Text("Location:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text(
                                              staffDetails!
                                                  .data.userData.address,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          child: const Text("Joining Date:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: const Text("Date",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                    child: const Text("Call Status Details",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20)),
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: (() async {
                                          final selctedDatetimetemp =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (selctedDatetimetemp == null) {
                                            return;
                                          } else {
                                            setState(() {
                                              fDate = DateFormat('dd-MM-yyyy')
                                                  .format(selctedDatetimetemp);
                                            });
                                            getCallDetails();
                                          }
                                        }),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .4,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .25,
                                                  child: Text(fDate)),
                                              const Icon(Icons.calendar_month)
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final selctedDatetimetemp =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (selctedDatetimetemp == null) {
                                            return;
                                          } else {
                                            setState(() {
                                              tDate = DateFormat('dd-MM-yyyy')
                                                  .format(selctedDatetimetemp);
                                            });
                                            getCallDetails();
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .4,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .25,
                                                  child: Text(tDate)),
                                              const Icon(Icons.calendar_month)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                              height: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 152, 157, 154),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 50,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Column(
                                          children: [
                                            const Text("Cloud Call Duration :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!.data.callDetails
                                                    .totDuration,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                            const Text("Phone Call Duration :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!.data.callDetails
                                                    .phoneCallDuration,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 127, 188, 151),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.closed_caption,
                                        size: 50,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Column(
                                          children: [
                                            const Text("Closed :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!.data.callDetails
                                                    .closedCalls
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0, bottom: 16.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 239, 192, 242),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.money,
                                        size: 50,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Column(
                                          children: [
                                            const Text("Cost :",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                            Text(
                                                callDetails!
                                                    .data.callDetails.totalCost
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: callDetails!
                                    .data.callCountByResponse.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        left: 20.0,
                                        right: 20.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(callDetails!
                                                .data
                                                .callCountByResponse[index]
                                                .callResponse),
                                            Text(
                                              "${callDetails!.data.callCountByResponse[index].resPercentage}%",
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        LinearProgressIndicator(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          backgroundColor: Colors.grey,
                                          value: double.parse(callDetails!
                                                  .data
                                                  .callCountByResponse[index]
                                                  .resPercentage) /
                                              100,
                                          valueColor:
                                               AlwaysStoppedAnimation<
                                                  Color>(_colors[index]),
                                          minHeight: 10,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible: data.isNotEmpty,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 60.0,
                                        bottom: 60.0,
                                        left: 40.0,
                                        right: 16),
                                    child: PieChart(
                                      dataMap: data,
                                      animationDuration:
                                          const Duration(milliseconds: 800),
                                      chartLegendSpacing: 20,
                                      chartRadius:
                                          MediaQuery.of(context).size.width / 2.5,
                                      colorList: _colors,
                                      initialAngleInDegree: 0,
                                      chartType: ChartType.ring,
                                      ringStrokeWidth: 25,
                                      centerText: "",
                                      legendOptions: const LegendOptions(
                                        legendShape: BoxShape.rectangle,
                                        showLegendsInRow: false,
                                        legendPosition: LegendPosition.right,
                                        showLegends: true,
                                        legendTextStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      chartValuesOptions:
                                          const ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        showChartValuesOutside: true,
                                        decimalPlaces: 1,
                                      ),
                                      // gradientList: ---To add gradient colors---
                                      // emptyColorGradient: ---Empty Color gradient---
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: SizedBox(
                            //     width: MediaQuery .of(context).size.width *2,
                            //     child: Column(
                            //       children: [
                            //         Padding(
                            //           padding:
                            //               const EdgeInsets.symmetric(horizontal: 8.0),
                            //           child: Table(
                            //             columnWidths: {
                            //               0: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .05,
                            //               ),
                            //               1: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .18,
                            //               ),
                            //               2: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .18,
                            //               ),
                            //               3: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .16,
                            //               ),
                            //               4: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .17,
                            //               ),
                            //               5: FixedColumnWidth(
                            //                 MediaQuery.of(context).size.width * .16,
                            //               ),
                            //             },
                            //             children: const [
                            //               TableRow(children: [
                            //                 Text(
                            //                   " ",
                            //                   style: TextStyle(fontSize: 10),
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.blue,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(
                            //                       " Total leads",
                            //                       style: TextStyle(fontSize: 10),
                            //                     ),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.green,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Confirmed",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.red,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Rejected",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.yellow,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Follow up",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //                 Row(
                            //                   children: [
                            //                     CircleAvatar(
                            //                       backgroundColor: Colors.redAccent,
                            //                       minRadius: 3,
                            //                     ),
                            //                     Text(" Closed",
                            //                         style: TextStyle(fontSize: 10)),
                            //                   ],
                            //                 ),
                            //               ])
                            //             ],
                            //           ),
                            //         ),
                            //         const Divider(
                            //       color: Colors.grey,
                            //     ),
                            //     SizedBox(
                            //       child: ListView.builder(
                            //         itemCount: 3,
                            //         shrinkWrap: true,
                            //         itemBuilder: (context, index) {
                            //           return Padding(
                            //             padding: const EdgeInsets.symmetric(
                            //                 vertical: 4.0),
                            //             child: Padding(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 8.0),
                            //               child: Table(
                            //                 columnWidths: {
                            //                   0: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .05,
                            //                   ),
                            //                   1: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .18,
                            //                   ),
                            //                   2: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .18,
                            //                   ),
                            //                   3: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .16,
                            //                   ),
                            //                   4: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .17,
                            //                   ),
                            //                   5: FixedColumnWidth(
                            //                     MediaQuery.of(context).size.width *
                            //                         .16,
                            //                   ),
                            //                 },
                            //                 children: const [
                            //                   TableRow(children: [
                            //                     Center(
                            //                       child: CircleAvatar(
                            //                         backgroundColor:
                            //                             Colors.redAccent,
                            //                         minRadius: 10,
                            //                       ),
                            //                     ),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                     Center(child: Text("10")),
                            //                   ])
                            //                 ],
                            //               ),
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //     ),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            Visibility(
                              visible: callDetails!.data.leadCategoryCount.isNotEmpty,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8)),
                                    dividerThickness: .5,
                                    dataRowHeight: 30,
                                    columnSpacing: 10,
                                    headingRowHeight: 40,
                                    columns:
                                        _buildColumns(), // Dynamically build columns
                                    rows: _buildRows(
                                        callDetails!.data.leadCategoryCount),
                                    checkboxHorizontalMargin: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60.0,
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  )
                ],
              ),
            )),
    );
  }

  List<DataColumn> _buildColumns() {
    if (callDetails != null &&
        callDetails!.data != null &&
        callDetails!.data.leadCategory != null) {
      return callDetails!.data.leadCategory.asMap().entries.map((entry) {
        int index = entry.key;
        String key = entry.value;
        return DataColumn(
          label: Text(
            key,
            // style: TextStyle(color: _colorsTable[index % _colorsTable.length]),
          ),
        );
      }).toList();
    } else {
      return []; // Return an empty list if callDetails or its properties are null
    }
  }

  List<DataRow> _buildRows(List<dynamic> data) {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      dynamic item = entry.value;
      return DataRow(
        cells: [
          DataCell(Text(
            item.leadCategory,
            // style: TextStyle(color: _colors[index % _colors.length]),
          )),
          DataCell(Text(
            item.the1Count,
          )),
          DataCell(Text(item.the2Count)),
          DataCell(Text(item.the3Count,
          // style: const TextStyle(color: Colors.red)
          )),
          DataCell(Text(item.the4Count)),
          DataCell(Text(item.the5Count)),
        ],
      );
    }).toList();
  }
}
