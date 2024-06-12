import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/editLeadModel.dart';
import '../../models/lead_management/leadDeatailsModel.dart';
import '../../models/lead_management/leadDeatailsModelAdd.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../screens/leadManagement/leadDetails.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

import '../../widgets/inputTextFeildWidget.dart';

// ignore: must_be_immutable
class EditLead extends StatefulWidget {
  String? token;
  String callMasterId;
  bool editLeads;
  bool deleteLeads;
  bool cloudCall;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrolToIndex;

  EditLead(this.token, this.callMasterId, this.editLeads, this.deleteLeads,
      this.cloudCall,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrolToIndex});

  @override
  State<EditLead> createState() => _EditLeadState();
}

class _EditLeadState extends State<EditLead> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
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
  String priority = 'Normal';
  String priorityId = '2';
  TextEditingController clientName = TextEditingController();
  TextEditingController contactNo = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController remark = TextEditingController();
  String? nextFollowupDate = '';
  LeadDeatailsModel? leadDetails;
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController assignUserval = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  var code = '91';

  final List<TextEditingController> _controllers = [];
  List descriptions = [];
  LeadDeatailsModelAdd? leadDetailsAdditional;
  String roleId = '';
  String multiBranch = '';
  String? branch;

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
    roleId = await Common.getSharedPref("roleId");
    multiBranch = await Common.getSharedPref("multiBranch");
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    leadDetails =
        await HttpService.leadDetails(widget.token, widget.callMasterId);
    leadDetailsAdditional =
        await HttpService.listAddonDet(widget.token, widget.callMasterId);

    if (commonDetails != null) {
      if (leadDetails!.data!.leadCategoryId.toString() != '') {
        leadSubTypeList = await HttpService.leadSubType(
            leadDetails!.data!.leadCategoryId.toString());
        setState(() {});
      }
      setState(() {
        if (leadDetails!.data!.branchId.toString() != '') {
          branch = leadDetails!.data!.branchId.toString();
        }
        leadType = leadDetails!.data!.leadCategory.toString();
        leadTypeId = leadDetails!.data!.leadCategoryId.toString();
        assignStaff = leadDetails!.data!.staffName.toString();
        assignStaffId = leadDetails!.data!.assignedUserId.toString();
        callResultId = leadDetails!.data!.callResultId.toString();
        callResult = leadDetails!.data!.callResult.toString();
        priorityId = leadDetails!.data!.priorityId.toString();
        priority = leadDetails!.data!.priority.toString();
        clientName.text = leadDetails!.data!.clientName.toString();
        contactNo.text = leadDetails!.data!.contactNumber1.toString();
        cost.text = leadDetails!.data!.cost.toString();
        final myString = leadDetails!.data!.contactNumber1.toString();
        int countryCodeLengt = leadDetails!.data!.countryCode!.length;
        contactNo.text = myString.substring(countryCodeLengt);
        address.text = leadDetails!.data!.address.toString();
        remark.text = leadDetails!.data!.remarks.toString();
        leadSubType = leadDetails!.data!.leadSubCategory.toString();
        leadSubTypeId = leadDetails!.data!.leadSubCategory.toString();
        leadTypeVal.text = leadType;
        leadSubTypeVal.text = leadSubType;
        assignUserval.text = leadDetails!.data!.staffName.toString();
        priorityVal.text = leadDetails!.data!.priority.toString();
        code = leadDetails!.data!.countryCode.toString();
        for (int i = 0;
            i < leadDetailsAdditional!.data!.additionalFields!.length;
            i++) {
          _controllers.add(TextEditingController());
          _controllers[i].text = leadDetailsAdditional!
              .data!.additionalFields![i].value
              .toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                        Navigator.of(context).pop();
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
                      'Edit Lead',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: commonDetails != null
          ? SingleChildScrollView(
              child: Form(
                key: globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    multiBranch == 'true' && roleId == '2'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: DropdownButtonFormField(
                              value: branch,
                              onChanged: (value) {
                                setState(() {
                                  branch = value.toString();
                                });
                              },
                              items: commonDetails!.data.branch.map((data) {
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
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'Select Branch',
                                prefixIcon: const Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                labelStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: InputTextField(
                        hintText: 'Customer Name',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: clientName,
                        width: 1,
                        iconData: Icons.person,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: leadTypeVal,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Lead Category'),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .2,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              .8,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: commonDetails!
                                            .data.leadCategory.length,
                                        itemBuilder: (context, ind) {
                                          return InkWell(
                                            onTap: () async {
                                              leadSubTypeList =
                                                  await HttpService.leadSubType(
                                                      commonDetails!
                                                          .data
                                                          .leadCategory[ind]
                                                          .leadCategoryId
                                                          .toString());
                                              setState(() {
                                                leadSubType =
                                                    'Lead Sub Category';
                                                leadSubTypeId = '';
                                                leadTypeVal.text =
                                                    commonDetails!
                                                        .data
                                                        .leadCategory[ind]
                                                        .leadCategory
                                                        .toString();
                                                leadType = commonDetails!
                                                    .data
                                                    .leadCategory[ind]
                                                    .leadCategory
                                                    .toString();
                                                leadTypeId = commonDetails!
                                                    .data
                                                    .leadCategory[ind]
                                                    .leadCategoryId
                                                    .toString();
                                                Navigator.pop(context, true);
                                              });
                                            },
                                            child: SizedBox(
                                              height: 50,
                                              child: Text(
                                                commonDetails!
                                                    .data
                                                    .leadCategory[ind]
                                                    .leadCategory
                                                    .toString(),
                                                style: const TextStyle(
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
                              labelText: 'Lead Category',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20, right: 20),
                    //   child: TextFormField(
                    //       onTap: () {
                    //         showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) {
                    //               return AlertDialog(
                    //                 scrollable: true,
                    //                 title: const Text('Lead Category'),
                    //                 content: ListView.builder(
                    //                   shrinkWrap: true,
                    //                   itemCount: commonDetails!
                    //                       .data!.leadCategory!.length,
                    //                   itemBuilder: (context, ind) {
                    //                     return InkWell(
                    //                       onTap: () async {
                    //                         leadSubTypeList =
                    //                             await HttpService.leadSubType(
                    //                                 commonDetails!
                    //                                     .data!
                    //                                     .leadCategory![ind]
                    //                                     .leadCategoryId
                    //                                     .toString());
                    //                         setState(() {
                    //                           leadSubType = 'Lead Sub Category';
                    //                           leadSubTypeId = '';
                    //                           leadType = commonDetails!.data!
                    //                               .leadCategory![ind].leadCategory
                    //                               .toString();
                    //                           leadTypeId = commonDetails!
                    //                               .data!
                    //                               .leadCategory![ind]
                    //                               .leadCategoryId
                    //                               .toString();
                    //                           Navigator.pop(context, true);
                    //                         });
                    //                       },
                    //                       child: SizedBox(
                    //                         height: 50,
                    //                         child: Text(
                    //                           commonDetails!.data!
                    //                               .leadCategory![ind].leadCategory
                    //                               .toString(),
                    //                           style:
                    //                               const TextStyle(fontSize: 18),
                    //                         ),
                    //                       ),
                    //                     );
                    //                   },
                    //                 ),
                    //               );
                    //             });
                    //       },
                    //       maxLines: 1,
                    //       readOnly: true,
                    //       keyboardType: TextInputType.text,
                    //       decoration: InputDecoration(
                    //           filled: true,
                    //           //<-- SEE HERE
                    //           fillColor: Colors.white,
                    //           prefixIcon: FittedBox(
                    //             fit: BoxFit.fill,
                    //             child: Row(
                    //               children: [
                    //                 Container(
                    //                   decoration: const BoxDecoration(
                    //                     color: Color(0xFF2a86c9),
                    //                     borderRadius: BorderRadius.only(
                    //                       topLeft: Radius.circular(40),
                    //                       bottomLeft: Radius.circular(40),
                    //                     ),
                    //                   ),
                    //                   width: 10,
                    //                   height: 50,
                    //                 ),
                    //                 const SizedBox(
                    //                   width: 10,
                    //                 ),
                    //                 const Icon(
                    //                   Icons.arrow_right,
                    //                   color: Colors.grey,
                    //                 ),
                    //                 const SizedBox(
                    //                   width: 10,
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           counterText: "",
                    //           hintText: leadType,
                    //           isDense: true,
                    //           border: OutlineInputBorder(
                    //               borderSide:
                    //                   BorderSide(color: Colors.purple.shade100),
                    //               borderRadius: BorderRadius.circular(10)))),
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                    leadSubTypeList != null && leadSubTypeList!.data!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: SizedBox(
                                    height: 50,
                                    child: TextFormField(
                                      controller: leadSubTypeVal,
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: const Text(
                                                    'Lead Sub Category'),
                                                content: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .12,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .8,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: leadSubTypeList!
                                                        .data!.length,
                                                    itemBuilder:
                                                        (context, subIndex) {
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            leadSubTypeVal
                                                                    .text =
                                                                leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategory
                                                                    .toString();
                                                            leadSubType =
                                                                leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategory
                                                                    .toString();
                                                            leadSubTypeId =
                                                                leadSubTypeList!
                                                                    .data![
                                                                        subIndex]
                                                                    .leadSubCategoryId
                                                                    .toString();
                                                            Navigator.pop(
                                                                context, true);
                                                          });
                                                        },
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: Text(
                                                            leadSubTypeList!
                                                                .data![subIndex]
                                                                .leadSubCategory
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
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
                                          labelText: 'Lead Sub Category',
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
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: contactNo,
                          decoration: InputDecoration(
                              labelText: 'Contact Number',
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
                                child: SizedBox(
                                  // color: Colors.blue,
                                  width: 70,
                                  // width: MediaQuery.of(context).size.width/3.5,
                                  child: Row(children: [
                                    Text("+$code"),
                                    const Icon(Icons.arrow_drop_down),
                                  ]),
                                ),
                              ),
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    // SizedBox(height: 10,),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20, right: 20),
                    //   child: InputTextField(
                    //     hintText: 'Contact Number',
                    //     hintTextColor: Colors.white,
                    //     backgroundColor: Colors.white,
                    //     controller: contactNo,
                    //     keyboardType: TextInputType.number,
                    //     width: 1,
                    //     iconData: Icons.phone_android,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: assignUserval,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Assign Staff'),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .32,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              .8,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            commonDetails!.data.staff.length,
                                        itemBuilder: (context, ind) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                assignUserval.text =
                                                    commonDetails!.data
                                                        .staff[ind].staffName
                                                        .toString();
                                                assignStaff = commonDetails!
                                                    .data.staff[ind].staffName
                                                    .toString();
                                                assignStaffId = commonDetails!
                                                    .data.staff[ind].staffId
                                                    .toString();
                                                Navigator.pop(context, true);
                                              });
                                            },
                                            child: SizedBox(
                                              height: 50,
                                              child: Text(
                                                commonDetails!
                                                    .data.staff[ind].staffName
                                                    .toString(),
                                                style: const TextStyle(
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
                              labelText: 'Assign Staff',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        controller: cost,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Cost',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),

                      // InputTextField(
                      //   hintText: 'Cost',
                      //   hintTextColor: Colors.white,
                      //   backgroundColor: Colors.white,
                      //   controller: cost,
                      //   keyboardType: TextInputType.number,
                      //   width: 1,
                      //   iconData: Icons.currency_rupee,
                      // ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .18,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              .8,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: commonDetails!
                                            .data.priority.length,
                                        itemBuilder: (context, ind) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                priorityVal.text =
                                                    commonDetails!.data
                                                        .priority[ind].priority
                                                        .toString();
                                                priority = commonDetails!.data
                                                    .priority[ind].priority
                                                    .toString();
                                                priorityId = commonDetails!
                                                    .data
                                                    .priority[ind]
                                                    .priorityId
                                                    .toString();
                                                Navigator.pop(context, true);
                                              });
                                            },
                                            child: SizedBox(
                                              height: 50,
                                              child: Text(
                                                commonDetails!.data
                                                    .priority[ind].priority
                                                    .toString(),
                                                style: const TextStyle(
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
                              labelText: 'Priority',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: InputTextField(
                        hintText: 'Address',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: address,
                        width: 1,
                        height: 80,
                        maxLine: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: InputTextField(
                        hintText: 'Remarks',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: remark,
                        width: 1,
                        height: 80,
                        maxLine: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                        itemCount: leadDetailsAdditional!
                            .data!.additionalFields!.length),
                    InkWell(
                      onTap: () async {
                        if (globalKey.currentState!.validate()) {
                          globalKey.currentState!.save();
                          descriptions.removeWhere(
                              (item) => ["", null, false, 0].contains(item));
                          final connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.mobile ||
                              connectivityResult == ConnectivityResult.wifi) {
                            if (multiBranch == 'true' &&
                                roleId == '2' &&
                                branch == null) {
                              Common.toastMessaage('Choose Branch', Colors.red);
                            } else if (clientName.text.isEmpty) {
                              Common.toastMessaage(
                                  'Customer Name cannot be empty', Colors.red);
                            } else if (contactNo.text.isEmpty) {
                              Common.toastMessaage(
                                  'Contact Number cannot be empty', Colors.red);
                            } else if (code == '') {
                              Common.toastMessaage(
                                  'Select country code', Colors.red);
                            } else if (code == '91' &&
                                contactNo.text.length != 10) {
                              Common.toastMessaage(
                                  'Phone Number must be 10 digit', Colors.red);
                            } else if (assignStaffId == '') {
                              Common.toastMessaage(
                                  'Staff cannot be empty', Colors.red);
                            } else if (cost.text.isEmpty) {
                              Common.toastMessaage(
                                  'Cost cannot be empty', Colors.red);
                            } else if (priorityId == '') {
                              Common.toastMessaage(
                                  'Priority cannot be empty', Colors.red);
                            } else {
                              if (context.mounted) {
                                Common.showProgressDialog(context, "Loading..");
                              }
                              EditLeadModel object =
                                  await HttpService.editLeads(
                                      widget.token,
                                      widget.callMasterId,
                                      branch,
                                      clientName.text,
                                      leadTypeId,
                                      leadSubTypeId,
                                      contactNo.text,
                                      assignStaffId,
                                      cost.text,
                                      priorityId,
                                      address.text,
                                      remark.text,
                                      descriptions,
                                      code);
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
                          } else {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No Network Found..Try Again Later..'),
                                  backgroundColor: Colors.redAccent,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                ),
                              );
                            });
                          }
                        }
                      },
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .45,
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
            ),
    );
  }

  Widget decriptionUi(index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: TextFormField(
              controller: _controllers[index],
              onSaved: (val) {
                descriptions.add("");
                descriptions[index] = {
                  "id":
                      leadDetailsAdditional!.data!.additionalFields![index].id,
                  "name": leadDetailsAdditional!
                      .data!.additionalFields![index].name,
                  "value": val
                };
              },
              onFieldSubmitted: (v) {
                setState(() {
                  _controllers[index].text = v;
                });
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
}
