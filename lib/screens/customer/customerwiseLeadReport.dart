import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/customers/customerLeadModel.dart';
import 'package:login2/models/lead_management/cloudCallModel.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:login2/service/service.dart';
import 'package:lottie/lottie.dart';

class CustomerLeadsPage extends StatefulWidget {
  final String custId;
  final String? customerName;

  const CustomerLeadsPage({
    Key? key,
    required this.custId,
    this.customerName,
  }) : super(key: key);

  @override
  _CustomerLeadsPageState createState() => _CustomerLeadsPageState();
}

class _CustomerLeadsPageState extends State<CustomerLeadsPage> {
  GetCustomerLeadsModel? _leadsData;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String cloudCallPermission = "false";
  String updateLeadPermission = "false";
  String deleteLeadPermission = "false";

  final List<Color> _colors = [
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
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

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _fetchCustomerLeads();
  }

  Future<void> _loadPermissions() async {
    cloudCallPermission =
        await Common.getSharedPref("cloudCallPermission") ?? "false";
    updateLeadPermission =
        await Common.getSharedPref("updateLeadPermission") ?? "false";
    deleteLeadPermission =
        await Common.getSharedPref("deleteLeadPermission") ?? "false";
  }

  Future<void> _fetchCustomerLeads() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await HttpService.getCustomerLeads(widget.custId);

      if (response != null && response.status == true) {
        setState(() {
          _leadsData = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response?.message ?? "Failed to load leads";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.customerName != null && widget.customerName!.isNotEmpty)
              Text(
                widget.customerName!,
                //  "Customer Leads",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            SizedBox(height: 5),
            if (widget.customerName != null && widget.customerName!.isNotEmpty)
              Text(
                // widget.customerName!,
                "Customer Leads",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchCustomerLeads,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset('assets/icons/noNetwork.jpg'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: _fetchCustomerLeads,
              child: Container(
                width: 120,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_leadsData?.data == null || _leadsData!.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset("assets/icons/nodatafound.png"),
            ),
            Text(
              'No Data Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _leadsData!.data!.length,
      itemBuilder: (context, index) {
        return leadListWidget(context, index);
      },
    );
  }

  Padding leadListWidget(BuildContext context, int index) {
    final lead = _leadsData!.data![index];
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final token = await Common.getSharedPref("token") ?? "";
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadDetails(
                token,
                updateLeadPermission == "true",
                deleteLeadPermission == "true",
                cloudCallPermission == "true",
                lead.callMasterId ?? "",
                pageName: "",
              ),
            ),
          );
        },
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: lead.isSelected == false
                ? Colors.grey.shade100
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
                    // Header row with priority, name, and category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Priority indicator
                              if (lead.priority == '1')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (lead.priority == '2')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (lead.priority == '3')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (lead.priority == '4')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              // Client name
                              Expanded(
                                child: Text(
                                  lead.clientName?.toString() ?? "Unknown",
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: lead.priority == "4"
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationThickness: 1.5,
                                    decorationColor: Colors.red,
                                    color: lead.isCustomer == true
                                        ? Colors.green
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Category count and lead category
                        Row(
                          children: [
                            // Category count
                            Visibility(
                              visible: lead.categoryCount?.toString() != "1" &&
                                  lead.categoryCount?.toString() != "",
                              child: Container(
                                height: 20,
                                width: 20,
                                margin: EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    lead.categoryCount?.toString() ?? "",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            // Lead category
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 2,
                                  bottom: 2,
                                ),
                                child: Text(
                                  lead.leadCategory?.toString() ?? "",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Phone number and staff info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Phone number
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  lead.contactNumber1?.toString() ?? "N/A",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              // Assigned to and call result
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Assigned: ${lead.staffName ?? "Unassigned"}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _colors[lead.callResultId ?? 0],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      lead.callResult?.toString() ??
                                          "No Result",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Date information
                              lead.callResultId == 1
                                  ? Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFd5f5f4),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/calendar.png",
                                            width: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Created Time',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                lead.createdDate?.toString() ??
                                                    "N/A",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFd5f5f4),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/calendar.png",
                                                  width: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Called Date',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      lead.isCalled == false
                                                          ? '--'
                                                          : lead.calledDate
                                                                  ?.toString() ??
                                                              "N/A",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFd5f5f4),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/calendar.png",
                                                  width: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Followup Date',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      lead.scheduledDate
                                                              ?.toString() ??
                                                          "N/A",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                            ],
                          ),
                        ),

                        // Profile picture and call button
                        SizedBox(
                          width: 70,
                          child: Column(
                            children: [
                              // Profile picture
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 3,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      lead.profilePic?.isNotEmpty == true
                                          ? lead.profilePic!
                                          : "https://s2.login2.in/images/staff_images/thumb/default.png",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Call button
                              InkWell(
                                onTap: () async {
                                  if (lead.contactNumber1?.isEmpty == true) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Alert !!!'),
                                          content: const Text(
                                              'No contact number available'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    if (cloudCallPermission == "true") {
                                      _chooseCallDialog(context, lead);
                                    } else {
                                      Common.dialPad(lead.contactNumber1!);
                                    }
                                  }
                                },
                                child: Container(
                                  width: 60,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.call,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Call',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseCallDialog(
      BuildContext context, CustomerLeadData lead) async {
    final token = await Common.getSharedPref("token") ?? "";

    showDialog(
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
                    token,
                    lead.callMasterId ?? "",
                    lead.contactNumber1 ?? "",
                  );

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
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.cloud_circle_rounded,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'Cloud Call',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  Common.dialPad(lead.contactNumber1!);
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
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.call,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'Phone Call',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
