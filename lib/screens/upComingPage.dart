
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../screens/authentication/login.dart';
import '../../screens/bottomNavigationBar.dart';
import '../../screens/homePage.dart';
import '../../screens/leadManagement/addLeads.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/settings/whatsappSettings.dart';
import 'package:flutter/material.dart';

class UpComingPage extends StatefulWidget {
  String? token;
   UpComingPage(this.token, {super.key});

  @override
  _UpComingPageState createState() => _UpComingPageState();
}

class _UpComingPageState extends State<UpComingPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Stack(
              children: [
                Image.asset("assets/icons/header.png",
                    width: size.width),
                Column(
                  children: [
                    const SizedBox(
                      height: 45,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _logout(context),
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2,
                                          color: Colors
                                              .grey.shade800,
                                          offset:
                                          const Offset(0, 2.0),
                                        )
                                      ],
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2191ce)),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        8.0),
                                    child: Image.asset(
                                      "assets/icons/user.png",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Login it solutions',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Company Admin',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20),
                            child: Image.asset(
                                "assets/icons/menu.png",
                                width: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 30),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                  "assets/icons/graph.png",
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                    EdgeInsets.only(
                                        top: 3),
                                    child: Text(
                                      'Upcoming',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Coming Soon..',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/main/coming_soon.json',
                            fit: BoxFit.fill,
                          )


                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
            );
          },
          child: Image.asset("assets/icons/menu.png",
              width: 25), //icon inside button
        ),
        bottomNavigationBar: BottomNavigation(widget.token!,false));
  }
  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Logout?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Common.saveSharedPref("Logout", "success");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Login()),
                            (Route<dynamic> route) => false);
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }
}
