import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:accordion/accordion.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/viewLeads.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/addMileStoneModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/createFolderModel.dart';
import '../../models/lead_management/deleteFolderAndFileModel.dart';
import '../../models/lead_management/deleteLeadFollowupModel.dart';
import '../../models/lead_management/deleteLeadMileStoneModel.dart';
import '../../models/lead_management/deleteLeadVoiceModel.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import '../../models/lead_management/leadDeatailsModel.dart';
import '../../models/lead_management/leadDeatailsModelAdd.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/leadTransferModel.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/renameFolderModel.dart';
import '../../models/lead_management/unsetReminderModel.dart';
import '../../models/lead_management/updateReminderSetings.dart';
import '../../models/lead_management/uploadAudioRecoed.dart';
import 'add_followup.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/leadManagement/editFollowup.dart';
import '../../screens/leadManagement/editLead.dart';
import '../../service/service.dart';
import 'add_leads.dart';
import 'audio_controller.dart';
import 'docViewWebView.dart';
import 'imageUploadController.dart';

// ignore: must_be_immutable
class LeadDetails extends StatefulWidget {
  String token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String callMasterId;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String pageName;
  bool? isCalled;
  String? searchKey;
  String? name;
  String? userId;
  bool? recordAccessPermission;
  int? scrollToIndex;
  int? page;
  int? pageSize;
  String? leadType;
  LeadDetails(
    this.token,
    this.editLead,
    this.deleteLead,
    this.cloudCall,
    this.callMasterId, {
    super.key,
    this.fromDate,
    this.toDate,
    this.status,
    this.category,
    this.staff,
    required this.pageName,
    this.isCalled,
    this.searchKey,
    this.name,
    this.userId,
    this.recordAccessPermission,
    this.scrollToIndex,
    this.page,
    this.pageSize,
    this.leadType,
  });

  @override
  State<LeadDetails> createState() => _LeadDetailsState();
}

class _LeadDetailsState extends State<LeadDetails> {
  AddLeadCommonDataModel? commonDetails;
  var dio = Dio();
  TextEditingController transferRemark = TextEditingController();
  TextEditingController folderName = TextEditingController();
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();
  TextEditingController timeBefore = TextEditingController();
  TextEditingController remarks = TextEditingController();
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
  String deletePath = '';
  bool addCustomeFeild = false;
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

  LeadMileStoneListModel? mileStone;
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
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());

  bool folderActionEnable = false;
  String rawId = '';
  String selectedRawIndex = '';
  String editableName = '';
  bool checked = false;
  PlatformFile? file;
  bool isFile = false;
  bool isExpanded = false;
  List checkedItems = [];
  List checkedItemsName = [];
  String accessCallRecordingPermission = '';
  bool timeOut = false;
  String callMasterId = "";
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    callMasterId = widget.callMasterId;
    getData();
    widget.fromDate ??= DateTime.now().toString();
    widget.toDate ??= DateTime.now().toString();
  }

  getData() async {
    setState(() {
      timeOut = false;
    });
    try {
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
      await Common.saveSharedPref("openAppLeadId", '0');
      leadDetails = await HttpService.leadDetails(widget.token, callMasterId);
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      if (leadDetails != null) {
        setState(() {
          // final myString = leadDetails!.data!.contactNumber1.toString();
          // int countryCodeLengt = leadDetails!.data!.countryCode!.length;
          // whatsappNo1 = myString.substring(countryCodeLengt);
          whatsappNo1 = leadDetails!.data!.contactNumber1.toString();
          whatsappNo = leadDetails!.data!.contactNumber1.toString();
          contactFName.text = leadDetails!.data!.clientName.toString();
          contactMobile.text = '+${leadDetails!.data!.contactNumber1}';
        });
        listAddonDet(widget.token, callMasterId);
        listFolderList(widget.token, callMasterId, '');
        listMileStone(widget.token, callMasterId);
      } else {
        setState(() {
          timeOut = true;
        });
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        timeOut = true;
      });
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

  listMileStone(
    token,
    callMasterId,
  ) async {
    mileStone = await HttpService.leadMileStone(token, callMasterId);
    if (mileStone != null) {
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
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) async {
        try {
          if (widget.pageName == "notification") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard(widget.token)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewLeads(
                        widget.token,
                        widget.editLead,
                        widget.deleteLead,
                        widget.cloudCall,
                        pageName: widget.pageName,
                        status: widget.status,
                        staff: widget.staff,
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
            Navigator.pop(context);
          }
        } catch (e) {
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   backgroundColor: Colors.red,
          //   content: Text(stackTrace.toString()),
          //   duration: Duration(seconds: 15),
          // ));
          log(e.toString());
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getData();
          return;
        },
        child: result == true && timeOut == false
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
                                onTap: () async {
                                  if (widget.pageName == "notification") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Dashboard(widget.token)),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                                widget.token,
                                                widget.editLead,
                                                widget.deleteLead,
                                                widget.cloudCall,
                                                pageName: widget.pageName,
                                                status: widget.status,
                                                staff: widget.staff,
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
                                    Navigator.pop(context);
                                  }
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
                              child: Dismissible(
                                key: const Key('0'),
                                background: Container(
                                  color: Colors.green,
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Icon(
                                          Icons.call,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          " Call",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.blue,
                                  child: const Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      
                                        Text(
                                          " Add Followup",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    if (leadDetails!.data!.callPermission ==
                                        false) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              title: const Text('Alert !!!'),
                                              content: Text(leadDetails!
                                                  .data!.warningMessage
                                                  .toString()),
                                              actions: [
                                                // The "Yes" button
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Close')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => LeadDetails(
                                                                widget.token,
                                                                widget.editLead,
                                                                widget
                                                                    .deleteLead,
                                                                widget
                                                                    .cloudCall,
                                                                leadDetails!
                                                                    .data!
                                                                    .callLeadId
                                                                    .toString(),
                                                                pageName: widget
                                                                    .pageName,
                                                                status: widget
                                                                    .status,
                                                                staff: widget
                                                                    .staff,
                                                                isCalled: widget
                                                                    .isCalled,
                                                                fromDate: widget
                                                                    .fromDate,
                                                                toDate: widget
                                                                    .toDate,
                                                                category: widget
                                                                    .category,
                                                                scrollToIndex:
                                                                    widget
                                                                        .scrollToIndex,
                                                                page:
                                                                    widget.page,
                                                                pageSize: widget
                                                                    .pageSize,
                                                                leadType: widget
                                                                    .leadType)),
                                                      );
                                                    },
                                                    child:
                                                        const Text('followup')),
                                              ],
                                            );
                                          });
                                    } else {
                                      if (widget.cloudCall == true) {
                                        chooseCallDialog(context);
                                      } else {
                                        String url =
                                            'tel:+${leadDetails!.data!.contactNumber1}';
                                        await launch(url);
                                      }
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddFollowup(
                                              widget.token,
                                              widget.editLead,
                                              widget.deleteLead,
                                              widget.cloudCall,
                                              widget.callMasterId,
                                              pageName: widget.pageName,
                                              status: widget.status,
                                              staff: widget.staff,
                                              isCalled: widget.isCalled,
                                              fromDate: widget.fromDate,
                                              toDate: widget.toDate,
                                              category: widget.category,
                                              leadType: leadDetails!
                                                  .data!.leadCategory,
                                              leadTypeId: leadDetails!
                                                  .data!.leadCategoryId,
                                              leadSubType: leadDetails!
                                                  .data!.leadSubCategory,
                                              leadSubTypeId: leadDetails!
                                                  .data!.leadSubCategoryId,
                                              priority:
                                                  leadDetails!.data!.priority,
                                              priorityId:
                                                  leadDetails!.data!.priorityId,
                                              cost: leadDetails!.data!.cost,
                                              address:
                                                  leadDetails!.data!.address,
                                              searchKey:
                                                  widget.searchKey.toString(),
                                              leadType1: widget.leadType)),
                                    ).then((r) {
                                      getData();
                                    });
                                  }

                                  return null;
                                },
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
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
                                                            leadDetails!.data!
                                                                .clientName
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                leadDetails!
                                                            .data!
                                                            .leadCategories!
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
                                                              PopupMenuItem<
                                                                      int>(
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
                                                                              size: 20,
                                                                              color: Colors.green,
                                                                            )
                                                                          : const SizedBox(
                                                                              width: 15,
                                                                            ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
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
                                                          callMasterId =
                                                              value.toString();
                                                          getData();
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                          leadDetails!.data!
                                                              .callResultId
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
                                                              color: Colors
                                                                  .black54,
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
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: InkWell(
                                              onTap: () async {
                                                if (leadDetails!
                                                        .data!.callPermission ==
                                                    false) {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext ctx) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Alert !!!'),
                                                          content: Text(
                                                              leadDetails!.data!
                                                                  .warningMessage
                                                                  .toString()),
                                                          actions: [
                                                            // The "Yes" button
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    'Close')),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => LeadDetails(
                                                                            widget
                                                                                .token,
                                                                            widget
                                                                                .editLead,
                                                                            widget
                                                                                .deleteLead,
                                                                            widget
                                                                                .cloudCall,
                                                                            leadDetails!.data!.callLeadId
                                                                                .toString(),
                                                                            pageName:
                                                                                widget.pageName,
                                                                            status: widget.status,
                                                                            staff: widget.staff,
                                                                            isCalled: widget.isCalled,
                                                                            fromDate: widget.fromDate,
                                                                            toDate: widget.toDate,
                                                                            category: widget.category,
                                                                            scrollToIndex: widget.scrollToIndex,
                                                                            page: widget.page,
                                                                            pageSize: widget.pageSize,
                                                                            leadType: widget.leadType)),
                                                                  );
                                                                },
                                                                child: const Text(
                                                                    'followup')),
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  if (widget.cloudCall ==
                                                      true) {
                                                    chooseCallDialog(context);
                                                  } else {
                                                    String url =
                                                        'tel:+${leadDetails!.data!.contactNumber1}';
                                                    await launch(url);
                                                  }
                                                }
                                              },
                                              child: Container(
                                                width: 85,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.call,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text('Call',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "MontserratMedium",
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: InkWell(
                                              onTap: () async {
                                                widget.editLead == true
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => EditLead(
                                                                widget.token,
                                                                widget
                                                                    .callMasterId,
                                                                widget.editLead,
                                                                widget
                                                                    .deleteLead,
                                                                widget
                                                                    .cloudCall,
                                                                pageName: widget
                                                                    .pageName,
                                                                status: widget
                                                                    .status,
                                                                staff: widget
                                                                    .staff,
                                                                isCalled: widget
                                                                    .isCalled,
                                                                fromDate: widget
                                                                    .fromDate,
                                                                toDate: widget
                                                                    .toDate,
                                                                category: widget
                                                                    .category,
                                                                scrolToIndex: widget
                                                                    .scrollToIndex)),
                                                      ).then((r) {
                                                        getData();
                                                      })
                                                    : _dialogue(
                                                        context, 'Edit Leads');
                                              },
                                              child: Container(
                                                width: 85,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text('Edit',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "MontserratMedium",
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: InkWell(
                                              onTap: () async {
                                                showGeneralDialog(
                                                  barrierLabel:
                                                      "showGeneralDialog",
                                                  barrierDismissible: true,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.6),
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 400),
                                                  context: context,
                                                  pageBuilder:
                                                      (context, _, __) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: IntrinsicHeight(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    right: 10),
                                                            child: Container(
                                                              width: double
                                                                  .maxFinite,
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                              child: Material(
                                                                child: Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    const Text(
                                                                      'Transfer Leads',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    FormField<
                                                                        String>(
                                                                      builder: (FormFieldState<
                                                                              String>
                                                                          state) {
                                                                        return Container(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.9,
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Colors.grey.shade900, width: 0),
                                                                              color: Colors.white,
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                                          child:
                                                                              DropdownButtonHideUnderline(
                                                                            child:
                                                                                DropdownButton<String>(
                                                                              isExpanded: true,
                                                                              hint: const Padding(
                                                                                padding: EdgeInsets.only(left: 20),
                                                                                child: Text('Staff'),
                                                                              ),
                                                                              value: staff,
                                                                              items: commonDetails!.data.transferStaffs.map((data) {
                                                                                return DropdownMenuItem(
                                                                                  value: data.tranStaffId.toString(),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 20),
                                                                                    child: Text(data.tranStaffName.toString()),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (newValue) {
                                                                                setState(() {
                                                                                  staff = newValue;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    TextFormField(
                                                                      controller:
                                                                          transferRemark,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return "Remark";
                                                                        }
                                                                        return null;
                                                                      },
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .name,
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          //<-- SEE HERE
                                                                          fillColor: Colors.white,
                                                                          counterText: "",
                                                                          hintText: "Remark",
                                                                          isDense: true,
                                                                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          25,
                                                                    ),
                                                                    Container(
                                                                      height:
                                                                          40,
                                                                      width: double
                                                                          .maxFinite,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Color(
                                                                            0xFF3375e0),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8)),
                                                                      ),
                                                                      child:
                                                                          RawMaterialButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (staff ==
                                                                              null) {
                                                                            Common.toastMessaage('Choose Staff Name',
                                                                                Colors.red);
                                                                          } else {
                                                                            Common.showProgressDialog(context,
                                                                                "Loading..");
                                                                            LeadTransferModel transfer = await HttpService.leadTransfer(
                                                                                widget.token,
                                                                                callMasterId,
                                                                                staff,
                                                                                transferRemark.text);
                                                                            if (transfer.status ==
                                                                                true) {
                                                                              Common.toastMessaage(transfer.message, Colors.green);
                                                                              if (context.mounted) {
                                                                                Navigator.pop(context);
                                                                                Navigator.pop(context);
                                                                                getData();
                                                                              }
                                                                            } else {
                                                                              Common.toastMessaage(transfer.message, Colors.red);
                                                                              if (context.mounted) {
                                                                                Navigator.of(context, rootNavigator: true).pop();
                                                                              }
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Text(
                                                                            'Continue',
                                                                            style:
                                                                                TextStyle(
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
                                                    });
                                                  },
                                                  transitionBuilder: (_,
                                                      animation1, __, child) {
                                                    return SlideTransition(
                                                      position: Tween(
                                                        begin:
                                                            const Offset(0, 1),
                                                        end: const Offset(0, 0),
                                                      ).animate(animation1),
                                                      child: child,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: 85,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .transfer_within_a_station,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text('Transfer',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "MontserratMedium",
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddLeads(
                                                    widget.token,
                                                    page: 'leadDetails',
                                                    leadMasterId: leadDetails!
                                                        .data!.callMasterId,
                                                    clientName: leadDetails!
                                                        .data!.clientName,
                                                    phoneNumber: leadDetails!
                                                        .data!.contactNumber1,
                                                    countryCode: leadDetails!
                                                        .data!.countryCode,
                                                    fromDate: widget.fromDate,
                                                    toDate: widget.toDate,
                                                    editLead: widget.editLead,
                                                    deleteLead:
                                                        widget.deleteLead,
                                                    cloudCall: widget.cloudCall,
                                                  ),
                                                ),
                                              ).then((r) {
                                                getData();
                                              });
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            leadDetailsAdditional != null &&
                                    listFolder != null &&
                                    mileStone != null
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
                                                : const SizedBox(),
                                            mileStone!.data!.milestones!
                                                    .isNotEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIndex = 5;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .25,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0),
                                                            color: selectedIndex ==
                                                                    5
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
                                                                'Mile Stone',
                                                                style:
                                                                    TextStyle(
                                                                  color: selectedIndex ==
                                                                          5
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
                                                    onTap: () {
                                                      if (leadDetailsAdditional!
                                                              .data!
                                                              .followUpData![
                                                                  index]
                                                              .isCalled ==
                                                          false) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => AddFollowup(
                                                                  widget.token,
                                                                  widget
                                                                      .editLead,
                                                                  widget
                                                                      .deleteLead,
                                                                  widget
                                                                      .cloudCall,
                                                                  widget
                                                                      .callMasterId,
                                                                  pageName: widget
                                                                      .pageName,
                                                                  status: widget
                                                                      .status,
                                                                  staff: widget
                                                                      .staff,
                                                                  isCalled: widget
                                                                      .isCalled,
                                                                  fromDate: widget
                                                                      .fromDate,
                                                                  toDate: widget
                                                                      .toDate,
                                                                  category: widget
                                                                      .category,
                                                                  leadType: leadDetails!
                                                                      .data!
                                                                      .leadCategory,
                                                                  leadTypeId: leadDetails!
                                                                      .data!
                                                                      .leadCategoryId,
                                                                  leadSubType:
                                                                      leadDetails!
                                                                          .data!
                                                                          .leadSubCategory,
                                                                  leadSubTypeId: leadDetails!.data!.leadSubCategoryId,
                                                                  priority: leadDetails!.data!.priority,
                                                                  priorityId: leadDetails!.data!.priorityId,
                                                                  cost: leadDetails!.data!.cost,
                                                                  address: leadDetails!.data!.address,
                                                                  searchKey: widget.searchKey.toString(),
                                                                  leadType1: widget.leadType)),
                                                        ).then((r) {
                                                          getData();
                                                        });
                                                      }
                                                    },
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
                                                                  Row(
                                                                    children: [
                                                                      leadDetailsAdditional!.data!.followUpData![index].isSetReminder ==
                                                                              true
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                timeBefore.text = leadDetailsAdditional!.data!.followUpData![index].time.toString();
                                                                                checked = leadDetailsAdditional!.data!.followUpData![index].isReminder!;
                                                                                // print(callMasterId);
                                                                                showGeneralDialog(
                                                                                  barrierLabel: "showGeneralDialog",
                                                                                  barrierDismissible: true,
                                                                                  barrierColor: Colors.black.withOpacity(0.6),
                                                                                  transitionDuration: const Duration(milliseconds: 400),
                                                                                  context: context,
                                                                                  pageBuilder: (context, _, __) {
                                                                                    return StatefulBuilder(builder: (context, setState) {
                                                                                      return Align(
                                                                                        alignment: Alignment.center,
                                                                                        child: IntrinsicHeight(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                                                                            child: Container(
                                                                                              width: double.maxFinite,
                                                                                              clipBehavior: Clip.antiAlias,
                                                                                              padding: const EdgeInsets.all(16),
                                                                                              decoration: const BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.only(
                                                                                                  topLeft: Radius.circular(10),
                                                                                                  topRight: Radius.circular(10),
                                                                                                  bottomRight: Radius.circular(10),
                                                                                                  bottomLeft: Radius.circular(10),
                                                                                                ),
                                                                                              ),
                                                                                              child: Material(
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    const SizedBox(height: 20),
                                                                                                    const Text(
                                                                                                      'Set Reminder',
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(height: 20),
                                                                                                    TextFormField(
                                                                                                      controller: timeBefore,
                                                                                                      keyboardType: TextInputType.number,
                                                                                                      decoration: const InputDecoration(
                                                                                                          contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                                                                                                          labelText: 'Time Before ( Min )',
                                                                                                          fillColor: Colors.white,
                                                                                                          filled: true,
                                                                                                          prefixIcon: Icon(Icons.lock_clock, color: Colors.grey),
                                                                                                          border: OutlineInputBorder(),
                                                                                                          focusedBorder: OutlineInputBorder(
                                                                                                            borderSide: BorderSide(color: Colors.grey),
                                                                                                          ),
                                                                                                          labelStyle: TextStyle(color: Colors.grey)),
                                                                                                    ),
                                                                                                    leadDetailsAdditional!.data!.followUpData![index].isReminder == true
                                                                                                        ? Align(
                                                                                                            alignment: Alignment.topRight,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.only(top: 15),
                                                                                                              child: InkWell(
                                                                                                                  onTap: () async {
                                                                                                                    UnsetReminderModel unsetReminder = await HttpService.unsetReminder(widget.token, leadDetailsAdditional!.data!.followUpData![index].callDetailsId.toString());
                                                                                                                    if (unsetReminder.data == true) {
                                                                                                                      if (mounted) {
                                                                                                                        Common.showProgressDialog(context, "Loading..");
                                                                                                                        Navigator.push(
                                                                                                                          context,
                                                                                                                          MaterialPageRoute(
                                                                                                                              builder: (context) => LeadDetails(
                                                                                                                                    widget.token,
                                                                                                                                    widget.editLead,
                                                                                                                                    widget.deleteLead,
                                                                                                                                    widget.cloudCall,
                                                                                                                                    callMasterId,
                                                                                                                                    pageName: widget.pageName,
                                                                                                                                    status: widget.status,
                                                                                                                                    staff: widget.staff,
                                                                                                                                    isCalled: widget.isCalled,
                                                                                                                                    fromDate: widget.fromDate,
                                                                                                                                    toDate: widget.toDate,
                                                                                                                                    category: widget.category,
                                                                                                                                    searchKey: widget.searchKey,
                                                                                                                                    leadType: widget.leadType,
                                                                                                                                  )),
                                                                                                                        );
                                                                                                                      }
                                                                                                                    } else {
                                                                                                                      Common.toastMessaage(unsetReminder.message, Colors.red);
                                                                                                                      if (context.mounted) {
                                                                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                                                                      }
                                                                                                                    }
                                                                                                                  },
                                                                                                                  child: const Text(
                                                                                                                    'Unset Reminder',
                                                                                                                    style: TextStyle(fontSize: 13, color: Colors.red),
                                                                                                                  )),
                                                                                                            ),
                                                                                                          )
                                                                                                        : const SizedBox(),
                                                                                                    const SizedBox(
                                                                                                      height: 25,
                                                                                                    ),
                                                                                                    Container(
                                                                                                      height: 40,
                                                                                                      width: double.maxFinite,
                                                                                                      decoration: const BoxDecoration(
                                                                                                        color: Color(0xFF3375e0),
                                                                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                                                      ),
                                                                                                      child: RawMaterialButton(
                                                                                                        onPressed: () async {
                                                                                                          if (timeBefore.text.isEmpty || timeBefore.text == '0') {
                                                                                                            Common.toastMessaage('Ser Time', Colors.red);
                                                                                                          } else {
                                                                                                            Common.showProgressDialog(context, "Loading..");
                                                                                                            UpdateReminderSetting updateReminder = await HttpService.updateReminder(widget.token, leadDetailsAdditional!.data!.followUpData![index].callDetailsId, true, timeBefore.text);
                                                                                                            if (updateReminder.status == true) {
                                                                                                              Common.toastMessaage(updateReminder.message, Colors.green);
                                                                                                              if (context.mounted) {
                                                                                                                Navigator.push(
                                                                                                                  context,
                                                                                                                  MaterialPageRoute(
                                                                                                                      builder: (context) => LeadDetails(
                                                                                                                            widget.token,
                                                                                                                            widget.editLead,
                                                                                                                            widget.deleteLead,
                                                                                                                            widget.cloudCall,
                                                                                                                            callMasterId,
                                                                                                                            pageName: widget.pageName,
                                                                                                                            status: widget.status,
                                                                                                                            staff: widget.staff,
                                                                                                                            isCalled: widget.isCalled,
                                                                                                                            fromDate: widget.fromDate,
                                                                                                                            toDate: widget.toDate,
                                                                                                                            category: widget.category,
                                                                                                                            searchKey: widget.searchKey,
                                                                                                                            leadType: widget.leadType,
                                                                                                                          )),
                                                                                                                );
                                                                                                              }
                                                                                                            } else {
                                                                                                              Common.toastMessaage(updateReminder.message, Colors.red);
                                                                                                              if (context.mounted) {
                                                                                                                Navigator.of(context, rootNavigator: true).pop();
                                                                                                              }
                                                                                                            }
                                                                                                          }
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
                                                                              },
                                                                              child: Icon(
                                                                                Icons.notifications,
                                                                                color: leadDetailsAdditional!.data!.followUpData![index].isReminder == true ? Colors.green : Colors.red,
                                                                                size: 20,
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      leadDetailsAdditional!.data!.followUpData![index].isEdit ==
                                                                              true
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => EditFollowup(
                                                                                            widget.token,
                                                                                            widget.editLead,
                                                                                            widget.deleteLead,
                                                                                            widget.cloudCall,
                                                                                            callMasterId,
                                                                                            leadDetailsAdditional!.data!.followUpData![index].callDetailsId.toString(),
                                                                                            pageName: widget.pageName,
                                                                                            status: widget.status,
                                                                                            staff: widget.staff,
                                                                                            isCalled: widget.isCalled,
                                                                                            fromDate: widget.fromDate,
                                                                                            toDate: widget.toDate,
                                                                                            category: widget.category,
                                                                                            scrollToIndex: widget.scrollToIndex,
                                                                                          )),
                                                                                ).then((r) {
                                                                                  getData();
                                                                                });
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.edit,
                                                                                color: Colors.blue,
                                                                                size: 20,
                                                                              ))
                                                                          : const SizedBox(),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      leadDetailsAdditional!.data!.followUpData![index].isDelete ==
                                                                              true
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                _deleteFollowup(context, leadDetailsAdditional!.data!.followUpData![index].callDetailsId);
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.delete,
                                                                                color: Colors.red,
                                                                                size: 20,
                                                                              ))
                                                                          : const SizedBox(),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
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
                                                              leadDetailsAdditional!
                                                                          .data!
                                                                          .followUpData![
                                                                              index]
                                                                          .reason !=
                                                                      ''
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        'Reason: ${leadDetailsAdditional!.data!.followUpData![index].reason}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                              leadDetailsAdditional!
                                                                          .data!
                                                                          .followUpData![
                                                                              index]
                                                                          .callResponse !=
                                                                      ''
                                                                  ? Text(
                                                                      'Call Response : ${leadDetailsAdditional!.data!.followUpData![index].callResponse}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    )
                                                                  : const SizedBox(),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              leadDetailsAdditional!
                                                                          .data!
                                                                          .followUpData![
                                                                              index]
                                                                          .playVoicePermission ==
                                                                      true
                                                                  ? Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showGeneralDialog(
                                                                            barrierLabel:
                                                                                "showGeneralDialog",
                                                                            barrierDismissible:
                                                                                false,
                                                                            barrierColor:
                                                                                Colors.black.withOpacity(0.6),
                                                                            transitionDuration:
                                                                                const Duration(milliseconds: 400),
                                                                            context:
                                                                                context,
                                                                            pageBuilder: (context,
                                                                                _,
                                                                                __) {
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
                                                                                            const Text(
                                                                                              'File Information',
                                                                                              style: TextStyle(
                                                                                                fontSize: 18,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(height: 20),
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
                                                                                                          audioCreateController.playVoice(leadDetailsAdditional!.data!.followUpData![index].voiceFile);
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
                                                                            transitionBuilder: (_,
                                                                                animation1,
                                                                                __,
                                                                                child) {
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
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                                width: 85,
                                                                                height: 35,
                                                                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))),
                                                                                child: const Center(
                                                                                    child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.play_arrow,
                                                                                      color: Colors.green,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      'Play',
                                                                                      style: TextStyle(color: Colors.green),
                                                                                    ),
                                                                                  ],
                                                                                ))),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Please Confirm'),
                                                                                        content: const Text('Are you sure to Remove this Voice?'),
                                                                                        actions: [
                                                                                          // The "Yes" button
                                                                                          TextButton(
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: const Text('No')),
                                                                                          TextButton(
                                                                                              onPressed: () async {
                                                                                                Common.showProgressDialog(context, "Uploading..");
                                                                                                DeleteLeadVoiceModel deleteVoice = await HttpService.deleteLeadVoice(
                                                                                                  widget.token,
                                                                                                  callMasterId,
                                                                                                  leadDetailsAdditional!.data!.followUpData![index].callDetailsId.toString(),
                                                                                                );
                                                                                                if (deleteVoice.data == true) {
                                                                                                  getData();
                                                                                                  if (mounted) {
                                                                                                    Navigator.of(context).pop();
                                                                                                    Navigator.of(context).pop();
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              child: const Text('Yes')),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Container(
                                                                                height: 35,
                                                                                width: 30,
                                                                                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.grey.shade100, borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))),
                                                                                child: const Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : leadDetailsAdditional!
                                                                              .data!
                                                                              .followUpData![
                                                                                  index]
                                                                              .voiceUploadPermission ==
                                                                          true
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showGeneralDialog(
                                                                              barrierLabel: "showGeneralDialog",
                                                                              barrierDismissible: false,
                                                                              barrierColor: Colors.black.withOpacity(0.6),
                                                                              transitionDuration: const Duration(milliseconds: 400),
                                                                              context: context,
                                                                              pageBuilder: (context, _, __) {
                                                                                return Obx(() {
                                                                                  return AlertDialog(
                                                                                    content: IntrinsicHeight(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          audioCreateController.isRecording.value | audioCreateController.audioPath.isNotEmpty
                                                                                              ? Column(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                                                                                                      style: const TextStyle(fontSize: 30),
                                                                                                    ),
                                                                                                    if (audioCreateController.isRecording.value) const Text("Voice Recording..."),
                                                                                                  ],
                                                                                                )
                                                                                              : const Column(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  children: [
                                                                                                    SizedBox(
                                                                                                      height: 10,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Voice Record ',
                                                                                                      style: TextStyle(fontSize: 18),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      height: 20,
                                                                                                    ),
                                                                                                    Text("Do you want to record voice?"),
                                                                                                  ],
                                                                                                ),
                                                                                          const SizedBox(height: 20.0),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(bottom: 20.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                if (audioCreateController.isRecording.value == false && audioCreateController.audioPath.isNotEmpty)
                                                                                                  FloatingActionButton(
                                                                                                      heroTag: "play tag",
                                                                                                      onPressed: () {
                                                                                                        audioCreateController.resetTimer();
                                                                                                        audioCreateController.playRcording();
                                                                                                      },
                                                                                                      shape: const CircleBorder(),
                                                                                                      backgroundColor: Colors.white,
                                                                                                      foregroundColor: Colors.teal,
                                                                                                      child: const Icon(
                                                                                                        Icons.play_arrow_rounded,
                                                                                                        color: Colors.green,
                                                                                                        size: 30,
                                                                                                      )),
                                                                                                const SizedBox(
                                                                                                  width: 25,
                                                                                                ),
                                                                                                if (audioCreateController.isRecording.value == true)
                                                                                                  FloatingActionButton(
                                                                                                      heroTag: "start tag",
                                                                                                      onPressed: () {
                                                                                                        audioCreateController.stopRecording();
                                                                                                        // recordController.stopTimer();
                                                                                                      },
                                                                                                      shape: const CircleBorder(),
                                                                                                      backgroundColor: Colors.redAccent,
                                                                                                      foregroundColor: Colors.white,
                                                                                                      child: const Text("Stop")),
                                                                                                const SizedBox(
                                                                                                  width: 25,
                                                                                                ),
                                                                                                if (audioCreateController.isRecording.value == false && audioCreateController.audioPath.isNotEmpty)
                                                                                                  FloatingActionButton(
                                                                                                      heroTag: "delete tag",
                                                                                                      onPressed: () {
                                                                                                        showDialog(
                                                                                                            context: context,
                                                                                                            builder: (BuildContext context) {
                                                                                                              return AlertDialog(
                                                                                                                title: const Text('Are You Sure'),
                                                                                                                iconColor: Colors.blue,
                                                                                                                actions: <Widget>[
                                                                                                                  TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      Get.back();
                                                                                                                    },
                                                                                                                    child: const Text('Cancel'),
                                                                                                                  ),
                                                                                                                  TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      audioCreateController.resetTimer();
                                                                                                                      audioCreateController.audioPath.value = "";
                                                                                                                      Get.back();
                                                                                                                    },
                                                                                                                    child: const Text('Delete'),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              );
                                                                                                            });
                                                                                                      },
                                                                                                      shape: const CircleBorder(),
                                                                                                      backgroundColor: Colors.white,
                                                                                                      foregroundColor: Colors.red,
                                                                                                      child: const Icon(
                                                                                                        Icons.delete,
                                                                                                        color: Colors.red,
                                                                                                        size: 30,
                                                                                                      )),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      audioCreateController.isRecording.value == false
                                                                                          ? TextButton(
                                                                                              onPressed: () async {
                                                                                                if (audioCreateController.audioPath.value != '') {
                                                                                                  audioCreateController.resetTimer();
                                                                                                  audioCreateController.audioPath.value = "";
                                                                                                }

                                                                                                Get.back();
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Back',
                                                                                                style: TextStyle(color: Colors.black),
                                                                                              ),
                                                                                            )
                                                                                          : const SizedBox(),
                                                                                      audioCreateController.isRecording.value == false && audioCreateController.audioPath.isNotEmpty
                                                                                          ? TextButton(
                                                                                              onPressed: () async {
                                                                                                Common.showProgressDialog(context, "Uploading..");
                                                                                                UploadAudioRecord uploadAudio = await HttpService.leadVoiceUpload(
                                                                                                  widget.token,
                                                                                                  callMasterId,
                                                                                                  leadDetailsAdditional!.data!.followUpData![index].callDetailsId.toString(),
                                                                                                  audioCreateController.audioPath.value.toString(),
                                                                                                );
                                                                                                if (uploadAudio.data == true) {
                                                                                                  audioCreateController.audioPath.value = '';
                                                                                                  audioCreateController.resetTimer();
                                                                                                  Common.toastMessaage(uploadAudio.message, Colors.green);

                                                                                                  if (mounted) {
                                                                                                    getData();
                                                                                                    Get.back();
                                                                                                    Get.back();
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Save',
                                                                                                style: TextStyle(color: Colors.green),
                                                                                              ),
                                                                                            )
                                                                                          : audioCreateController.isRecording.value == false
                                                                                              ? TextButton(
                                                                                                  onPressed: () {
                                                                                                    if (audioCreateController.audioPath.isNotEmpty) {
                                                                                                      audioCreateController.isBack.value = true;
                                                                                                      audioCreateController.resetTimer();

                                                                                                      audioCreateController.startRecording();
                                                                                                    } else {
                                                                                                      audioCreateController.startRecording();
                                                                                                    }
                                                                                                    isBack = true;
                                                                                                  },
                                                                                                  child: const Text(
                                                                                                    'Record',
                                                                                                    style: TextStyle(color: Colors.black),
                                                                                                  ),
                                                                                                )
                                                                                              : const SizedBox(),
                                                                                    ],
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
                                                                          },
                                                                          child: Container(
                                                                              width: 95,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                border: Border.all(color: Colors.grey.shade300),
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: const Center(
                                                                                  child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.mic,
                                                                                    color: Colors.green,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    'Upload',
                                                                                    style: TextStyle(color: Colors.green),
                                                                                  ),
                                                                                ],
                                                                              ))))
                                                                      : const SizedBox(),
                                                              const SizedBox(
                                                                height: 10,
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
                                                    leadDetailsAdditional!.data!
                                                        .callHistory![i].time
                                                        .toString(),
                                                    leadDetailsAdditional!
                                                        .data!
                                                        .callHistory![i]
                                                        .isAttended!,
                                                    leadDetailsAdditional!.data!
                                                        .callHistory![i].date
                                                        .toString(),
                                                    leadDetailsAdditional!.data!
                                                        .callHistory![i].status
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
                                                    leadDetailsAdditional!.data!
                                                        .voiceListerningPermission!,
                                                    leadDetailsAdditional!.data!
                                                        .callHistory![i].id
                                                        .toString(),
                                                    leadDetailsAdditional!
                                                        .data!
                                                        .callHistory![i]
                                                        .isTransfered!,
                                                    widget.token,
                                                    widget.editLead,
                                                    widget.deleteLead,
                                                    widget.cloudCall,
                                                    callMasterId,
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
                                                    category: widget.category,
                                                  );
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
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, left: 10, right: 10),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: Colors.grey)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      decoration: const BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          5))),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          'Basic Details ',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Client Name',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.45,
                                                            child: Text(
                                                              leadDetails!.data!
                                                                  .clientName
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Phone',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .contactNumber1
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Assigned to',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .staffName
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Created date',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .createdDate
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Call Result',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .callResult
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Cost',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!.cost
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Source',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .leadMethod
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                              child: const Text(
                                                                'Remark',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          const Text(':'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.45,
                                                              child: Text(
                                                                leadDetails!
                                                                    .data!
                                                                    .remarks
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
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
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            leadDetailsAdditional!
                                                    .data!
                                                    .additionalFields!
                                                    .isNotEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          5)),
                                                            ),
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                'Additional Fields',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
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
                                                              itemBuilder:
                                                                  (context, i) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          top:
                                                                              5),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.44,
                                                                          child:
                                                                              Text(
                                                                            leadDetailsAdditional!.data!.additionalFields![i].name.toString(),
                                                                            style:
                                                                                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )),
                                                                      const Text(
                                                                          ':'),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.4,
                                                                          child:
                                                                              Text(
                                                                            leadDetailsAdditional!.data!.additionalFields![i].value.toString(),
                                                                            style:
                                                                                const TextStyle(fontSize: 14),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                );
                                                              }),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
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
                                                                          path =
                                                                              '$backPath/';
                                                                        } else {
                                                                          backPath =
                                                                              '';
                                                                          path =
                                                                              backPath;
                                                                        }
                                                                        listPath =
                                                                            backPath;
                                                                        folderActionEnable ==
                                                                            false;
                                                                        selectedRawIndex =
                                                                            '';
                                                                        listFolderList(
                                                                            widget.token,
                                                                            callMasterId,
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
                                                            InkWell(
                                                              onTap: () {
                                                                fileManagerPermission!
                                                                            .data!
                                                                            .createFile ==
                                                                        true
                                                                    ? showGeneralDialog(
                                                                        barrierLabel:
                                                                            "showGeneralDialog",
                                                                        barrierDismissible:
                                                                            true,
                                                                        barrierColor: Colors
                                                                            .black
                                                                            .withOpacity(0.6),
                                                                        transitionDuration:
                                                                            const Duration(milliseconds: 400),
                                                                        context:
                                                                            context,
                                                                        pageBuilder: (context,
                                                                            _,
                                                                            __) {
                                                                          return StatefulBuilder(builder:
                                                                              (context, setState) {
                                                                            return Align(
                                                                              alignment: Alignment.center,
                                                                              child: IntrinsicHeight(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                                                  child: Container(
                                                                                    width: double.maxFinite,
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    padding: const EdgeInsets.all(16),
                                                                                    decoration: const BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topLeft: Radius.circular(10),
                                                                                        topRight: Radius.circular(10),
                                                                                        bottomRight: Radius.circular(10),
                                                                                        bottomLeft: Radius.circular(10),
                                                                                      ),
                                                                                    ),
                                                                                    child: Material(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          const SizedBox(height: 20),
                                                                                          const Text(
                                                                                            'New Folder',
                                                                                            style: TextStyle(
                                                                                              fontSize: 18,
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 20),
                                                                                          TextFormField(
                                                                                            controller: folderName,
                                                                                            style: const TextStyle(
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                            validator: (value) {
                                                                                              if (value!.isEmpty) {
                                                                                                return "New Folder";
                                                                                              }
                                                                                              return null;
                                                                                            },
                                                                                            decoration: InputDecoration(
                                                                                                filled: true,
                                                                                                //<-- SEE HERE
                                                                                                fillColor: Colors.white,
                                                                                                counterText: "",
                                                                                                hintText: "Folder Name",
                                                                                                isDense: true,
                                                                                                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 25,
                                                                                          ),
                                                                                          Container(
                                                                                            height: 40,
                                                                                            width: double.maxFinite,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Color(0xFF3375e0),
                                                                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                                            ),
                                                                                            child: RawMaterialButton(
                                                                                              onPressed: () async {
                                                                                                if (folderName.text.isEmpty) {
                                                                                                  Common.toastMessaage('Enter Folder name', Colors.red);
                                                                                                } else {
                                                                                                  CreateFolderModel createFolder = await HttpService.createFolder(widget.token, callMasterId, path + folderName.text);
                                                                                                  if (createFolder.data == true) {
                                                                                                    listFolderList(widget.token, callMasterId, listPath);
                                                                                                    folderName.text = '';
                                                                                                    if (mounted) {
                                                                                                      Navigator.pop(context);
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              child: const Center(
                                                                                                child: Text(
                                                                                                  'Create',
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
                                                                          });
                                                                        },
                                                                        transitionBuilder: (_,
                                                                            animation1,
                                                                            __,
                                                                            child) {
                                                                          return SlideTransition(
                                                                            position:
                                                                                Tween(
                                                                              begin: const Offset(0, 1),
                                                                              end: const Offset(0, 0),
                                                                            ).animate(animation1),
                                                                            child:
                                                                                child,
                                                                          );
                                                                        },
                                                                      )
                                                                    : _dialogue(
                                                                        context,
                                                                        'Create Folder');
                                                              },
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      DottedBorder(
                                                                    borderType:
                                                                        BorderType
                                                                            .RRect,
                                                                    radius: const Radius
                                                                        .circular(
                                                                        5),
                                                                    dashPattern: const [
                                                                      8,
                                                                      4
                                                                    ],
                                                                    strokeCap:
                                                                        StrokeCap
                                                                            .round,
                                                                    color: Colors
                                                                        .blue,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          130,
                                                                      height:
                                                                          30,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .blue
                                                                              .shade50
                                                                              .withOpacity(
                                                                                  .3),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10)),
                                                                      child:
                                                                          const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.folder,
                                                                              color: Colors.blue,
                                                                              size: 15),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Text(
                                                                            'New Folder',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.blue,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            folderActionEnable ==
                                                                    true
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      fileManagerPermission!.data!.renameFile ==
                                                                              true
                                                                          ? showGeneralDialog(
                                                                              barrierLabel: "showGeneralDialog",
                                                                              barrierDismissible: true,
                                                                              barrierColor: Colors.black.withOpacity(0.6),
                                                                              transitionDuration: const Duration(milliseconds: 400),
                                                                              context: context,
                                                                              pageBuilder: (context, _, __) {
                                                                                return StatefulBuilder(builder: (context, setState) {
                                                                                  return Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: IntrinsicHeight(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                                                                        child: Container(
                                                                                          width: double.maxFinite,
                                                                                          clipBehavior: Clip.antiAlias,
                                                                                          padding: const EdgeInsets.all(16),
                                                                                          decoration: const BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.only(
                                                                                              topLeft: Radius.circular(10),
                                                                                              topRight: Radius.circular(10),
                                                                                              bottomRight: Radius.circular(10),
                                                                                              bottomLeft: Radius.circular(10),
                                                                                            ),
                                                                                          ),
                                                                                          child: Material(
                                                                                            child: Column(
                                                                                              children: [
                                                                                                const SizedBox(height: 20),
                                                                                                const Text(
                                                                                                  'Rename Folder',
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 18,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 20),
                                                                                                TextFormField(
                                                                                                  controller: fileNameEdit,
                                                                                                  style: const TextStyle(
                                                                                                    color: Colors.black,
                                                                                                  ),
                                                                                                  validator: (value) {
                                                                                                    if (value!.isEmpty) {
                                                                                                      return "New Folder";
                                                                                                    }
                                                                                                    return null;
                                                                                                  },
                                                                                                  decoration: InputDecoration(
                                                                                                      filled: true,
                                                                                                      //<-- SEE HERE
                                                                                                      fillColor: Colors.white,
                                                                                                      counterText: "",
                                                                                                      hintText: "Folder Name",
                                                                                                      isDense: true,
                                                                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  height: 25,
                                                                                                ),
                                                                                                Container(
                                                                                                  height: 40,
                                                                                                  width: double.maxFinite,
                                                                                                  decoration: const BoxDecoration(
                                                                                                    color: Color(0xFF3375e0),
                                                                                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                                                  ),
                                                                                                  child: RawMaterialButton(
                                                                                                    onPressed: () async {
                                                                                                      if (fileNameEdit.text.isEmpty) {
                                                                                                        Common.toastMessaage('Enter Folder name', Colors.red);
                                                                                                      } else {
                                                                                                        RenameFolderModel createFolder = await HttpService.renameFolder(widget.token, callMasterId, listPath, editableName, fileNameEdit.text, rawId);
                                                                                                        if (createFolder.data == true) {
                                                                                                          folderActionEnable == false;
                                                                                                          selectedRawIndex = '';
                                                                                                          listFolderList(widget.token, callMasterId, listPath);

                                                                                                          if (mounted) {
                                                                                                            Navigator.pop(context);
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    },
                                                                                                    child: const Center(
                                                                                                      child: Text(
                                                                                                        'Rename',
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
                                                                          : _dialogue(
                                                                              context,
                                                                              'Rename Folder');
                                                                    },
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .mode_edit,
                                                                      color: Colors
                                                                          .blue,
                                                                    ))
                                                                : const SizedBox(),
                                                            folderActionEnable ==
                                                                    true
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      fileManagerPermission!.data!.deleteFile ==
                                                                              true
                                                                          ? showDialog(
                                                                              context:
                                                                                  context,
                                                                              builder: (BuildContext
                                                                                  ctx) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Please Confirm'),
                                                                                  content: const Text('Are you sure to Delete?'),
                                                                                  actions: [
                                                                                    // The "Yes" button
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        child: const Text('No')),
                                                                                    TextButton(
                                                                                        onPressed: () async {
                                                                                          DeleteFolderAndFileModel deleteFolder = await HttpService.deleteLeadFolderAndFiles(widget.token, callMasterId, deletePath, rawId);
                                                                                          if (deleteFolder.data == true) {
                                                                                            folderActionEnable == false;
                                                                                            selectedRawIndex = '';
                                                                                            listFolderList(widget.token, callMasterId, listPath);
                                                                                          }
                                                                                          if (mounted) {
                                                                                            Navigator.of(context).pop();
                                                                                          }
                                                                                        },
                                                                                        child: const Text('Yes')),
                                                                                  ],
                                                                                );
                                                                              })
                                                                          : _dialogue(
                                                                              context,
                                                                              'Delete Folder');
                                                                    },
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red,
                                                                    ))
                                                                : const SizedBox()
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
                                                                  deletePath =
                                                                      '${listFolder!.data![index].path}';
                                                                  folderActionEnable =
                                                                      true;
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
                                                                        folderActionEnable =
                                                                            false;
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
                                                                                callMasterId,
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
                                                                                  : listFolder!.data![index].extension == 'doc' || listFolder!.data![index].extension == 'docx'
                                                                                      ? const AssetImage('assets/icons/doc.png')
                                                                                      : listFolder!.data![index].extension == 'pdf' || listFolder!.data![index].extension == 'PDF'
                                                                                          ? const AssetImage('assets/icons/pdf.png')
                                                                                          : const AssetImage('assets/icons/picture.png'),
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
                                      if (selectedIndex == 5)
                                        Column(
                                          children: [
                                            mileStone != null &&
                                                    mileStone!.data!.milestones!
                                                        .isNotEmpty
                                                ? Accordion(
                                                    headerBorderColor:
                                                        Colors.blueGrey,
                                                    headerBorderColorOpened:
                                                        Colors.transparent,
                                                    headerBackgroundColorOpened:
                                                        Colors.green,
                                                    contentBackgroundColor:
                                                        Colors.white,
                                                    contentBorderColor:
                                                        Colors.green,
                                                    contentBorderWidth: 3,
                                                    contentHorizontalPadding:
                                                        10,
                                                    scaleWhenAnimating: true,
                                                    openAndCloseAnimation: true,
                                                    disableScrolling: true,
                                                    headerPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 7,
                                                            horizontal: 10),
                                                    children: List.generate(
                                                      1,
                                                      (i) => AccordionSection(
                                                        isOpen: false,
                                                        header: const Text(
                                                          'Add Mile Stone',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        content:
                                                            ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, i) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                            // a widget that detects taps on the screen
                                                                            onTap:
                                                                                () {
                                                                              // when the widget is tapped
                                                                              // setState(() {
                                                                              //   // update the state of the widget
                                                                              //   mileStone!.data!.milestones![i].isChecked = !mileStone!.data!.milestones![i].isChecked!; // toggle the isChecked variable
                                                                              // });
                                                                              showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return StatefulBuilder(builder: (context, setState) {
                                                                                      return AlertDialog(
                                                                                        scrollable: true,
                                                                                        title: Text(mileStone!.data!.milestones![i].milestone.toString()),
                                                                                        content: Column(
                                                                                          children: [
                                                                                            const SizedBox(
                                                                                              height: 5,
                                                                                            ),
                                                                                            InkWell(
                                                                                              onTap: () {
                                                                                                showDialog(
                                                                                                    context: context,
                                                                                                    builder: (BuildContext context) {
                                                                                                      return AlertDialog(
                                                                                                        scrollable: true,
                                                                                                        title: const Text('Accessible Users'),
                                                                                                        content: SizedBox(
                                                                                                          height: MediaQuery.of(context).size.height * .32,
                                                                                                          width: MediaQuery.of(context).size.height * .8,
                                                                                                          child: ListView.builder(
                                                                                                            shrinkWrap: true,
                                                                                                            itemCount: commonDetails!.data.transferStaffs.length,
                                                                                                            itemBuilder: (context, ind) {
                                                                                                              return CheckboxListTile(
                                                                                                                title: SizedBox(
                                                                                                                  width: 200,
                                                                                                                  child: Text(
                                                                                                                    commonDetails!.data.transferStaffs[ind].tranStaffName.toString(),
                                                                                                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                value: checkedItems.contains(commonDetails!.data.transferStaffs[ind].tranStaffId.toString()) ? true : false,
                                                                                                                onChanged: (bool? value) {
                                                                                                                  if (value == true) {
                                                                                                                    setState(() {
                                                                                                                      checkedItems.add(commonDetails!.data.transferStaffs[ind].tranStaffId.toString());
                                                                                                                      checkedItemsName.add(commonDetails!.data.transferStaffs[ind].tranStaffName.toString());

                                                                                                                      Navigator.pop(context, true);
                                                                                                                    });
                                                                                                                  } else {
                                                                                                                    setState(() {
                                                                                                                      checkedItems.remove(commonDetails!.data.transferStaffs[ind].tranStaffId.toString());
                                                                                                                      checkedItemsName.remove(commonDetails!.data.transferStaffs[ind].tranStaffName.toString());

                                                                                                                      Navigator.pop(context, true);
                                                                                                                    });
                                                                                                                  }
                                                                                                                },
                                                                                                                controlAffinity: ListTileControlAffinity.leading,
                                                                                                              );
                                                                                                            },
                                                                                                          ),
                                                                                                        ),
                                                                                                      );
                                                                                                    });
                                                                                              },
                                                                                              child: Container(
                                                                                                height: 40,
                                                                                                width: MediaQuery.of(context).size.height * 1,
                                                                                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.only(right: 20),
                                                                                                  child: SizedBox(
                                                                                                    height: 40,
                                                                                                    child: ListView.builder(
                                                                                                      scrollDirection: Axis.horizontal,
                                                                                                      itemCount: checkedItemsName.length,
                                                                                                      itemBuilder: (context, i) {
                                                                                                        return Padding(
                                                                                                          padding: const EdgeInsets.only(right: 5),
                                                                                                          child: InkWell(
                                                                                                            onTap: () {
                                                                                                              setState(() {});
                                                                                                            },
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Container(
                                                                                                                  height: 35,
                                                                                                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))),
                                                                                                                  child: Center(
                                                                                                                    child: Row(
                                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                      children: [
                                                                                                                        Padding(
                                                                                                                          padding: const EdgeInsets.all(10),
                                                                                                                          child: Text(
                                                                                                                            checkedItemsName[i],
                                                                                                                            style: const TextStyle(
                                                                                                                              color: Colors.black,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                InkWell(
                                                                                                                  onTap: () {
                                                                                                                    showDialog(
                                                                                                                        context: context,
                                                                                                                        builder: (BuildContext context) {
                                                                                                                          return AlertDialog(
                                                                                                                            title: const Text('Please Confirm'),
                                                                                                                            content: const Text('Are you sure to Remove this Number?'),
                                                                                                                            actions: [
                                                                                                                              // The "Yes" button
                                                                                                                              TextButton(
                                                                                                                                  onPressed: () async {
                                                                                                                                    setState(() {
                                                                                                                                      checkedItemsName.remove(checkedItemsName[i]);
                                                                                                                                      checkedItems.remove(checkedItems[i]);
                                                                                                                                    });
                                                                                                                                    Navigator.of(context).pop();
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
                                                                                                                  },
                                                                                                                  child: Container(
                                                                                                                    height: 35,
                                                                                                                    width: 30,
                                                                                                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.grey.shade100, borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))),
                                                                                                                    child: const Icon(
                                                                                                                      Icons.close,
                                                                                                                      color: Colors.red,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        );
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 5,
                                                                                            ),
                                                                                            TextFormField(
                                                                                              controller: remarks,
                                                                                              maxLines: 2,
                                                                                              decoration: const InputDecoration(
                                                                                                  labelText: 'Remarks',
                                                                                                  fillColor: Colors.white,
                                                                                                  filled: true,
                                                                                                  border: OutlineInputBorder(),
                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(color: Colors.grey),
                                                                                                  ),
                                                                                                  labelStyle: TextStyle(color: Colors.grey)),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        actions: [
                                                                                          // The "Yes" button
                                                                                          TextButton(
                                                                                              onPressed: () async {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: const Text('Close')),
                                                                                          TextButton(
                                                                                              onPressed: () async {
                                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                                Map<String, dynamic> body = {
                                                                                                  "token": widget.token,
                                                                                                  'leadMasterId': callMasterId,
                                                                                                  'milestone_id': mileStone!.data!.milestones![i].milestoneId.toString(),
                                                                                                  'userid': checkedItems,
                                                                                                  'remarks': remarks.text,
                                                                                                };
                                                                                                AddMileStoneModel addMileStone = await HttpService.addMileStone(body);
                                                                                                if (addMileStone.data == true) {
                                                                                                  Common.toastMessaage(addMileStone.message, Colors.green);
                                                                                                  if (context.mounted) {
                                                                                                    Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                          builder: (context) => LeadDetails(
                                                                                                                widget.token,
                                                                                                                widget.editLead,
                                                                                                                widget.deleteLead,
                                                                                                                widget.cloudCall,
                                                                                                                callMasterId,
                                                                                                                pageName: widget.pageName,
                                                                                                                status: widget.status,
                                                                                                                staff: widget.staff,
                                                                                                                isCalled: widget.isCalled,
                                                                                                                fromDate: widget.fromDate,
                                                                                                                toDate: widget.toDate,
                                                                                                                category: widget.category,
                                                                                                                searchKey: widget.searchKey,
                                                                                                                leadType: widget.leadType,
                                                                                                              )),
                                                                                                    );
                                                                                                  }
                                                                                                } else {
                                                                                                  Common.toastMessaage(addMileStone.message, Colors.red);
                                                                                                  if (context.mounted) {
                                                                                                    Navigator.of(context).pop();
                                                                                                  }
                                                                                                }
                                                                                              },
                                                                                              child: const Text('Send'))
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                                  });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: 25,
                                                                              height: 25,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                gradient: mileStone!.data!.milestones![i].isChecked! // if the checkbox is checked, apply a gradient to the container
                                                                                    ? const LinearGradient(
                                                                                        colors: [
                                                                                          Color(0xFF16BFFD),
                                                                                          Color(0xFFCB3066),
                                                                                        ],
                                                                                        begin: Alignment.topLeft,
                                                                                        end: Alignment.bottomRight,
                                                                                      )
                                                                                    : null,
                                                                                // if the checkbox is not checked, do not apply a gradient
                                                                                border: Border.all(color: Colors.grey, width: 1), // add a grey border to the container
                                                                              ),
                                                                              child: mileStone!.data!.milestones![i].isChecked! // if the checkbox is checked
                                                                                  ? const Icon(
                                                                                      Icons.check,
                                                                                      color: Colors.white,
                                                                                      size: 26,
                                                                                    ) // add a check icon to the container
                                                                                  : null, // if the checkbox is not checked, do not add anything to the container
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 20),
                                                                          Text(mileStone!
                                                                              .data!
                                                                              .milestones![i]
                                                                              .milestone
                                                                              .toString())
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          itemCount: mileStone!
                                                              .data!
                                                              .milestones!
                                                              .length,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            MediaQuery.removePadding(
                                              context: context,
                                              removeTop: true,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: mileStone!.data!
                                                      .leadMilestones!.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              left: 10,
                                                              right: 10),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border(
                                                            top: BorderSide(
                                                              width: 3,
                                                              color: Colors.blue
                                                                  .shade100,
                                                            ),
                                                            left: BorderSide(
                                                              width: 3,
                                                              color: Colors.blue
                                                                  .shade100,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              color: Colors.blue
                                                                  .shade100,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 10,
                                                                        bottom:
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.85,
                                                                        child:
                                                                            Text(
                                                                          mileStone!
                                                                              .data!
                                                                              .leadMilestones![i]
                                                                              .milestone
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w500),
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                child: Text(
                                                                    mileStone!
                                                                        .data!
                                                                        .leadMilestones![
                                                                            i]
                                                                        .dateTime
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400)),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 5),
                                                              child: Row(
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
                                                                          0.25,
                                                                      child:
                                                                          const Text(
                                                                        'Staff',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      )),
                                                                  const Text(
                                                                      ':'),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SingleChildScrollView(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          30,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.55,
                                                                      child: ListView
                                                                          .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        itemCount: mileStone!
                                                                            .data!
                                                                            .leadMilestones![i]
                                                                            .userData!
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 5, right: 5),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                setState(() {});
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    height: 40,
                                                                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                                                                    child: Center(
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(5),
                                                                                            child: Text(
                                                                                              mileStone!.data!.leadMilestones![i].userData![index].staffName.toString(),
                                                                                              style: const TextStyle(
                                                                                                color: Colors.black,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 5),
                                                              child: Row(
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
                                                                          0.25,
                                                                      child:
                                                                          const Text(
                                                                        'Remarks',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      )),
                                                                  const Text(
                                                                      ':'),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.55,
                                                                      child:
                                                                          Text(
                                                                        mileStone!
                                                                            .data!
                                                                            .leadMilestones![i]
                                                                            .remarks
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                13),
                                                                      )),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 2),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5,
                                                                      bottom:
                                                                          5),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Please Confirm'),
                                                                          content:
                                                                              const Text('You are about to delete this Mile stone?'),
                                                                          actions: [
                                                                            // The "Yes" button
                                                                            TextButton(
                                                                                onPressed: () async {
                                                                                  Common.showProgressDialog(context, "Loading..");
                                                                                  DeleteLeadMileStoneModel deleteMilestoneLead = await HttpService.deleteMileStoneLeads(widget.token, mileStone!.data!.leadMilestones![i].milestoneId.toString());
                                                                                  // print(updateAssignStaff.data);
                                                                                  if (deleteMilestoneLead.data == true) {
                                                                                    if (mounted) {
                                                                                      // print(updateAssignStaff.data);
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => LeadDetails(
                                                                                                  widget.token,
                                                                                                  widget.editLead,
                                                                                                  widget.deleteLead,
                                                                                                  widget.cloudCall,
                                                                                                  callMasterId,
                                                                                                  pageName: widget.pageName,
                                                                                                  status: widget.status,
                                                                                                  staff: widget.staff,
                                                                                                  isCalled: widget.isCalled,
                                                                                                  fromDate: widget.fromDate,
                                                                                                  toDate: widget.toDate,
                                                                                                  category: widget.category,
                                                                                                  searchKey: widget.searchKey,
                                                                                                  leadType: widget.leadType,
                                                                                                )),
                                                                                      );
                                                                                    }
                                                                                  }
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
                                                                },
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: Container(
                                                                      height: 30,
                                                                      width: 80,
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.red)),
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                7,
                                                                            right:
                                                                                7),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                              size: 18,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 7,
                                                                            ),
                                                                            Text(
                                                                              'Delete',
                                                                              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            const SizedBox(
                                              height: 60,
                                            )
                                          ],
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'add',
                        backgroundColor: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddFollowup(
                                    widget.token,
                                    widget.editLead,
                                    widget.deleteLead,
                                    widget.cloudCall,
                                    callMasterId,
                                    pageName: widget.pageName,
                                    status: widget.status,
                                    staff: widget.staff,
                                    isCalled: widget.isCalled,
                                    fromDate: widget.fromDate,
                                    toDate: widget.toDate,
                                    category: widget.category,
                                    leadType: leadDetails!.data!.leadCategory,
                                    leadTypeId:
                                        leadDetails!.data!.leadCategoryId,
                                    leadSubType:
                                        leadDetails!.data!.leadSubCategory,
                                    leadSubTypeId:
                                        leadDetails!.data!.leadSubCategoryId,
                                    priorityId: leadDetails!.data!.priorityId,
                                    priority: leadDetails!.data!.priority,
                                    cost: leadDetails!.data!.cost,
                                    address: leadDetails!.data!.address,
                                    searchKey: widget.searchKey,
                                    leadType1: widget.leadType)),
                          ).then((r) {
                            getData();
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ), //icon inside button
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      fileManagerPermission != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: isExpanded,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FloatingActionButton(
                                        tooltip: 'Upload Voice',
                                        heroTag: 'voice',
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          fileManagerPermission!
                                                      .data!.createFile ==
                                                  true
                                              ? showGeneralDialog(
                                                  barrierLabel:
                                                      "showGeneralDialog",
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.6),
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 400),
                                                  context: context,
                                                  pageBuilder:
                                                      (context, _, __) {
                                                    return Obx(() {
                                                      return AlertDialog(
                                                        content:
                                                            IntrinsicHeight(
                                                          child: Column(
                                                            children: [
                                                              audioCreateController
                                                                          .isRecording
                                                                          .value |
                                                                      audioCreateController
                                                                          .audioPath
                                                                          .isNotEmpty
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                                                                          style:
                                                                              const TextStyle(fontSize: 30),
                                                                        ),
                                                                        if (audioCreateController
                                                                            .isRecording
                                                                            .value)
                                                                          const Text(
                                                                              "Voice Recording..."),
                                                                      ],
                                                                    )
                                                                  : const Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          'Voice Record ',
                                                                          style:
                                                                              TextStyle(fontSize: 18),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Text(
                                                                            "Do you want to record voice?"),
                                                                      ],
                                                                    ),
                                                              const SizedBox(
                                                                  height: 20.0),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            20.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    if (audioCreateController.isRecording.value ==
                                                                            false &&
                                                                        audioCreateController
                                                                            .audioPath
                                                                            .isNotEmpty)
                                                                      FloatingActionButton(
                                                                          heroTag:
                                                                              "play tag",
                                                                          onPressed:
                                                                              () {
                                                                            audioCreateController.resetTimer();
                                                                            audioCreateController.playRcording();
                                                                          },
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          backgroundColor: Colors
                                                                              .white,
                                                                          foregroundColor: Colors
                                                                              .teal,
                                                                          child:
                                                                              const Icon(
                                                                            Icons.play_arrow_rounded,
                                                                            color:
                                                                                Colors.green,
                                                                            size:
                                                                                30,
                                                                          )),
                                                                    const SizedBox(
                                                                      width: 25,
                                                                    ),
                                                                    if (audioCreateController
                                                                            .isRecording
                                                                            .value ==
                                                                        true)
                                                                      FloatingActionButton(
                                                                          heroTag:
                                                                              "start tag",
                                                                          onPressed:
                                                                              () {
                                                                            audioCreateController.stopRecording();
                                                                            // recordController.stopTimer();
                                                                          },
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          backgroundColor: Colors
                                                                              .redAccent,
                                                                          foregroundColor: Colors
                                                                              .white,
                                                                          child:
                                                                              const Text("Stop")),
                                                                    const SizedBox(
                                                                      width: 25,
                                                                    ),
                                                                    if (audioCreateController.isRecording.value ==
                                                                            false &&
                                                                        audioCreateController
                                                                            .audioPath
                                                                            .isNotEmpty)
                                                                      FloatingActionButton(
                                                                          heroTag:
                                                                              "delete tag",
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: const Text('Are You Sure'),
                                                                                    iconColor: Colors.blue,
                                                                                    actions: <Widget>[
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Get.back();
                                                                                        },
                                                                                        child: const Text('Cancel'),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          audioCreateController.resetTimer();
                                                                                          audioCreateController.audioPath.value = "";
                                                                                          Get.back();
                                                                                        },
                                                                                        child: const Text('Delete'),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                });
                                                                          },
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          backgroundColor: Colors
                                                                              .white,
                                                                          foregroundColor: Colors
                                                                              .red,
                                                                          child:
                                                                              const Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                30,
                                                                          )),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (audioCreateController
                                                                          .isRecording
                                                                          .value ==
                                                                      false &&
                                                                  audioCreateController
                                                                      .audioPath
                                                                      .isNotEmpty)
                                                                TextFormField(
                                                                  controller:
                                                                      fileName,
                                                                  decoration: const InputDecoration(
                                                                      contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                                                                      labelText: 'File Name',
                                                                      fillColor: Colors.white,
                                                                      filled: true,
                                                                      prefixIcon: Icon(Icons.file_copy, color: Colors.grey),
                                                                      border: OutlineInputBorder(),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(color: Colors.grey),
                                                                      ),
                                                                      labelStyle: TextStyle(color: Colors.grey)),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          audioCreateController
                                                                      .isRecording
                                                                      .value ==
                                                                  false
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (audioCreateController
                                                                            .isBack
                                                                            .value ==
                                                                        true) {
                                                                      audioCreateController
                                                                          .audioPath
                                                                          .value = '';
                                                                      audioCreateController
                                                                          .stopTimer();
                                                                      audioCreateController
                                                                          .audioPlayer
                                                                          .stop();
                                                                      audioCreateController
                                                                          .resetTimer();
                                                                      fileName.text =
                                                                          '';
                                                                    }

                                                                    // if(audioCreateController
                                                                    //     .isRecording.value ==
                                                                    //     false &&
                                                                    //     audioCreateController
                                                                    //         .audioPath.isNotEmpty)
                                                                    //   {
                                                                    //     audioCreateController
                                                                    //         .resetTimer();
                                                                    //   }
                                                                    Get.back();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Back',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                          audioCreateController
                                                                          .isRecording
                                                                          .value ==
                                                                      false &&
                                                                  audioCreateController
                                                                      .audioPath
                                                                      .isNotEmpty
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    bool containsString = json
                                                                        .encode(listFolder!
                                                                            .data)
                                                                        .contains(audioCreateController
                                                                            .audioPath
                                                                            .value
                                                                            .split('/')
                                                                            .last);
                                                                    bool
                                                                        containsString1;
                                                                    if (fileName
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      containsString1 = json
                                                                          .encode(listFolder!
                                                                              .data)
                                                                          .contains(fileName.text +
                                                                              extension(audioCreateController.audioPath.value));
                                                                    } else {
                                                                      containsString1 =
                                                                          false;
                                                                    }
                                                                    setState(
                                                                        () {});
                                                                    File file = File.fromUri(Uri.parse(audioCreateController
                                                                        .audioPath
                                                                        .value
                                                                        .toString()));
                                                                    // File file = File(audioCreateController
                                                                    //     .audioPath
                                                                    //     .value);
                                                                    int fileSizeInBytes =
                                                                        await file
                                                                            .length();
                                                                    double
                                                                        fileSizeInKB =
                                                                        fileSizeInBytes /
                                                                            1024;
                                                                    double
                                                                        fileSizeInMB =
                                                                        fileSizeInKB /
                                                                            1024;

                                                                    //print('file Size :$fileSizeInMB');
                                                                    if (fileName
                                                                            .text
                                                                            .isEmpty &&
                                                                        containsString ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileName
                                                                            .text
                                                                            .isNotEmpty &&
                                                                        containsString1 ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist1',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .maxFileSize
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Maximum Size 5 MB',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .remainingStorage
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Insufficient Storage',
                                                                          Colors
                                                                              .red);
                                                                    } else {
                                                                      if (mounted) {
                                                                        Common.showProgressDialog(
                                                                            context,
                                                                            "Uploading..");
                                                                      }
                                                                      UploadAudioRecord uploadAudio = await HttpService.uploadRecord(
                                                                          widget
                                                                              .token,
                                                                          widget
                                                                              .callMasterId,
                                                                          listPath,
                                                                          audioCreateController
                                                                              .audioPath
                                                                              .value,
                                                                          fileName
                                                                              .text);
                                                                      if (uploadAudio
                                                                              .data ==
                                                                          true) {
                                                                        audioCreateController
                                                                            .audioPath
                                                                            .value = '';
                                                                        fileName.text =
                                                                            '';
                                                                        audioCreateController
                                                                            .resetTimer();
                                                                        Common.toastMessaage(
                                                                            uploadAudio.message,
                                                                            Colors.green);
                                                                        listFolderList(
                                                                            widget.token,
                                                                            callMasterId,
                                                                            listPath);
                                                                        if (mounted) {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Save',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  ),
                                                                )
                                                              : audioCreateController
                                                                          .isRecording
                                                                          .value ==
                                                                      false
                                                                  ? TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (audioCreateController
                                                                            .audioPath
                                                                            .isNotEmpty) {
                                                                          audioCreateController
                                                                              .isBack
                                                                              .value = true;
                                                                          audioCreateController
                                                                              .resetTimer();

                                                                          audioCreateController
                                                                              .startRecording();
                                                                        } else {
                                                                          audioCreateController
                                                                              .startRecording();
                                                                        }
                                                                        isBack =
                                                                            true;
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Record',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                        ],
                                                      );
                                                    });
                                                  },
                                                  transitionBuilder: (_,
                                                      animation1, __, child) {
                                                    return SlideTransition(
                                                      position: Tween(
                                                        begin:
                                                            const Offset(0, 1),
                                                        end: const Offset(0, 0),
                                                      ).animate(animation1),
                                                      child: child,
                                                    );
                                                  },
                                                )
                                              : _dialogue(
                                                  context, 'Create File');
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                          ),
                                        ), //icon inside button
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'Upload image',
                                        heroTag: 'image',
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          fileManagerPermission!
                                                      .data!.createFile ==
                                                  true
                                              ? showGeneralDialog(
                                                  barrierLabel:
                                                      "showGeneralDialog",
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.6),
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 400),
                                                  context: context,
                                                  pageBuilder:
                                                      (context, _, __) {
                                                    return Obx(() {
                                                      return AlertDialog(
                                                        content:
                                                            IntrinsicHeight(
                                                          child: Column(
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  const Text(
                                                                    'Upload Image',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  imageUploadController
                                                                              .file
                                                                              .value ==
                                                                          ''
                                                                      ? const Text(
                                                                          "Do you want to upload image?")
                                                                      : Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <Widget>[
                                                                            Padding(
                                                                                padding: const EdgeInsets.only(left: 20, right: 20),
                                                                                child: Center(
                                                                                  child: Container(
                                                                                    height: 150,
                                                                                    width: 150,
                                                                                    decoration: BoxDecoration(
                                                                                      border: Border.all(
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      color: Colors.transparent,
                                                                                      image: DecorationImage(
                                                                                        fit: BoxFit.cover,
                                                                                        image: FileImage(File(imageUploadController.file.value)),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                            TextButton(
                                                                              onPressed: () async {
                                                                                setState(() {
                                                                                  imageUploadController.file.value = '';
                                                                                });
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.delete,
                                                                                color: Colors.red,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            TextFormField(
                                                                              controller: fileName,
                                                                              decoration: const InputDecoration(
                                                                                  contentPadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                                                                                  labelText: 'File Name',
                                                                                  fillColor: Colors.white,
                                                                                  filled: true,
                                                                                  prefixIcon: Icon(Icons.file_copy, color: Colors.grey),
                                                                                  border: OutlineInputBorder(),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(color: Colors.grey),
                                                                                  ),
                                                                                  labelStyle: TextStyle(color: Colors.grey)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 20.0),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              imageUploadController
                                                                  .file
                                                                  .value = '';
                                                              fileName.text =
                                                                  '';
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                              'Back',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          imageUploadController
                                                                      .file
                                                                      .value !=
                                                                  ''
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    bool containsString = json
                                                                        .encode(listFolder!
                                                                            .data)
                                                                        .contains(imageUploadController
                                                                            .fileName
                                                                            .value);
                                                                    bool
                                                                        containsString1;
                                                                    if (fileName
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      containsString1 = json
                                                                          .encode(listFolder!
                                                                              .data)
                                                                          .contains(fileName.text +
                                                                              extension(imageUploadController.file.value));
                                                                    } else {
                                                                      containsString1 =
                                                                          false;
                                                                    }
                                                                    File file = File(
                                                                        imageUploadController
                                                                            .file
                                                                            .value);
                                                                    int fileSizeInBytes =
                                                                        await file
                                                                            .length();
                                                                    double
                                                                        fileSizeInKB =
                                                                        fileSizeInBytes /
                                                                            1024;
                                                                    double
                                                                        fileSizeInMB =
                                                                        fileSizeInKB /
                                                                            1024;

                                                                    if (fileName
                                                                            .text
                                                                            .isEmpty &&
                                                                        containsString ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileName
                                                                            .text
                                                                            .isNotEmpty &&
                                                                        containsString1 ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .maxFileSize
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Maximum Size 5 MB',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .remainingStorage
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Insufficient Storage',
                                                                          Colors
                                                                              .red);
                                                                    } else {
                                                                      if (mounted) {
                                                                        Common.showProgressDialog(
                                                                            context,
                                                                            "Uploading..");
                                                                      }

                                                                      UploadAudioRecord uploadAudio = await HttpService.uploadRecord(
                                                                          widget
                                                                              .token,
                                                                          widget
                                                                              .callMasterId,
                                                                          listPath,
                                                                          imageUploadController
                                                                              .file
                                                                              .value,
                                                                          fileName
                                                                              .text);
                                                                      if (uploadAudio
                                                                              .data ==
                                                                          true) {
                                                                        imageUploadController
                                                                            .file
                                                                            .value = '';
                                                                        fileName.text =
                                                                            '';
                                                                        Common.toastMessaage(
                                                                            uploadAudio.message,
                                                                            Colors.green);
                                                                        listFolderList(
                                                                            widget.token,
                                                                            callMasterId,
                                                                            listPath);
                                                                        if (mounted) {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Save',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  ),
                                                                )
                                                              : TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          ((builder) {
                                                                        return Container(
                                                                          height:
                                                                              100.0,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 1,
                                                                          margin:
                                                                              const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                20,
                                                                            vertical:
                                                                                20,
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            children: <Widget>[
                                                                              const Text(
                                                                                "Choose Profile photo",
                                                                                style: TextStyle(
                                                                                  fontSize: 20.0,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                                                                InkWell(
                                                                                  onTap: () async {
                                                                                    imageUploadController.takePhoto(ImageSource.camera);
                                                                                    Get.back();
                                                                                  },
                                                                                  child: const Column(
                                                                                    children: [
                                                                                      Icon(Icons.camera),
                                                                                      Text('Camera')
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 30,
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    imageUploadController.takePhoto(ImageSource.gallery);
                                                                                    Get.back();
                                                                                  },
                                                                                  child: const Column(
                                                                                    children: [
                                                                                      Icon(Icons.image),
                                                                                      Text('Gallery'),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ])
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Upload',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                        ],
                                                      );
                                                    });
                                                  },
                                                  transitionBuilder: (_,
                                                      animation1, __, child) {
                                                    return SlideTransition(
                                                      position: Tween(
                                                        begin:
                                                            const Offset(0, 1),
                                                        end: const Offset(0, 0),
                                                      ).animate(animation1),
                                                      child: child,
                                                    );
                                                  },
                                                )
                                              : _dialogue(
                                                  context, 'Create File');
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                        ), //icon inside button
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'Upload doc/pdf',
                                        heroTag: 'doc',
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          fileManagerPermission!
                                                      .data!.createFile ==
                                                  true
                                              ? showGeneralDialog(
                                                  barrierLabel:
                                                      "showGeneralDialog",
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.6),
                                                  transitionDuration:
                                                      const Duration(
                                                          milliseconds: 400),
                                                  context: context,
                                                  pageBuilder:
                                                      (context, _, __) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return AlertDialog(
                                                        content:
                                                            IntrinsicHeight(
                                                          child: Column(
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  const Text(
                                                                    'Upload Docs/Pdf',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  isFile == true
                                                                      ? DottedBorder(
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
                                                                                100,
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.blue.shade50.withOpacity(.3), borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(Icons.upload, color: Colors.black, size: 50),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Text('Doc/Pdf')
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : const Text(
                                                                          'Do you want to upload document?'),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 20.0),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Get.back();
                                                              isFile = false;
                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              'Back',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          isFile == false
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    FilePickerResult?
                                                                        result =
                                                                        await FilePicker
                                                                            .platform
                                                                            .pickFiles(
                                                                      type: FileType
                                                                          .custom,
                                                                      allowedExtensions: [
                                                                        'pdf',
                                                                        'doc',
                                                                        'docx'
                                                                      ],
                                                                    );

                                                                    if (result !=
                                                                        null) {
                                                                      isFile =
                                                                          true;
                                                                      file = result
                                                                          .files
                                                                          .first;
                                                                    } else {
                                                                      isFile =
                                                                          false;
                                                                      // User cance
                                                                      // isled the file selection.
                                                                    }
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: const Text(
                                                                      "Pick a Document"),
                                                                )
                                                              : TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    String fileName1 = file!
                                                                        .path!
                                                                        .split(
                                                                            '/')
                                                                        .last;
                                                                    bool containsString = json
                                                                        .encode(listFolder!
                                                                            .data)
                                                                        .contains(
                                                                            fileName1);
                                                                    bool
                                                                        containsString1;
                                                                    if (fileName
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      containsString1 = json
                                                                          .encode(listFolder!
                                                                              .data)
                                                                          .contains(fileName.text +
                                                                              extension(file!.path.toString()));
                                                                    } else {
                                                                      containsString1 =
                                                                          false;
                                                                    }

                                                                    int sizeInBytes = await File(file!
                                                                            .path
                                                                            .toString())
                                                                        .length();
                                                                    double
                                                                        fileSizeInKB =
                                                                        sizeInBytes /
                                                                            1024;
                                                                    double
                                                                        fileSizeInMB =
                                                                        fileSizeInKB /
                                                                            1024;
                                                                    if (fileName
                                                                            .text
                                                                            .isEmpty &&
                                                                        containsString ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileName
                                                                            .text
                                                                            .isNotEmpty &&
                                                                        containsString1 ==
                                                                            true) {
                                                                      Common.toastMessaage(
                                                                          'File Name already exist',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .maxFileSize
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Maximum Size 5 MB',
                                                                          Colors
                                                                              .red);
                                                                    } else if (fileSizeInMB >
                                                                        double.parse(fileManagerPermission!
                                                                            .data!
                                                                            .remainingStorage
                                                                            .toString())) {
                                                                      Common.toastMessaage(
                                                                          'Insufficient Storage',
                                                                          Colors
                                                                              .red);
                                                                    } else {
                                                                      if (mounted) {
                                                                        Common.showProgressDialog(
                                                                            context,
                                                                            "Uploading..");
                                                                      }
                                                                      UploadAudioRecord uploadAudio = await HttpService.uploadRecord(
                                                                          widget
                                                                              .token,
                                                                          widget
                                                                              .callMasterId,
                                                                          listPath,
                                                                          file!
                                                                              .path
                                                                              .toString(),
                                                                          fileName
                                                                              .text);
                                                                      if (uploadAudio
                                                                              .data ==
                                                                          true) {
                                                                        setState(
                                                                            () {
                                                                          isFile =
                                                                              false;
                                                                        });
                                                                        imageUploadController
                                                                            .file
                                                                            .value = '';
                                                                        fileName.text =
                                                                            '';
                                                                        Common.toastMessaage(
                                                                            uploadAudio.message,
                                                                            Colors.green);
                                                                        listFolderList(
                                                                            widget.token,
                                                                            callMasterId,
                                                                            listPath);
                                                                        if (mounted) {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Upload',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  ),
                                                                )
                                                        ],
                                                      );
                                                    });
                                                  },
                                                  transitionBuilder: (_,
                                                      animation1, __, child) {
                                                    return SlideTransition(
                                                      position: Tween(
                                                        begin:
                                                            const Offset(0, 1),
                                                        end: const Offset(0, 0),
                                                      ).animate(animation1),
                                                      child: child,
                                                    );
                                                  },
                                                )
                                              : _dialogue(
                                                  context, 'Create File');
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                            Icons.file_copy,
                                            color: Colors.white,
                                          ),
                                        ), //icon inside button
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Icon(
                                      isExpanded ? Icons.close : Icons.upload),
                                ),
                              ],
                            )
                          : const SizedBox()
                    ],
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
                      Text(
                        timeOut == true
                            ? "There seems to be a temporary issue, \n Please retry to continue"
                            : 'No Network Found !',
                        textAlign: TextAlign.center,
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

  Future<dynamic> chooseCallDialog(BuildContext context) {
    return showDialog(
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
                        widget.token,
                        widget.callMasterId,
                        leadDetails!.data!.contactNumber1);
                    if (object1.data == true) {
                      Common.toastMessaage(object1.message, Colors.green);
                      if (context.mounted) {
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
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(
                            Icons.cloud_circle_rounded,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Cloud Call',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    // String url =
                    //     'tel:${'+${leadDetails!.data!.contactNumber1}'}';
                    // await launch(url);
                    bool? res = await FlutterPhoneDirectCaller.callNumber(
                        '+${leadDetails!.data!.contactNumber1}');
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
                                borderRadius: BorderRadius.circular(5)),
                            child: const Icon(
                              Icons.call,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text(
                            'Phone Call',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
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

  void _deleteFollowup(BuildContext context, followupId) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () async {
                    DeleteLeadFollowModel delete =
                        await HttpService.deleteLeadFollowup(
                            widget.token, followupId, callMasterId);
                    if (delete.data == true) {
                      Common.toastMessaage(delete.message, Colors.green);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LeadDetails(
                                    widget.token,
                                    widget.editLead,
                                    widget.deleteLead,
                                    widget.cloudCall,
                                    callMasterId,
                                    pageName: widget.pageName,
                                    status: widget.status,
                                    staff: widget.staff,
                                    isCalled: widget.isCalled,
                                    fromDate: widget.fromDate,
                                    toDate: widget.toDate,
                                    category: widget.category,
                                    searchKey: widget.searchKey,
                                    leadType: widget.leadType,
                                  )),
                        );
                      }
                    } else {
                      Common.toastMessaage(delete.message, Colors.red);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
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
  bool editLead;
  bool deleteLead;
  bool cloudCall;
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
    this.editLead,
    this.deleteLead,
    this.cloudCall,
    this.callMasterId,
    this.image,
    this.staffName,
    this.clientName, {
    super.key,
    this.fromDate,
    this.toDate,
    this.sts,
    this.category,
    this.staff,
    this.pageName,
    this.isCalled,
  });

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

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    super.dispose();
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {}
  }

  LeadDetails? lead;

  // Future<void> setAudioPlayer() async {
  //   super.initState();
  //   audioPlayer.play(UrlSource(widget.resourceUrl));
  //   audioPlayer.setReleaseMode(ReleaseMode.stop);
  // }

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
                                      log(widget.resourceUrl);
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
                                widget.isTransfer == false
                                    ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddFollowup(
                                                      widget.token,
                                                      widget.editLead,
                                                      widget.deleteLead,
                                                      widget.cloudCall,
                                                      widget.callMasterId,
                                                      pageName: widget.pageName,
                                                      status: widget.sts,
                                                      staff: widget.staff,
                                                      isCalled: widget.isCalled,
                                                      fromDate: widget.fromDate,
                                                      toDate: widget.toDate,
                                                      category: widget.category,
                                                      callingDate: widget.date,
                                                      callHistoryId:
                                                          widget.callHistoryId,
                                                    )),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 15,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.green.shade900,
                                            size: 15,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
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
