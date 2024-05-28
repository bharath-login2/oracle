import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:login2/screens/userManagement/staffDashboard.dart';
import 'package:login2/screens/userManagement/staffLeadDetails.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../screens/bottomNavigationBar.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';

// ignore: must_be_immutable
class StaffViewLeads extends StatefulWidget {
  String? token;
  String? staff;
  String? staffName;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;
  int? page;
  int? pageSize;
  String? leadType;

  StaffViewLeads(this.token, this.staff, this.staffName,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.pageName,
      this.isCalled,
      this.scrollToIndex,
      this.page,
      this.pageSize,
      this.leadType});

  @override
  State<StaffViewLeads> createState() => _StaffViewLeadsState();
}

class _StaffViewLeadsState extends State<StaffViewLeads> {
  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  bool? result = true;
  bool? result1 = true;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  dynamic category;
  dynamic status;
  dynamic priority;
  bool? isCalled = true;
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
  CommonConfigureModel? configure;
  bool isSort = true;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<dynamic> items = [];
  int page = 1;
  int pageSize = 20;
  bool isLoading = false;
  String statusWise = '';
  String statusWiseId = '';
  String statusCatId = '';
  String type = '';
    String phoneCallLogPermission = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.page != null) {
      page = widget.page! - 1;
    }
    if (widget.pageSize != null) {
      pageSize = widget.pageSize!;
    }
    fromdate = DateTime.parse(widget.fromDate.toString());
    todate = DateTime.parse(widget.toDate.toString());
    status = widget.status;
    category = widget.category;
    if (isCalled == false) isCalled = widget.isCalled!;
    getData('desc', true);
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.last.index ==
          items.length - 1) {
        if (items.length < viewLeads!.data!.totalLeads!) {
          getData('desc', false);
        }
      }
    });
  }

  void getData(sort, isFirst) async {
    //print('scrollIndex1:${widget.scrollToIndex}');

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
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
      statusWise = await Common.getSharedPref("statusWise");
      setState(() {});
      if (statusWise == 'yes') {
        statusWiseId = await Common.getSharedPref("statusWisId");
        statusCatId = await Common.getSharedPref("statusCatId");
        type = await Common.getSharedPref("type");
        viewLeads = await HttpService.viewLeadsSts(
            widget.token,
            fromdate,
            todate,
            type,
            statusCatId,
            statusWiseId,
            sort,
            page,
            pageSize,
            isFirst,'');
      } else {
        viewLeads = await HttpService.viewLeads(
            widget.token,
            fromdate,
            todate,
            category,
            status,
            widget.staff,
            isCalled,
            priority,
            sort,
            page,
            pageSize,
            isFirst,
            widget.leadType,'');
      }

      commonDetails = await HttpService.addLeadCommonData(widget.token);
      if (commonDetails != null) {
        setState(() {});
      }
      configure = await HttpService.configure(widget.token);
      setState(() {
        items.addAll(viewLeads!.data!.details as Iterable);
        page++;
        isLoading = false;
      });
    } else {}
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  StaffDashboard(widget.token, widget.staff, widget.staffName)),
        );
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getData('desc', true);
          return;
        },
        child: result == true
            ? Scaffold(
                backgroundColor: Colors.grey.shade200,
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
                                        builder: (context) => StaffDashboard(
                                            widget.token,
                                            widget.staff,
                                            widget.staffName)),
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
                              Text(
                                widget.pageName.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: viewLeads != null && configure != null
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 10, top: 15),
                            child: Row(
                              children: [
                                const Text('Date from ',
                                    style: TextStyle(fontSize: 16)),
                                Text(outputFormat.format(fromdate),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Text(' to ',
                                    style: TextStyle(fontSize: 16)),
                                Text(outputFormat.format(todate),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    showGeneralDialog(
                                      barrierLabel: "showGeneralDialog",
                                      barrierDismissible: true,
                                      barrierColor:
                                          Colors.black.withOpacity(0.6),
                                      transitionDuration:
                                          const Duration(milliseconds: 400),
                                      context: context,
                                      pageBuilder: (context, _, __) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return Align(
                                              alignment: Alignment.bottomCenter,
                                              child: IntrinsicHeight(
                                                child: Container(
                                                  width: double.maxFinite,
                                                  clipBehavior: Clip.antiAlias,
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(16),
                                                      topRight:
                                                          Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Material(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 20),
                                                        const Text(
                                                          'Filtration',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Row(
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    'From Date',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 50,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.43,
                                                                  child: Center(
                                                                    child:
                                                                        DateTimePicker(
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          //<-- SEE HERE
                                                                          fillColor: Colors.white,
                                                                          prefixIcon: const Icon(
                                                                            Icons.arrow_right,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                          counterText: "",
                                                                          hintText: 'From Date',
                                                                          isDense: true,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                      initialValue:
                                                                          fromdate
                                                                              .toString(),
                                                                      type: DateTimePickerType
                                                                          .date,

                                                                      //controller: fromDate,
                                                                      firstDate:
                                                                          DateTime(
                                                                              1995),
                                                                      lastDate: DateTime
                                                                              .now()
                                                                          .add(const Duration(
                                                                              days: 365)),
                                                                      // This will add one year from current date
                                                                      validator:
                                                                          (value) {
                                                                        return null;
                                                                      },
                                                                      onChanged:
                                                                          (value) {
                                                                        if (value
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            fromdate =
                                                                                DateTime.parse(value);
                                                                          });
                                                                        }
                                                                      },
                                                                      // We can also use onSaved
                                                                      onSaved:
                                                                          (value) {
                                                                        if (value!
                                                                            .isNotEmpty) {
                                                                          fromdate =
                                                                              DateTime.parse(value);
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
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    'To Date',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 50,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.43,
                                                                  child: Center(
                                                                    child:
                                                                        DateTimePicker(
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          //<-- SEE HERE
                                                                          fillColor: Colors.white,
                                                                          prefixIcon: const Icon(
                                                                            Icons.arrow_right,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                          counterText: "",
                                                                          hintText: 'From Date',
                                                                          isDense: true,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                      initialValue:
                                                                          todate
                                                                              .toString(),
                                                                      type: DateTimePickerType
                                                                          .date,

                                                                      //controller: fromDate,
                                                                      firstDate:
                                                                          DateTime(
                                                                              1995),
                                                                      lastDate: DateTime
                                                                              .now()
                                                                          .add(const Duration(
                                                                              days: 365)),
                                                                      // This will add one year from current date
                                                                      validator:
                                                                          (value) {
                                                                        return null;
                                                                      },
                                                                      onChanged:
                                                                          (value) {
                                                                        if (value
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            todate =
                                                                                DateTime.parse(value);
                                                                          });
                                                                        }
                                                                      },
                                                                      // We can also use onSaved
                                                                      onSaved:
                                                                          (value) {
                                                                        if (value!
                                                                            .isNotEmpty) {
                                                                          todate =
                                                                              DateTime.parse(value);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 13,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    'Category',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                FormField<
                                                                    String>(
                                                                  builder: (FormFieldState<
                                                                          String>
                                                                      state) {
                                                                    return Container(
                                                                      height:
                                                                          50,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.43,
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Colors
                                                                                  .grey.shade900,
                                                                              width:
                                                                                  0),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius: const BorderRadius
                                                                              .all(
                                                                              Radius.circular(5))),
                                                                      child:
                                                                          DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                            String>(
                                                                          isExpanded:
                                                                              true,
                                                                          hint:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 20),
                                                                            child:
                                                                                Text('category'),
                                                                          ),
                                                                          value:
                                                                              category,
                                                                          items: commonDetails!
                                                                              .data!
                                                                              .leadCategory!
                                                                              .map((data) {
                                                                            return DropdownMenuItem(
                                                                              value: data.leadCategoryId.toString(),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 20),
                                                                                child: Text(data.leadCategory.toString()),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged:
                                                                              (newValue) {
                                                                            setState(() {
                                                                              category = newValue;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    'Status',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                FormField<
                                                                    String>(
                                                                  builder: (FormFieldState<
                                                                          String>
                                                                      state) {
                                                                    return Container(
                                                                      height:
                                                                          50,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.43,
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Colors
                                                                                  .grey.shade900,
                                                                              width:
                                                                                  0),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius: const BorderRadius
                                                                              .all(
                                                                              Radius.circular(5))),
                                                                      child:
                                                                          DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                            String>(
                                                                          isExpanded:
                                                                              true,
                                                                          hint:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 20),
                                                                            child:
                                                                                Text('Status'),
                                                                          ),
                                                                          value:
                                                                              status,
                                                                          items: commonDetails!
                                                                              .data!
                                                                              .callResult!
                                                                              .map((data) {
                                                                            return DropdownMenuItem(
                                                                              value: data.callResultId.toString(),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 20),
                                                                                child: Text(data.callResult.toString()),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged:
                                                                              (newValue) {
                                                                            setState(() {
                                                                              status = newValue;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 13,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                                'Priority',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            FormField<
                                                                String>(
                                                              builder: (FormFieldState<
                                                                      String>
                                                                  state) {
                                                                return Container(
                                                                  height:
                                                                      50,
                                                                  width: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                      0.9,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey.shade900,
                                                                          width:
                                                                              0),
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: const BorderRadius
                                                                          .all(
                                                                          Radius.circular(5))),
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton<
                                                                        String>(
                                                                      isExpanded:
                                                                          true,
                                                                      hint:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: 20),
                                                                        child:
                                                                            Text('Priority'),
                                                                      ),
                                                                      value:
                                                                          priority,
                                                                      items: commonDetails!
                                                                          .data!
                                                                          .priority!
                                                                          .map((data) {
                                                                        return DropdownMenuItem(
                                                                          value: data.priorityId.toString(),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 20),
                                                                            child: Text(data.priority.toString()),
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (newValue1) {
                                                                        setState(() {
                                                                          priority = newValue1;
                                                                        });
                                                                        if (kDebugMode) {
                                                                          print(priority);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Container(
                                                          height: 40,
                                                          width:
                                                              double.maxFinite,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF3375e0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                          child:
                                                              RawMaterialButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                getData('desc',
                                                                    true);
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              });
                                                            },
                                                            child: const Center(
                                                              child: Text(
                                                                'Continue',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      transitionBuilder:
                                          (_, animation1, __, child) {
                                        return SlideTransition(
                                          position: Tween(
                                            begin: const Offset(0, 1),
                                            end: const Offset(0, 0),
                                          ).animate(animation1),
                                          child: child,
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: const Color(0xFFd5f5f4),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                        child: Image.asset(
                                            "assets/icons/filter.png",
                                            width: 20)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text('Total Leads : ${viewLeads!.data!.totalLeads}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          viewLeads!.data!.details!.isNotEmpty
                              ? Expanded(
                                  child: ScrollablePositionedList.builder(
                                    //reverse: true,
                                    initialScrollIndex:
                                        widget.scrollToIndex == null
                                            ? 0
                                            : widget.scrollToIndex!,
                                    //you can pass the desired index here//
                                    itemCount:
                                        items.length + (isLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == items.length) {
                                        // When reaching the end of the list, show a loader
                                        return _buildLoaderListItem();
                                      }
                                      return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => StaffLeadDetails(
                                                            widget.token!,
                                                            widget.staff!,
                                                            widget.staffName,
                                                            items[index]
                                                                .callMasterId
                                                                .toString(),
                                                            pageName: widget
                                                                .pageName,
                                                            status:
                                                                widget.status,
                                                            isCalled: widget
                                                                .isCalled,
                                                            fromDate: widget
                                                                .fromDate,
                                                            toDate:
                                                                widget.toDate,
                                                            category: widget
                                                                .category,
                                                            scrollToIndex:
                                                                index,
                                                            page: page,
                                                            pageSize: page *
                                                                pageSize,
                                                            leadType: widget
                                                                .leadType)),
                                                  );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              decoration: BoxDecoration(
                                                color: items[index]
                                                            .isSelected ==
                                                        false
                                                    ? Colors.white
                                                    : Colors.blue.shade100,
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
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 10,
                                                            left: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            children: [
                                                              if (items[index]
                                                                      .priority ==
                                                                  '1')
                                                                Container(
                                                                  width: 10.0,
                                                                  height:
                                                                      10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (items[index]
                                                                      .priority ==
                                                                  '2')
                                                                Container(
                                                                  width: 10.0,
                                                                  height:
                                                                      10.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              if (items[index]
                                                                      .priority ==
                                                                  '3')
                                                                Container(
                                                                  width: 10.0,
                                                                  height:
                                                                      10.0,
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
                                                                width: 170,
                                                                child: Text(
                                                                  items[index]
                                                                      .clientName
                                                                      .toString(),
                                                                  // items.length.toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight.bold),
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
                                                                          BorderRadius.circular(5)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        left:
                                                                            5,
                                                                        right:
                                                                            5,
                                                                        top:
                                                                            2,
                                                                        bottom:
                                                                            2),
                                                                    child:
                                                                        Text(
                                                                      items[index]
                                                                          .leadCategory
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color:
                                                                            Colors.red,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                      softWrap:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
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
                                                                  width: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                      0.68,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment.start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          items[index].contactNumber1.toString(),
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
                                                                                'Assigned to : ${items[index].staffName}',
                                                                                style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(color: _colors[items[index].callResultId!], borderRadius: BorderRadius.circular(5)),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                                                                                child: Text(
                                                                                  items[index].callResult.toString(),
                                                                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              decoration: BoxDecoration(color: const Color(0xFFd5f5f4), borderRadius: BorderRadius.circular(5)),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                                          items[index].isCalled == false ? '--' : items[index].calledDate.toString(),
                                                                                          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(color: const Color(0xFFd5f5f4), borderRadius: BorderRadius.circular(5)),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                                          items[index].scheduledDate.toString(),
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
                                                                    maxHeight:
                                                                        60,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      minHeight:
                                                                          20,
                                                                      minWidth:
                                                                          20,
                                                                      maxHeight:
                                                                          50,
                                                                      maxWidth:
                                                                          50,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.white,
                                                                          width: 0),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                            color: Colors.grey,
                                                                            blurRadius: 5,
                                                                            offset: Offset(1, 1)),
                                                                      ],
                                                                      color: Colors
                                                                          .white,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: DecorationImage(
                                                                          fit:
                                                                              BoxFit.cover,
                                                                          image: NetworkImage(items[index].profilePic.toString())),
                                                                      // image: AssetImage(
                                                                      //     'assets/images/img.jpeg')),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
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
                                          ));
                                    },
                                    itemScrollController: itemScrollController,
                                    itemPositionsListener:
                                        itemPositionsListener,
                                  ),
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
                                      const Text(
                                        'Result Not Found',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Whoops... this information is \n not available for a moment',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StaffDashboard(
                                                        widget.token,
                                                        widget.staff,
                                                        widget.staffName)),
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
                          // ListView.builder(
                          //     itemCount: viewLeads!.data!.length,
                          //     shrinkWrap: true,
                          //   physics: NeverScrollableScrollPhysics(),
                          //   itemBuilder: (context, i) {
                          //       return InkWell(
                          //         onTap: (){
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (context) =>
                          //                     LeadDetails(widget.token!,widget.editLead,widget.deleteLead,viewLeads!.data![i].callMasterId.toString(),pageName: widget.pageName,status: widget.status,staff: widget.staff,isCalled: widget.isCalled,fromDate: widget.fromDate,toDate: widget.toDate,category: widget.category,)),
                          //           );
                          //         },
                          //         child: Padding(
                          //           padding:
                          //               const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          //           child: Column(
                          //             children: [
                          //               SwipeTo(
                          //                 onLeftSwipe: () {
                          //                   _dialogue(context);
                          //                 },
                          //                 onRightSwipe: () async {
                          //                   String url = 'tel:' +
                          //                       viewLeads!.data![i].contactNumber1.toString();
                          //                   await launch(url);
                          //                 },
                          //                 child: Container(
                          //                   padding:
                          //                       EdgeInsets.only(left: 10, right: 10, top: 10),
                          //                   width: MediaQuery.of(context).size.width * 1,
                          //                   height: 140,
                          //                   decoration: new BoxDecoration(
                          //                     color: Colors.white,
                          //                     boxShadow: [
                          //                       new BoxShadow(
                          //                         color: Colors.grey,
                          //                         offset: Offset(2.0, 2.0),
                          //                       )
                          //                     ],
                          //                     borderRadius: new BorderRadius.circular(10),
                          //                   ),
                          //                   child: Column(
                          //                     mainAxisAlignment: MainAxisAlignment.start,
                          //                     crossAxisAlignment: CrossAxisAlignment.start,
                          //                     children: [
                          //                       Row(
                          //                           mainAxisAlignment: MainAxisAlignment.start,
                          //                           crossAxisAlignment: CrossAxisAlignment.start,
                          //                           children: [
                          //                             Row(
                          //                               mainAxisAlignment:
                          //                                   MainAxisAlignment.spaceBetween,
                          //                               crossAxisAlignment:
                          //                                   CrossAxisAlignment.start,
                          //                               children: [
                          //                                 Container(
                          //                                   width: MediaQuery.of(context)
                          //                                           .size
                          //                                           .width *
                          //                                       0.65,
                          //                                   child: Padding(
                          //                                     padding:
                          //                                         const EdgeInsets.only(left: 10),
                          //                                     child: Column(
                          //                                       mainAxisAlignment:
                          //                                           MainAxisAlignment.start,
                          //                                       crossAxisAlignment:
                          //                                           CrossAxisAlignment.start,
                          //                                       children: [
                          //                                         Row(
                          //                                           children: [
                          //                                             if (viewLeads!.data![i]
                          //                                                     .priority ==
                          //                                                 '1')
                          //                                               Container(
                          //                                                 width: 10.0,
                          //                                                 height: 10.0,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color: Colors.grey,
                          //                                                   shape:
                          //                                                       BoxShape.circle,
                          //                                                 ),
                          //                                               ),
                          //                                             if (viewLeads!.data![i]
                          //                                                     .priority ==
                          //                                                 '2')
                          //                                               Container(
                          //                                                 width: 10.0,
                          //                                                 height: 10.0,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color: Colors.green,
                          //                                                   shape:
                          //                                                       BoxShape.circle,
                          //                                                 ),
                          //                                               ),
                          //                                             if (viewLeads!.data![i]
                          //                                                     .priority ==
                          //                                                 '3')
                          //                                               Container(
                          //                                                 width: 10.0,
                          //                                                 height: 10.0,
                          //                                                 decoration:
                          //                                                     const BoxDecoration(
                          //                                                   color: Colors.red,
                          //                                                   shape:
                          //                                                       BoxShape.circle,
                          //                                                 ),
                          //                                               ),
                          //                                             SizedBox(
                          //                                               width: 5,
                          //                                             ),
                          //                                             Container(
                          //                                               //width: MediaQuery.of(context).size.width * 0.1,
                          //                                               child: Text(
                          //                                                 viewLeads!
                          //                                                     .data![i].clientName
                          //                                                     .toString(),
                          //                                                 style: TextStyle(
                          //                                                     fontSize: 16,
                          //                                                     color: Colors.black,
                          //                                                     fontWeight:
                          //                                                         FontWeight
                          //                                                             .bold),
                          //                                                 maxLines: 1,
                          //                                                 overflow: TextOverflow
                          //                                                     .ellipsis,
                          //                                               ),
                          //                                             ),
                          //                                           ],
                          //                                         ),
                          //                                         SizedBox(
                          //                                           height: 3,
                          //                                         ),
                          //                                         Container(
                          //                                           child: Text(
                          //                                             viewLeads!
                          //                                                 .data![i].contactNumber1
                          //                                                 .toString(),
                          //                                             style: TextStyle(
                          //                                                 fontSize: 13,
                          //                                                 color: Colors.black54,
                          //                                                 fontWeight:
                          //                                                     FontWeight.w500),
                          //                                           ),
                          //                                         ),
                          //                                         SizedBox(
                          //                                           height: 3,
                          //                                         ),
                          //                                         Row(
                          //                                           mainAxisAlignment:
                          //                                               MainAxisAlignment
                          //                                                   .spaceBetween,
                          //                                           children: [
                          //                                             Container(
                          //                                               child: Text(
                          //                                                 'Assigned to : ' +
                          //                                                     viewLeads!.data![i]
                          //                                                         .staffName
                          //                                                         .toString(),
                          //                                                 style: TextStyle(
                          //                                                     fontSize: 13,
                          //                                                     color:
                          //                                                         Colors.black54,
                          //                                                     fontWeight:
                          //                                                         FontWeight
                          //                                                             .w500),
                          //                                               ),
                          //                                             ),
                          //                                             Container(
                          //                                               decoration: BoxDecoration(
                          //                                                   color: _colors[
                          //                                                       viewLeads!
                          //                                                           .data![i]
                          //                                                           .callResultId!],
                          //                                                   borderRadius:
                          //                                                       BorderRadius
                          //                                                           .circular(5)),
                          //                                               child: Padding(
                          //                                                 padding:
                          //                                                     const EdgeInsets
                          //                                                             .only(
                          //                                                         left: 5,
                          //                                                         right: 5,
                          //                                                         top: 2,
                          //                                                         bottom: 2),
                          //                                                 child: Text(
                          //                                                   viewLeads!.data![i]
                          //                                                       .callResult
                          //                                                       .toString(),
                          //                                                   style: TextStyle(
                          //                                                       fontSize: 13,
                          //                                                       color:
                          //                                                           Colors.white,
                          //                                                       fontWeight:
                          //                                                           FontWeight
                          //                                                               .w500),
                          //                                                 ),
                          //                                               ),
                          //                                             ),
                          //                                           ],
                          //                                         ),
                          //                                         SizedBox(
                          //                                           height: 10,
                          //                                         ),
                          //                                         Row(
                          //                                           mainAxisAlignment:
                          //                                               MainAxisAlignment
                          //                                                   .spaceBetween,
                          //                                           children: [
                          //                                             Container(
                          //                                               decoration: BoxDecoration(
                          //                                                   color:
                          //                                                       Color(0xFFd5f5f4),
                          //                                                   borderRadius:
                          //                                                       BorderRadius
                          //                                                           .circular(5)),
                          //                                               child: Padding(
                          //                                                 padding:
                          //                                                     const EdgeInsets
                          //                                                             .only(
                          //                                                         left: 5,
                          //                                                         right: 5,
                          //                                                         top: 5,
                          //                                                         bottom: 5),
                          //                                                 child: Row(
                          //                                                   mainAxisAlignment:
                          //                                                       MainAxisAlignment
                          //                                                           .start,
                          //                                                   crossAxisAlignment:
                          //                                                       CrossAxisAlignment
                          //                                                           .center,
                          //                                                   children: [
                          //                                                     Image.asset(
                          //                                                         "assets/icons/calendar.png",width:20
                          //                                                     ),
                          //                                                     SizedBox(
                          //                                                       width: 5,
                          //                                                     ),
                          //                                                     Column(
                          //                                                       children: [
                          //                                                         Container(
                          //                                                           child: Text(
                          //                                                             'Called Date',
                          //                                                             style: TextStyle(
                          //                                                                 fontSize:
                          //                                                                     13,
                          //                                                                 color: Colors
                          //                                                                     .black54,
                          //                                                                 fontWeight:
                          //                                                                     FontWeight.w500),
                          //                                                           ),
                          //                                                         ),
                          //                                                         SizedBox(
                          //                                                           height: 5,
                          //                                                         ),
                          //                                                         Container(
                          //                                                           child: Text(
                          //                                                             viewLeads!.data![i].isCalled ==
                          //                                                                     false
                          //                                                                 ? '--'
                          //                                                                 : viewLeads!
                          //                                                                     .data![i]
                          //                                                                     .calledDate
                          //                                                                     .toString(),
                          //                                                             style: TextStyle(
                          //                                                                 fontSize:
                          //                                                                     13,
                          //                                                                 color: Colors
                          //                                                                     .black,
                          //                                                                 fontWeight:
                          //                                                                     FontWeight.w500),
                          //                                                           ),
                          //                                                         ),
                          //                                                       ],
                          //                                                     ),
                          //                                                   ],
                          //                                                 ),
                          //                                               ),
                          //                                             ),
                          //                                             Container(
                          //                                               decoration: BoxDecoration(
                          //                                                   color:
                          //                                                       Color(0xFFd5f5f4),
                          //                                                   borderRadius:
                          //                                                       BorderRadius
                          //                                                           .circular(5)),
                          //                                               child: Padding(
                          //                                                 padding:
                          //                                                     const EdgeInsets
                          //                                                             .only(
                          //                                                         left: 5,
                          //                                                         right: 5,
                          //                                                         top: 5,
                          //                                                         bottom: 5),
                          //                                                 child: Row(
                          //                                                   mainAxisAlignment:
                          //                                                       MainAxisAlignment
                          //                                                           .start,
                          //                                                   crossAxisAlignment:
                          //                                                       CrossAxisAlignment
                          //                                                           .center,
                          //                                                   children: [
                          //                                                     Image.asset(
                          //                                                         "assets/icons/calendar.png",width:20
                          //                                                     ),
                          //                                                     SizedBox(
                          //                                                       width: 5,
                          //                                                     ),
                          //                                                     Column(
                          //                                                       children: [
                          //                                                         Container(
                          //                                                           child: Text(
                          //                                                             'Followup Date',
                          //                                                             style: TextStyle(
                          //                                                                 fontSize:
                          //                                                                     13,
                          //                                                                 color: Colors
                          //                                                                     .black54,
                          //                                                                 fontWeight:
                          //                                                                     FontWeight.w500),
                          //                                                           ),
                          //                                                         ),
                          //                                                         SizedBox(
                          //                                                           height: 5,
                          //                                                         ),
                          //                                                         Container(
                          //                                                           child: Text(
                          //                                                             viewLeads!
                          //                                                                 .data![
                          //                                                                     i]
                          //                                                                 .scheduledDate
                          //                                                                 .toString(),
                          //                                                             style: TextStyle(
                          //                                                                 fontSize:
                          //                                                                     13,
                          //                                                                 color: Colors
                          //                                                                     .black,
                          //                                                                 fontWeight:
                          //                                                                     FontWeight.w500),
                          //                                                           ),
                          //                                                         ),
                          //                                                       ],
                          //                                                     ),
                          //                                                   ],
                          //                                                 ),
                          //                                               ),
                          //                                             ),
                          //                                           ],
                          //                                         ),
                          //                                       ],
                          //                                     ),
                          //                                   ),
                          //                                 ),
                          //                                 Column(
                          //                                   children: [
                          //                                     Container(
                          //                                       decoration: BoxDecoration(
                          //                                           color: Colors.pink.shade100,
                          //                                           borderRadius:
                          //                                               BorderRadius.circular(5)),
                          //                                       child: Padding(
                          //                                         padding: const EdgeInsets.only(
                          //                                             left: 5,
                          //                                             right: 5,
                          //                                             top: 2,
                          //                                             bottom: 2),
                          //                                         child: Container(
                          //                                             width: 76,
                          //                                             child: Text(
                          //                                               viewLeads!
                          //                                                   .data![i].leadCategory
                          //                                                   .toString(),
                          //                                               style: TextStyle(
                          //                                                 fontSize: 13,
                          //                                                 color: Colors.red,
                          //                                                 fontWeight:
                          //                                                     FontWeight.w500,
                          //                                               ),
                          //                                               maxLines: 1,
                          //                                               overflow:
                          //                                                   TextOverflow.ellipsis,
                          //                                             )),
                          //                                       ),
                          //                                     ),
                          //                                     SizedBox(
                          //                                       height: 10,
                          //                                     ),
                          //                                     Container(
                          //                                       constraints: const BoxConstraints(
                          //                                         maxHeight: 60,
                          //                                       ),
                          //                                       child: Container(
                          //                                         constraints:
                          //                                             const BoxConstraints(
                          //                                           minHeight: 20,
                          //                                           minWidth: 20,
                          //                                           maxHeight: 50,
                          //                                           maxWidth: 50,
                          //                                         ),
                          //                                         decoration: BoxDecoration(
                          //                                           border: Border.all(
                          //                                               color: Colors.white,
                          //                                               width: 0),
                          //                                           boxShadow: const [
                          //                                             BoxShadow(
                          //                                                 color: Colors.grey,
                          //                                                 blurRadius: 5,
                          //                                                 offset: Offset(1, 1)),
                          //                                           ],
                          //                                           color: Colors.white,
                          //                                           shape: BoxShape.circle,
                          //                                           image: DecorationImage(
                          //                                               fit: BoxFit.cover,
                          //                                               image: NetworkImage(
                          //                                                   viewLeads!.data![i]
                          //                                                       .profilePic
                          //                                                       .toString())),
                          //                                           // image: AssetImage(
                          //                                           //     'assets/images/img.jpeg')),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     SizedBox(
                          //                                       height: 10,
                          //                                     ),
                          //                                     InkWell(
                          //                                       onTap: () async {
                          //                                         String url = 'tel:' +
                          //                                             viewLeads!
                          //                                                 .data![i].contactNumber1
                          //                                                 .toString();
                          //                                         await launch(url);
                          //                                       },
                          //                                       child: Container(
                          //                                         width: 65,
                          //                                         height: 30,
                          //                                         decoration: new BoxDecoration(
                          //                                           color: Colors.green,
                          //                                           border: Border.all(
                          //                                               color:
                          //                                                   Colors.grey.shade300),
                          //                                           borderRadius:
                          //                                               new BorderRadius.circular(
                          //                                                   8),
                          //                                         ),
                          //                                         child: Center(
                          //                                           child: Row(
                          //                                             mainAxisAlignment:
                          //                                                 MainAxisAlignment
                          //                                                     .center,
                          //                                             crossAxisAlignment:
                          //                                                 CrossAxisAlignment
                          //                                                     .center,
                          //                                             children: [
                          //                                               Icon(
                          //                                                 Icons.call,
                          //                                                 color: Colors.white,
                          //                                                 size: 15,
                          //                                               ),
                          //                                               SizedBox(
                          //                                                 width: 5,
                          //                                               ),
                          //                                               Text('Call',
                          //                                                   style: TextStyle(
                          //                                                       fontFamily:
                          //                                                           "MontserratMedium",
                          //                                                       fontSize: 14,
                          //                                                       color:
                          //                                                           Colors.white,
                          //                                                       fontWeight:
                          //                                                           FontWeight
                          //                                                               .bold)),
                          //                                             ],
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                   ],
                          //                                 ),
                          //                               ],
                          //                             ),
                          //                           ]),
                          //                       SizedBox(
                          //                         height: 8,
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                        ],
                      )
                    : Center(
                  child: Lottie.asset('assets/main/loading.json',
                      fit: BoxFit.fill),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Dashboard(widget.token)),
                    );
                  },
                  child: Image.asset("assets/icons/menu.png",
                      width: 25), //icon inside button
                ),
                bottomNavigationBar: configure != null
                    ? BottomNavigation(
                        widget.token!, configure!.data!.whatsappConfigured,phoneCallLogPermission: phoneCallLogPermission,)
                    : const SizedBox())
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          getData('desc', true);
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
      ),
    );
  }

  Widget _buildLoaderListItem() {
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
}

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Text(label));
  }
}
