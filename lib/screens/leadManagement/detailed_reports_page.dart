import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/userManagement/staffDashboard.dart';
import 'package:login2/service/service.dart';
import 'package:login2/models/lead_management/leadCategoryStaffWiseModel.dart';
import 'package:login2/screens/leadManagement/viewLeads.dart';
import 'package:login2/screens/leadManagement/viewLeadCategory.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/core/common.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:pie_chart/pie_chart.dart';

class DetailedReportsPage extends StatefulWidget {
  final String token;
  final DateTime fromDate;
  final DateTime toDate;
  final String fromDate1;
  final DateTime toDate1;
  final bool updateLeadPermission1;
  final bool deleteLeadPermission1;
  final bool cloudCallPermission1;
  final String viewLeadPermission;

  const DetailedReportsPage({
    Key? key,
    required this.token,
    required this.fromDate,
    required this.toDate,
    required this.fromDate1,
    required this.toDate1,
    required this.updateLeadPermission1,
    required this.deleteLeadPermission1,
    required this.cloudCallPermission1,
    required this.viewLeadPermission,
  }) : super(key: key);

  @override
  State<DetailedReportsPage> createState() => _DetailedReportsPageState();
}

class _DetailedReportsPageState extends State<DetailedReportsPage> {
  LeadCategoryStaffWiseModel? staffWise;
  bool isLoading = false;
  bool moreloading = false;
  Map<String, double> data = {};

  List<Color> _colors = [
    Colors.redAccent,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.teal,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.black,
    Colors.green,
  ];

  int catNew = 0;
  int catPending = 0;
  int catFollowup = 0;
  int catRejected = 0;
  int catClosed = 0;
  int stfNew = 0;
  int stfPending = 0;
  int stfFollowup = 0;
  int stfRejected = 0;
  int stfClosed = 0;

  String fromdate1 = '';
  DateTime todate1 = DateTime.now();
  String viewLeadCategoryPermission = '';

  @override
  void initState() {
    super.initState();
    fromdate1 = widget.fromDate1;
    todate1 = widget.toDate1;
    _loadPermissions();
    _loadStaffWiseData();
  }

  void _loadPermissions() async {
    viewLeadCategoryPermission =
        await Common.getSharedPref("viewLeadCategoryPermission") ?? '';
  }

  Future<void> _loadStaffWiseData() async {
    setState(() {
      isLoading = true;
    });

    staffWise = await HttpService.leadDashboard1(
      widget.token,
      widget.fromDate,
      widget.toDate,
      fromdate1,
      todate1,
    );

    if (staffWise != null) {
      _processData();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _processData() {
    data.clear();
    for (int i = 0; i < staffWise!.data!.categoryGraph!.length; i++) {
      data.addAll({
        staffWise!.data!.categoryGraph![i].categoryName.toString():
            staffWise!.data!.categoryGraph![i].categoryCount!.toDouble(),
      });
    }

  
    catNew = 0;
    catPending = 0;
    catFollowup = 0;
    catRejected = 0;
    catClosed = 0;
    stfNew = 0;
    stfPending = 0;
    stfFollowup = 0;
    stfRejected = 0;
    stfClosed = 0;

 
    for (int i = 0; i < staffWise!.data!.categoryLeads!.length; i++) {
      catNew +=
          int.parse(staffWise!.data!.categoryLeads![i].newCount.toString());
      catPending +=
          int.parse(staffWise!.data!.categoryLeads![i].pendingCount.toString());
      catFollowup += int.parse(
          staffWise!.data!.categoryLeads![i].followupCount.toString());
      catRejected += int.parse(
          staffWise!.data!.categoryLeads![i].rejectedCount.toString());
      catClosed += int.parse(
          staffWise!.data!.categoryLeads![i].confirmedCount.toString());
    }


    for (int i = 0; i < staffWise!.data!.staffLeads!.length; i++) {
      stfNew += int.parse(staffWise!.data!.staffLeads![i].newCount.toString());
      stfPending +=
          int.parse(staffWise!.data!.staffLeads![i].pendingCount.toString());
      stfFollowup +=
          int.parse(staffWise!.data!.staffLeads![i].followupCount.toString());
      stfRejected +=
          int.parse(staffWise!.data!.staffLeads![i].rejectedCount.toString());
      stfClosed +=
          int.parse(staffWise!.data!.staffLeads![i].confirmedCount.toString());
    }
  }

  void _showDateFilterDialog() {
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: IntrinsicHeight(
            child: Container(
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
                        'Filter By Date Range',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: const Text(
                              'From Date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Center(
                              child: DateTimePicker(
                                decoration: InputDecoration(
                                  filled: true,
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
                                        color: Colors.purple.shade100),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                initialValue: fromdate1.toString(),
                                type: DateTimePickerType.date,
                                firstDate: DateTime(1995),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                validator: (value) {
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      fromdate1 =
                                          DateTime.parse(value).toString();
                                    });
                                  }
                                },
                                onSaved: (value) {
                                  if (value!.isNotEmpty) {
                                    fromdate1 =
                                        DateTime.parse(value).toString();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: const Text(
                              'To Date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Center(
                              child: DateTimePicker(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    Icons.arrow_right,
                                    color: Colors.grey,
                                  ),
                                  counterText: "",
                                  hintText: 'To date',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple.shade100),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                initialValue: todate1.toString(),
                                type: DateTimePickerType.date,
                                firstDate: DateTime(1995),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                validator: (value) {
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      todate1 = DateTime.parse(value);
                                    });
                                  }
                                },
                                onSaved: (value) {
                                  if (value!.isNotEmpty) {
                                    todate1 = DateTime.parse(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3375e0),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: RawMaterialButton(
                          onPressed: () {
                            setState(() {
                              data.remove(data);
                            });
                            _loadStaffWiseData();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
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
          ),
        );
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

  void _dialogue(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: const Text(
            'You have no permission to access the feature please contact the support team',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Report'),
        backgroundColor: const Color.fromARGB(255, 41, 137, 216),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffWise == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildCategoryWiseReport(),
                      const SizedBox(height: 20),
                      _buildStaffWiseReport(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCategoryWiseReport() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 2.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text(
                      'Category Wise Report',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    viewLeadCategoryPermission == 'true'
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewLeadCategory(
                                    widget.token,
                                    false, // createLeadCategory1
                                    false, // updateLeadCategory1
                                    false, // deleteLeadCategory1
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.settings,
                              color: Colors.blue.shade800,
                              size: 15,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                InkWell(
                  onTap: _showDateFilterDialog,
                  child: Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              'From ${DateFormat("dd-MM-yyyy").format(DateTime.parse(fromdate1))} To ${DateFormat("dd-MM-yyyy").format(todate1)}',
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1.0,
          ),
          const SizedBox(height: 10),
          data.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: PieChart(
                    dataMap: data,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 20,
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    colorList: _colors,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 25,
                    centerText: "Total",
                    centerTextStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    legendOptions: const LegendOptions(
                      legendShape: BoxShape.rectangle,
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: false,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: true,
                      decimalPlaces: 1,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/nodatafound.png',
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                    const Text(
                      'Result Not Found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Whoops... this information is \n not available for a moment',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
          const SizedBox(height: 10),
          const Divider(),
          data.isNotEmpty ? _buildCategoryTable() : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildCategoryTable() {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(10),
            1: FlexColumnWidth(5),
            2: FlexColumnWidth(5),
            3: FlexColumnWidth(5),
            4: FlexColumnWidth(5),
            5: FlexColumnWidth(5),
          },
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      'New',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      'Followup',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      'Closed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            for (int i = 0; i < staffWise!.data!.categoryLeads!.length; i++)
              TableRow(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 0, bottom: 10, left: 10),
                    child: Text(
                      staffWise!.data!.categoryLeads![i].categoryName
                          .toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // or any color you like
                      ),
                    ),
                  ),
                  _buildCategoryCell(i, 'newCount', '1', 'New Leads'),
                  _buildCategoryCell(i, 'pendingCount', '2', 'Pending Leads'),
                  _buildCategoryCell(i, 'followupCount', '3', 'Followup Leads'),
                  _buildCategoryCell(i, 'rejectedCount', '4', 'Rejected Leads'),
                  _buildCategoryCell(i, 'confirmedCount', '5', 'Closed Leads'),
                ],
              ),
          ],
        ),
        const Divider(endIndent: 8, indent: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(10),
              1: FlexColumnWidth(5),
              2: FlexColumnWidth(5),
              3: FlexColumnWidth(5),
              4: FlexColumnWidth(5),
              5: FlexColumnWidth(5),
            },
            children: [
              TableRow(
                children: [
                  const Center(
                    child: Text(
                      "Total Leads",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTotalCell('1', 'New Leads', catNew.toString()),
                  _buildTotalCell('2', 'Pending Leads', catPending.toString()),
                  _buildTotalCell(
                      '3', 'Followup Leads', catFollowup.toString()),
                  _buildTotalCell(
                      '4', 'Rejected Leads', catRejected.toString()),
                  _buildTotalCell('5', 'Closed Leads', catClosed.toString()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCell(
      int index, String field, String statusId, String pageName) {
    return InkWell(
      onTap: () {
        if (widget.viewLeadPermission != 'true') {
          _dialogue(context, 'View Leads');
          return;
        }

        Common.saveSharedPref("statusWise", 'yes');
        Common.saveSharedPref("statusWisId", statusId);
        Common.saveSharedPref("type", 'category');
        Common.saveSharedPref("statusCatId",
            staffWise!.data!.categoryLeads![index].categoryid.toString());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLeads(
              widget.token,
              widget.updateLeadPermission1,
              widget.deleteLeadPermission1,
              widget.cloudCallPermission1,
              pageName: pageName,
              fromDate: fromdate1.toString(),
              toDate: todate1.toString(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10),
        child: Center(
          child: Text(
            _getCategoryFieldValue(index, field),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: field == 'rejectedCount' ? Colors.red : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryFieldValue(int index, String field) {
    switch (field) {
      case 'newCount':
        return staffWise!.data!.categoryLeads![index].newCount.toString();
      case 'pendingCount':
        return staffWise!.data!.categoryLeads![index].pendingCount.toString();
      case 'followupCount':
        return staffWise!.data!.categoryLeads![index].followupCount.toString();
      case 'rejectedCount':
        return staffWise!.data!.categoryLeads![index].rejectedCount.toString();
      case 'confirmedCount':
        return staffWise!.data!.categoryLeads![index].confirmedCount.toString();
      default:
        return '0';
    }
  }

  Widget _buildTotalCell(String statusId, String pageName, String value) {
    return InkWell(
      onTap: () {
        if (widget.viewLeadPermission != 'true') {
          _dialogue(context, 'View Leads');
          return;
        }

        Common.saveSharedPref("statusWise", 'yes');
        Common.saveSharedPref("statusWisId", statusId);
        Common.saveSharedPref("type", 'category');
        Common.saveSharedPref("statusCatId", "-1");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLeads(
              widget.token,
              widget.updateLeadPermission1,
              widget.deleteLeadPermission1,
              widget.cloudCallPermission1,
              pageName: pageName,
              fromDate: fromdate1.toString(),
              toDate: todate1.toString(),
            ),
          ),
        );
      },
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: statusId == '4' ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffWiseReport() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 2.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Text(
                  'Staff Wise Report',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              'From ${DateFormat("dd-MM-yyyy").format(DateTime.parse(fromdate1))} To ${DateFormat("dd-MM-yyyy").format(todate1)}',
            ),
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1.0,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0;
                        i < staffWise!.data!.staffLeads!.length;
                        i++)
                      Expanded(
                        flex: staffWise!.data!.staffLeads![i].staffPercentage!,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: _getStaffProgressBarRadius(i),
                            color: Colors.green,
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
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
          const SizedBox(height: 10),

          // Staff Table
          _buildStaffTable(),
          const Divider(endIndent: 8, indent: 8),

          // Staff Totals
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 12.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(10),
                1: FlexColumnWidth(5),
                2: FlexColumnWidth(5),
                3: FlexColumnWidth(5),
                4: FlexColumnWidth(5),
                5: FlexColumnWidth(5),
              },
              children: [
                TableRow(
                  children: [
                    const Center(
                      child: Text(
                        "Total Leads",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStaffTotalCell('1', 'New Leads', stfNew.toString()),
                    _buildStaffTotalCell(
                        '2', 'Pending Leads', stfPending.toString()),
                    _buildStaffTotalCell(
                        '3', 'Followup Leads', stfFollowup.toString()),
                    _buildStaffTotalCell(
                        '4', 'Rejected Leads', stfRejected.toString()),
                    _buildStaffTotalCell(
                        '5', 'Closed Leads', stfClosed.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius _getStaffProgressBarRadius(int index) {
    if (staffWise!.data!.staffLeads!.length == 1) {
      return const BorderRadius.only(
        topLeft: Radius.circular(5),
        bottomLeft: Radius.circular(5),
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
      );
    } else if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(5),
        bottomLeft: Radius.circular(5),
      );
    } else if (index == staffWise!.data!.staffLeads!.length - 1) {
      return const BorderRadius.only(
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
      );
    } else {
      return BorderRadius.circular(0);
    }
  }

  Widget _buildStaffTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(10),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(5),
        3: FlexColumnWidth(5),
        4: FlexColumnWidth(5),
        5: FlexColumnWidth(5),
      },
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  "",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'New',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Followup',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Rejected',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Closed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        for (int j = 0; j < staffWise!.data!.staffLeads!.length; j++)
          TableRow(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StaffDashboard(
                        widget.token,
                        staffWise!.data!.staffLeads![j].staffId.toString(),
                        staffWise!.data!.staffLeads![j].staffName.toString(),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 10, left: 15),
                  child: Text(
                    staffWise!.data!.staffLeads![j].staffName.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // or any color you like
                    ),
                  ),
                ),
              ),
              _buildStaffCell(j, 'newCount', '1', 'New Leads'),
              _buildStaffCell(j, 'pendingCount', '2', 'Pending Leads'),
              _buildStaffCell(j, 'followupCount', '3', 'Followup Leads'),
              _buildStaffCell(j, 'rejectedCount', '4', 'Rejected Leads'),
              _buildStaffCell(j, 'confirmedCount', '5', 'Closed Leads'),
            ],
          ),
      ],
    );
  }

  Widget _buildStaffCell(
      int index, String field, String statusId, String pageName) {
    return InkWell(
      onTap: () {
        if (widget.viewLeadPermission != 'true') {
          _dialogue(context, 'View Leads');
          return;
        }

        Common.saveSharedPref("statusWise", 'yes');
        Common.saveSharedPref("statusWisId", statusId);
        Common.saveSharedPref("type", 'staff');
        Common.saveSharedPref("statusCatId",
            staffWise!.data!.staffLeads![index].staffId.toString());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLeads(
              widget.token,
              widget.updateLeadPermission1,
              widget.deleteLeadPermission1,
              widget.cloudCallPermission1,
              pageName: pageName,
              fromDate: fromdate1.toString(),
              toDate: todate1.toString(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10),
        child: Center(
          child: Text(
            _getStaffFieldValue(index, field),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: field == 'rejectedCount' ? Colors.red : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _getStaffFieldValue(int index, String field) {
    switch (field) {
      case 'newCount':
        return staffWise!.data!.staffLeads![index].newCount.toString();
      case 'pendingCount':
        return staffWise!.data!.staffLeads![index].pendingCount.toString();
      case 'followupCount':
        return staffWise!.data!.staffLeads![index].followupCount.toString();
      case 'rejectedCount':
        return staffWise!.data!.staffLeads![index].rejectedCount.toString();
      case 'confirmedCount':
        return staffWise!.data!.staffLeads![index].confirmedCount.toString();
      default:
        return '0';
    }
  }

  Widget _buildStaffTotalCell(String statusId, String pageName, String value) {
    return InkWell(
      onTap: () {
        if (widget.viewLeadPermission != 'true') {
          _dialogue(context, 'View Leads');
          return;
        }

        Common.saveSharedPref("statusWise", 'yes');
        Common.saveSharedPref("statusWisId", statusId);
        Common.saveSharedPref("type", 'staff');
        Common.saveSharedPref("statusCatId", "-1");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLeads(
              widget.token,
              widget.updateLeadPermission1,
              widget.deleteLeadPermission1,
              widget.cloudCallPermission1,
              pageName: pageName,
              fromDate: fromdate1.toString(),
              toDate: todate1.toString(),
            ),
          ),
        );
      },
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: statusId == '4' ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}
