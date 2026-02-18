// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/customerListModel.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/profit_and_loss_model.dart';
import 'package:login2/models/expense/targetGroupModel.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/addInvoiceUpdated.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/screens/accounts/expense/expense_list.dart';
import 'package:login2/screens/accounts/expense/advance&expense.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/sidebarscreens/accountsSidebarScreen.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:shimmer/shimmer.dart';

class AccountsDashboardNew extends StatefulWidget {
  String token;

  AccountsDashboardNew({super.key, required this.token});
  @override
  State<AccountsDashboardNew> createState() => _AccountsDashboardNewState();
}

class _AccountsDashboardNewState extends State<AccountsDashboardNew> {
  bool result = true;
  bool isLoading = true;
  String token = '';
  String name = '';
  String userId = '';
  String staffId = '';
  bool isExpired = false;
  bool loadmore = false;
  String startAndStopWorkPermission = '';
  Offset _floatingButtonPosition = Offset.zero;
  bool _showFloatingOptions = false;
  TextEditingController search = TextEditingController();
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  String customerName = "Choose Customer";
  String customerId = "";
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String role = '';
  String phoneCallLogPermission = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? proformaInvoiceMenu;
  String? gstInvoiceMenu;
  String? pendingInvoiceMenu;
  String? receiptMenu;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  LeadDashboardModel? leadDashboard;
  DashboardModel? userDashboard;
  CommonConfigureModel? configure;
  AccountDashboardModel? dashboard;
  String? firebaseToken;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  bool toggle = false;
  int notificationCount = 0;
  List<TargetGroupAll> companyTargets = [];
  bool isLoadingTargets = false;
  DateTime targetFromDate = DateTime.now();
  DateTime targetToDate = DateTime.now();
  ProfitLossItem? dashboardProfitLoss;
  bool isDashboardPLLoading = false;

  List<dynamic> get list => [
        "Invoices",
        "Pending Invoices",
        "Receipts",
        "Expense",
        "Customers",
        "Account Head",
        if (proformaInvoiceMenu == "true") "Proforma Invoices",
        if (gstInvoiceMenu == "true") "GST Invoices",
      ];
  List<dynamic> get tabColors => [
        Colors.green,
        Colors.orange,
        Colors.blue,
        Colors.red,
        Colors.teal,
        Colors.purple,
        if (proformaInvoiceMenu == "true")
          const Color.fromARGB(255, 111, 27, 207),
        if (gstInvoiceMenu == "true") const Color.fromARGB(255, 228, 43, 235),
      ];

  Future<void> _fetchDashboardProfitLoss() async {
    setState(() => isDashboardPLLoading = true);
    try {
      final now = DateTime.now();
      String month = DateFormat('MM').format(now);
      String year = now.year.toString();

      final response = await HttpService().getProfitOrLose(month, year);
      if (mounted) {
        if (response != null &&
            response.data != null &&
            response.data!.list != null &&
            response.data!.list!.isNotEmpty) {
          setState(() {
            dashboardProfitLoss = response.data!.list!.first;
            isDashboardPLLoading = false;
          });
        } else {
          setState(() {
            dashboardProfitLoss = null;
            isDashboardPLLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isDashboardPLLoading = false);
    }
  }

  getData() async {
    token = await Common.getSharedPref("token") ?? "";
    final connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     result = true;
    //   });
    // } else {
    //   setState(() {
    //     result = false;
    //   });
    // }
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }
    proformaInvoiceMenu =
        await Common.getSharedPref("proformaInvoiceMenu") ?? "";
    gstInvoiceMenu = await Common.getSharedPref("gstInvoiceMenu") ?? "";
    pendingInvoiceMenu = await Common.getSharedPref("pendingInvoiceMenu") ?? "";
    receiptMenu = await Common.getSharedPref("receiptMenu") ?? "";
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission") ?? "";
    getList();
    getCustomerList();
    getCompanyTargets();
    await Permission.notification.request();
    firebaseToken = await FirebaseMessaging.instance.getToken();
    LoginCheckModel? loginCheck =
        await HttpService.loginCheck(token, firebaseToken!);
    log(firebaseToken.toString());
    if (loginCheck!.data == false) {
      Common.toastMessaage('Token Expired', Colors.red);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
    }
    configure = await HttpService.configure(token);

    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");

    role = await Common.getSharedPref("role");
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    leadDashboard = await HttpService.leadDashboard(
        token, fromdate, todate, fromdate1, todate1);
    userDashboard = await HttpService.mainDashboard(token);
    Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);
    setState(() {
      notificationCount = leadDashboard!.data.unreadNotification;
    });
    configure = await HttpService.configure(token);
    if (configure != null) {
      isExpired = configure!.data!.isExpired!;
      setState(() {});
    }
  }

  getList() async {
    String tog = await Common.getSharedPref("acc_toggle") ?? "";
    toggle = tog == "true" ? true : false;
    dashboard = await HttpService.accountsDashboard(fDate, tDate);
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

  getCustomerList() async {
    try {
      CustomerListModel? customerData =
          await HttpService.customerList(widget.token);
      if (customerData != null && customerData.status == true) {
        setState(() {
          customers = customerData.data ?? [];
          filteredCustomers = List.from(customers);
        });
      }
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  Future<void> getCompanyTargets() async {
    setState(() => isLoadingTargets = true);

    final now = DateTime.now();
    targetFromDate = DateTime(now.year, now.month, 1);
    targetToDate = now;

    final fromStr = targetFromDate.toIso8601String().split('T').first;
    final toStr = targetToDate.toIso8601String().split('T').first;

    final result = await HttpService.getAllTargetReport(fromStr, toStr);
    if (result != null && result.status) {
      setState(() {
        companyTargets = List<TargetGroupAll>.from(result.data)
            .where((report) => report.isCompany == "1")
            .toList();
        isLoadingTargets = false;
      });
    } else {
      setState(() {
        companyTargets = [];
        isLoadingTargets = false;
      });
    }
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  double _calculateProgress(String target, String achieved) {
    final targetAmount = _parseAmount(target);
    final achievedAmount = _parseAmount(achieved);
    if (targetAmount <= 0) return 0.0;
    return (achievedAmount / targetAmount).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    getData();
    _fetchDashboardProfitLoss();
    _initializeFloatingButtonPosition();
    super.initState();
  }

  void _initializeFloatingButtonPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _floatingButtonPosition = Offset(screenWidth - 130, 400);
      });
    });
  }

  Future<Object?> addInvoiceDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Customer  Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: search,
                                        autocorrect: false,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        autofocus: true,
                                        onChanged: (value) {
                                          setState(() {
                                            filteredCustomers = customers
                                                .where((item) => item.name!
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
                                                .toList();
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(8),
                                          hintText: 'Search',
                                          prefixIcon: Icon(Icons.search),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      child: ListView.builder(
                                        itemCount: filteredCustomers.length,
                                        physics: const ScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              onTap: () {
                                                customerName =
                                                    filteredCustomers[index]
                                                        .name!;
                                                customerId =
                                                    filteredCustomers[index]
                                                        .id!;
                                                search.clear();
                                                filteredCustomers =
                                                    List.from(customers);
                                                setState(() {});
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              title: Text(
                                                  filteredCustomers[index]
                                                      .name!));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        search.clear();
                                        filteredCustomers =
                                            List.from(customers);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Close")),
                                ],
                              );
                            });
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    customerName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (customerId == '') {
                          Common.toastMessaage('Choose Client', Colors.red);
                        } else {
                          search.clear();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddInvoice(widget.token, customerId, "")),
                          ).then((_) {
                            getData();
                          });
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 25, right: 25),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

  void _updateFloatingButtonPosition(Offset newPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double x = newPosition.dx.clamp(0.0, screenWidth - 80);
    double y = newPosition.dy.clamp(0.0, screenHeight - 80);

    setState(() {
      _floatingButtonPosition = Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return result == true
        ? Scaffold(
            key: _scaffoldKey,
            appBar: appBarWidget(context, "lead"),
            body: isLoading == true
                ? buildLoaderListItem()
                : RefreshIndicator(
                    onRefresh: () async {
                      getData();
                      getCompanyTargets();
                    },
                    child: Stack(
                      children: [
                        SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Company Targets",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          // IconButton(
                                          //   icon: Icon(Icons.add,
                                          //       color: Color(0xFF2a86c9)),
                                          //   onPressed: () {
                                          //     Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             const SetTargetPage(),
                                          //       ),
                                          //     ).then((_) {
                                          //       getCompanyTargets();
                                          //     });
                                          //   },
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(height: 9),
                                      isLoadingTargets
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                  color: Color(0xFF2a86c9)))
                                          : companyTargets.isEmpty
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "No company targets set",
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: companyTargets
                                                      .map((target) =>
                                                          _buildTargetCard(
                                                              target))
                                                      .toList(),
                                                ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Quick Overview",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.3,
                                    children: [
                                      _buildModernCard(
                                        title: "Bank Account",
                                        value:
                                            dashboard?.data.bankAccount ?? "₹0",
                                        icon: Icons.account_balance,
                                        color: Colors.blue,
                                        onTap: () {
                                          if (dashboard?.data.bankAccCount ==
                                              "1") {
                                            if (dashboard?.data.isViewBankAcc ==
                                                true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BankAccount(
                                                    accId: dashboard!
                                                        .data.bankAccountId,
                                                    accName: dashboard!
                                                        .data.bankAccountName,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Common.toastMessaage(
                                                  "No permission", Colors.red);
                                            }
                                          } else if (dashboard
                                                  ?.data.bankAccCount ==
                                              "0") {
                                            Common.toastMessaage(
                                                "Please add a 'BANK ACCOUNT'",
                                                Colors.red);
                                          } else {
                                            if (dashboard!.data.isViewBankAcc) {
                                              if (dashboard!
                                                  .data.isViewPendingExpense) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PendingExpense(
                                                        status: "1",
                                                      ),
                                                    ));
                                              } else {
                                                Common.toastMessaage(
                                                    "No permission",
                                                    Colors.red);
                                              }
                                            } else {}
                                          }
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Pending Expense",
                                        value: dashboard?.data.pendingExpense ??
                                            "₹0",
                                        icon: Icons.pending_actions,
                                        color: Colors.orange,
                                        onTap: () {
                                          if (dashboard
                                                  ?.data.isViewPendingExpense ==
                                              true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PendingExpense(
                                                  status: "2",
                                                ),
                                              ),
                                            );
                                          } else {
                                            Common.toastMessaage(
                                                "No permission", Colors.red);
                                          }
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Today's Income",
                                        value: dashboard?.data.todaysIncome ??
                                            "₹0",
                                        icon: Icons.trending_up,
                                        color: Colors.green,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReceiptList(
                                                widget.token,
                                                fdate: DateFormat('dd-MM-yyyy')
                                                    .format(DateTime.now()),
                                                tdate: DateFormat('dd-MM-yyyy')
                                                    .format(DateTime.now()),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Today's Expense",
                                        value: dashboard?.data.todayExpense ??
                                            "₹0",
                                        icon: Icons.trending_down,
                                        color: Colors.red,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ExpenseList(
                                                fdate: DateFormat('yyyy-MM-dd')
                                                    .format(DateTime.now()),
                                                tdate: DateFormat('yyyy-MM-dd')
                                                    .format(DateTime.now()),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Month Income",
                                        value: dashboard?.data.monthlyIncome ??
                                            "₹0",
                                        icon: Icons.calendar_today,
                                        color: Colors.purple,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReceiptList(
                                                widget.token,
                                                fdate: DateFormat('dd-MM-yyyy')
                                                    .format(DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        1)),
                                                tdate: DateFormat('dd-MM-yyyy')
                                                    .format(DateTime.now()),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Month Expense",
                                        value: dashboard?.data.monthlyExpense ??
                                            "₹0",
                                        icon: Icons.calendar_month,
                                        color: Colors.amber,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ExpenseList(
                                                fdate: DateFormat('yyyy-MM-dd')
                                                    .format(DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        1)),
                                                tdate: DateFormat('yyyy-MM-dd')
                                                    .format(DateTime.now()),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Pending Invoice",
                                        value: dashboard?.data.pendingIncome ??
                                            "₹0",
                                        icon: Icons.receipt_long,
                                        color: Colors.deepOrange,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PendingInvoice(widget.token),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildModernCard(
                                        title: "Advance Amount",
                                        value: dashboard?.data.advanceAmount ??
                                            "₹0",
                                        icon: Icons.account_balance_wallet,
                                        color: Colors.teal,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PendingExpense(
                                                status: "3",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 18),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Profit Or Loss",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2a86c9)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "This Month",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF2a86c9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: GestureDetector(
                                    onTap: () => _showProfitLossPopup(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            // In your build method, replace the profit/loss section with this:
                                            if (isDashboardPLLoading)
                                              const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              )
                                            else if (dashboardProfitLoss !=
                                                null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: _isProfit(
                                                          dashboardProfitLoss!)
                                                      ? const Color(0xFF00C853)
                                                          .withOpacity(0.05)
                                                      : const Color(0xFFF44336)
                                                          .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _isProfit(
                                                            dashboardProfitLoss!)
                                                        ? const Color(
                                                                0xFF00C853)
                                                            .withOpacity(0.2)
                                                        : const Color(
                                                                0xFFF44336)
                                                            .withOpacity(0.2),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _isProfit(
                                                                    dashboardProfitLoss!)
                                                                ? const Color(
                                                                        0xFF00C853)
                                                                    .withOpacity(
                                                                        0.1)
                                                                : const Color(
                                                                        0xFFF44336)
                                                                    .withOpacity(
                                                                        0.1),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            _isProfit(
                                                                    dashboardProfitLoss!)
                                                                ? Icons
                                                                    .trending_up
                                                                : Icons
                                                                    .trending_down,
                                                            color: _isProfit(dashboardProfitLoss!)
                                                                ? const Color(
                                                                    0xFF00C853)
                                                                : const Color(
                                                                    0xFFF44336),
                                                            size: 24,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                          _isProfit(
                                                                  dashboardProfitLoss!)
                                                              ? "NET PROFIT"
                                                              : "NET LOSS",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: _isProfit(dashboardProfitLoss!)
                                                                ? const Color(
                                                                    0xFF00C853)
                                                                : const Color(
                                                                    0xFFF44336),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      "₹${_formatCurrency(dashboardProfitLoss!.profitLoss ?? '0')}",
                                                      style: TextStyle(
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: _isProfit(
                                                                dashboardProfitLoss!)
                                                            ? const Color(
                                                                0xFF00C853)
                                                            : const Color(
                                                                0xFFF44336),
                                                      ),
                                                    ),
                                                    // const SizedBox(height: 8),
                                                    // Text(
                                                    //   "${_isProfit(dashboardProfitLoss!) ? 'Profit' : 'Loss'} for ${dashboardProfitLoss!.month ?? _getCurrentMonth()} ${dashboardProfitLoss!.year ?? DateTime.now().year}",
                                                    //   style: const TextStyle(
                                                    //     fontSize: 12,
                                                    //     color: Colors.grey,
                                                    //     fontWeight:
                                                    //         FontWeight.w500,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "No data available",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            // const SizedBox(height: 12),
                                            // Container(
                                            //   width: double.infinity,
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           vertical: 12),
                                            //   decoration: BoxDecoration(
                                            //     color: const Color(0xFF2a86c9)
                                            //         .withOpacity(0.05),
                                            //     borderRadius:
                                            //         BorderRadius.circular(12),
                                            //     border: Border.all(
                                            //       color: const Color(0xFF2a86c9)
                                            //           .withOpacity(0.2),
                                            //       width: 1,
                                            //     ),
                                            //   ),
                                            //   child: Center(
                                            //     child: Row(
                                            //       mainAxisAlignment:
                                            //           MainAxisAlignment.center,
                                            //       children: [
                                            //         Text(
                                            //           "View Full Report",
                                            //           style: TextStyle(
                                            //             fontSize: 14,
                                            //             fontWeight:
                                            //                 FontWeight.w600,
                                            //             color: const Color(
                                            //                 0xFF2a86c9),
                                            //           ),
                                            //         ),
                                            //         const SizedBox(width: 8),
                                            //         Icon(
                                            //           Icons.chevron_right,
                                            //           size: 20,
                                            //           color: const Color(
                                            //               0xFF2a86c9),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Date Range",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final selectedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          1),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime.now(),
                                                    );
                                                    if (selectedDate != null) {
                                                      fDate = DateFormat(
                                                              'dd-MM-yyyy')
                                                          .format(selectedDate);
                                                      getList();
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          fDate,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                            color: Colors.blue),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text("to",
                                                  style: TextStyle(
                                                      color: Colors.grey[600])),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final selectedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (selectedDate != null) {
                                                      tDate = DateFormat(
                                                              'dd-MM-yyyy')
                                                          .format(selectedDate);
                                                      getList();
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          tDate,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                            color: Colors.blue),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          if (dashboard != null &&
                                              dashboard!
                                                  .data.incomeGraph.isNotEmpty)
                                            _buildChartSection(
                                              title: "Income Breakdown",
                                              data: dashboard!.data.incomeGraph,
                                              isIncome: true,
                                            ),
                                          const SizedBox(height: 16),
                                          if (dashboard != null &&
                                              dashboard!
                                                  .data.expenseGraph.isNotEmpty)
                                            _buildChartSection(
                                              title: "Expense Breakdown",
                                              data:
                                                  dashboard!.data.expenseGraph,
                                              isIncome: false,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: _floatingButtonPosition.dx == 0 ? 30 : null,
                          bottom: _floatingButtonPosition.dy == 0 ? 100 : null,
                          left: _floatingButtonPosition.dx != 0
                              ? _floatingButtonPosition.dx
                              : null,
                          top: _floatingButtonPosition.dy != 0
                              ? _floatingButtonPosition.dy
                              : null,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final newPosition = Offset(
                                _floatingButtonPosition.dx + details.delta.dx,
                                _floatingButtonPosition.dy + details.delta.dy,
                              );
                              _updateFloatingButtonPosition(newPosition);
                            },
                            child: Column(
                              children: [
                                if (_showFloatingOptions) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: SizedBox(
                                              width: 130,
                                              child:
                                                  FloatingActionButton.extended(
                                                heroTag: "simple_invoice",
                                                onPressed: () {
                                                  setState(() {
                                                    _showFloatingOptions =
                                                        false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddInvoiceUpdated(
                                                        widget.token,
                                                        "",
                                                        "",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                label: const Text(
                                                  'Sale',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.receipt,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: SizedBox(
                                              width: 130,
                                              child:
                                                  FloatingActionButton.extended(
                                                heroTag: "complex_invoice",
                                                onPressed: () {
                                                  setState(() {
                                                    _showFloatingOptions =
                                                        false;
                                                  });
                                                  addInvoiceDialog(context);
                                                },
                                                label: const Text(
                                                  'Invoice',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.description,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                backgroundColor: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                                FloatingActionButton(
                                  heroTag: "main_floating_button",
                                  onPressed: () {
                                    setState(() {
                                      _showFloatingOptions =
                                          !_showFloatingOptions;
                                    });
                                  },
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: _showFloatingOptions
                                        ? Icon(Icons.close, color: Colors.white)
                                        : Icon(Icons.add, color: Colors.white),
                                  ),
                                  backgroundColor: _showFloatingOptions
                                      ? Colors.red
                                      : Color(0xFF2a86c9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            endDrawer: DraweScreen(token),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                ProjectDashboardPermission == "true"
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectDashboard()),
                      )
                    : AccountsDashboardPermission == "true"
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AccountsDashboardNew(token: token)),
                          )
                        : MenuDashboard == "true"
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(token)),
                              )
                            : RenewalDashboardPermission == "true"
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RenewalDashboard()),
                                  )
                                : Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Dashboard(token)),
                                  );
              },
              child: Image.asset("assets/icons/menu.png", width: 25),
            ),
            bottomNavigationBar: configure != null
                ? BottomNavigation(
                    token,
                    phoneCallLogPermission: phoneCallLogPermission,
                    name: name,
                    userId: userId,
                  )
                : const SizedBox(),
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

  Widget _buildTargetCard(TargetGroupAll target) {
    final progress =
        _calculateProgress(target.targetAmount, target.totalAchieved);
    final progressPercent = (progress * 100).toStringAsFixed(1);
    final targetAmount = _parseAmount(target.targetAmount);
    final achievedAmount = _parseAmount(target.totalAchieved);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.business, color: Colors.blue[700], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.groupName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (target.staffName.isNotEmpty)
                        Text(
                          "Managed by: ${target.staffName}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? Colors.green[50]
                        : progress >= 0.7
                            ? Colors.blue[50]
                            : progress >= 0.4
                                ? Colors.orange[50]
                                : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: progress >= 1.0
                          ? Colors.green
                          : progress >= 0.7
                              ? Colors.blue
                              : progress >= 0.4
                                  ? Colors.orange
                                  : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "$progressPercent%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: progress >= 1.0
                          ? Colors.green[700]
                          : progress >= 0.7
                              ? Colors.blue[700]
                              : progress >= 0.4
                                  ? Colors.orange[700]
                                  : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? Colors.green
                      : progress >= 0.7
                          ? Colors.blue
                          : progress >= 0.4
                              ? Colors.orange
                              : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTargetStat(
                  "Target",
                  "₹${NumberFormat("#,##0").format(targetAmount)}",
                  Colors.blue[700]!,
                ),
                _buildTargetStat(
                  "Achieved",
                  "₹${NumberFormat("#,##0").format(achievedAmount)}",
                  Colors.green[700]!,
                ),
                _buildTargetStat(
                  "Remaining",
                  "₹${NumberFormat("#,##0").format(targetAmount - achievedAmount)}",
                  Colors.orange[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCardNew({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required List<dynamic> data,
    required bool isIncome,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...data.map((item) {
          double value = double.parse(item.perc);
          return GestureDetector(
            onTap: () {
              if (isIncome) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptList(
                      widget.token.toString(),
                      type: item.type,
                      fdate: fDate,
                      tdate: tDate,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseList(
                      catId: item.expCatid,
                      catName: item.expCatName,
                      fdate: convertDate(fDate),
                      tdate: convertDate(tDate),
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isIncome ? item.category : item.expCatName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              item.totalExpense,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isIncome
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFF44336),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${value.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String convertDate(String date) {
    final inputFormat = DateFormat('dd-MM-yyyy');
    final outputFormat = DateFormat('yyyy-MM-dd');
    final parsedDate = inputFormat.parse(date);
    return outputFormat.format(parsedDate);
  }

  PreferredSizeWidget appBarWidget(BuildContext context, String type) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: EdgeInsets.only(
              left: 20, top: type == "lead" ? 55 : 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        final result = await HttpService.getWorkStatus();
                        if (result != null && result.data.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout Blocked'),
                              content: const Text(
                                  'Work is in progress. Please close all work before logging out.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          logout(context);
                        }
                      } catch (e) {
                        print('Error checking work status: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to check work status')),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.grey.shade800,
                              offset: const Offset(0, 2.0),
                            )
                          ],
                          shape: BoxShape.circle,
                          color: const Color(0xFF2191ce)),
                      child: userDashboard != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                userDashboard!.data.profilePic,
                              ),
                            )
                          : Shimmer.fromColors(
                              enabled: true,
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const CircleAvatar()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  userDashboard != null && startAndStopWorkPermission == "true"
                      ? StartStopToggle(
                          initialStatus: userDashboard!.data.loginCheck,
                          onToggle: (bool started) {
                            setState(() {
                              userDashboard!.data.loginCheck = started;
                            });
                          },
                          setDashboardLoading: (bool loading) {
                            setState(() {
                              isLoading = loading;
                            });
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () async {
                      var status = await Permission.notification.status;
                      if (status.isPermanentlyDenied) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Permission Required'),
                            content: const Text(
                                'Notification permission is permanently denied. Please enable it in settings to receive updates.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  AppSettings.openAppSettings(
                                      type: AppSettingsType.notification);
                                },
                                child: const Text('Open Settings'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        await Permission.notification.request();
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage(
                                token,
                                createLeadCategory1,
                                updateLeadCategory1,
                                deleteLeadCategory1)),
                      ).then((r) {
                        getData();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Stack(
                        children: [
                          Image.asset("assets/icons/notification.png",
                              width: 20, color: Colors.white),
                          notificationCount > 0
                              ? Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                  AccountsMenuWidget(
                    token: widget.token!,
                    name: name,
                    userId: userId,
                    staffId: staffId,
                    isExpired: isExpired,
                    configure: configure,
                    leadDashboard: leadDashboard,
                    fromdate: fromdate.toString(),
                    todate: todate.toString(),
                    loadmore: loadmore,
                    onDataRefresh: () {
                      getData();
                    },
                    onStaffwiseRefresh: getList,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfitLossPopup(BuildContext context) {
    String selectedMonth = _getCurrentMonth();
    int selectedYear = DateTime.now().year;

    showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          ProfitLossItem? currentItem;
          bool isLoading = true;
          bool isFirstLoad = true;

          return StatefulBuilder(builder: (context, setDialogState) {
            if (isFirstLoad) {
              isFirstLoad = false;
              Future.microtask(() async {
                setDialogState(() => isLoading = true);
                try {
                  String monthNum = selectedMonth;
                  try {
                    monthNum = DateFormat('MM')
                        .format(DateFormat('MMMM').parse(selectedMonth));
                  } catch (_) {}

                  final response = await HttpService()
                      .getProfitOrLose(monthNum, selectedYear.toString());
                  if (response != null &&
                      response.data != null &&
                      response.data!.list != null &&
                      response.data!.list!.isNotEmpty) {
                    setDialogState(() {
                      currentItem = response.data!.list!.first;
                      isLoading = false;
                    });
                  } else {
                    setDialogState(() {
                      currentItem = null;
                      isLoading = false;
                    });
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: LayoutBuilder(builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 500;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2a86c9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Profit and Loss Report",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 24),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a86c9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showMonthPicker(context, (month) {
                                      setDialogState(() {
                                        selectedMonth = month;
                                        isFirstLoad = true;
                                        isLoading = true;
                                      });
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(selectedMonth,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white)),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_drop_down,
                                              size: 18, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("-",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () =>
                                        _showYearPicker(context, (year) {
                                      setDialogState(() {
                                        selectedYear = year;
                                        isFirstLoad = true;
                                        isLoading = true;
                                      });
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(selectedYear.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white)),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_drop_down,
                                              size: 18, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                          child: Column(
                            children: [
                              _buildProfitLossContentFromModel(isSmallScreen,
                                  item: currentItem, isLoading: isLoading),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          });
        });
  }

  void _loadProfitLossData(String month, int year) {}

  void _showProfitLossPopupOld(BuildContext context) {
    String selectedMonth = _getCurrentMonth();
    int selectedYear = DateTime.now().year;
    final hasProfitLossData = dashboard?.data.profitAndLoss != null;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 500;
            final isMediumScreen = constraints.maxWidth < 700;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a86c9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Profit and Loss Report",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        //const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a86c9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _showMonthPicker(context, (month) {
                                  selectedMonth = month;
                                  _loadProfitLossData(month, selectedYear);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        selectedMonth,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "-",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showYearPicker(context, (year) {
                                  selectedYear = year;
                                  _loadProfitLossData(selectedMonth, year);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedYear.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                      child: Column(
                        children: [
                          // Show either real data from API or dummy data
                          if (hasProfitLossData)
                            _buildProfitLossContentFromModel(isSmallScreen)
                          else
                            _buildDefaultProfitLossContent(isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: SingleChildScrollView(
                  //     padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  //     child: Column(
                  //       children: [
                  //         // // Opening Balance at top
                  //         // _buildReportSection(
                  //         //   title: "Opening Balance",
                  //         //   value: "₹0.00",
                  //         //   valueColor: Colors.grey[800]!,
                  //         //   backgroundColor: Colors.grey[50]!,
                  //         //   isSmall: isSmallScreen,
                  //         // ),

                  //         // const SizedBox(height: 20),

                  //         Container(
                  //           padding: const EdgeInsets.all(12),
                  //           decoration: BoxDecoration(
                  //             color: const Color(0xFF00C853).withOpacity(0.05),
                  //             borderRadius: BorderRadius.circular(12),
                  //             border: Border.all(
                  //               color: const Color(0xFF00C853).withOpacity(0.3),
                  //               width: 2,
                  //             ),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               const Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Icon(
                  //                     Icons.trending_up,
                  //                     color: Color(0xFF00C853),
                  //                     size: 20,
                  //                   ),
                  //                   SizedBox(width: 4),
                  //                   Text(
                  //                     "PROFIT/LOSS",
                  //                     style: TextStyle(
                  //                       fontSize: 12,
                  //                       fontWeight: FontWeight.w800,
                  //                       color: Color(0xFF00C853),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //               const SizedBox(height: 6),
                  //               Text(
                  //                 "₹24,788.68",
                  //                 style: const TextStyle(
                  //                   fontSize: 18,
                  //                   fontWeight: FontWeight.w800,
                  //                   color: Color(0xFF00C853),
                  //                 ),
                  //                 textAlign: TextAlign.center,
                  //               ),
                  //               const SizedBox(height: 2),
                  //               const Text(
                  //                 "Net",
                  //                 style: TextStyle(
                  //                   fontSize: 10,
                  //                   color: Colors.grey,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(height: 20),
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: _buildCompactBalanceCard(
                  //                 title: "Opening Balance",
                  //                 value: "₹0.00",
                  //                 color: Colors.grey[800]!,
                  //                 icon: Icons.account_balance_outlined,
                  //                 isSmall: isSmallScreen,
                  //               ),
                  //             ),
                  //             SizedBox(width: isSmallScreen ? 8 : 12),
                  //             Expanded(
                  //               child: _buildCompactBalanceCard(
                  //                 title: "Closing Balance",
                  //                 value: "₹24,788.68",
                  //                 color: const Color(0xFF2a86c9),
                  //                 icon: Icons.account_balance_wallet_outlined,
                  //                 isSmall: isSmallScreen,
                  //               ),
                  //             ),
                  //           ],
                  //         ),

                  //         const SizedBox(height: 20),
                  //         _buildSmallScreenLayout(),

                  //         const SizedBox(height: 20),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showMonthPicker(
      BuildContext context, Function(String) onMonthSelected) async {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final currentMonth = _getCurrentMonth();
    final initialIndex = months.indexOf(currentMonth);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Month"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: months.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(months[index]),
                trailing: initialIndex == index
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onMonthSelected(months[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showYearPicker(
      BuildContext context, Function(int) onYearSelected) async {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Year"),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(years[index].toString()),
                trailing: currentYear == years[index]
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onYearSelected(years[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPettyCashSection(ProfitLossItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 242, 239).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 221, 213, 201).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  size: 18,
                  color: Color.fromARGB(255, 7, 7, 7),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "PETTY CASH",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpenseItem(
            label: "Petty Cash",
            value: "₹${_formatCurrency(item.pettyCash ?? '0')}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitLossContentFromModel(bool isSmallScreen,
      {ProfitLossItem? item, bool isLoading = false}) {
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (item == null) {
      return const SizedBox(
        height: 300,
        child: Center(
            child:
                Text("No records found", style: TextStyle(color: Colors.grey))),
      );
    }

    String plString =
        item.profitLoss?.replaceAll(RegExp(r'[^0-9.-]'), '') ?? '0';
    double plValue = double.tryParse(plString) ?? 0;
    final isProfit = plValue >= 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isProfit
                ? const Color(0xFF00C853).withOpacity(0.05)
                : const Color(0xFFF44336).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isProfit
                  ? const Color(0xFF00C853).withOpacity(0.2)
                  : const Color(0xFFF44336).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? const Color(0xFF00C853).withOpacity(0.1)
                          : const Color(0xFFF44336).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit
                          ? const Color(0xFF00C853)
                          : const Color(0xFFF44336),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isProfit ? "NET PROFIT" : "NET LOSS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isProfit
                          ? const Color(0xFF00C853)
                          : const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "₹${_formatCurrency(item.profitLoss ?? '0')}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isProfit
                      ? const Color(0xFF00C853)
                      : const Color(0xFFF44336),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${isProfit ? 'Profit' : 'Loss'} for ${_getMonthName(item.month)} ${item.year ?? DateTime.now().year}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCompactBalanceCard(
                title: "Opening Balance",
                value: "₹${_formatCurrency(item.openingBalance ?? '0')}",
                color: Colors.grey[800]!,
                icon: Icons.account_balance_outlined,
                isSmall: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildCompactBalanceCard(
                title: "Closing Balance",
                value: "₹${_formatCurrency(item.closingBalance ?? '0')}",
                color: const Color(0xFF2a86c9),
                icon: Icons.account_balance_wallet_outlined,
                isSmall: isSmallScreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceiptList(
                  widget.token,
                  fdate: DateFormat('dd-MM-yyyy').format(
                      DateTime(DateTime.now().year, DateTime.now().month, 1)),
                  tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: Color(0xFF00C853),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "INCOME",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIncomeItem(
                  label: "Receipt",
                  value: "₹${_formatCurrency(item.receipt ?? '0')}",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildIncomeItem(
                  label: "Total Income",
                  value:
                      "₹${_formatCurrency(item.receipt ?? item.receipt ?? '0')}",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseList(
                  fdate: DateFormat('yyyy-MM-dd').format(
                      DateTime(DateTime.now().year, DateTime.now().month, 1)),
                  tdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        size: 18,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "EXPENSE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExpenseItem(
                  label: "Expense",
                  value: "₹${_formatCurrency(item.expense ?? '0')}",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildExpenseItem(
                  label: "Net Expense",
                  value: "₹${_formatCurrency(item.expense ?? '0')}",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildPettyCashSection(item),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.remark}",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultProfitLossContent(bool isSmallScreen) {
    return Column(
      children: [
        // Profit/Loss Summary Card (Dummy)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00C853).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Color(0xFF00C853),
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "PROFIT/LOSS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "₹24,788.68",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00C853),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                "Net",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Opening & Closing Balance (Dummy)
        Row(
          children: [
            Expanded(
              child: _buildCompactBalanceCard(
                title: "Opening Balancesss",
                value: "₹0.00",
                color: Colors.grey[800]!,
                icon: Icons.account_balance_outlined,
                isSmall: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildCompactBalanceCard(
                title: "Closing Balance",
                value: "₹24,788.68",
                color: const Color(0xFF2a86c9),
                icon: Icons.account_balance_wallet_outlined,
                isSmall: isSmallScreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Use your existing _buildSmallScreenLayout() for dummy data
        _buildSmallScreenLayout(),

        const SizedBox(height: 20),
      ],
    );
  }

// Update _buildSmallScreenLayout to optionally use real data
  Widget _buildSmallScreenLayout() {
    final hasProfitLossData = dashboard?.data.profitAndLoss != null;

    if (hasProfitLossData) {
      final profitLoss = dashboard!.data.profitAndLoss!;

      return Column(
        children: [
          // Income Section from API
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: Color(0xFF00C853),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "INCOME",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIncomeItem(
                  label: "Receipt",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.income.receipt)}",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildIncomeItem(
                  label: "Total Income",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.income.totalIncome)}",
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Expense Section from API
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        size: 18,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "EXPENSE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExpenseItem(
                  label: "Expense",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.expense.expense)}",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Advance",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.expense.advance)}",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Last Month Advance",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.expense.lastMonthAdvance)}",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Difference",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.expense.difference)}",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildExpenseItem(
                  label: "Net Expense",
                  value:
                      "₹${_formatCurrency(profitLoss.incomeExpense.expense.netExpense)}",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Return your existing dummy layout
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 244, 248, 246)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: Color(0xFF00C853),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "INCOME",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIncomeItem(
                  label: "Receipt",
                  value: "₹210,160.66",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildIncomeItem(
                  label: "Total Income",
                  value: "₹210,160.66",
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        size: 18,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "EXPENSE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExpenseItem(
                  label: "Expense",
                  value: "₹500.00",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Advance",
                  value: "₹184,871.98",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Last Month Advance",
                  value: "₹184,871.98",
                ),
                const SizedBox(height: 6),
                _buildExpenseItem(
                  label: "Difference",
                  value: "₹184,871.98",
                ),
                const Divider(height: 16, color: Colors.grey),
                _buildExpenseItem(
                  label: "Net Expense",
                  value: "₹185,371.98",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  String _formatCurrency(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0.0;
      return NumberFormat("#,##0.00").format(value);
    } catch (e) {
      return amount;
    }
  }

  Widget _buildCompactBalanceCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isSmall ? 16 : 20, color: color),
              SizedBox(width: isSmall ? 4 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? const Color(0xFF00C853) : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color:
                    isTotal ? const Color(0xFF00C853) : const Color(0xFF00C853),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  bool _isProfit(ProfitLossItem item) {
    if (item.profitLoss == null) return false;
    final value =
        double.tryParse(item.profitLoss!.replaceAll(RegExp(r'[^0-9.-]'), '')) ??
            0;
    return value >= 0;
  }

  String _getMonthName(String? month) {
    if (month == null || month.isEmpty) return _getCurrentMonth();

    // If it's already a month name (contains letters), return as is
    if (RegExp(r'[a-zA-Z]').hasMatch(month)) return month;

    try {
      final monthInt = int.tryParse(month);
      if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
        // Return short month name (e.g., Feb) as requested "feb like that"
        return DateFormat('MMM').format(DateTime(0, monthInt));
      }
    } catch (e) {
      log("Error parsing month: $e");
    }

    return month;
  }

  String _getCurrentMonth() {
    return DateFormat('MMMM').format(DateTime.now());
  }

// Keep this as fallback
  Widget _buildDefaultProfitLoss() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.trending_up,
            color: Color(0xFF00C853),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Net Profit",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "₹0.00",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00C853),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseItem({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal
                    ? const Color.fromARGB(255, 12, 12, 12)
                    : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color:
                    isTotal ? const Color(0xFFF44336) : const Color(0xFFF44336),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: List.generate(
                    8,
                    (index) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[300],
                          ),
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
