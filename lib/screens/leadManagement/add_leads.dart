import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/widgets/AddLeadSourceDialog.dart';
import 'package:login2/widgets/addLeadCateoryPopup.dart';
// import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/addLeadModel.dart';
import '../../models/lead_management/checkLeadPhoneNumberModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../service/service.dart';

// ignore: must_be_immutable
class AddLeads extends StatefulWidget {
  String? token;
  String? page;
  String? leadMasterId;
  String? clientName;
  String? phoneNumber;
  String? fromDate;
  String? toDate;
  bool? editLead;
  bool? deleteLead;
  bool? cloudCall;
  String? countryCode;
  String? address;

  AddLeads(this.token,
      {super.key,
      this.page,
      this.leadMasterId,
      this.clientName,
      this.phoneNumber,
      this.fromDate,
      this.toDate,
      this.editLead,
      this.deleteLead,
      this.cloudCall,
      this.countryCode,
      this.address});

  @override
  State<AddLeads> createState() => _AddLeadsState();
}

class _AddLeadsState extends State<AddLeads> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  String callResponse = 'Call Response';
  String callResponseId = '';
  bool? result = true;
  bool? result1 = true;
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  String callResult = 'New';
  String callResultId = '1';
  String leadSource = 'Direct Entry';
  String leadSourceId = "1";
  String priority = 'Normal';
  String priorityId = '2';
  String? contactPermission = '';
    String? createLeadCategory = '';
       String? addLeadSource = '';
  TextEditingController clientName = TextEditingController();
  TextEditingController contactNo = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController remark = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController assignStaffVal = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  TextEditingController timeBefore = TextEditingController(text: '10');
  TextEditingController callResultVal = TextEditingController();
  TextEditingController leadSourceVal = TextEditingController();
  TextEditingController stateVal = TextEditingController();

  String? nextFollowupDate = '';
  TextEditingController nextFollowupDate1 = TextEditingController();
  final List<TextEditingController> _controllers = [];
  TextEditingController pinCode = TextEditingController();
  TextEditingController districtVal = TextEditingController();
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  bool isDistrictLoading = false;
  bool isLoading = false;
  String? StateId;
  String? DistrictId;
  List descriptions = [];
  var code = '91';
  String roleId = '';
  String multiBranch = '';
  String? branch;
  bool checked = false;
  void toggleTextFieldVisibility() {
    setState(() {
      checked = !checked;
    });
  }

  @override
  void initState() {
    super.initState();
    clientName.text = widget.clientName ?? "";
    contactNo.text = trimPlus91(widget.phoneNumber ?? "");
    address.text = widget.address ?? "";
    getData();
  }

  String trimPlus91(String mobileNumber) {
    if (mobileNumber.startsWith('+91')) {
      return mobileNumber.substring(3);
    } else if (mobileNumber.startsWith('91')) {
      return mobileNumber.substring(2);
    } else {
      return mobileNumber;
    }
  }

  getData() async {
    contactPermission = await Common.getSharedPref("getContactPermission");
     contactPermission = await Common.getSharedPref("getContactPermission");
       createLeadCategory = await Common.getSharedPref("createLeadCategory");
         addLeadSource = await Common.getSharedPref("addLeadSource");
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
    assignStaff = await Common.getSharedPref("name");
    assignStaffId = await Common.getSharedPref("userId");
    roleId = await Common.getSharedPref("roleId");
    multiBranch = await Common.getSharedPref("multiBranch");
    setState(() {
      result = result1;
    });
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (commonDetails != null) {
      code = commonDetails!.data.countryCode.toString();
      setState(() {});
      configure = await HttpService.configure(widget.token);
      if (configure != null) {
        setState(() {});
      }
    }
    stateDetails = await HttpService.getState();
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  @override
  Widget build(BuildContext context) {
    leadTypeVal.text = leadType;
    leadSubTypeVal.text = leadSubType;
    assignStaffVal.text = assignStaff;
    priorityVal.text = priority;
    callResultVal.text = callResult;
    leadSourceVal.text = leadSource;
    if (widget.page == 'leadDetails') {
      clientName.text = widget.clientName.toString();
      // final myString = widget.phoneNumber;
      // int countryCodeLengt = widget.countryCode!.length;
      // contactNo.text = myString!.substring(countryCodeLengt);
      final phone = widget.phoneNumber ?? "";
      final code = widget.countryCode ?? "";
      if (phone.startsWith(code)) {
        contactNo.text = phone.replaceFirst(code, "");
      } else if (phone.startsWith("+$code")) {
        contactNo.text = phone.replaceFirst("+$code", "");
      } else {
        contactNo.text = phone;
      }
    }
    return result == true
        ? Scaffold(
            backgroundColor: Colors.white,
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
                              Navigator.pop(context);
                              // if (widget.page == 'NavigationBar') {
                              //   Navigator.of(context).push(
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             HomePage(widget.token)),
                              //   );
                              // } else if (widget.page == 'leadDetails') {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => LeadDetails(
                              //               widget.token!,
                              //               widget.editLead!,
                              //               widget.deleteLead!,
                              //               widget.cloudCall!,
                              //               widget.leadMasterId!,
                              //               pageName: widget.page,
                              //               fromDate: widget.fromDate,
                              //               toDate: widget.toDate,
                              //             )),
                              //   );
                              // } else {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             Dashboard(widget.token)),
                              //   );
                              // }
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
                            'Add Leads',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: commonDetails != null && configure != null
                ? SingleChildScrollView(
                    child: configure!.data!.isExpired == false
                        ? Form(
                            key: globalKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                multiBranch == 'true' && roleId == '2'
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, top: 20),
                                        child: DropdownButtonFormField(
                                          value: branch,
                                          onChanged: (value) async {
                                            setState(() {
                                              branch = value.toString();
                                            });
                                            commonDetails = await HttpService
                                                .addLeadCommonData(widget.token,
                                                    branchId: branch);
                                            setState(() {});
                                          },
                                          items: commonDetails!.data.branch
                                              .map((data) {
                                            return DropdownMenuItem<String>(
                                              value: data.branchId.toString(),
                                              child: Text(
                                                data.branchName.toString(),
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              // Custom border
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Select Branch',
                                            prefixIcon: const Icon(
                                                Icons
                                                    .arrow_drop_down_circle_outlined,
                                                color: Colors.grey),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 10,
                                                    top: 2,
                                                    bottom: 2),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 20,
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: clientName,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              labelText: 'Customer Name *',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(Icons.person,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (contactPermission == 'true') {
                                            selectContact();
                                          } else {
                                            contactPermissionDialog(context);
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF2a86c9),
                                                  Color(0xFF406dbe)
                                                ]),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.contacts,
                                              color: Colors.white,
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: SizedBox(
                                    child: TextFormField(
                                      controller: contactNo,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          labelText: 'Contact Number *',
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefix: GestureDetector(
                                            onTap: () {
                                              showCountryPicker(
                                                context: context,
                                                searchAutofocus: false,
                                                showPhoneCode: true,
                                                // optional. Shows phone code before the country name.
                                                onSelect: (Country country) {
                                                  setState(() {
                                                    code = country.phoneCode;
                                                  });
                                                  // flag = country.flagEmoji;
                                                  // print(countryPickerController.code.value);
                                                  // print(flag);
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: SizedBox(
                                                // color: Colors.blue,
                                                width: 70,
                                                // width: MediaQuery.of(context).size.width/3.5,
                                                child: Row(children: [
                                                  Text("+$code"),
                                                  const Icon(
                                                      Icons.arrow_drop_down),
                                                ]),
                                              ),
                                            ),
                                          ),
                                          border: const OutlineInputBorder(),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          labelStyle: const TextStyle(
                                              color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: assignStaffVal,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                TextEditingController
                                                    searchController =
                                                    TextEditingController();
                                                List<Staff>
                                                    filteredList = List.from(
                                                        commonDetails!.data
                                                            .staff);

                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text(
                                                          'Assign Staff'),
                                                      content: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // 🔍 Search box
                                                          TextField(
                                                            controller:
                                                                searchController,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                filteredList = commonDetails!
                                                                    .data
                                                                    .staff
                                                                    .where((staff) => staff
                                                                        .staffName
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            value.toLowerCase()))
                                                                    .toList();
                                                              });
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  "Search",
                                                              prefixIcon: const Icon(
                                                                  Icons.search,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),

                                                          // 📋 Staff list
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .8,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .35,
                                                            child: ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  filteredList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      ind) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      assignStaff = filteredList[
                                                                              ind]
                                                                          .staffName
                                                                          .toString();
                                                                      assignStaffId = filteredList[
                                                                              ind]
                                                                          .userId
                                                                          .toString();
                                                                      assignStaffVal
                                                                          .text = filteredList[
                                                                              ind]
                                                                          .staffName
                                                                          .toString();
                                                                      Navigator.pop(
                                                                          context,
                                                                          true);
                                                                    });
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        filteredList[ind]
                                                                            .staffName
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),

                                                          // ❌ Unassigned option
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                assignStaff =
                                                                    'Un Assigned';
                                                                assignStaffId =
                                                                    '';
                                                                assignStaffVal
                                                                        .text =
                                                                    'Un Assigned';
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              });
                                                            },
                                                            child:
                                                                const SizedBox(
                                                              height: 45,
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  'Un Assigned',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          maxLines: 1,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                left: 10, top: 2, bottom: 2),
                                            labelText: 'Assign Staff',
                                            fillColor: Colors.white,
                                            filled: true,
                                            prefixIcon: Icon(Icons.person,
                                                color: Colors.grey),
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: cost,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, top: 2, bottom: 2),
                                              labelText: 'Cost',
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(
                                                  Icons.currency_rupee,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       left: 10, right: 10),
                                //   child: TextFormField(
                                //     controller: leadTypeVal,
                                //     onTap: () {
                                //       showDialog(
                                //           context: context,
                                //           builder: (BuildContext context) {
                                //             return AlertDialog(
                                //               scrollable: true,
                                //               title:
                                //                   const Text('Lead Category'),
                                //               content: SizedBox(
                                //                 width: MediaQuery.of(context)
                                //                         .size
                                //                         .width *
                                //                     .8,
                                //                 height: MediaQuery.of(context)
                                //                         .size
                                //                         .height *
                                //                     .46,
                                //                 child: ListView.builder(
                                //                   shrinkWrap: true,
                                //                   itemCount: commonDetails!
                                //                       .data.leadCategory.length,
                                //                   itemBuilder: (context, ind) {
                                //                     return InkWell(
                                //                       onTap: () async {
                                //                         leadSubTypeList =
                                //                             await HttpService.leadSubType(
                                //                                 commonDetails!
                                //                                     .data
                                //                                     .leadCategory[
                                //                                         ind]
                                //                                     .leadCategoryId
                                //                                     .toString());
                                //                         setState(() {
                                //                           leadSubType =
                                //                               'Lead Sub Category';
                                //                           leadSubTypeId = '';
                                //                           leadType =
                                //                               commonDetails!
                                //                                   .data
                                //                                   .leadCategory[
                                //                                       ind]
                                //                                   .leadCategory
                                //                                   .toString();
                                //                           leadTypeId =
                                //                               commonDetails!
                                //                                   .data
                                //                                   .leadCategory[
                                //                                       ind]
                                //                                   .leadCategoryId
                                //                                   .toString();
                                //                           Navigator.pop(
                                //                               context, true);
                                //                         });
                                //                       },
                                //                       child: SizedBox(
                                //                         height: 50,
                                //                         child: Text(
                                //                           commonDetails!
                                //                               .data
                                //                               .leadCategory[ind]
                                //                               .leadCategory
                                //                               .toString(),
                                //                           style:
                                //                               const TextStyle(
                                //                                   fontSize: 18),
                                //                         ),
                                //                       ),
                                //                     );
                                //                   },
                                //                 ),
                                //               ),
                                //             );
                                //           });
                                //     },
                                //     maxLines: 1,
                                //     readOnly: true,
                                //     decoration: const InputDecoration(
                                //         contentPadding: EdgeInsets.only(
                                //             left: 10, top: 2, bottom: 2),
                                //         labelText: 'Lead Category',
                                //         fillColor: Colors.white,
                                //         filled: true,
                                //         prefixIcon: Icon(
                                //             Icons
                                //                 .arrow_drop_down_circle_outlined,
                                //             color: Colors.grey),
                                //         border: OutlineInputBorder(),
                                //         focusedBorder: OutlineInputBorder(
                                //           borderSide:
                                //               BorderSide(color: Colors.grey),
                                //         ),
                                //         labelStyle:
                                //             TextStyle(color: Colors.grey)),
                                //   ),
                                // ),

                               
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: leadTypeVal,
                                          readOnly: true,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                TextEditingController
                                                    searchController =
                                                    TextEditingController();
                                                List<LeadCategory>
                                                    filteredList = List.from(
                                                        commonDetails!
                                                            .data.leadCategory);

                                                return StatefulBuilder(
                                                  builder: (context,
                                                      setDialogState) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text(
                                                          'Lead Category'),
                                                      content: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.55,
                                                        child: Column(
                                                          children: [
                                                            // 🔍 Search box
                                                            TextField(
                                                              controller:
                                                                  searchController,
                                                              onChanged:
                                                                  (value) {
                                                                setDialogState(
                                                                    () {
                                                                  filteredList = commonDetails!
                                                                      .data
                                                                      .leadCategory
                                                                      .where((cat) => cat
                                                                          .leadCategory
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              value.toLowerCase()))
                                                                      .toList();
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    "Search",
                                                                prefixIcon: const Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: Colors
                                                                        .grey),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            // Category list
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    filteredList
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        ind) {
                                                                  final category =
                                                                      filteredList[
                                                                          ind];
                                                                  return InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      // Fetch subcategories
                                                                      final subTypeResponse = await HttpService.leadSubType(category
                                                                          .leadCategoryId
                                                                          .toString());

                                                                      // Update parent page state
                                                                      setState(
                                                                          () {
                                                                        leadType =
                                                                            category.leadCategory;
                                                                        leadTypeId = category
                                                                            .leadCategoryId
                                                                            .toString();
                                                                        leadTypeVal.text =
                                                                            category.leadCategory;

                                                                        leadSubTypeList =
                                                                            subTypeResponse;
                                                                        leadSubType =
                                                                            'Lead Sub Category';
                                                                        leadSubTypeId =
                                                                            '';
                                                                        leadSubTypeVal.text =
                                                                            '';
                                                                      });

                                                                      Navigator.pop(
                                                                          context); // Close dialog
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          45,
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        category
                                                                            .leadCategory,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Lead Category',
                                            prefixIcon: const Icon(
                                                Icons
                                                    .arrow_drop_down_circle_outlined,
                                                color: Colors.grey),
                                               
                                            suffixIcon: 
                                             createLeadCategory == 'true'?
                                            IconButton(
                                              icon: const Icon(Icons.add_circle,
                                                  color: Colors.green),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AddLeadCategoryDialog(
                                                    onSubmit: (leadName, cost,
                                                        subcategory) async {
                                                      final token = await Common
                                                          .getSharedPref(
                                                              'token');
                                                      final response =
                                                          await HttpService
                                                              .postLeadCategory(
                                                        leadName,
                                                        cost,
                                                        subcategory,
                                                      );

                                                      if (response != null &&
                                                          response.status) {
                                                        final refreshed =
                                                            await HttpService
                                                                .addLeadCommonData(
                                                                    token);
                                                        setState(() {
                                                          commonDetails =
                                                              refreshed;
                                                          final last = refreshed
                                                              .data
                                                              .leadCategory
                                                              .last;
                                                          leadType =
                                                              last.leadCategory;
                                                          leadTypeId = last
                                                              .leadCategoryId
                                                              .toString();
                                                          leadTypeVal.text =
                                                              last.leadCategory;

                                                          leadSubType =
                                                              'Lead Sub Category';
                                                          leadSubTypeId = '';
                                                          leadSubTypeVal.text =
                                                              '';
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Lead category added successfully"),
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Failed to add lead category"),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ):SizedBox(),
                                            border: const OutlineInputBorder(),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 15),

// Lead Sub Category Field
                                leadSubTypeList != null &&
                                        leadSubTypeList!.data!.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: TextFormField(
                                          controller: leadSubTypeVal,
                                          readOnly: true,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  scrollable: true,
                                                  title: const Text(
                                                      'Lead Sub Category'),
                                                  content: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                    child: ListView.builder(
                                                      itemCount:
                                                          leadSubTypeList!
                                                              .data!.length,
                                                      itemBuilder:
                                                          (context, subIndex) {
                                                        final subCategory =
                                                            leadSubTypeList!
                                                                    .data![
                                                                subIndex];
                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              leadSubType =
                                                                  subCategory
                                                                      .leadSubCategory!;
                                                              leadSubTypeId =
                                                                  subCategory
                                                                      .leadSubCategoryId
                                                                      .toString();
                                                              leadSubTypeVal
                                                                      .text =
                                                                  leadSubType;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                              subCategory
                                                                  .leadSubCategory!,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Lead Sub Category',
                                            prefixIcon: Icon(Icons
                                                .arrow_drop_down_circle_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),

                                SizedBox(height: 15),

                                // leadSubTypeList != null &&
                                //         leadSubTypeList!.data!.isNotEmpty
                                //     ? Padding(
                                //         padding: const EdgeInsets.only(
                                //             bottom: 20, left: 10, right: 10),
                                //         child: TextFormField(
                                //           controller: leadSubTypeVal,
                                //           onTap: () {
                                //             showDialog(
                                //               context: context,
                                //               builder: (BuildContext context) {
                                //                 return AlertDialog(
                                //                   scrollable: true,
                                //                   title: const Text(
                                //                       'Lead Sub Category'),
                                //                   content:
                                //                       SingleChildScrollView(
                                //                     child: ConstrainedBox(
                                //                       constraints:
                                //                           BoxConstraints(
                                //                         maxHeight: MediaQuery
                                //                                     .of(context)
                                //                                 .size
                                //                                 .height *
                                //                             0.5, // Adjust as needed
                                //                       ),
                                //                       child: ListView.builder(
                                //                         shrinkWrap: true,
                                //                         itemCount:
                                //                             leadSubTypeList!
                                //                                 .data!.length,
                                //                         itemBuilder: (context,
                                //                             subIndex) {
                                //                           return InkWell(
                                //                             onTap: () {
                                //                               setState(() {
                                //                                 leadSubType = leadSubTypeList!
                                //                                     .data![
                                //                                         subIndex]
                                //                                     .leadSubCategory
                                //                                     .toString();
                                //                                 leadSubTypeId = leadSubTypeList!
                                //                                     .data![
                                //                                         subIndex]
                                //                                     .leadSubCategoryId
                                //                                     .toString();
                                //                                 Navigator.pop(
                                //                                     context,
                                //                                     true);
                                //                               });
                                //                             },
                                //                             child: SizedBox(
                                //                               height: 50,
                                //                               child: Text(
                                //                                 leadSubTypeList!
                                //                                     .data![
                                //                                         subIndex]
                                //                                     .leadSubCategory
                                //                                     .toString(),
                                //                                 style:
                                //                                     const TextStyle(
                                //                                         fontSize:
                                //                                             18),
                                //                               ),
                                //                             ),
                                //                           );
                                //                         },
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 );
                                //               },
                                //             );
                                //           },
                                //           maxLines: 1,
                                //           readOnly: true,
                                //           decoration: const InputDecoration(
                                //               contentPadding: EdgeInsets.only(
                                //                   left: 10, top: 2, bottom: 2),
                                //               labelText: 'Lead Sub Category',
                                //               fillColor: Colors.white,
                                //               filled: true,
                                //               prefixIcon: Icon(
                                //                   Icons
                                //                       .arrow_drop_down_circle_outlined,
                                //                   color: Colors.grey),
                                //               border: OutlineInputBorder(),
                                //               focusedBorder: OutlineInputBorder(
                                //                 borderSide: BorderSide(
                                //                     color: Colors.grey),
                                //               ),
                                //               labelStyle: TextStyle(
                                //                   color: Colors.grey)),
                                //         ),
                                //       )
                                //     : const SizedBox(),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      TextFormField(
                                        controller: leadSourceVal,
                                        readOnly: true,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              TextEditingController
                                                  searchController =
                                                  TextEditingController();
                                              List<LeadSource> filteredList =
                                                  List.from(commonDetails!
                                                      .data.leadSource);

                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Lead Source'),
                                                    content: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.55,
                                                      child: Column(
                                                        children: [
                                                          // 🔍 Search Box
                                                          TextField(
                                                            controller:
                                                                searchController,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                filteredList = commonDetails!
                                                                    .data
                                                                    .leadSource
                                                                    .where((src) => src
                                                                        .leadSource
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            value.toLowerCase()))
                                                                    .toList();
                                                              });
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  "Search",
                                                              prefixIcon: const Icon(
                                                                  Icons.search,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),

                                                          // 📋 Source List
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  filteredList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      ind) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      leadSource =
                                                                          filteredList[ind]
                                                                              .leadSource;
                                                                      leadSourceId =
                                                                          filteredList[ind]
                                                                              .leadSourceId;
                                                                      leadSourceVal
                                                                          .text = filteredList[
                                                                              ind]
                                                                          .leadSource;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    child: Text(
                                                                      filteredList[
                                                                              ind]
                                                                          .leadSource,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Lead Source',
                                          prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey,
                                          ),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        child: 
                                        addLeadSource == 'true'?
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  AddLeadSourceDialog(
                                                onSubmit:
                                                    (leadSourceName) async {
                                                  final token = await Common
                                                      .getSharedPref('token');
                                                  final response =
                                                      await HttpService
                                                          .postLeadSource(
                                                              leadSourceName);

                                                  if (response != null &&
                                                      response.status) {
                                                    final refreshed =
                                                        await HttpService
                                                            .addLeadCommonData(
                                                                token);
                                                    setState(() {
                                                      commonDetails = refreshed;
                                                    });
                                                    Navigator.pop(context);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Failed to add lead source")),
                                                    );
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ):SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: priorityVal,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text('Priority'),
                                              content: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .24,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .8,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: commonDetails!
                                                      .data.priority.length,
                                                  itemBuilder: (context, ind) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          priority =
                                                              commonDetails!
                                                                  .data
                                                                  .priority[ind]
                                                                  .priority
                                                                  .toString();
                                                          priorityId =
                                                              commonDetails!
                                                                  .data
                                                                  .priority[ind]
                                                                  .priorityId
                                                                  .toString();
                                                          Navigator.pop(
                                                              context, true);
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Text(
                                                          commonDetails!
                                                              .data
                                                              .priority[ind]
                                                              .priority
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    maxLines: 1,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Priority',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: address,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                        labelText: 'Address',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: SizedBox(
                                    child: TextFormField(
                                      controller: pinCode,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'PIN Code',
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      onChanged: (value) async {
                                        if (value.length == 6) {
                                          setState(() {
                                            isLoading = true;
                                            postOffices = [];
                                            selectedPostOffice = null;
                                          });
                                          var model =
                                              await HttpService.fetchPostOffice(
                                                  value);
                                          setState(() {
                                            isLoading = false;
                                            postalCodeModel = model;
                                            postOffices =
                                                model?.postOffice ?? [];
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                //   const SizedBox(height: 15),
                                if (isLoading)
                                  const Center(
                                      child: CircularProgressIndicator()),

                                if (postOffices.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 337,
                                        child:
                                            DropdownButtonFormField<PostOffice>(
                                          value: selectedPostOffice,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: "Select Post Office",
                                            border: OutlineInputBorder(),
                                          ),
                                          items: postOffices.map((postOffice) {
                                            return DropdownMenuItem<PostOffice>(
                                              value: postOffice,
                                              child:
                                                  Text(postOffice.name ?? ''),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedPostOffice = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                if (postOffices.isNotEmpty)
                                  SizedBox(
                                    height: 15,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    children: [
                                      // 🔹 State Selection
                                      Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          TextFormField(
                                            controller: stateVal,
                                            readOnly: true,
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  TextEditingController
                                                      searchController =
                                                      TextEditingController();
                                                  List<StateList> filteredList =
                                                      List.from(
                                                          stateDetails!.data);

                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setStateSB) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Select State'),
                                                        content: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.55,
                                                          child: Column(
                                                            children: [
                                                              TextField(
                                                                controller:
                                                                    searchController,
                                                                onChanged:
                                                                    (value) {
                                                                  setStateSB(
                                                                      () {
                                                                    filteredList = stateDetails!
                                                                        .data
                                                                        .where((item) => item
                                                                            .name
                                                                            .toLowerCase()
                                                                            .contains(value.toLowerCase()))
                                                                        .toList();
                                                                  });
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      "Search State",
                                                                  prefixIcon: const Icon(
                                                                      Icons
                                                                          .search,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Expanded(
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      filteredList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          ind) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          stateVal.text =
                                                                              filteredList[ind].name;
                                                                          StateId =
                                                                              filteredList[ind].id;
                                                                          districtVal
                                                                              .clear();
                                                                          districtList =
                                                                              [];
                                                                          isDistrictLoading =
                                                                              true;
                                                                        });
                                                                        Navigator.pop(
                                                                            context);
                                                                        var result =
                                                                            await HttpService.getDistrict(StateId!);
                                                                        setState(
                                                                            () {
                                                                          districtList =
                                                                              result?.data ?? [];
                                                                          isDistrictLoading =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                10,
                                                                            horizontal:
                                                                                5),
                                                                        child:
                                                                            Text(
                                                                          filteredList[ind]
                                                                              .name,
                                                                          style:
                                                                              const TextStyle(fontSize: 18),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'State',
                                              prefixIcon: Icon(
                                                  Icons
                                                      .arrow_drop_down_circle_outlined,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 15),
                                      if (isDistrictLoading)
                                        const Center(
                                            child: CircularProgressIndicator()),
                                      if (!isDistrictLoading &&
                                          districtList.isNotEmpty)
                                        DropdownButtonFormField<DistrictList>(
                                          value: districtList.isNotEmpty
                                              ? districtList.firstWhere(
                                                  (d) => d.id == DistrictId,
                                                  orElse: () =>
                                                      districtList.first)
                                              : null,
                                          decoration: const InputDecoration(
                                            labelText: 'Select District',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: districtList.map((d) {
                                            return DropdownMenuItem<
                                                DistrictList>(
                                              value: d,
                                              child: Text(d.name),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              DistrictId = value?.id;
                                              districtVal.text =
                                                  value?.name ?? '';
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: remark,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                        labelText: 'Remarks',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(Icons.list,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: callResultVal,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text('Status'),
                                              content: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: commonDetails!
                                                      .data.callResult.length,
                                                  itemBuilder: (context, ind) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          callResult =
                                                              commonDetails!
                                                                  .data
                                                                  .callResult[
                                                                      ind]
                                                                  .callResult
                                                                  .toString();
                                                          callResultId =
                                                              commonDetails!
                                                                  .data
                                                                  .callResult[
                                                                      ind]
                                                                  .callResultId
                                                                  .toString();
                                                          if (callResultId !=
                                                              '2') {
                                                            nextFollowupDate =
                                                                '';
                                                          }
                                                          Navigator.pop(
                                                              context, true);
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Text(
                                                          commonDetails!
                                                              .data
                                                              .callResult[ind]
                                                              .callResult
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    maxLines: 1,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Lead Status',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),
                                if (callResultId == '2' ||
                                    callResultId == '3' ||
                                    callResultId == '4')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: TextFormField(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            List filteredResponses = List.from(
                                                commonDetails!
                                                    .data.callResponseStatus);
                                            TextEditingController
                                                searchController =
                                                TextEditingController();

                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  scrollable: true,
                                                  title: const Text(
                                                      'Call Response'),
                                                  content: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.8,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.53,
                                                    child: Column(
                                                      children: [
                                                        // Search Box
                                                        TextField(
                                                          controller:
                                                              searchController,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Search...",
                                                            prefixIcon:
                                                                const Icon(Icons
                                                                    .search),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                          ),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              filteredResponses = commonDetails!
                                                                  .data
                                                                  .callResponseStatus
                                                                  .where((element) => element
                                                                      .callResponse
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          value
                                                                              .toLowerCase()))
                                                                  .toList();
                                                            });
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        // List
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                filteredResponses
                                                                    .length,
                                                            itemBuilder:
                                                                (context, ind) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    callResponse = filteredResponses[
                                                                            ind]
                                                                        .callResponse
                                                                        .toString();
                                                                    callResponseId = filteredResponses[
                                                                            ind]
                                                                        .callResponseId
                                                                        .toString();

                                                                    /// ✅ Update the TextFormField controller
                                                                    callResponseVal
                                                                            .text =
                                                                        callResponse;

                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  });
                                                                },
                                                                child: SizedBox(
                                                                  height: 50,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8,
                                                                        horizontal:
                                                                            5),
                                                                    child: Text(
                                                                      filteredResponses[
                                                                              ind]
                                                                          .callResponse
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      maxLines: 1,
                                      readOnly: true,
                                      controller: callResponseVal,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 10, top: 2, bottom: 2),
                                          labelText: 'Call Response',
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: Icon(Icons.add_call,
                                              color: Colors.grey),
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          labelStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                SizedBox(
                                  height: 15,
                                ),

                                if (callResultId == '2')
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: checked == true
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.88,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: TextFormField(
                                            controller: nextFollowupDate1,
                                            readOnly: true,
                                            onTap: () async {
                                              await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2100))
                                                  .then((selectedDate) {
                                                if (selectedDate != null) {
                                                  showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              TimeOfDay.now())
                                                      .then((selectedTime) {
                                                    String newDate =
                                                        selectedDate.toString();
                                                    newDate = newDate.substring(
                                                        0,
                                                        newDate.indexOf(" "));
                                                    String convertedNewDate =
                                                        getYmdFromDmy(newDate);
                                                    if (selectedTime != null) {
                                                      nextFollowupDate1.text =
                                                          "$convertedNewDate ${selectedTime.format(context)}";
                                                    } else {}
                                                  });
                                                }
                                              });
                                            },
                                            decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 2,
                                                    bottom: 2),
                                                labelText: 'Next Followup Date',
                                                fillColor: Colors.white,
                                                filled: true,
                                                prefixIcon: Icon(
                                                    Icons.calendar_month_sharp,
                                                    color: Colors.grey),
                                                border: OutlineInputBorder(),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: checked,
                                        child: SizedBox(
                                          width: 90,
                                          child: Container(
                                            width: 80,
                                            foregroundDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              border: Border.all(
                                                color: Colors.blueGrey,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                    ),
                                                    controller: timeBefore,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                      decimal: false,
                                                      signed: true,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 38.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            Icons.arrow_drop_up,
                                                            size: 18.0,
                                                          ),
                                                          onTap: () {
                                                            int currentValue =
                                                                int.parse(
                                                                    timeBefore
                                                                        .text);
                                                            setState(() {
                                                              currentValue++;
                                                              timeBefore.text =
                                                                  (currentValue)
                                                                      .toString(); // incrementing value
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: const Icon(
                                                          Icons.arrow_drop_down,
                                                          size: 18.0,
                                                        ),
                                                        onTap: () {
                                                          int currentValue =
                                                              int.parse(
                                                                  timeBefore
                                                                      .text);
                                                          setState(() {
                                                            currentValue--;
                                                            timeBefore
                                                                .text = (currentValue >
                                                                        0
                                                                    ? currentValue
                                                                    : 0)
                                                                .toString(); // decrementing value
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (callResultId == '2')
                                        InkWell(
                                          onTap: toggleTextFieldVisibility,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15, left: 5),
                                            child: SizedBox(
                                              width: 10,
                                              child: Icon(Icons.notifications,
                                                  color: checked == false
                                                      ? Colors.green
                                                      : Colors.red),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (callResultId == '2')
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          decriptionUi(index),
                                        ],
                                      );
                                    },
                                    itemCount: commonDetails!
                                        .data.additionalFields.length),
                                InkWell(
                                  onTap: () async {
                                    if (globalKey.currentState!.validate()) {
                                      globalKey.currentState!.save();
                                      descriptions.removeWhere((item) =>
                                          ["", null, false, 0].contains(item));
                                      final connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.mobile ||
                                          connectivityResult ==
                                              ConnectivityResult.wifi) {
                                        if (multiBranch == 'true' &&
                                            roleId == '2' &&
                                            branch == null) {
                                          Common.toastMessaage(
                                              'Choose Branch', Colors.red);
                                        } else if (clientName.text.isEmpty) {
                                          Common.toastMessaage(
                                              'Customer Name cannot be empty',
                                              Colors.red);
                                        } else if (contactNo.text.isEmpty) {
                                          Common.toastMessaage(
                                              'Contact Number cannot be empty',
                                              Colors.red);
                                        } else if (code == '91' &&
                                            contactNo.text.length != 10) {
                                          Common.toastMessaage(
                                              'Phone Number must be 10 digit',
                                              Colors.red);
                                        } else if (priorityId == '') {
                                          Common.toastMessaage(
                                              'Priority cannot be empty',
                                              Colors.red);
                                        } else if (callResultId == '') {
                                          Common.toastMessaage(
                                              'Status cannot be empty',
                                              Colors.red);
                                        } else if (callResultId == '2' &&
                                            nextFollowupDate1.text.isEmpty) {
                                          Common.toastMessaage(
                                              'Choose next followup date',
                                              Colors.red);
                                        } else {
                                          if (context.mounted) {
                                            Common.showProgressDialog(
                                                context, "Loading..");
                                          }
                                          CheckLeadPhoneNumberModel
                                              checkLeadPhone = await HttpService
                                                  .checkLeadPhoneNumber(
                                                      widget.token,
                                                      contactNo.text,
                                                      code);
                                          if (checkLeadPhone.data == true) {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext ctx) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Alert !!!'),
                                                      content: Text(
                                                          checkLeadPhone.message
                                                              .toString()),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Close')),
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              if (context
                                                                  .mounted) {
                                                                Common.showProgressDialog(
                                                                    context,
                                                                    "Loading..");
                                                              }
                                                              AddLeadModel object = await HttpService.addLeads(
                                                                  widget.token,
                                                                  branch,
                                                                  clientName
                                                                      .text,
                                                                  leadTypeId,
                                                                  leadSubTypeId,
                                                                  contactNo
                                                                      .text,
                                                                  assignStaffId,
                                                                  cost.text,
                                                                  priorityId,
                                                                  address.text,
                                                                  pinCode.text,
                                                                  selectedPostOffice
                                                                          ?.name ??
                                                                      "",
                                                                  remark.text,
                                                                  callResultId,
                                                                   callResponseId,
                                                                  nextFollowupDate1
                                                                      .text,
                                                                  descriptions,
                                                                  code,
                                                                  checked,
                                                                  timeBefore,
                                                                  leadSourceId,
                                                                  stateId:
                                                                      StateId,
                                                                  districtId:
                                                                      DistrictId);
                                                              if (object
                                                                      .status ==
                                                                  true) {
                                                                Common.toastMessaage(
                                                                    object
                                                                        .message,
                                                                    Colors
                                                                        .green);

                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              } else {
                                                                Common.toastMessaage(
                                                                    object
                                                                        .message,
                                                                    Colors.red);
                                                                if (context
                                                                    .mounted) {
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              }
                                                            },
                                                            child: const Text(
                                                                'Continue')),
                                                      ],
                                                    );
                                                  });
                                            }
                                          } else {
                                            AddLeadModel object =
                                                await HttpService.addLeads(
                                                    widget.token,
                                                    branch,
                                                    clientName.text,
                                                    leadTypeId,
                                                    leadSubTypeId,
                                                    contactNo.text,
                                                    assignStaffId,
                                                    cost.text,
                                                    priorityId,
                                                    address.text,
                                                    pinCode.text,
                                                    selectedPostOffice?.name ??
                                                        "",
                                                    remark.text,
                                                    callResultId,
                                                    callResponseId,
                                                    nextFollowupDate1.text,
                                                    descriptions,
                                                    code,
                                                    checked,
                                                    timeBefore.text,
                                                    leadSourceId,
                                                    stateId:
                                                        StateId, // ← pass selected state
                                                    districtId: DistrictId
                                                    //  leadSourceId
                                                    );
                                            if (object.status == true) {
                                              Common.toastMessaage(
                                                  object.message, Colors.green);
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              }
                                            } else {
                                              Common.toastMessaage(
                                                  object.message, Colors.red);
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            }
                                          }
                                        }
                                      } else {
                                        setState(() {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'No Network Found..Try Again Later..'),
                                              backgroundColor: Colors.redAccent,
                                              elevation: 10,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.all(10),
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text('Submit',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.1),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/main/packageimage.png',
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 15, 15, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                const Text(
                                                  'Package Expired..',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    const Spacer(),
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
                                          Container(height: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
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

  Future<dynamic> contactPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Permission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          // decoration: TextDecoration.none,
                          //fontFamily: Theme.of(context).textTheme,
                        ),
                      ),
                      const Text(
                        "Our app accesses your contact book to help you efficiently manage and organize your contacts. Specifically, we allow you to save or update contact information directly in your device’s contact list.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xffe94040)),
                              child: const Center(
                                child: Text("Deny",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              contactPermission = "true";
                              setState(() {
                                Common.saveSharedPref(
                                    "getContactPermission", 'true');
                                selectContact();
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green),
                              child: const Center(
                                child: Text("Allow",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
              TextButton(
                  onPressed: () async {
                    String url = 'tel:${configure!.data!.supportTeamNumber}';
                    await launchUrl(Uri.parse(url));
                  },
                  child: const Text('Call'))
            ],
          );
        });
  }

  Widget decriptionUi(index) {
    _controllers.add(TextEditingController());
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: TextFormField(
              onSaved: (val) {
                descriptions.add("");
                descriptions[index] = {
                  "id": commonDetails!.data.additionalFields[index].id,
                  "name": commonDetails!.data.additionalFields[index].fieldName,
                  "value": val
                };
              },
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText:
                      commonDetails!.data.additionalFields[index].fieldName,
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.arrow_drop_down_circle,
                      color: Colors.grey),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  // Future<void> selectContact() async {
  //   // Check and request permissions
  //   if (await FlutterContacts.requestPermission()) {
  //     // Pick a contact
  //     final Contact? contact = await FlutterContacts.openExternalPick();
  //     if (contact != null && contact.phones.isNotEmpty) {
  //       String number = contact.phones.first.number;
  //       String name = contact.displayName;

  //       contactNo.text = number.replaceAll(RegExp(r'[ ()-]'), '');
  //       clientName.text = name;

  //       setState(() {});
  //     }
  //   } else {
  //     Common.toastMessaage(
  //         "Permission denied! Please enable contacts access.", Colors.red);
  //   }
  // }
  Future<void> selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final Contact? contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number = contact.phones.first.number;
        String name = contact.displayName;
        number = number.replaceAll(RegExp(r'[^\d+]'), '');
        if (number.startsWith('+') && number.length > 10) {
          number = number.substring(number.length - 10);
        } else if (number.length > 10) {
          number = number.substring(number.length - 10);
        }
        contactNo.text = number;
        clientName.text = name;
        setState(() {});
      }
    } else {
      Common.toastMessaage(
          "Permission denied! Please enable contacts access.", Colors.red);
    }
  }
}
