// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/followup_dashboard_model.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/reminder_history_model.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renew_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/screens/accounts/renewal_mannagement/view_history.dart';
import 'package:login2/service/service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeline_tile/timeline_tile.dart';

class RenewalDetails extends StatefulWidget {
  String id;
  RenewalDetails({super.key, required this.id});

  @override
  State<RenewalDetails> createState() => _RenewalDetailsState();
}

class _RenewalDetailsState extends State<RenewalDetails> {
  bool isLoading = true;
  bool historyLoading = true;
  ReminderHistoryModel? reminderHistory;
  FollowupDashboardModel? details;
  int selectedIndex = 0;
  HideModel? hideResponse;
  RenewalTemplateModel? template;
  PostReminderModel? postReminderRes;
  final formKey = GlobalKey<FormState>();
  TextEditingController recieverName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();

  getHistory() async {
    reminderHistory = await HttpService.viewHistory(widget.id);
    if (reminderHistory != null && reminderHistory!.status == true) {
      setState(() {
        historyLoading = false;
      });
    } else {
      setState(() {
        historyLoading = false;
      });
    }
  }

  getData() async {
    details = await HttpService.getRenewalFollowUpDashboard(widget.id);
    if (details != null && details!.status == true) {
      setState(() {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  hide(id) async {
    hideResponse = await HttpService.hideRenewal(id);
    if (hideResponse != null && hideResponse!.status == true) {
      Common.toastMessaage(hideResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(hideResponse!.message, Colors.red);
    }
  }

  getRenewalReminderMessage(String renewalId, String contactId) async {
    template = await HttpService.getRenewalReminderMessage(renewalId);
    if (template != null && template!.status == true) {
      setState(() {
        Navigator.pop(context);
        reminderBottomSheet(renewalId, contactId);
      });
    } else {
      Common.toastMessaage(template!.message, Colors.red);

      setState(() {
        Navigator.pop(context);
      });
    }
  }

  postReminder(String renewalId, String contactNumber) async {
    postReminderRes = await HttpService.postReminder(
        renewalId,
        contactNumber,
        template!.data.templateType,
        template!.data.templateName,
        template!.data.templateId,
        template!.data.customerId,
        template!.data.message);
    if (postReminderRes != null && postReminderRes!.status == true) {
      Common.toastMessaage(postReminderRes!.message, Colors.green);
    } else {
      Common.toastMessaage(postReminderRes!.message, Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
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
                        "Renewal Details",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: isLoading == true
          ? buildLoader()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 15),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .65,
                                    child: Text(
                                      details!.data.customerName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    details!.data.contactNo,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.shopping_basket,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      SizedBox(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .58,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: details!
                                                .data.productLists.length,
                                            itemBuilder: (context, i) {
                                              return Text(
                                                details!.data.productLists[i]
                                                    .productName,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Created by :${details!.data.createdBy}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (details!.data.nextFollowUpDate != "")
                                    Text(
                                      "Next Followup :${details!.data.nextFollowUpDate}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  Text(
                                    "End date :${details!.data.nextEndDate}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: details!.data.renewalStatus ==
                                              "Upcoming"
                                          ? Colors.red
                                          : Colors.yellow,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 2,
                                            offset: Offset(.5, .5)),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 8.0),
                                      child: Text(
                                        details!.data.renewalStatus,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                details!.data.renewalStatus ==
                                                        "Upcoming"
                                                    ? Colors.white
                                                    : Colors.black),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    padding: const EdgeInsets.only(left: 35),
                                    iconColor: Colors.black,
                                    color: Colors.white,
                                    onSelected: (value) {
                                      if (value == "0") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RenewalFollowup(
                                                        details!.data.renewalId,
                                                        DateTime.now()))).then(
                                            (_) {
                                          getData();
                                        });
                                      } else if (value == "1") {
                                        Common.showProgressDialog(
                                            context, "Loading..");
                                        getRenewalReminderMessage(
                                            details!.data.renewalId,
                                            details!.data.contactNo);
                                        recieverName.text =
                                            details!.data.customerName;
                                        contactNumber.text =
                                            details!.data.contactNo;
                                      } else if (value == "2") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCustomRenewal(
                                                      renId: details!
                                                          .data.renewalId,
                                                      renewalType: "Cart",
                                                    ))).then((_) {
                                          getData();
                                        });
                                      } else if (value == "3") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RenewCustomRenewal(
                                                renId: details!.data.renewalId,
                                                renewalType: "Cart",
                                              ),
                                            )).then((_) {
                                          getData();
                                        });
                                      } else if (value == "4") {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: const Text(
                                                    'Please Confirm'),
                                                content: const Text(
                                                    'Are you sure to Hide?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('No')),
                                                  TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        await hide(details!
                                                            .data.renewalId);
                                                        getData();
                                                      },
                                                      child: const Text('Yes')),
                                                ],
                                              );
                                            });
                                      } else if (value == "5") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewHistory(
                                                id: details!.data.renewalId,
                                                title:
                                                    details!.data.customerName,
                                              ),
                                            ));
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: '0',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Add Followup',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '1',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.notification_add,
                                                color: Colors.green,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Remind',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '2',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '3',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.restart_alt,
                                                color: Colors.green,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Renew',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // const PopupMenuItem<
                                        //     String>(
                                        //   value: '4',
                                        //   child: Row(
                                        //     children: [
                                        //       Icon(
                                        //         Icons
                                        //             .visibility_off,
                                        //         color: Colors
                                        //             .black,
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             5,
                                        //       ),
                                        //       Text(
                                        //         'Hide',
                                        //         style: TextStyle(
                                        //             color:
                                        //                 Colors.black),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // const PopupMenuItem<
                                        //     String>(
                                        //   value: '5',
                                        //   child: Row(
                                        //     children: [
                                        //       Icon(
                                        //         Icons
                                        //             .history,
                                        //         color: Colors
                                        //             .black,
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             5,
                                        //       ),
                                        //       Text(
                                        //         'Remind History',
                                        //         style: TextStyle(
                                        //             color:
                                        //                 Colors.black),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // )
                                      ];
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Common.dialPad(details!.data.contactNo);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .18,
                                    height: MediaQuery.of(context).size.height *
                                        .038,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          Text('Call',
                                              style: TextStyle(
                                                  fontFamily:
                                                      "MontserratMedium",
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditCustomRenewal(
                                                  renId:
                                                      details!.data.renewalId,
                                                  renewalType: "Cart",
                                                ))).then((_) {
                                      getData();
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .18,
                                    height: MediaQuery.of(context).size.height *
                                        .038,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          Text('Edit',
                                              style: TextStyle(
                                                  fontFamily:
                                                      "MontserratMedium",
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RenewalFollowup(widget.id,
                                                    DateTime.now()))).then((_) {
                                      getData();
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .1,
                                    height: MediaQuery.of(context).size.height *
                                        .045,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.green,
                                            weight: 20000,
                                            size: 20,
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
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 20, top: 18, right: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .4,
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0),
                                color: selectedIndex == 0
                                    ? const Color(0xFFd5f5f4)
                                    : Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Followup',
                                    style: TextStyle(
                                      color: selectedIndex == 0
                                          ? const Color(0xFF3c9f9a)
                                          : const Color(0xFF717171),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            getHistory();
                            setState(() {
                              selectedIndex = 1;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .4,
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0),
                                color: selectedIndex == 1
                                    ? const Color(0xFFd5f5f4)
                                    : Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reminder History',
                                    style: TextStyle(
                                      color: selectedIndex == 1
                                          ? const Color(0xFF3c9f9a)
                                          : const Color(0xFF717171),
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
                  if (selectedIndex == 0)
                    details!.data.followup.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: 200,
                                    width: 150,
                                    child: Image.asset(
                                        "assets/icons/nodatafound.png")),
                                const Text("No Followups")
                              ],
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              // height: MediaQuery.of(context).size.height*.5,
                              child: ListView.builder(
                                itemCount: details!.data.followup.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: ((context, index) {
                                  return SizedBox(
                                    child: TimelineTile(
                                        isFirst: false,
                                        isLast: index ==
                                                details!.data.followup.length -
                                                    1
                                            ? true
                                            : false,
                                        beforeLineStyle:
                                            const LineStyle(color: Colors.blue),
                                        indicatorStyle: IndicatorStyle(
                                            width: 20,
                                            color: Colors.blue,
                                            iconStyle: IconStyle(
                                                iconData: Icons.done,
                                                color: Colors.blue)),
                                        endChild: Container(
                                          decoration: BoxDecoration(
                                            color: index == 0
                                                ? Colors.amber.shade100
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          margin: const EdgeInsets.all(15),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0,
                                                              bottom: 8.0),
                                                      child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(details!
                                                                  .data
                                                                  .followup[
                                                                      index]
                                                                  .proPicThumb)),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          details!
                                                              .data
                                                              .followup[index]
                                                              .staffName,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Scheduled date :${DateFormat('dd-MM-yyyy').format(details!.data.followup[index].nextFollowupDate).toString()}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                        ),

                                                        if (details!
                                                                .data
                                                                .followup[index]
                                                                .leadStatus !=
                                                            "")
                                                          Text(
                                                            "Status : ${details!.data.followup[index].leadStatusName}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        //  if (details!.data.followup[index]
                                                        //       . !=
                                                        //   "")
                                                        // Text(
                                                        //   "Call response : ${details!.data.followup[index].leadStatusName}",
                                                        //   style: const TextStyle(
                                                        //     fontSize: 12,
                                                        //     color: Colors.black,
                                                        //   ),
                                                        // ),
                                                        if (details!
                                                                .data
                                                                .followup[index]
                                                                .remarks !=
                                                            "")
                                                          Text(
                                                            "Remarks : ${details!.data.followup[index].remarks}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                if (details!
                                                        .data
                                                        .followup[index]
                                                        .calledDate !=
                                                    "")
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        details!
                                                            .data
                                                            .followup[index]
                                                            .calledDate,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  );
                                }),
                              ),
                            ),
                          )
                  else if (selectedIndex == 1)
                    historyLoading == true
                        ? buildLoaderListItem()
                        : reminderHistory!.data.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height: 200,
                                        width: 150,
                                        child: Image.asset(
                                            "assets/icons/nodatafound.png")),
                                    const Text("No Reminders Yet")
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: ListView.builder(
                                  itemCount: reminderHistory!.data.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: ((context, index) {
                                    return SizedBox(
                                      child: TimelineTile(
                                          isFirst: false,
                                          isLast: index ==
                                                  reminderHistory!.data.length -
                                                      1
                                              ? true
                                              : false,
                                          beforeLineStyle: const LineStyle(
                                              color: Colors.blue),
                                          indicatorStyle: IndicatorStyle(
                                              width: 20,
                                              color: Colors.blue,
                                              iconStyle: IconStyle(
                                                  iconData: Icons.done,
                                                  color: Colors.blue)),
                                          endChild: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            margin: const EdgeInsets.all(15),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 8.0,
                                                                bottom: 8.0),
                                                        child: CircleAvatar(
                                                            backgroundImage: NetworkImage(
                                                                reminderHistory!
                                                                    .data[index]
                                                                    .profileImage)),
                                                      ),
                                                      Text(
                                                        reminderHistory!
                                                            .data[index]
                                                            .staffName,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    reminderHistory!
                                                        .data[index].content,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        reminderHistory!
                                                            .data[index]
                                                            .createdAt,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    );
                                  }),
                                ),
                              )
                ],
              ),
            ),
    );
  }

  Widget buildLoader() {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white, // Added background color
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .4,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white, // Added background color
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .4,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white, // Added background color
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
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
        ],
      ),
    );
  }

  reminderBottomSheet(String id, String contactNo) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Send Reminder",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: recieverName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please EnterName";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: contactNumber,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Contact Number";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Contact No',
                              prefixIcon: Icon(Icons.phone, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 4.0, bottom: 4.0),
                          child: Text("Reminder Message"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(template!.data.message),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await postReminder(id, contactNo);
                            },
                            child: const Text("Send Reminder",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
      },
    );
  }
}
