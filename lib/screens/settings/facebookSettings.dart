import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/settings/deleteFbLeadsModel.dart';
import '../../models/settings/facebookSettingsModel.dart';

import '../../models/settings/sendNotificationModel.dart';
import '../../models/settings/updateFbLeadAssignStaff.dart';
import '../../service/service.dart';
import '../homePage.dart';
import '../upComingPage.dart';
import 'fbNotificationMessageSend.dart';

class FacebookSettings extends StatefulWidget {
  String token;

  FacebookSettings(this.token, {Key? key}) : super(key: key);

  @override
  State<FacebookSettings> createState() => _FacebookSettingsState();
}

class _FacebookSettingsState extends State<FacebookSettings> {
  AddLeadCommonDataModel? commonDetails;
  FacebookSettingsModel? fbSettings;
  List checkedStaffItems = [];
  List checkedStaffItemsName = [];
  List checkedNotificationStaffItems = [];
  List checkedNotificationsStaffItemsName = [];
  bool? result = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
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
    fbSettings = await HttpService.fbDetails(widget.token);
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (fbSettings != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? WillPopScope(
            onWillPop: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(widget.token)),
              );

              return true;
            },
            child: Scaffold(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(widget.token)),
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
                            const Text(
                              'Facebook Settings',
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
              body: fbSettings != null && commonDetails != null
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Manage FB Settings',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(fbSettings!
                                        .data!.fbConnectUrl
                                        .toString()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF406dbe),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Connect With facebook',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'You have the option to connect your Facebook lead with our system to synchronize leads. Once connected, our system will automatically assign leads to the staff members and notification will send to staffs WhatsApp number. Along with you have the option to set up a welcome message or acknowledgment to be sent to customers. ',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                                onTap: () async {
                                  await launchUrl(Uri.parse(fbSettings!
                                      .data!.testToolUrl
                                      .toString()));
                                },
                                child: const Text(
                                  'Lead Test Tool',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue),
                                )),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ListView.builder(
                              itemCount: fbSettings!.data!.fbData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 2.0),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 0),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.grey,
                                                          blurRadius: 5,
                                                          offset: Offset(1, 1)),
                                                    ],
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            fbSettings!
                                                                .data!
                                                                .fbData![i]
                                                                .imageUrl
                                                                .toString())),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Column(
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
                                                              0.6,
                                                          child: Text(
                                                            fbSettings!.data!
                                                                .fbData![i].name
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                'Page:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 160,
                                                              child: Text(
                                                                fbSettings!
                                                                    .data!
                                                                    .fbData![i]
                                                                    .pageName
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                'From:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 160,
                                                              child: Text(
                                                                fbSettings!
                                                                    .data!
                                                                    .fbData![i]
                                                                    .formName
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey.shade300,
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 140,
                                                child: Text(
                                                  'Assigned staff:',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                height: 35,
                                                child: ListView.builder(
                                                    itemCount: fbSettings!
                                                        .data!
                                                        .fbData![i]
                                                        .assignedStaff!
                                                        .length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, ind) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 0),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6)),
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        fbSettings!
                                                                            .data!
                                                                            .fbData![i]
                                                                            .assignedStaff![ind]
                                                                            .staffName
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ListView.builder(
                                              itemCount: fbSettings!
                                                  .data!
                                                  .fbData![i]
                                                  .formFeilds!
                                                  .length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 140,
                                                        child: Text(
                                                          '${fbSettings!.data!.fbData![i].formFeilds![index].title} :',
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 160,
                                                        child: Text(
                                                          fbSettings!
                                                              .data!
                                                              .fbData![i]
                                                              .formFeilds![
                                                                  index]
                                                              .value
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpComingPage(widget.token)),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .shade300)),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                        'Whatsapp Alert',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    for (int b = 0;
                                                    b <
                                                        fbSettings!
                                                            .data!
                                                            .fbData![i]
                                                            .notificationUsers!
                                                            .length;
                                                    b++) {
                                                      checkedNotificationStaffItems.add(
                                                          fbSettings!
                                                              .data!
                                                              .fbData![i]
                                                              .notificationUsers![b].notificationUserId);
                                                      checkedNotificationsStaffItemsName.add(
                                                          fbSettings!
                                                              .data!
                                                              .fbData![i]
                                                              .notificationUsers![b]
                                                              .notificationUserName);
                                                    }
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext context) {
                                                        return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return AlertDialog(
                                                                scrollable: true,
                                                                title: const Text(
                                                                    'Select the users to send push notification other than assigned staff',style: TextStyle(fontSize: 13),),
                                                                content:
                                                                ListView.builder(
                                                                  shrinkWrap: true,
                                                                  itemCount:
                                                                  commonDetails!
                                                                      .data!
                                                                      .transferStaffs!
                                                                      .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                      indexStaff) {
                                                                    return CheckboxListTile(
                                                                      title: SizedBox(
                                                                        width: 200,
                                                                        child: Text(
                                                                          commonDetails!
                                                                              .data!
                                                                              .transferStaffs![
                                                                          indexStaff]
                                                                              .tranStaffName
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .w400,
                                                                              fontSize:
                                                                              14),
                                                                        ),
                                                                      ),
                                                                      value: checkedNotificationStaffItems.contains(commonDetails!
                                                                          .data!
                                                                          .transferStaffs![
                                                                      indexStaff]
                                                                          .tranStaffId
                                                                          .toString())
                                                                          ? true
                                                                          : false,
                                                                      //value: false,
                                                                      onChanged:
                                                                          (bool?
                                                                      value) {
                                                                        if (value ==
                                                                            true) {
                                                                          checkedNotificationStaffItems.add(commonDetails!
                                                                              .data!
                                                                              .transferStaffs![
                                                                          indexStaff]
                                                                              .tranStaffId
                                                                              .toString());
                                                                          checkedNotificationsStaffItemsName.add(commonDetails!
                                                                              .data!
                                                                              .transferStaffs![
                                                                          indexStaff]
                                                                              .tranStaffName
                                                                              .toString());
                                                                          setState(
                                                                                  () {});
                                                                        } else {
                                                                          setState(
                                                                                  () {
                                                                                    checkedNotificationStaffItems.remove(commonDetails!
                                                                                    .data!
                                                                                    .transferStaffs![
                                                                                indexStaff]
                                                                                    .tranStaffId
                                                                                    .toString());
                                                                                    checkedNotificationsStaffItemsName.remove(commonDetails!
                                                                                    .data!
                                                                                    .transferStaffs![
                                                                                indexStaff]
                                                                                    .tranStaffName
                                                                                    .toString());
                                                                              });
                                                                        }
                                                                      },
                                                                      controlAffinity:
                                                                      ListTileControlAffinity
                                                                          .leading,
                                                                    );
                                                                  },
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        setState(
                                                                                () {});
                                                                        checkedNotificationStaffItems =
                                                                        [];
                                                                        checkedNotificationsStaffItemsName =
                                                                        [];
                                                                        Navigator.of(
                                                                            context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'close')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        if (checkedNotificationStaffItems
                                                                            .isEmpty) {
                                                                          Common.toastMessaage(
                                                                              'At least choose one staff',
                                                                              Colors
                                                                                  .red);
                                                                        } else {
                                                                          Common.showProgressDialog(
                                                                              context,
                                                                              "Loading..");
                                                                          Map<String,
                                                                              dynamic>
                                                                          body = {
                                                                            'token':
                                                                            widget
                                                                                .token,
                                                                            "fb_settings_id": fbSettings!
                                                                                .data!
                                                                                .fbData![
                                                                            i]
                                                                                .id,
                                                                            'staff_id':
                                                                            checkedNotificationStaffItems,
                                                                          };
                                                                          SendNotificationModel
                                                                          sendNotification =
                                                                          await HttpService.sendLeadNotification(
                                                                              body);
                                                                          // print(updateAssignStaff.data);
                                                                          if (sendNotification
                                                                              .data ==
                                                                              true) {
                                                                            if (mounted) {

                                                                              Navigator
                                                                                  .push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => FacebookSettings(widget.token)),
                                                                              );
                                                                            }
                                                                          }
                                                                        }
                                                                      },
                                                                      child: const Text(
                                                                          'Submit'))
                                                                ],
                                                              );
                                                            });
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .shade300)),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                        'Push Notification',
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  for (int a = 0;
                                                      a <
                                                          fbSettings!
                                                              .data!
                                                              .fbData![i]
                                                              .assignedStaff!
                                                              .length;
                                                      a++) {
                                                    checkedStaffItems.add(
                                                        fbSettings!
                                                            .data!
                                                            .fbData![i]
                                                            .assignedStaff![a]
                                                            .staffId);
                                                    checkedStaffItemsName.add(
                                                        fbSettings!
                                                            .data!
                                                            .fbData![i]
                                                            .assignedStaff![a]
                                                            .staffName);
                                                  }
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                        // print(checkedStaffItems);
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: const Text(
                                                              'Assigned Staff'),
                                                          content:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                commonDetails!
                                                                    .data!
                                                                    .transferStaffs!
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    indexStaff) {
                                                              return CheckboxListTile(
                                                                title: SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    commonDetails!
                                                                        .data!
                                                                        .transferStaffs![
                                                                            indexStaff]
                                                                        .tranStaffName
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                                value: checkedStaffItems.contains(commonDetails!
                                                                        .data!
                                                                        .transferStaffs![
                                                                            indexStaff]
                                                                        .tranStaffId
                                                                        .toString())
                                                                    ? true
                                                                    : false,
                                                                //value: false,
                                                                onChanged:
                                                                    (bool?
                                                                        value) {
                                                                  if (value ==
                                                                      true) {
                                                                    checkedStaffItems.add(commonDetails!
                                                                        .data!
                                                                        .transferStaffs![
                                                                            indexStaff]
                                                                        .tranStaffId
                                                                        .toString());
                                                                    checkedStaffItemsName.add(commonDetails!
                                                                        .data!
                                                                        .transferStaffs![
                                                                            indexStaff]
                                                                        .tranStaffName
                                                                        .toString());
                                                                    setState(
                                                                        () {});
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      checkedStaffItems.remove(commonDetails!
                                                                          .data!
                                                                          .transferStaffs![
                                                                              indexStaff]
                                                                          .tranStaffId
                                                                          .toString());
                                                                      checkedStaffItemsName.remove(commonDetails!
                                                                          .data!
                                                                          .transferStaffs![
                                                                              indexStaff]
                                                                          .tranStaffName
                                                                          .toString());
                                                                    });
                                                                  }
                                                                },
                                                                controlAffinity:
                                                                    ListTileControlAffinity
                                                                        .leading,
                                                              );
                                                            },
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(
                                                                      () {});
                                                                  checkedStaffItems =
                                                                      [];
                                                                  checkedStaffItemsName =
                                                                      [];
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    'close')),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (checkedStaffItems
                                                                      .isEmpty) {
                                                                    Common.toastMessaage(
                                                                        'At least choose one staff',
                                                                        Colors
                                                                            .red);
                                                                  } else {
                                                                    Common.showProgressDialog(
                                                                        context,
                                                                        "Loading..");
                                                                    Map<String,
                                                                            dynamic>
                                                                        body = {
                                                                      'token':
                                                                          widget
                                                                              .token,
                                                                      "fb_settings_id": fbSettings!
                                                                          .data!
                                                                          .fbData![
                                                                              i]
                                                                          .id,
                                                                      'staff_id':
                                                                          checkedStaffItems,
                                                                    };
                                                                    UpdateFbLeadAssignStaff
                                                                        updateAssignStaff =
                                                                        await HttpService.updateAssignStaffFbLead(
                                                                            body);
                                                                    // print(updateAssignStaff.data);
                                                                    if (updateAssignStaff
                                                                            .data ==
                                                                        true) {
                                                                      if (mounted) {
                                                                        // print(updateAssignStaff.data);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => FacebookSettings(widget.token)),
                                                                        );
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'Submit'))
                                                          ],
                                                        );
                                                      });
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color:
                                                                Colors.blue)),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(left: 7,right: 7),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.person_add_alt_1,
                                                            color: Colors.blue,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 7,),
                                                          Text('Assign Staff',style: TextStyle(color: Colors.blue,fontSize: 11,fontWeight: FontWeight.bold),)
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpComingPage(widget.token)),
                                                  );
                                                },
                                                child: Container(
                                                    height: 40,

                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5),
                                                        border: Border.all(
                                                            color: Colors.amber)),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(left: 7,right: 7),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.message,
                                                            color: Colors.amber,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 7,),
                                                          Text('Send Message',style: TextStyle(color: Colors.amber,fontSize: 11,fontWeight: FontWeight.bold),)

                                                        ],
                                                      ),
                                                    )),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Please Confirm'),
                                                          content: const Text(
                                                              'You are about to delete an Account Connection ?'),
                                                          actions: [
                                                            // The "Yes" button
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  Common.showProgressDialog(
                                                                      context,
                                                                      "Loading..");
                                                                  DeleteFbLeadsModel
                                                                      deleteFbLeads =
                                                                      await HttpService.deleteFbLeads(
                                                                          widget
                                                                              .token,
                                                                          fbSettings!
                                                                              .data!
                                                                              .fbData![i]
                                                                              .id);
                                                                  // print(updateAssignStaff.data);
                                                                  if (deleteFbLeads
                                                                          .data ==
                                                                      true) {
                                                                    if (mounted) {
                                                                      // print(updateAssignStaff.data);
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                FacebookSettings(widget.token)),
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Yes')),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'No'))
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Container(
                                                    height: 40,

                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: Colors.red)),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(left: 7,right: 7),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 7,),
                                                          Text('Delete',style: TextStyle(color: Colors.red,fontSize: 11,fontWeight: FontWeight.bold),)
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    ),
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
}
