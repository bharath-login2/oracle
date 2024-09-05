import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:login2/screens/accounts/accounts_dashboard.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
import 'package:login2/screens/product_mannagement/categories.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import '../../screens/authentication/login.dart';
import 'bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';

import 'accounts/clients/invoiceList.dart';
import 'complaints/complaint_list_screen.dart';
import 'leadManagement/allReport.dart';
import 'officialWhatsapp/chat_home_screen.dart';

class HomePage extends StatefulWidget {
  String? token;

  HomePage(this.token, {super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? result = true;
  bool? result1 = true;
  Timer? _timer;
  int _currentPage = 0;
  DashboardModel? userDashboard;
  CommonConfigureModel? configure;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = '';
  String role = '';
  bool isLongPress = false;
  String officialWhatsapp = '';
  String unOfficialWhatsapp = '';
  String phoneCallLogPermission = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  getData() async {
    //

    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    log(role.toString());
    officialWhatsapp = await Common.getSharedPref("officialWhatsApp");
    unOfficialWhatsapp = await Common.getSharedPref("unofficialWhatsApp");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");

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
    userDashboard = await HttpService.mainDashboard(widget.token);
    if (userDashboard != null) {
      setState(() {
        _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
          if (_currentPage < userDashboard!.data!.slides!.length) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          if (isLongPress == false) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn,
            );
          }
        });
      });
    }
    configure = await HttpService.configure(widget.token);
    if (configure != null) {
      setState(() {});
    }
  }

  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool? result = await _exitApp(context);
        result ??= false;
        return result;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getData();
          return;
        },
        child: result == true
            ? Scaffold(
                key: _scaffoldKey,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => logout(context),
                                child: Container(
                                  width: 43,
                                  height: 43,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/icons/user.png",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
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
                                  const SizedBox(
                                    height: 2,
                                  ),
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
                          InkWell(
                            onTap: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/icons/menu.png",
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                body: userDashboard != null && configure != null
                    ? SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 220,
                                  child: PageView.builder(
                                      scrollDirection: Axis.horizontal,
                                      controller: _pageController,
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          userDashboard!.data!.slides!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            setState(() {
                                              isLongPress = true;
                                            });
                                          },
                                          onLongPressEnd: (details) {
                                            setState(() {
                                              isLongPress = false;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      userDashboard!
                                                          .data!
                                                          .slides![index]
                                                          .imageUrl
                                                          .toString()),
                                                  fit: BoxFit.fill),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: userDashboard!.data!.slides!.length,
                                    effect: const WormEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                      type: WormType.thin,
                                      // strokeWidth: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextScroll(
                                  userDashboard!.data!.scrollingText.toString(),
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(40, 0)),
                                  intervalSpaces: 10,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Visibility(
                                  visible: role == "Company Admin",
                                  child: Card(
                                    // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    // Set the clip behavior of the card
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    // Define the child widgets of the card
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                        Image.network(
                                          userDashboard!.data!.image1
                                              .toString(),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        // Add a container with padding that contains the card's title, text, and buttons
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 15, 15, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              // Display the card's title using a font size of 24 and a dark grey color
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    userDashboard!
                                                        .data!.packageName
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  userDashboard!.data!
                                                              .expireSoon ==
                                                          true
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFd6ebff),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    right: 5,
                                                                    top: 4,
                                                                    bottom: 4),
                                                            child: Text(
                                                              userDashboard!
                                                                  .data!
                                                                  .expireSoonContent
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              // Add a space between the title and the text
                                              Container(height: 10),
                                              // Display the card's text using a font size of 15 and a light grey color
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Start Date',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDashboard!
                                                            .data!.startDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'End Date',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDashboard!
                                                            .data!.endDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Staff Count ( ${userDashboard!.data!.currentStaff}/${userDashboard!.data!.staffCount} )',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              StepProgressIndicator(
                                                selectedColor: Colors.green,
                                                totalSteps: userDashboard!
                                                    .data!.staffCount!,
                                                currentStep: userDashboard!
                                                    .data!.currentStaff!,
                                              ),
                                              // Add a row with two buttons spaced apart and aligned to the right side of the card
                                              Row(
                                                children: <Widget>[
                                                  // Add a spacer to push the buttons to the right side of the card
                                                  const Spacer(),
                                                  // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                                  // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                                  TextButton(
                                                    child: const Text(
                                                      "UPGRADE",
                                                    ),
                                                    onPressed: () {
                                                      _upgrade(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Add a small space between the card and the next widget
                                        Container(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1.3),
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      userDashboard!.data!.modules!.length,
                                  itemBuilder: (BuildContext context, i) {
                                    return Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xff5ecea8),
                                          )),
                                      child: InkWell(
                                        onTap: () async {
                                          if (configure!.data!.isExpired ==
                                              true) {
                                            _upgrade(context);
                                          } else {
                                            if (userDashboard!.data!.modules![i]
                                                    .menuName ==
                                                'call_management') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Dashboard(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'Staff_management') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewUsers(
                                                            widget.token)),
                                              );
                                            }
                                            //  else if (userDashboard!.data!
                                            //         .modules![i].menuName ==
                                            //     'messages') {
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             const ChatHomeScreen()),
                                            //   );
                                            // showDialog(
                                            //     barrierColor: Colors.grey
                                            //         .withOpacity(.5),
                                            //     context: context,
                                            //     builder:
                                            //         (BuildContext context) {
                                            //       return WillPopScope(
                                            //         onWillPop: () async {
                                            //           return true;
                                            //         },
                                            //         child: Material(
                                            //           type: MaterialType
                                            //               .transparency,
                                            //           child: Padding(
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .only(
                                            //                     bottom: 50),
                                            //             child: Center(
                                            //               child: Container(
                                            //                 decoration:
                                            //                     BoxDecoration(
                                            //                   borderRadius:
                                            //                       BorderRadius
                                            //                           .circular(
                                            //                               10),
                                            //                   color: Colors
                                            //                       .white,
                                            //                 ),
                                            //                 width: MediaQuery.of(
                                            //                             context)
                                            //                         .size
                                            //                         .width *
                                            //                     0.9,
                                            //                 height: 250,
                                            //                 child: Padding(
                                            //                   padding:
                                            //                       const EdgeInsets
                                            //                           .only(
                                            //                           left:
                                            //                               20,
                                            //                           right:
                                            //                               20),
                                            //                   child: Column(
                                            //                     mainAxisAlignment:
                                            //                         MainAxisAlignment
                                            //                             .center,
                                            //                     crossAxisAlignment:
                                            //                         CrossAxisAlignment
                                            //                             .center,
                                            //                     children: [
                                            //                       Image.asset(
                                            //                         'assets/icons/official_whatsapp.png',
                                            //                         width: 80,
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height:
                                            //                             10,
                                            //                       ),
                                            //                       const Text(
                                            //                         'Whatsapp',
                                            //                         style: TextStyle(
                                            //                             fontSize:
                                            //                                 18,
                                            //                             fontWeight:
                                            //                                 FontWeight.w400),
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height: 5,
                                            //                       ),
                                            //                       const Text(
                                            //                         'Choose WhatsApp',
                                            //                         style: TextStyle(
                                            //                             fontSize:
                                            //                                 15,
                                            //                             fontWeight:
                                            //                                 FontWeight.w400),
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height:
                                            //                             15,
                                            //                       ),
                                            //                       Row(
                                            //                         mainAxisAlignment:
                                            //                             MainAxisAlignment
                                            //                                 .spaceBetween,
                                            //                         children: [
                                            //                           officialWhatsapp ==
                                            //                                   'true'
                                            //                               ? InkWell(
                                            //                                   onTap: () {
                                            //                                     Navigator.push(
                                            //                                       context,
                                            //                                       MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
                                            //                                     );
                                            //                                   },
                                            //                                   child: Container(
                                            //                                     width: MediaQuery.of(context).size.width * 0.35,
                                            //                                     //  color: RandomColorModel().getColor(),
                                            //                                     decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                            //                                     child: const Padding(
                                            //                                       padding: EdgeInsets.all(5),
                                            //                                       child: Text('Official', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                            //                                     ),
                                            //                                   ),
                                            //                                 )
                                            //                               : const SizedBox(),
                                            //                           unOfficialWhatsapp ==
                                            //                                   'true'
                                            //                               ? InkWell(
                                            //                                   onTap: () {
                                            //                                     Navigator.push(
                                            //                                       context,
                                            //                                       MaterialPageRoute(builder: (context) => GroupList(widget.token)),
                                            //                                     );
                                            //                                   },
                                            //                                   child: Container(
                                            //                                     width: MediaQuery.of(context).size.width * 0.35,
                                            //                                     decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                            //                                     child: const Padding(
                                            //                                       padding: EdgeInsets.all(5),
                                            //                                       child: Text('Un Official', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                            //                                     ),
                                            //                                   ),
                                            //                                 )
                                            //                               : const SizedBox()
                                            //                         ],
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height: 8,
                                            //                       ),
                                            //                     ],
                                            //                   ),
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     });
                                            // }
                                            else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'Settings') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WhatsappSettings(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'file_manager') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FileMangerList(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'customers') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ClientList(
                                                            widget.token!)),
                                              );
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'invoices') {
                                                   Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AccountsDashboard(
                                                                token: widget
                                                                    .token
                                                                    .toString(),
                                                              ),
                                                            ));
                                              } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'reports') {
                                              showDialog(
                                                  barrierColor: Colors.white
                                                      .withOpacity(.2),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return WillPopScope(
                                                      onWillPop: () async {
                                                        return true;
                                                      },
                                                      child: Material(
                                                        type: MaterialType
                                                            .transparency,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 50),
                                                          child: Center(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              height: 300,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      'assets/icons/check.png',
                                                                      width: 80,
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    const Text(
                                                                      'Reports',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    const Text(
                                                                      'Choose Report',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => AllReport(
                                                                                        widget.token!,
                                                                                        true,
                                                                                        true,
                                                                                        true,
                                                                                        pageName: 'AllLeads',
                                                                                      )),
                                                                            );
                                                                            // Navigator.of(
                                                                            //     context)
                                                                            //     .push(
                                                                            //   MaterialPageRoute(
                                                                            //       builder: (context) =>
                                                                            //           Dashboard(widget.token)),
                                                                            // );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.38,
                                                                            //  color: RandomColorModel().getColor(),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.all(5),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.dashboard,
                                                                                    size: 15,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text('Lead Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => TransferLeadReport(
                                                                                        widget.token!,
                                                                                        true,
                                                                                        true,
                                                                                        true,
                                                                                        pageName: 'transferLeads',
                                                                                      )),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.38,
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.all(5),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.list_alt,
                                                                                    size: 15,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text('Transfer Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'complaints') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ComplaintListScreen()));
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'renewal') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const RenewalDashboard()));
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'products') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ProductCategories()));
                                            } else if (userDashboard!.data!
                                                    .modules![i].menuName ==
                                                'whatsapp') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChatHomeScreen()),
                                              );
                                            } else {
                                              _dialogue(context,
                                                  'Access ${userDashboard!.data!.modules![i].categoryName}');
                                            }
                                          }
                                        },
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: userDashboard!
                                                  .data!.modules![i].image
                                                  .toString(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            )),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                      )
                    : Center(
                        child: Lottie.asset('assets/main/loading.json',
                            fit: BoxFit.fill),
                      ),
                endDrawer: DraweScreen(widget.token!),
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
                        widget.token!, configure!.data!.whatsappConfigured,
                        phoneCallLogPermission: phoneCallLogPermission)
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
                )),
      ),
    );
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: const Text(
                'You have no permission to access the feature please contact the support team'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }

  void _upgrade(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Upgrade Package !!!'),
            content: const Text(
                'Please contact the support team to upgrade your current plan'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
              TextButton(
                  onPressed: () async {
                    String url = 'tel:${configure!.data!.supportTeamNumber}';
                    await launch(url);
                  },
                  child: const Text('Call'))
            ],
          );
        });
  }

  Future<bool?> _exitApp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure to exit app?"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return null;
  }
}
