import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:login2/screens/userManagement/staffViewLeads.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import '../../models/lead_management/leadDeatailsModel.dart';
import '../../models/lead_management/leadDeatailsModelAdd.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../service/service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../leadManagement/audio_controller.dart';
import '../leadManagement/docViewWebView.dart';
import '../leadManagement/leadDetails.dart';

// ignore: must_be_immutable
class StaffLeadDetails extends StatefulWidget {
  String token;
  String? staff;
  String? staffName;
  String callMasterId;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? pageName;
  bool? isCalled;
  String? searchKey;
  String? name;
  String? userId;
  bool? recordAccessPermission;
  int? scrollToIndex;
  int? page;
  int? pageSize;
  String? leadType;

  StaffLeadDetails(this.token, this.staff, this.staffName, this.callMasterId,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.pageName,
      this.isCalled,
      this.searchKey,
      this.name,
      this.userId,
      this.recordAccessPermission,
      this.scrollToIndex,
      this.page,
      this.pageSize,
      this.leadType});

  @override
  State<StaffLeadDetails> createState() => _StaffLeadDetailsState();
}

class _StaffLeadDetailsState extends State<StaffLeadDetails> {
  AddLeadCommonDataModel? commonDetails;
  var dio = Dio();
  TextEditingController transferRemark = TextEditingController();
  TextEditingController folderName = TextEditingController();
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();
  TextEditingController timeBefore = TextEditingController();
  int selectedIndex = 0;
  String callResult = 'New';
  String callResultId = '1';
  var callDate = DateTime.now();
  String? nextFollowupDate = '';
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String path = '';
  String listPath = '';
  String backPath = '';
  String listPathAudio = '';
  bool isPlay = false;
  bool isBack = false;
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
    Colors.blueGrey
  ];
  LeadDeatailsModel? leadDetails;
  ListFolderNameModel? listFolder;
  FileManagerPermissionModel? fileManagerPermission;
  LeadDeatailsModelAdd? leadDetailsAdditional;
  bool? result = true;
  bool? result1 = true;
  dynamic staff;
  String whatsappNo = '';
  String whatsappNo1 = '';
  TextEditingController contactFName = TextEditingController();
  TextEditingController contactLName = TextEditingController();
  TextEditingController contactMobile = TextEditingController();
  final AudioRecordController audioCreateController =
      Get.put(AudioRecordController());
  String rawId = '';
  String selectedRawIndex = '';
  String editableName = '';
  bool checked = false;
  bool isFile = false;
  bool isExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    audioCreateController.audioRecord.dispose();
    audioCreateController.audioPlayer.dispose();
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
    leadDetails =
        await HttpService.leadDetails(widget.token, widget.callMasterId);
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (leadDetails != null) {
      setState(() {
        final myString = leadDetails!.data!.contactNumber1.toString();
        int countryCodeLengt = leadDetails!.data!.countryCode!.length;
        whatsappNo1 = myString.substring(countryCodeLengt);
        whatsappNo = leadDetails!.data!.contactNumber1.toString();
        contactFName.text = leadDetails!.data!.clientName.toString();
        contactMobile.text = '+${leadDetails!.data!.contactNumber1}';
      });
      listAddonDet(widget.token, widget.callMasterId);
      listFolderList(widget.token, widget.callMasterId, '');
    }
  }

  listFolderList(token, callMasterId, path) async {
    listFolder =
        await HttpService.listFolderAndFiles(token, callMasterId, path);
    if (listFolder != null) {
      fileManagerPermissionFunction(widget.token);
      setState(() {});
    }
  }

  listAddonDet(token, callMasterId) async {
    leadDetailsAdditional = await HttpService.listAddonDet(token, callMasterId);
    if (leadDetailsAdditional != null) {
      setState(() {});
    }
  }

  fileManagerPermissionFunction(token) async {
    fileManagerPermission = await HttpService.fileManagerPermission(token);
    if (fileManagerPermission != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Staff Id:${widget.staff}');
    print('Staff Name:${widget.staffName}');
    widget.fromDate ??= DateTime.now().toString();
    widget.toDate ??= DateTime.now().toString();
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StaffViewLeads(
                    widget.token,
                    widget.staff,
                    widget.staffName,
                    pageName: widget.pageName,
                    status: widget.status,
                    isCalled: widget.isCalled,
                    fromDate: widget.fromDate,
                    toDate: widget.toDate,
                    category: widget.category,
                    scrollToIndex: widget.scrollToIndex,
                    page: widget.page,
                    pageSize: widget.pageSize,
                    leadType: widget.leadType,
                  )),
        );
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getData();
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
                                        builder: (context) => StaffViewLeads(
                                              widget.token,
                                              widget.staff,
                                              widget.staffName,
                                              pageName: widget.pageName,
                                              status: widget.status,
                                              isCalled: widget.isCalled,
                                              fromDate: widget.fromDate,
                                              toDate: widget.toDate,
                                              category: widget.category,
                                              scrollToIndex:
                                                  widget.scrollToIndex,
                                              page: widget.page,
                                              pageSize: widget.pageSize,
                                              leadType: widget.leadType,
                                            )),
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
                                'Lead Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final whatsappLink =
                                      "https://wa.me/$whatsappNo";
                                  await launch(whatsappLink);
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Center(
                                      child: Image.asset(
                                          "assets/icons/whatsapp_white.png",
                                          width: 32),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  final whatsappLink =
                                      "https://wa.me?text=Name: ${contactFName.text}\nPhone :$whatsappNo1";
                                  await launch(whatsappLink);
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.brown,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  showGeneralDialog(
                                    barrierLabel: "showGeneralDialog",
                                    barrierDismissible: true,
                                    barrierColor: Colors.black.withOpacity(0.6),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    context: context,
                                    pageBuilder: (context, _, __) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
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
                                                          'Save Contact to Phone',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        TextFormField(
                                                          controller:
                                                              contactFName,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                  labelText:
                                                                      'First Name',
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  prefixIcon: Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
                                                        ),
                                                        const SizedBox(
                                                          height: 13,
                                                        ),
                                                        TextFormField(
                                                          controller:
                                                              contactLName,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                  labelText:
                                                                      'Last Name',
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  prefixIcon: Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
                                                        ),
                                                        const SizedBox(
                                                          height: 13,
                                                        ),
                                                        TextFormField(
                                                          controller:
                                                              contactMobile,
                                                          decoration:
                                                              const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                  labelText:
                                                                      'Mobile Number',
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  prefixIcon: Icon(
                                                                      Icons
                                                                          .phone_android_rounded,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey)),
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
                                                            onPressed:
                                                                () async {
                                                              if (contactFName
                                                                  .text
                                                                  .isEmpty) {
                                                                Common.toastMessaage(
                                                                    'Enter the first name',
                                                                    Colors.red);
                                                              } else if (contactMobile
                                                                  .text
                                                                  .isEmpty) {
                                                                Common.toastMessaage(
                                                                    'Enter the Mobile number',
                                                                    Colors.red);
                                                              } else {
                                                                PermissionStatus
                                                                    permission =
                                                                    await Permission
                                                                        .contacts
                                                                        .status;

                                                                if (permission !=
                                                                    PermissionStatus
                                                                        .granted) {
                                                                  await Permission
                                                                      .contacts
                                                                      .request();
                                                                  PermissionStatus
                                                                      permission =
                                                                      await Permission
                                                                          .contacts
                                                                          .status;

                                                                  if (permission ==
                                                                      PermissionStatus
                                                                          .granted) {
                                                                    Contact
                                                                        newContact =
                                                                        Contact();
                                                                    newContact
                                                                            .givenName =
                                                                        contactFName
                                                                            .text;
                                                                    newContact
                                                                            .familyName =
                                                                        contactLName
                                                                            .text;
                                                                    newContact
                                                                        .phones = [
                                                                      Item(
                                                                          label:
                                                                              "mobile",
                                                                          value:
                                                                              contactMobile.text)
                                                                    ];
                                                                    await ContactsService
                                                                        .addContact(
                                                                            newContact);
                                                                    Common.toastMessaage(
                                                                        'Saved',
                                                                        Colors
                                                                            .green);
                                                                  } else {
                                                                    //_handleInvalidPermissions(context);
                                                                  }
                                                                } else {
                                                                  Contact
                                                                      newContact =
                                                                      Contact();
                                                                  newContact
                                                                          .givenName =
                                                                      contactFName
                                                                          .text;
                                                                  newContact
                                                                          .familyName =
                                                                      contactLName
                                                                          .text;
                                                                  newContact
                                                                      .phones = [
                                                                    Item(
                                                                        label:
                                                                            "mobile",
                                                                        value: contactMobile
                                                                            .text)
                                                                  ];
                                                                  await ContactsService
                                                                      .addContact(
                                                                          newContact);
                                                                  Common.toastMessaage(
                                                                      'Contact Saved',
                                                                      Colors
                                                                          .green);
                                                                }
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                }
                                                              }
                                                            },
                                                            child: const Center(
                                                              child: Text(
                                                                'Save',
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
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Center(
                                      child: Icon(
                                        Icons.person_add,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: leadDetails != null
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 15),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                top: 2,
                                              ),
                                              child: Text(
                                                leadDetails!.data!
                                                            .leadSubCategory !=
                                                        ''
                                                    ? '${leadDetails!.data!.leadCategory}-${leadDetails!.data!.leadSubCategory}'
                                                    : '${leadDetails!.data!.leadCategory}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            thickness: 0.5,
                                            indent: 0,
                                            endIndent: 0,
                                            color: Colors.grey,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10.0,
                                                        height: 10.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: leadDetails!
                                                                      .data!
                                                                      .priorityId ==
                                                                  '1'
                                                              ? Colors.grey
                                                              : leadDetails!
                                                                          .data!
                                                                          .priorityId ==
                                                                      '2'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      SizedBox(
                                                        width: 170,
                                                        //width: MediaQuery.of(context).size.width * 0.1,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.clientName
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              leadDetails!.data!.leadCategories!
                                                          .length >
                                                      1
                                                  ? PopupMenuButton(
                                                      // add icon, by default "3 dot" icon
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            shape: BoxShape
                                                                .circle),
                                                        child: const Icon(
                                                          Icons.arrow_right,
                                                          color: Colors.black,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      itemBuilder: (context) {
                                                        return [
                                                          for (int i = 0;
                                                              i <
                                                                  leadDetails!
                                                                      .data!
                                                                      .leadCategories!
                                                                      .length;
                                                              i++)
                                                            PopupMenuItem<int>(
                                                                value: int.parse(leadDetails!
                                                                    .data!
                                                                    .leadCategories![
                                                                        i]
                                                                    .callMasterId
                                                                    .toString()),
                                                                child: Row(
                                                                  children: [
                                                                    leadDetails!.data!.leadCategories![i].isSelected ==
                                                                            true
                                                                        ? const Icon(
                                                                            Icons.done,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : const SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.5,
                                                                      child:
                                                                          Text(
                                                                        leadDetails!
                                                                            .data!
                                                                            .leadCategories![i]
                                                                            .leadCategory
                                                                            .toString(),
                                                                        maxLines:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                        ];
                                                      },
                                                      onSelected: (value) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  StaffLeadDetails(
                                                                    widget
                                                                        .token,
                                                                    widget
                                                                        .staff,
                                                                    widget
                                                                        .staffName!,
                                                                    value
                                                                        .toString(),
                                                                    pageName: widget
                                                                        .pageName,
                                                                    status: widget
                                                                        .status,
                                                                    isCalled: widget
                                                                        .isCalled,
                                                                    fromDate: widget
                                                                        .fromDate,
                                                                    toDate: widget
                                                                        .toDate,
                                                                    category: widget
                                                                        .category,
                                                                    searchKey:
                                                                        widget
                                                                            .searchKey,
                                                                    leadType: widget
                                                                        .leadType,
                                                                  )),
                                                        );
                                                      })
                                                  : const SizedBox()
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            leadDetails!.data!.contactNumber1
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  'Assigned to : ${leadDetails!.data!.staffName}',
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: _colors[int.parse(
                                                        leadDetails!
                                                            .data!.callResultId
                                                            .toString())],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 2,
                                                          bottom: 2),
                                                  child: Text(
                                                    leadDetails!
                                                        .data!.callResult
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Created date: ${leadDetails!.data!.createdDate}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          leadDetails!.data!.address
                                                      .toString() !=
                                                  ''
                                              ? Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        leadDetails!
                                                            .data!.address
                                                            .toString(),
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Cost: ${leadDetails!.data!.cost}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'Source : ${leadDetails!.data!.leadMethod}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            leadDetailsAdditional != null && listFolder != null
                                ? Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                            left: 20, top: 18, right: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 30,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 0;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 0),
                                                    color: selectedIndex == 0
                                                        ? const Color(
                                                            0xFFd5f5f4)
                                                        : Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                6))),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Followup',
                                                        style: TextStyle(
                                                          color: selectedIndex ==
                                                                  0
                                                              ? const Color(
                                                                  0xFF3c9f9a)
                                                              : const Color(
                                                                  0xFF717171),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            leadDetails!.data!
                                                        .callHistoryPermission ==
                                                    true
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIndex = 2;
                                                      });
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .25,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 0),
                                                          color: selectedIndex ==
                                                                  2
                                                              ? const Color(
                                                                  0xFFd5f5f4)
                                                              : Colors.white,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          6))),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'Call History',
                                                              style: TextStyle(
                                                                color: selectedIndex ==
                                                                        2
                                                                    ? const Color(
                                                                        0xFF3c9f9a)
                                                                    : const Color(
                                                                        0xFF717171),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            leadDetails!.data!
                                                        .callHistoryPermission ==
                                                    true
                                                ? const SizedBox(
                                                    width: 10,
                                                  )
                                                : const SizedBox(),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 1;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 0),
                                                    color: selectedIndex == 1
                                                        ? const Color(
                                                            0xFFd5f5f4)
                                                        : Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                6))),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Activities',
                                                        style: TextStyle(
                                                          color: selectedIndex ==
                                                                  1
                                                              ? const Color(
                                                                  0xFF3c9f9a)
                                                              : const Color(
                                                                  0xFF717171),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 3;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 0),
                                                    color: selectedIndex == 3
                                                        ? const Color(
                                                            0xFFd5f5f4)
                                                        : Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                6))),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Details',
                                                        style: TextStyle(
                                                          color: selectedIndex ==
                                                                  3
                                                              ? const Color(
                                                                  0xFF3c9f9a)
                                                              : const Color(
                                                                  0xFF717171),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            leadDetails!.data!
                                                        .fileManagerPermission ==
                                                    true
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIndex = 4;
                                                      });
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .25,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 0),
                                                          color: selectedIndex ==
                                                                  4
                                                              ? const Color(
                                                                  0xFFd5f5f4)
                                                              : Colors.white,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          6))),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'Documents',
                                                              style: TextStyle(
                                                                color: selectedIndex ==
                                                                        4
                                                                    ? const Color(
                                                                        0xFF3c9f9a)
                                                                    : const Color(
                                                                        0xFF717171),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                      ),
                                      if (selectedIndex == 0)
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Stack(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 50.0),
                                                  child: InkWell(
                                                    child: Card(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: leadDetailsAdditional!
                                                                      .data!
                                                                      .followUpData![
                                                                          index]
                                                                      .isCalled ==
                                                                  false
                                                              ? Colors.green
                                                                  .shade100
                                                              : Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 4,
                                                              blurRadius: 6,
                                                              offset:
                                                                  const Offset(
                                                                      1, 1),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 40),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              50,
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
                                                                                40,
                                                                            maxWidth:
                                                                                40,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.white, width: 0),
                                                                            boxShadow: const [
                                                                              BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(1, 1)),
                                                                            ],
                                                                            color:
                                                                                Colors.white,
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            image:
                                                                                DecorationImage(fit: BoxFit.cover, image: NetworkImage(leadDetailsAdditional!.data!.followUpData![index].proPicThumb.toString())),
                                                                            // image: AssetImage(
                                                                            //     'assets/images/img.jpeg')),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            90,
                                                                        child:
                                                                            Text(
                                                                          leadDetailsAdditional!
                                                                              .data!
                                                                              .followUpData![index]
                                                                              .staffName
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Text(
                                                                'Scheduled Date : ${leadDetailsAdditional!.data!.followUpData![index].scheduledDate}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                'Remark:${leadDetailsAdditional!.data!.followUpData![index].remarks}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        'Status :',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                _colors[int.parse(leadDetailsAdditional!.data!.followUpData![index].callResultId.toString())],
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 2,
                                                                              bottom: 2),
                                                                          child:
                                                                              Text(
                                                                            leadDetailsAdditional!.data!.followUpData![index].callResult.toString(),
                                                                            style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      leadDetailsAdditional!.data!.followUpData![index].isCalled ==
                                                                              false
                                                                          ? const Text(
                                                                              '( Pending )',
                                                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                                                          : const SizedBox()
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
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0.0,
                                                  bottom: 0.0,
                                                  left: 35.0,
                                                  child: Container(
                                                    height: double.infinity,
                                                    width: 1.0,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 30.0,
                                                  left: 15.0,
                                                  child: Container(
                                                    height: 30.0,
                                                    width: 80.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            blurRadius: 5,
                                                            offset:
                                                                Offset(1, 1)),
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .followUpData![index]
                                                          .dispalyDate
                                                          .toString(),
                                                    )),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                          itemCount: leadDetailsAdditional!
                                              .data!.followUpData!.length,
                                        ),
                                      if (selectedIndex == 1)
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: leadDetailsAdditional!
                                                .data!.activities!.length,
                                            itemBuilder: (context, i) {
                                              return Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                            width: size.width *
                                                                0.2),
                                                        SizedBox(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  leadDetailsAdditional!
                                                                      .data!
                                                                      .activities![
                                                                          i]
                                                                      .staffName
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14)),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 240,
                                                                child: Text(
                                                                  leadDetailsAdditional!
                                                                      .data!
                                                                      .activities![
                                                                          i]
                                                                      .remark
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                leadDetailsAdditional!
                                                                    .data!
                                                                    .activities![
                                                                        i]
                                                                    .createdTime
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 50,
                                                    child: Container(
                                                      height: size.height * 0.7,
                                                      width: 1.0,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              30.0),
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                          maxHeight: 50,
                                                        ),
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                            minHeight: 20,
                                                            minWidth: 20,
                                                            maxHeight: 40,
                                                            maxWidth: 40,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .grey,
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      Offset(1,
                                                                          1)),
                                                            ],
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: NetworkImage(leadDetailsAdditional!
                                                                    .data!
                                                                    .activities![
                                                                        i]
                                                                    .proPicThumb
                                                                    .toString())),
                                                            // image: AssetImage(
                                                            //     'assets/images/img.jpeg')),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      if (selectedIndex == 2)
                                        leadDetailsAdditional!
                                                .data!.callHistory!.isNotEmpty
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    leadDetailsAdditional!.data!
                                                        .callHistory!.length,
                                                itemBuilder: (context, i) {
                                                  return AudioItem(
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .direction
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .time
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .isAttended!,
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .date
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .status
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .resourceURL
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .callDurationHr
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .voiceListerningPermission!,
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .id
                                                          .toString(),
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .isTransfered!,
                                                      widget.token,
                                                      widget.callMasterId,
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .callHistoryImage,
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .callHistory![i]
                                                          .staffName,
                                                      leadDetails!
                                                          .data!.clientName,
                                                      pageName: widget.pageName,
                                                      sts: widget.status,
                                                      staff: widget.staff,
                                                      isCalled: widget.isCalled,
                                                      fromDate: widget.fromDate,
                                                      toDate: widget.toDate,
                                                      category:
                                                          widget.category);
                                                })
                                            : SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.55,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 110,
                                                      height: 110,
                                                      child: Image.asset(
                                                        "assets/icons/nocall-history.png",
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const Text(
                                                      'Calls Not Found',
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      'Whoops... this information is \n not available for a moment',
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      if (selectedIndex == 3)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Client Name',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.clientName
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Phone',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!.data!
                                                              .contactNumber1
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Assigned to',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.staffName
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Created date',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.createdDate
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Call Result',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.callResult
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Cost',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.cost
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Source',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.leadMethod
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: const Text(
                                                          'Remark',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    const Text(':'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        child: Text(
                                                          leadDetails!
                                                              .data!.remarks
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      leadDetailsAdditional!
                                                          .data!
                                                          .additionalFields!
                                                          .length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetailsAdditional!
                                                                    .data!
                                                                    .additionalFields![
                                                                        i]
                                                                    .name
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: Text(
                                                                leadDetailsAdditional!
                                                                    .data!
                                                                    .additionalFields![
                                                                        i]
                                                                    .value
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            15),
                                                              )),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                            ],
                                          ),
                                        ),
                                      if (selectedIndex == 4)
                                        listFolder != null
                                            ? leadDetails!.data!
                                                        .fileManagerPermission ==
                                                    true
                                                ? Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            listPath != ''
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        bool?
                                                                            checkString =
                                                                            backPath.contains('/');
                                                                        if (checkString ==
                                                                            true) {
                                                                          backPath = backPath.substring(
                                                                              0,
                                                                              backPath.lastIndexOf('/'));
                                                                        } else {
                                                                          backPath =
                                                                              '';
                                                                        }
                                                                        listFolderList(
                                                                            widget.token,
                                                                            widget.callMasterId,
                                                                            backPath);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                20),
                                                                        child:
                                                                            DottedBorder(
                                                                          borderType:
                                                                              BorderType.RRect,
                                                                          radius: const Radius
                                                                              .circular(
                                                                              5),
                                                                          dashPattern: const [
                                                                            8,
                                                                            4
                                                                          ],
                                                                          strokeCap:
                                                                              StrokeCap.round,
                                                                          color:
                                                                              Colors.black,
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                30,
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.blue.shade50.withOpacity(.3), borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(Icons.arrow_back_ios, color: Colors.black, size: 15),
                                                                                SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                Text(
                                                                                  'Back',
                                                                                  style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        child: GridView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 4,
                                                              // Number of columns in the grid
                                                              crossAxisSpacing: 2,
                                                              // Spacing between columns
                                                              mainAxisSpacing: 2,
                                                              // Spacing between rows
                                                              childAspectRatio: 1),
                                                          itemCount: listFolder!
                                                              .data!.length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return InkWell(
                                                              onLongPress: () {
                                                                setState(() {
                                                                  rawId = listFolder!
                                                                      .data![
                                                                          index]
                                                                      .id
                                                                      .toString();
                                                                  selectedRawIndex =
                                                                      index
                                                                          .toString();
                                                                  editableName =
                                                                      listFolder!
                                                                          .data![
                                                                              index]
                                                                          .name
                                                                          .toString();
                                                                  fileNameEdit
                                                                          .text =
                                                                      editableName;
                                                                });
                                                              },
                                                              onTap: () {
                                                                fileManagerPermission!
                                                                            .data!
                                                                            .openFile ==
                                                                        true
                                                                    ? setState(
                                                                        () {
                                                                        rawId =
                                                                            '';
                                                                        selectedRawIndex =
                                                                            '';
                                                                        if (listFolder!.data![index].isFolder ==
                                                                            'Y') {
                                                                          backPath =
                                                                              '${listFolder!.data![index].path}';
                                                                          path =
                                                                              '${listFolder!.data![index].path}/';
                                                                          listPath =
                                                                              '${listFolder!.data![index].path}';
                                                                        } else {
                                                                          listPathAudio =
                                                                              '${listFolder!.data![index].path}';
                                                                        }
                                                                        folderName.text =
                                                                            '';
                                                                        listFolder!.data![index].isFolder ==
                                                                                'Y'
                                                                            ? listFolderList(
                                                                                widget.token,
                                                                                widget.callMasterId,
                                                                                listPath)
                                                                            : listFolder!.data![index].extension == 'M4A' || listFolder!.data![index].extension == 'm4a'
                                                                                ? showGeneralDialog(
                                                                                    barrierLabel: "showGeneralDialog",
                                                                                    barrierDismissible: false,
                                                                                    barrierColor: Colors.black.withOpacity(0.6),
                                                                                    transitionDuration: const Duration(milliseconds: 400),
                                                                                    context: context,
                                                                                    pageBuilder: (context, _, __) {
                                                                                      return Obx(() {
                                                                                        return Align(
                                                                                          alignment: Alignment.bottomCenter,
                                                                                          child: IntrinsicHeight(
                                                                                            child: Container(
                                                                                              width: double.maxFinite,
                                                                                              clipBehavior: Clip.antiAlias,
                                                                                              decoration: const BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.only(
                                                                                                  topLeft: Radius.circular(16),
                                                                                                  topRight: Radius.circular(16),
                                                                                                ),
                                                                                              ),
                                                                                              child: Material(
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    Align(
                                                                                                      alignment: Alignment.topRight,
                                                                                                      child: IconButton(
                                                                                                        onPressed: () {
                                                                                                          audioCreateController.stopTimer();
                                                                                                          audioCreateController.audioPlayer.stop();
                                                                                                          audioCreateController.resetTimer();
                                                                                                          isPlay = false;
                                                                                                          Get.back();
                                                                                                        },
                                                                                                        icon: const Icon(Icons.close_rounded),
                                                                                                        color: Colors.redAccent,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().toString().padLeft(2, '0')}',
                                                                                                      style: const TextStyle(fontSize: 30),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        isPlay == false
                                                                                                            ? FloatingActionButton(
                                                                                                                heroTag: "play tag",
                                                                                                                onPressed: () async {
                                                                                                                  isPlay = true;
                                                                                                                  audioCreateController.playVoice(listPathAudio);
                                                                                                                },
                                                                                                                shape: const CircleBorder(),
                                                                                                                backgroundColor: Colors.white,
                                                                                                                foregroundColor: Colors.teal,
                                                                                                                child: const Icon(
                                                                                                                  Icons.play_arrow_rounded,
                                                                                                                  color: Colors.green,
                                                                                                                  size: 30,
                                                                                                                ))
                                                                                                            : const SizedBox(),
                                                                                                        const SizedBox(
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                        FloatingActionButton(
                                                                                                            heroTag: "stop tag",
                                                                                                            onPressed: () {
                                                                                                              audioCreateController.stopTimer();
                                                                                                              audioCreateController.audioPlayer.stop();
                                                                                                              audioCreateController.resetTimer();
                                                                                                              isPlay = false;
                                                                                                            },
                                                                                                            shape: const CircleBorder(),
                                                                                                            backgroundColor: Colors.white,
                                                                                                            foregroundColor: Colors.teal,
                                                                                                            child: const Icon(
                                                                                                              Icons.stop,
                                                                                                              color: Colors.red,
                                                                                                              size: 30,
                                                                                                            )),
                                                                                                      ],
                                                                                                    ),
                                                                                                    const SizedBox(
                                                                                                      height: 20,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
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
                                                                                  )
                                                                                : Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => DocumentViewerScreen(
                                                                                        documentUrl: listFolder!.data![index].path.toString(),
                                                                                        title: listFolder!.data![index].name.toString(),
                                                                                        extension: listFolder!.data![index].extension.toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                      })
                                                                    : _dialogue(
                                                                        context,
                                                                        'Open Folder');
                                                              },
                                                              child: Container(
                                                                color: selectedRawIndex ==
                                                                        index
                                                                            .toString()
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .grey
                                                                        .shade200,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          50.0,
                                                                      width:
                                                                          50.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image: listFolder!.data![index].isFolder == 'Y'
                                                                              ? const AssetImage('assets/icons/folder.png')
                                                                              : listFolder!.data![index].extension == 'M4A' || listFolder!.data![index].extension == 'm4a'
                                                                                  ? const AssetImage('assets/icons/audio.png')
                                                                                  : const AssetImage('assets/icons/file.png'),
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          100,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          listFolder!
                                                                              .data![index]
                                                                              .name
                                                                              .toString(),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox()
                                            : Center(
                                                child: Lottie.asset(
                                                    'assets/main/loading.json',
                                                    fit: BoxFit.fill),
                                              ),
                                    ],
                                  )
                                : Shimmer.fromColors(
                                    enabled: true,
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 96.0,
                                                  height: 72.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 96.0,
                                                  height: 72.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 96.0,
                                                  height: 72.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 10.0,
                                                        color: Colors.white,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8.0),
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
                                    ))
                          ],
                        ),
                      )
                    : Center(
                        child: Lottie.asset('assets/main/loading.json',
                            fit: BoxFit.fill),
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
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }
}

// ignore: must_be_immutable
class AudioItem extends StatefulWidget {
  String direction;
  String time;
  bool isAttend;
  String date;
  String status;
  String resourceUrl;
  String duration;
  bool voicePlayPermission;
  String callHistoryId;
  bool isTransfer;
  String token;
  String callMasterId;
  String? fromDate;
  String? toDate;
  String? sts;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  String? image;
  String? staffName;
  String? clientName;

  AudioItem(
      this.direction,
      this.time,
      this.isAttend,
      this.date,
      this.status,
      this.resourceUrl,
      this.duration,
      this.voicePlayPermission,
      this.callHistoryId,
      this.isTransfer,
      this.token,
      this.callMasterId,
      this.image,
      this.staffName,
      this.clientName,
      {super.key,
      this.fromDate,
      this.toDate,
      this.sts,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled});

  @override
  State<AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  var dio = Dio();
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int maxDuration = 100;
  int currentPos = 0;
  String currentPostLabel = "00:00";
  bool isplaying = false;
  bool audioPlayed = false;
  Duration duration = Duration.zero; // For total duration
  Duration position = Duration.zero; // For the current position
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      audioPlayer.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxDuration = d.inMilliseconds;
        setState(() {});
      });

      audioPlayer.onPositionChanged.listen((Duration p) {
        currentPos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentPos).inHours;
        int sminutes = Duration(milliseconds: currentPos).inMinutes;
        int sseconds = Duration(milliseconds: currentPos).inSeconds;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentPostLabel = "$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {}
  }

  LeadDetails? lead;

  Future<void> setAudioPlayer() async {
    super.initState();
    audioPlayer.play(UrlSource(widget.resourceUrl));
    audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Card(
            margin: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.green.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 6,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              widget.direction.toString() == 'Incoming Call'
                                  ? const Icon(Icons.phone_callback_sharp,
                                      color: Colors.green, size: 20)
                                  : widget.direction.toString() == 'Missed Call'
                                      ? const Icon(
                                          Icons.phone_missed,
                                          color: Colors.red,
                                          size: 20,
                                        )
                                      : const Icon(Icons.phone_forwarded_sharp,
                                          color: Colors.blueAccent, size: 20),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                widget.direction.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2, bottom: 2),
                              child: SizedBox(
                                  width: 76,
                                  child: Center(
                                    child: Text(
                                      widget.status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: widget.status.toString() ==
                                                'ANSWERED'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(widget.time.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 14)),
                    ),
                    widget.isAttend == true &&
                            widget.voicePlayPermission == true
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      isPlaying == false
                                          ? audioPlayer.play(
                                              UrlSource(widget.resourceUrl))
                                          : await audioPlayer.pause();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 15,
                                      child: Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '$currentPostLabel/${widget.duration}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(
                                    height: 25,
                                    width: 135,
                                    child: Slider(
                                      min: 0,
                                      value: position.inMilliseconds.toDouble(),
                                      max: duration.inMilliseconds.toDouble(),
                                      onChanged: (value) {
                                        setState(() {
                                          position = Duration(
                                              milliseconds: value.toInt());
                                        });
                                        audioPlayer.seek(position);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Called By ${widget.staffName}'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    final whatsappLink =
                                        "https://wa.me?text=Name:${widget.clientName} \nUrl:${widget.resourceUrl}";
                                    await launch(whatsappLink);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.green.shade900,
                                      size: 15,
                                    ),
                                  ),
                                )
                              ],
                            )

                            // widget.isAttend == true &&
                            //         widget.voicePlayPermission == true
                            //     ? InkWell(
                            //         onTap: () async {
                            //           var statusPermission =
                            //               await Permission.storage.status;
                            //           if (!statusPermission.isGranted) {
                            //             await Permission.storage.request();
                            //           }
                            //           final tempDir =
                            //               await DownloadsPathProvider
                            //                   .downloadsDirectory;
                            //           String tempPath = tempDir.path;
                            //           final path = tempPath + '/login2';
                            //           bool directoryExists =
                            //               await Directory(path).exists();
                            //
                            //           if (directoryExists) {
                            //             print('Exist');
                            //
                            //             final newPath = path;
                            //             String fileName = 'rec-' +
                            //                 DateTime.now().toString() +
                            //                 '.wav';
                            //             String fullPath =
                            //                 "$newPath/" + fileName;
                            //             print('full path ${fullPath}');
                            //             final fileUrl = widget.resourceUrl;
                            //             download2(dio, fileUrl, fullPath);
                            //           } else {
                            //             print('Not Exist');
                            //             final newPath = await Directory(path)
                            //                 .create(recursive: true);
                            //             print(newPath);
                            //
                            //             String fileName = 'rec-' +
                            //                 DateTime.now().toString() +
                            //                 '.wav';
                            //             ;
                            //             String fullPath =
                            //                 "$newPath/" + fileName;
                            //             print('full path ${fullPath}');
                            //             final fileUrl = widget.resourceUrl;
                            //             download2(dio, fileUrl, fullPath);
                            //           }
                            //         },
                            //         child: CircleAvatar(
                            //           backgroundColor: Colors.white,
                            //           radius: 15,
                            //           child: Icon(
                            //             Icons.download,
                            //             color: Colors.green.shade900,
                            //             size: 15,
                            //           ),
                            //         ),
                            //       )
                            //     : SizedBox()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          bottom: 0.0,
          left: 35.0,
          child: Container(
            height: double.infinity,
            width: 1.0,
            color: Colors.blue,
          ),
        ),
        Positioned(
          top: 20.0,
          left: 5.0,
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 60,
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 20,
                    minWidth: 20,
                    maxHeight: 50,
                    maxWidth: 50,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0),
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
                        image: NetworkImage(widget.image.toString())),
                    // image: AssetImage(
                    //     'assets/images/img.jpeg')),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                width: 80.0,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        offset: Offset(1, 1)),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                    child: Text(DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(widget.date.toString())))),
              ),
            ],
          ),
        )
      ],
    );
  }
}
