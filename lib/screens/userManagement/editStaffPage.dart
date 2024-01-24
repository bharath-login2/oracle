import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/models/userManagement/staffDetailsModel.dart';
import 'package:login2/screens/userManagement/viewUsers.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/userManagement/addUserCommonDataModel.dart';
import '../../models/userManagement/addUserImageModel.dart';
import '../../models/userManagement/editUserBasicDetailsModel.dart';
import '../../models/userManagement/postEditStaffPermissionModel.dart';
import '../../models/userManagement/postEditStaffSubmenuModel.dart';
import '../../service/service.dart';

// ignore: must_be_immutable
class EditProfilePage extends StatefulWidget {
  String? token;
  String? staffId;

  EditProfilePage({this.token, this.staffId, super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;
  int selectedIndex = 0;
  bool? result = true;
  String users = 'Accessible Users';
  String usersId = '';
  List checkedItems = [];

  List checkedItemsName = [];
  List checkedMenuItems = [];
  List checkedPermissionItems = [];

  String designation = 'Designation';
  String designationId = '';
  StaffDetailsModel? staffDetails;
  AddUserCommonDataModel? commonDetails;
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController designationVal = TextEditingController();
  bool sts = false;
  bool permissionSts = false;
  final ImagePicker _picker = ImagePicker();
  bool? imageSts = false;
  String? _imageFile;
  bool isLoad = false;
  String? branch;
  String roleId = '';
  String multiBranch = '';

  Future<void> retriveLostData() async {
    final LostData response = (await _picker.retrieveLostData()) as LostData;
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file!.path;
        imageSts = true;
      });
    } else {}
  }

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
    staffDetails = await HttpService.staffDetails(widget.token, widget.staffId);
    commonDetails = await HttpService.addUserCommonData(widget.token);
    roleId = await Common.getSharedPref("roleId");
    multiBranch = await Common.getSharedPref("multiBranch");
    if (staffDetails != null) {
      setState(() {
        if(staffDetails!.data!.branchId.toString()!=''){
          branch = staffDetails!.data!.branchId.toString();
        }
        designation = staffDetails!.data!.designation.toString();
        designationId = staffDetails!.data!.designationId.toString();
        name.text = staffDetails!.data!.staffName.toString();
        phoneNumber.text = staffDetails!.data!.phoneNo.toString();
        emailId.text = staffDetails!.data!.email.toString();
        designationVal.text = staffDetails!.data!.designation.toString();
        if (staffDetails!.data!.staffIds!.isNotEmpty) {
          for (int a = 0; a < staffDetails!.data!.staffIds!.length; a++) {
            checkedItems.add(staffDetails!.data!.staffIds![a]);
            checkedItemsName.add(staffDetails!.data!.staffNames![a]);
          }
        }
        for (int i = 0; i < staffDetails!.data!.menuList!.length; i++) {
          if (staffDetails!.data!.menuList![i].isAvailable == true) {
            for (int j = 0;
            j < staffDetails!.data!.menuList![i].subMenu!.length;
            j++) {
              if (staffDetails!.data!.menuList![i].subMenu![j].isChecked ==
                  true) {
                setState(() {
                  checkedMenuItems
                      .add(staffDetails!.data!.menuList![i].subMenu![j].id);
                  sts = true;
                });
              } else {
                setState(() {
                  sts = true;
                });
              }
            }
          } else {
            setState(() {
              sts = true;
            });
          }
        }

        if (staffDetails!.data!.privilages!.isNotEmpty) {
          for (int a = 0; a < staffDetails!.data!.privilages!.length; a++) {
            if (staffDetails!.data!.privilages![a].isPrivilageAvailable ==
                true) {
              for (int b = 0;
              b < staffDetails!.data!.privilages![a].permission!.length;
              b++) {
                if (staffDetails!
                    .data!.privilages![a].permission![b].isselected ==
                    true) {
                  setState(() {
                    checkedPermissionItems.add(staffDetails!
                        .data!.privilages![a].permission![b].permissionId);
                    permissionSts = true;
                  });
                } else {
                  setState(() {
                    permissionSts = true;
                  });
                }
              }
            } else {
              setState(() {
                permissionSts = true;
              });
            }
          }
        } else {
          setState(() {
            permissionSts = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ViewUsers(widget.token)),
                (Route<dynamic> route) => false);
        return true;
      },
      child: result == true
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
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewUsers(widget.token)),
                                    (Route<dynamic> route) => false);
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
                          'Edit Staff',
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
          body: staffDetails != null && sts == true && permissionSts == true
              ? SingleChildScrollView(
              child: IgnorePointer(
                ignoring: isLoad,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                            Colors.deepPurpleAccent,
                                            width: 0),
                                        color: selectedIndex == 0
                                            ? Colors.deepPurpleAccent
                                            : Colors.white,
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Text(
                                              'Basic Details',
                                              style: TextStyle(
                                                color: selectedIndex == 0
                                                    ? Colors.white
                                                    : const Color(
                                                    0xFF717171),
                                              ),
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
                                      selectedIndex = 1;
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                            Colors.deepPurpleAccent,
                                            width: 0),
                                        color: selectedIndex == 1
                                            ? Colors.deepPurpleAccent
                                            : Colors.white,
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Text(
                                              'Manage Modules',
                                              style: TextStyle(
                                                color: selectedIndex == 1
                                                    ? Colors.white
                                                    : const Color(
                                                    0xFF717171),
                                              ),
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
                                      selectedIndex = 2;
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                            Colors.deepPurpleAccent,
                                            width: 0),
                                        color: selectedIndex == 2
                                            ? Colors.deepPurpleAccent
                                            : Colors.white,
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Text(
                                              'Manage Privileges',
                                              style: TextStyle(
                                                color: selectedIndex == 2
                                                    ? Colors.white
                                                    : const Color(
                                                    0xFF717171),
                                              ),
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
                        ),
                        if (selectedIndex == 0)
                          Container(
                            padding: const EdgeInsets.only(
                                left: 16, top: 25, right: 16),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                              },
                              child: ListView(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                children: [
                                  Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 4,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                              boxShadow: [
                                                BoxShadow(
                                                    spreadRadius: 2,
                                                    blurRadius: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    offset: const Offset(
                                                        0, 10))
                                              ],
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    staffDetails!
                                                        .data!.proPicThumb
                                                        .toString(),
                                                  ))),
                                          child: isLoad == true
                                              ? const CircularProgressIndicator()
                                              : null,
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: InkWell(
                                              onTap: _selectFile,
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    width: 4,
                                                    color: Theme.of(
                                                        context)
                                                        .scaffoldBackgroundColor,
                                                  ),
                                                  color: Colors.green,
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  multiBranch=='true'&& roleId=='2'?
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 15),
                                    child: DropdownButtonFormField(
                                      value: branch,
                                      onChanged: (value) {
                                        setState(() {
                                          branch = value.toString();
                                        });
                                      },
                                      items: commonDetails!
                                          .data!.branch!
                                          .map((data) {
                                        return DropdownMenuItem<String>(
                                          value:
                                          data.branchId.toString(),
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
                                            Icons.arrow_drop_down_circle_outlined,
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
                                  ):
                                  const SizedBox(),
                                  buildTextField(
                                      "Full Name",
                                      staffDetails!.data!.staffName
                                          .toString(),
                                      name,
                                      Icons.person),
                                  buildTextField(
                                      "Phone Number",
                                      staffDetails!.data!.phoneNo
                                          .toString(),
                                      phoneNumber,
                                      Icons.phone_android_rounded),
                                  buildTextField(
                                      "E-mail",
                                      staffDetails!.data!.email
                                          .toString(),
                                      emailId,
                                      Icons.email),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          const Text('Accessible Users',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.w500,
                                              )),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                  context) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text(
                                                          'Accessible Users'),
                                                      content: ListView
                                                          .builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                        commonDetails!
                                                            .data!
                                                            .users!
                                                            .length,
                                                        itemBuilder:
                                                            (context,
                                                            ind) {
                                                          return CheckboxListTile(
                                                            title:
                                                            SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                commonDetails!
                                                                    .data!
                                                                    .users![
                                                                ind]
                                                                    .staffName
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    fontSize:
                                                                    14),
                                                              ),
                                                            ),
                                                            value: checkedItems.contains(commonDetails!
                                                                .data!
                                                                .users![
                                                            ind]
                                                                .userId
                                                                .toString())
                                                                ? true
                                                                : false,
                                                            onChanged:
                                                                (bool?
                                                            value) {
                                                              if (value ==
                                                                  true) {
                                                                setState(
                                                                        () {
                                                                      checkedItems.add(commonDetails!
                                                                          .data!
                                                                          .users![ind]
                                                                          .userId
                                                                          .toString());
                                                                      checkedItemsName.add(commonDetails!
                                                                          .data!
                                                                          .users![ind]
                                                                          .staffName
                                                                          .toString());

                                                                      Navigator.pop(
                                                                          context,
                                                                          true);
                                                                    });
                                                              } else {
                                                                setState(
                                                                        () {
                                                                      checkedItems.remove(commonDetails!
                                                                          .data!
                                                                          .users![ind]
                                                                          .userId
                                                                          .toString());
                                                                      checkedItemsName.remove(commonDetails!
                                                                          .data!
                                                                          .users![ind]
                                                                          .staffName
                                                                          .toString());

                                                                      Navigator.pop(
                                                                          context,
                                                                          true);
                                                                    });
                                                              }
                                                            },
                                                            controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 35,
                                        child: ListView.builder(
                                          scrollDirection:
                                          Axis.horizontal,
                                          itemCount:
                                          checkedItemsName.length,
                                          itemBuilder: (context, i) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                },
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey,
                                                              width: 0),
                                                          color: Colors
                                                              .white,
                                                          borderRadius: const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                  6),
                                                              bottomLeft:
                                                              Radius.circular(
                                                                  6))),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(
                                                                  10),
                                                              child: Text(
                                                                checkedItemsName[
                                                                i],
                                                                style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .black,
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
                                                            context:
                                                            context,
                                                            builder:
                                                                (BuildContext
                                                            context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Please Confirm'),
                                                                content:
                                                                const Text(
                                                                    'Are you sure to Remove this Number?'),
                                                                actions: [
                                                                  // The "Yes" button
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        setState(() {
                                                                          checkedItemsName.remove(checkedItemsName[i]);
                                                                          checkedItems.remove(checkedItems[i]);
                                                                        });

                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child:
                                                                      const Text('Yes')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child:
                                                                      const Text('No'))
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: Container(
                                                        height: 35,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey,
                                                                width: 0),
                                                            color: Colors
                                                                .grey
                                                                .shade100,
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topRight:
                                                                Radius.circular(
                                                                    6),
                                                                bottomRight:
                                                                Radius.circular(
                                                                    6))),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color:
                                                          Colors.red,
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: designationVal,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text(
                                                  'Designation'),
                                              content: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: commonDetails!
                                                    .data!
                                                    .designations!
                                                    .length,
                                                itemBuilder:
                                                    (context, ind) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        designationVal
                                                            .text =
                                                            commonDetails!
                                                                .data!
                                                                .designations![
                                                            ind]
                                                                .designation
                                                                .toString();
                                                        designation =
                                                            commonDetails!
                                                                .data!
                                                                .designations![
                                                            ind]
                                                                .designation
                                                                .toString();
                                                        designationId =
                                                            commonDetails!
                                                                .data!
                                                                .designations![
                                                            ind]
                                                                .id
                                                                .toString();
                                                        Navigator.pop(
                                                            context,
                                                            true);
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 50,
                                                      child: Text(
                                                        commonDetails!
                                                            .data!
                                                            .designations![
                                                        ind]
                                                            .designation
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
                                            );
                                          });
                                    },
                                    maxLines: 1,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 2, bottom: 2),
                                        labelText: 'Designation',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey),
                                        ),
                                        labelStyle: TextStyle(
                                            color: Colors.grey)),
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if (multiBranch == 'true' &&
                                          roleId == '2' && branch==null) {
                                        Common.toastMessaage(
                                            'Choose Branch', Colors.red);
                                      }
                                      else if (name.text.isEmpty) {
                                        Common.toastMessaage(
                                            'Enter Staff Name',
                                            Colors.red);
                                      } else if (phoneNumber
                                          .text.isEmpty) {
                                        Common.toastMessaage(
                                            'Enter Phone Number',
                                            Colors.red);
                                      } else {
                                        Common.showProgressDialog(
                                            context, "Loading..");
                                        Map<String, dynamic> body = {
                                          'token': widget.token,
                                          "designation": designationId,
                                          'phoneNumber': phoneNumber.text,
                                          'name': name.text,
                                          'email': emailId.text,
                                          "user_list": checkedItems,
                                          "staff_id": widget.staffId,
                                          "branchId":branch
                                        };
                                        EditUserBasicDetailsModel
                                        editUserBasicDetails =
                                        await HttpService
                                            .editUserBasicData(body);
                                        if (editUserBasicDetails.data ==
                                            true) {
                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfilePage(
                                                          token: widget
                                                              .token,
                                                          staffId: widget
                                                              .staffId)),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.45,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Text('Submit',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight:
                                                FontWeight.w500)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        if (selectedIndex == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount: staffDetails!
                                      .data!.menuList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 10),
                                      child: ExpansionPanelList(
                                        animationDuration: const Duration(
                                            milliseconds: 1000),
                                        dividerColor: Colors.red,
                                        elevation: 1,
                                        children: [
                                          ExpansionPanel(
                                              body: MediaQuery
                                                  .removePadding(
                                                context: context,
                                                removeTop: true,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                  const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, i) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                          CheckboxListTile(
                                                            title:
                                                            SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                staffDetails!
                                                                    .data!
                                                                    .menuList![
                                                                index]
                                                                    .subMenu![
                                                                i]
                                                                    .menu
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    fontSize:
                                                                    14),
                                                              ),
                                                            ),
                                                            //value:true,
                                                            value: checkedMenuItems.contains(staffDetails!
                                                                .data!
                                                                .menuList![
                                                            index]
                                                                .subMenu![
                                                            i]
                                                                .id)
                                                                ? true
                                                                : false,
                                                            onChanged:
                                                                (bool?
                                                            value) {
                                                              if (value ==
                                                                  true) {
                                                                setState(
                                                                        () {
                                                                      checkedMenuItems.add(staffDetails!
                                                                          .data!
                                                                          .menuList![index]
                                                                          .subMenu![i]
                                                                          .id);
                                                                      // print(checkedItems);
                                                                    });
                                                              } else {
                                                                setState(
                                                                        () {
                                                                      checkedMenuItems.remove(staffDetails!
                                                                          .data!
                                                                          .menuList![index]
                                                                          .subMenu![i]
                                                                          .id);
                                                                      // print(checkedItems);
                                                                    });
                                                              }
                                                            },
                                                            controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  itemCount: staffDetails!
                                                      .data!
                                                      .menuList![index]
                                                      .subMenu!
                                                      .length,
                                                ),
                                              ),
                                              headerBuilder:
                                                  (BuildContext context,
                                                  bool isExpanded) {
                                                return Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        staffDetails!
                                                            .data!
                                                            .menuList![
                                                        index]
                                                            .categoryName
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .black87,
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              isExpanded: staffDetails!
                                                  .data!
                                                  .menuList![index]
                                                  .isExpand!),
                                        ],
                                        expansionCallback:
                                            (int item, bool status) {
                                          setState(() {
                                            staffDetails!
                                                .data!
                                                .menuList![index]
                                                .isExpand =
                                            !staffDetails!
                                                .data!
                                                .menuList![index]
                                                .isExpand!;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                                InkWell(
                                  onTap: () async {
                                    Common.showProgressDialog(
                                        context, "Loading..");
                                    Map<String, dynamic> subMenuBody = {
                                      "token": widget.token,
                                      'staff_id': widget.staffId,
                                      'sub_menu_id': checkedMenuItems,
                                      'designation_id': staffDetails!
                                          .data!.designationId,
                                    };
                                    PostEditStaffSubmenuModel
                                    postSubmenu = await HttpService
                                        .postEditStaffSubMenu(
                                        subMenuBody);
                                    if (postSubmenu.data == true) {
                                      Common.toastMessaage(
                                          postSubmenu.message,
                                          Colors.green);
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfilePage(
                                                    token: widget.token,
                                                    staffId:
                                                    widget.staffId,
                                                  )),
                                        );
                                      }
                                    } else {
                                      Common.toastMessaage(
                                          postSubmenu.message,
                                          Colors.red);
                                      if (mounted) {
                                        Navigator.pop(context, true);
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.45,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text('Submit',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (selectedIndex == 2 &&
                            staffDetails!.data!.privilages!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount: staffDetails!
                                      .data!.privilages!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 10),
                                      child: ExpansionPanelList(
                                        animationDuration: const Duration(
                                            milliseconds: 1000),
                                        dividerColor: Colors.red,
                                        elevation: 1,
                                        children: [
                                          ExpansionPanel(
                                              body: MediaQuery
                                                  .removePadding(
                                                context: context,
                                                removeTop: true,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                  const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, i) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                          CheckboxListTile(
                                                            title:
                                                            SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                staffDetails!
                                                                    .data!
                                                                    .privilages![
                                                                index]
                                                                    .permission![
                                                                i]
                                                                    .permission
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    fontSize:
                                                                    14),
                                                              ),
                                                            ),
                                                            //value:true,
                                                            value: checkedPermissionItems.contains(staffDetails!
                                                                .data!
                                                                .privilages![
                                                            index]
                                                                .permission![
                                                            i]
                                                                .permissionId)
                                                                ? true
                                                                : false,
                                                            onChanged:
                                                                (bool?
                                                            value) {
                                                              if (value ==
                                                                  true) {
                                                                setState(
                                                                        () {
                                                                      checkedPermissionItems.add(staffDetails!
                                                                          .data!
                                                                          .privilages![index]
                                                                          .permission![i]
                                                                          .permissionId);
                                                                      // print(checkedItems);
                                                                    });
                                                              } else {
                                                                setState(
                                                                        () {
                                                                      checkedPermissionItems.remove(staffDetails!
                                                                          .data!
                                                                          .privilages![index]
                                                                          .permission![i]
                                                                          .permissionId);
                                                                      // print(checkedItems);
                                                                    });
                                                              }
                                                            },
                                                            controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  itemCount: staffDetails!
                                                      .data!
                                                      .privilages![index]
                                                      .permission!
                                                      .length,
                                                ),
                                              ),
                                              headerBuilder:
                                                  (BuildContext context,
                                                  bool isExpanded) {
                                                return Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        staffDetails!
                                                            .data!
                                                            .privilages![
                                                        index]
                                                            .categoryName
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .black87,
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              isExpanded: staffDetails!
                                                  .data!
                                                  .privilages![index]
                                                  .isPrivilageExpand!),
                                        ],
                                        expansionCallback:
                                            (int item, bool status) {
                                          setState(() {
                                            staffDetails!
                                                .data!
                                                .privilages![index]
                                                .isPrivilageExpand =
                                            !staffDetails!
                                                .data!
                                                .privilages![index]
                                                .isPrivilageExpand!;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                                InkWell(
                                  onTap: () async {
                                    Common.showProgressDialog(
                                        context, "Loading..");
                                    Map<String, dynamic> permissionBody =
                                    {
                                      "token": widget.token,
                                      'staff_id': widget.staffId,
                                      'permission_ids':
                                      checkedPermissionItems,
                                    };
                                    PostEditStaffPermissionModel
                                    postPermission = await HttpService
                                        .postEditStaffPermission(
                                        permissionBody);
                                    if (postPermission.data == true) {
                                      Common.toastMessaage(
                                          postPermission.message,
                                          Colors.green);
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfilePage(
                                                    token: widget.token,
                                                    staffId:
                                                    widget.staffId,
                                                  )),
                                        );
                                      }
                                    } else {
                                      Common.toastMessaage(
                                          postPermission.message,
                                          Colors.red);
                                      if (mounted) {
                                        Navigator.pop(context, true);
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.45,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text('Submit',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    isLoad == true
                        ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.grey.withOpacity(0.5),
                      child: const Center(
                          child: CircularProgressIndicator()),
                    )
                        : Container(),
                  ],
                ),
              ))
              : Center(
            child: Lottie.asset('assets/main/loading.json',
                fit: BoxFit.fill),
          )
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
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            labelStyle: TextStyle(color: Colors.grey)),
      ),
    );
  }

  _selectFile() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: _pickImage,
                      child: const Icon(
                        Icons.photo_library,
                        size: 50,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("OR"),
                    ),
                    OutlinedButton(
                      onPressed: _captureImage,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    setState(() {
      isLoad = false;
    });
    try {
      Navigator.pop(context);

      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      setState(() async {
        //Common.showProgressDialog(context, "Loading..");
        isLoad = true;
        _imageFile = pickedFile!.path;
        var formData = FormData.fromMap({
          'token': widget.token,
          'staff_id': widget.staffId,
          'image_status': imageSts,
          if (_imageFile == null)
            "staffImage": _imageFile
          else
            "staffImage": await MultipartFile.fromFile(_imageFile!)
        });

        AddUserImageModel upload =
        await HttpService.updateUploadImages(formData);
        if (upload.data == true) {
          Common.toastMessaage(upload.message, Colors.green);
          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditProfilePage(
                  token: widget.token,
                  staffId: widget.staffId,
                )));
          }
        } else {
          Common.toastMessaage(upload.message, Colors.red);
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  void _captureImage() async {
    setState(() {
      isLoad = false;
    });
    try {
      Navigator.pop(context);
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() async {
        isLoad = true;
        _imageFile = pickedFile!.path;
        imageSts = true;
        var formData = FormData.fromMap({
          'token': widget.token,
          'staff_id': widget.staffId,
          'image_status': imageSts,
          if (_imageFile == null)
            "staffImage": _imageFile
          else
            "staffImage": await MultipartFile.fromFile(_imageFile!)
        });

        AddUserImageModel upload =
        await HttpService.updateUploadImages(formData);
        Common.toastMessaage(upload.message, Colors.green);
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditProfilePage(
                token: widget.token,
                staffId: widget.staffId,
              )));
        }
      });
      // ignore: empty_catches
    } catch (e) {}
  }
}
