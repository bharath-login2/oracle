import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/userManagement/addUserCommonDataModel.dart';
import '../../models/userManagement/addUserImageModel.dart';
import '../../models/userManagement/addUserModel.dart';
import '../../service/service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/inputTextFeildWidget.dart';

// ignore: must_be_immutable
class AddUser extends StatefulWidget {
  String token;

  AddUser(this.token, {super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  AddUserCommonDataModel? commonDetails;
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController openingBalance = TextEditingController();
  TextEditingController designationVal = TextEditingController();

  //TextEditingController accessibleUsersVal = TextEditingController();

  String designation = 'Designation';
  String designationId = '';
  String users = 'Accessible Users';
  String usersId = '';
  bool? result = true;
  bool? result1 = true;
  bool? imageSts = false;
  String? _imageFile;
  List checkedItems = [];
  List checkedItemsName = [];
  final ImagePicker _picker = ImagePicker();
  String? branch;
  String roleId = '';
  String multiBranch = '';
  bool accessWhatsapp = false;
  bool accessCallLog = false;

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
    //
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
    commonDetails = await HttpService.addUserCommonData(widget.token);
    if (commonDetails != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    designationVal.text = designation;
    // accessibleUsersVal.text=users;
    return result == true
        ? Scaffold(
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
                            'Add User',
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
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        multiBranch == 'true' && roleId == '2'
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 20),
                                child: DropdownButtonFormField(
                                  value: branch,
                                  onChanged: (value) {
                                    setState(() {
                                      branch = value.toString();
                                    });
                                  },
                                  items:
                                      commonDetails!.data!.branch!.map((data) {
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
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    labelText: 'Select Branch',
                                    prefixIcon:
                                        const Icon(Icons.arrow_drop_down),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, top: 2, bottom: 2),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        InputTextField(
                          hintText: 'Name',
                          hintTextColor: Colors.white,
                          backgroundColor: Colors.white,
                          controller: name,
                          width: 0.9,
                          iconData: Icons.person,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        InputTextField(
                          hintText: 'Phone Number',
                          hintTextColor: Colors.white,
                          backgroundColor: Colors.white,
                          controller: phoneNumber,
                          width: 0.9,
                          iconData: Icons.call,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        InputTextField(
                          hintText: 'Password',
                          hintTextColor: Colors.white,
                          backgroundColor: Colors.white,
                          controller: password,
                          width: 0.9,
                          iconData: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: designationVal,
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Designation'),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .32,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .8,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: commonDetails!
                                                .data!.designations!.length,
                                            itemBuilder: (context, ind) {
                                              return InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    designation = commonDetails!
                                                        .data!
                                                        .designations![ind]
                                                        .designation
                                                        .toString();
                                                    designationId =
                                                        commonDetails!
                                                            .data!
                                                            .designations![ind]
                                                            .id
                                                            .toString();
                                                    Navigator.pop(
                                                        context, true);
                                                  });
                                                },
                                                child: SizedBox(
                                                  height: 50,
                                                  child: Text(
                                                    commonDetails!
                                                        .data!
                                                        .designations![ind]
                                                        .designation
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
                                  labelText: 'Designation',
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
                          height: 15,
                        ),
                        InputTextField(
                          hintText: 'Email Id',
                          hintTextColor: Colors.white,
                          backgroundColor: Colors.white,
                          controller: emailId,
                          width: 0.9,
                          iconData: Icons.email,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Accessible Users'),
                                        content: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .32,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .8,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: commonDetails!
                                                .data!.users!.length,
                                            itemBuilder: (context, ind) {
                                              return CheckboxListTile(
                                                title: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    commonDetails!.data!
                                                        .users![ind].staffName
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                value: checkedItems.contains(
                                                        commonDetails!.data!
                                                            .users![ind].userId
                                                            .toString())
                                                    ? true
                                                    : false,
                                                onChanged: (bool? value) {
                                                  if (value == true) {
                                                    setState(() {
                                                      checkedItems.add(
                                                          commonDetails!
                                                              .data!
                                                              .users![ind]
                                                              .userId
                                                              .toString());
                                                      checkedItemsName.add(
                                                          commonDetails!
                                                              .data!
                                                              .users![ind]
                                                              .staffName
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      checkedItems.remove(
                                                          commonDetails!
                                                              .data!
                                                              .users![ind]
                                                              .userId
                                                              .toString());
                                                      checkedItemsName.remove(
                                                          commonDetails!
                                                              .data!
                                                              .users![ind]
                                                              .staffName
                                                              .toString());

                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  }
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
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
                                  hintText: 'Accessible Users',
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
                          height: 10,
                        ),
                        checkedItemsName.isNotEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 10),
                                child: SizedBox(
                                  height: 30,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: checkedItemsName.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
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
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(6))),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  checkedItemsName[i],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 0),
                                      color: Colors.grey.shade300,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6))),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No User Selected',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 15,
                        ),
                        // InputTextField(
                        //   hintText: 'Opening Balance',
                        //   hintTextColor: Colors.white,
                        //   backgroundColor: Colors.white,
                        //   controller: openingBalance,
                        //   width: 0.9,
                        //   iconData: Icons.currency_rupee,
                        //   obscureText: true,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              CheckboxListTile(
                                title: const Text('Access Official Whatsapp'),
                                value: accessWhatsapp,
                                onChanged: (value) {
                                  setState(() {
                                    accessWhatsapp = value!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('Access Phone Call Log'),
                                value: accessCallLog,
                                onChanged: (value) {
                                  setState(() {
                                    accessCallLog = value!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        _imageFile == null
                            ? GestureDetector(
                                onTap: _selectFile,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 20.0),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [8, 4],
                                      strokeCap: StrokeCap.round,
                                      color: Colors.black,
                                      child: Container(
                                        width: double.infinity,
                                        height: 130,
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade50
                                                .withOpacity(.3),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo,
                                                color: Colors.black, size: 40),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              'Add Photo',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              )
                            : const SizedBox(
                                height: 10,
                              ),
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              //color: Colors.white, //background color of box
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 25.0, // soften the shadow
                                spreadRadius: 5.0, //extend the shadow
                                offset: Offset(
                                  15.0, // Move to right 10  horizontally
                                  15.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                          child: FutureBuilder<void>(
                            future: retriveLostData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const Text('Picked an image');
                                case ConnectionState.done:
                                  return _previewImage();
                                default:
                                  return const Text('Picked an image');
                              }
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (multiBranch == 'true' &&
                                roleId == '2' &&
                                branch == null) {
                              Common.toastMessaage('Choose Branch', Colors.red);
                            } else if (name.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Staff Name', Colors.red);
                            } else if (phoneNumber.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Phone Number', Colors.red);
                            } else if (password.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Password', Colors.red);
                            } else if (designationId == '') {
                              Common.toastMessaage(
                                  'Choose Designation', Colors.red);
                            } else {
                              Common.showProgressDialog(context, "Loading..");
                              Map<String, dynamic> body = {
                                'token': widget.token,
                                "designation": designationId,
                                'phoneNumber': phoneNumber.text,
                                'password': password.text,
                                'name': name.text,
                                'email': emailId.text,
                                'opening_balance': openingBalance.text,
                                  "officialWhatsAppAccess": accessWhatsapp,
                                  "callLogAccess": accessCallLog,
                                "user_list": checkedItems,
                                "branchId": branch
                              };
                              AddUserModel addUser =
                                  await HttpService.postUserData(body);
                              if (addUser.status == true) {
                                var formData = FormData.fromMap({
                                  'token': widget.token,
                                  'user_id': addUser.data,
                                  'image_status': imageSts,
                                  if (_imageFile == null)
                                    "staffImage": _imageFile
                                  else
                                    "staffImage": await MultipartFile.fromFile(
                                        _imageFile!)
                                });

                                AddUserImageModel upload =
                                    await HttpService.uploadImages(formData);
                                Common.toastMessaage(
                                    upload.message, Colors.red);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              } else {
                                Common.toastMessaage(
                                    addUser.message, Colors.red);
                                if (context.mounted) {
                                  Navigator.pop(context, true);
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
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ))
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

  void _pickImage() async {
    try {
      Navigator.pop(context);

      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      setState(() {
        _imageFile = pickedFile!.path;
        _cropImage(pickedFile.path);
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  void _captureImage() async {
    try {
      Navigator.pop(context);
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        _imageFile = pickedFile!.path;
        imageSts = true;
        _cropImage(pickedFile.path);
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  _cropImage(filePath) async {
    File? croppedFile = (await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3))) as File?;
    if (croppedFile != null) {
      _imageFile = croppedFile.path;
      setState(() {});
    }
  }

  Widget _previewImage() {
    if (_imageFile != null) {
      // Navigator.pop(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Center(
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.file(File(_imageFile!)))),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _imageFile = null;
                  imageSts = true;
                });
              },
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      );
    } else {
      return const Text(
        '',
        textAlign: TextAlign.center,
      );
    }
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
}
