// ignore_for_file: file_names, must_be_immutable

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/branchListModel.dart';
import '../../../models/clients/editClientDetailsModel.dart';
import '../../../models/clients/editClientsModel.dart';
import '../../../models/clients/postalCodeModel.dart';
import '../../../service/service.dart';
import '../../homePage.dart';
import '../../leadManagement/dashboard.dart';
import 'invoiceList.dart';

class EditClients extends StatefulWidget {
  String token;
  String clientId;
  EditClients(this.token, this.clientId, {Key? key}) : super(key: key);

  @override
  State<EditClients> createState() => _EditClientsState();
}

class _EditClientsState extends State<EditClients> {
  EditClientDetailsModel? mainClientDetail;
  bool result = true;
  TextEditingController clientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  PostalCodeModel? postal;
  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldValue = TextEditingController();
  List<Map<String, dynamic>> additionalFields = [];
  String roleId = '';
  String multiBranch = '';
  String? branch;
  BranchListModel? branchList;
  bool isExists = false;
  IsCustomerExistModel? isExist;
  var code = '91';

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
    branchList = await HttpService.getBranchList(widget.token);
    if (branchList != null) {
      setState(() {});
    }
    mainClientDetail =
        await HttpService.editClientDetails(widget.token, widget.clientId);
    if (mainClientDetail != null) {
      clientName.text = mainClientDetail!.data.name.toString();
      phoneNumber.text = mainClientDetail!.data.contactNo.toString();
      email.text = mainClientDetail!.data.emailId.toString();
      address1.text = mainClientDetail!.data.address1.toString();
      address2.text = mainClientDetail!.data.address2.toString();
      address3.text = mainClientDetail!.data.address3.toString();
      pinCode.text = mainClientDetail!.data.pincode.toString();
      gstNumber.text = mainClientDetail!.data.gstNum.toString();
      remarks.text = mainClientDetail!.data.remarks.toString();
      postOffice.text = mainClientDetail!.data.postOffice.toString();
      if (mainClientDetail!.data.countryCode.toString() != '') {
        code = mainClientDetail!.data.countryCode.toString();
      }

      if (pinCode.text != '') {
        postal = await HttpService.fetchPostOffice(pinCode.text);
      }
      if (mainClientDetail!.data.branchId.toString() != '') {
        branch = mainClientDetail!.data.branchId.toString();
      }
      if (mainClientDetail!.data.additionalFields.isNotEmpty) {
        for (int i = 0;
            i < mainClientDetail!.data.additionalFields.length;
            i++) {
          additionalFields.add({
            // "product_name":productName.text,
            "field_name": mainClientDetail!.data.additionalFields[i].fieldName,
            "field_value":
                mainClientDetail!.data.additionalFields[i].fieldValue,
          });
        }
      }
      setState(() {});
    }
  }

  isCustomerExists() async {
    isExist =
        await HttpService.isCustomerExists(widget.clientId, phoneNumber.text);
    if (isExist != null) {
      isExists = isExist!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
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
                    left: 10.0, top: 10.0, bottom: 10.0),
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
                          'Edit Customer',
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
          body: mainClientDetail != null && branchList != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        multiBranch == 'true' && roleId == '2'
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: DropdownButtonFormField(
                                  value: branch,
                                  onChanged: (value) async {
                                    setState(() {
                                      branch = value.toString();
                                    });
                                  },
                                  items: branchList!.data!.map((data) {
                                    return DropdownMenuItem<String>(
                                      value: data.branchId.toString(),
                                      child: Text(
                                        data.branchName.toString(),
                                      ),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
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
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        TextFormField(
                          controller: clientName,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Customer Name *',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onChanged: (value) {
                            if (value.length == 10) {
                              isCustomerExists();
                            }
                          },
                          controller: phoneNumber,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Phone Number *',
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
                              labelStyle:
                                  const TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: email,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Email',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: address1,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Address 1 *',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.location_on,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: address2,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Address 2',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.location_on,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: address3,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Address 3',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.location_on,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onChanged: (value) async {
                            if (value.length >= 6) {
                              postal =
                                  await HttpService.fetchPostOffice(value);
                              setState(() {});
                            } else {
                              postal = null;
                              postOffice.clear();
                              setState(() {});
                            }
                          },
                          controller: pinCode,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Pin Code',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon:
                                  Icon(Icons.pin_drop, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        postal != null
                            ? TextFormField(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            scrollable: true,
                                            title:
                                                const Text('Post Office'),
                                            content: postal!.postOffice !=
                                                    null
                                                ? SizedBox(
                                                    height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height *
                                                        .32,
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height *
                                                        .8,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: postal!
                                                          .postOffice!
                                                          .length,
                                                      itemBuilder:
                                                          (context, ind) {
                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              postOffice.text = postal!
                                                                  .postOffice![
                                                                      ind]
                                                                  .name
                                                                  .toString();
                                                              Navigator.pop(
                                                                  context,
                                                                  true);
                                                            });
                                                          },
                                                          child: SizedBox(
                                                            height: 50,
                                                            child: Text(
                                                              postal!
                                                                  .postOffice![
                                                                      ind]
                                                                  .name
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      18),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : const Text(
                                                    'No Post Office Found'));
                                      });
                                },
                                maxLines: 1,
                                readOnly: true,
                                controller: postOffice,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                    labelText: 'Post Office',
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
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: gstNumber,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'GST Number',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.arrow_right,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: remarks,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10, top: 2, bottom: 2),
                              labelText: 'Remark',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.arrow_right,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        Visibility(
                          visible:
                              additionalFields.isNotEmpty ? true : false,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4), // Using 10%
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4),
                                      2: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.10), // Using 30%
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: const Color(0xFFece9fd),
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Field',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign:
                                                    TextAlign.center),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Value',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign:
                                                    TextAlign.center),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign:
                                                    TextAlign.center),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: additionalFields.length,
                              itemBuilder: (context, index) {
                                Color color = index % 2 == 0
                                    ? const Color(0xFFF3F3F3)
                                    : const Color(0xFFece9fd);
                                return Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4), // Using 10%
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4),
                                      2: FixedColumnWidth(
                                          MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.10), // Using 30%
                                    },
                                    children: [
                                      // Each TableRow represents a row in the Table
                                      TableRow(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: color,
                                        ),
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(8.0),
                                            child: Text(
                                              additionalFields[index]
                                                  ['field_name'],
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(8.0),
                                            child: Text(
                                              additionalFields[index]
                                                  ['field_value'],
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              additionalFields.removeWhere(
                                                (item) => mapEquals(
                                                    item,
                                                    ({
                                                      "field_name":
                                                          additionalFields[
                                                                  index][
                                                              'field_name'],
                                                      "field_value":
                                                          additionalFields[
                                                                  index][
                                                              'field_value'],
                                                    })),
                                              );
        
                                              setState(() {});
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 5),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.8,
                                child: const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Additional Fields',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'If you require extra fields on the customer creation form, kindly generate the fields here.',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    barrierColor:
                                        Colors.white.withOpacity(.4),
                                    context: context,
                                    builder: (context) {
                                      return Material(
                                        type: MaterialType.transparency,
                                        color: Colors.grey.shade200,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Container(
                                              decoration:
                                                  const BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: Offset(1, 1),
                                                  )
                                                ],
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            10)),
                                              ),
                                              height: 280,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  const Text(
                                                    'Additional Fields',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .all(8.0),
                                                    child: SizedBox(
                                                      child: TextFormField(
                                                        controller:
                                                            fieldName,
                                                        keyboardType:
                                                            TextInputType
                                                                .text,
                                                        decoration: const InputDecoration(
                                                            hintText:
                                                                'Field Name',
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            border:
                                                                OutlineInputBorder()),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .all(8.0),
                                                    child: SizedBox(
                                                      child: TextFormField(
                                                        controller:
                                                            fieldValue,
                                                        keyboardType:
                                                            TextInputType
                                                                .text,
                                                        decoration: const InputDecoration(
                                                            hintText:
                                                                'Value',
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            border:
                                                                OutlineInputBorder()),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (fieldName
                                                          .text.isEmpty) {
                                                        Common.toastMessaage(
                                                            'Enter Field Name',
                                                            Colors.red);
                                                      } else if (fieldValue
                                                          .text.isEmpty) {
                                                        Common.toastMessaage(
                                                            'Enter Field Value',
                                                            Colors.red);
                                                      } else {
                                                        additionalFields
                                                            .add({
                                                          // "product_name":productName.text,
                                                          "field_name":
                                                              fieldName
                                                                  .text,
                                                          "field_value":
                                                              fieldValue
                                                                  .text,
                                                        });
                                                        fieldName.clear();
                                                        fieldValue.clear();
                                                        Navigator.of(
                                                                context)
                                                            .pop();
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .green,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child:
                                                            const Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                                  top: 10,
                                                                  bottom:
                                                                      10,
                                                                  left: 25,
                                                                  right:
                                                                      25),
                                                          child: Text(
                                                            'Add',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.green)),
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 5,
                                          bottom: 5),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            if (clientName.text.isEmpty) {
                              Common.toastMessaage(
                                  'Customer Name cannot be empty',
                                  Colors.red);
                            } else if (phoneNumber.text.isEmpty) {
                              Common.toastMessaage(
                                  'phoneNumber Name cannot be empty',
                                  Colors.red);
                            } else if (isExists == true) {
                              Common.toastMessaage(
                                  'PhoneNumber is already exists',
                                  Colors.red);
                            } else {
                              if (context.mounted) {
                                Common.showProgressDialog(
                                    context, "Loading..");
                              }
                              var body = FormData.fromMap({
                                "token": widget.token,
                                'client_id': widget.clientId,
                                'name': clientName.text,
                                'country_code': code,
                                'contact_no': phoneNumber.text,
                                'email_id': email.text,
                                'address': address1.text,
                                'address2': address2.text,
                                'address3': address3.text,
                                'pincode': pinCode.text,
                                'post_office': postOffice.text,
                                'gst_num': gstNumber.text,
                                'remarks': remarks.text,
                                "branch_id": branch,
                                'additional_fields':
                                    jsonEncode(additionalFields),
                              });
                              EditClientsModel object =
                                  await HttpService.editClients(body);
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
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.45,
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
