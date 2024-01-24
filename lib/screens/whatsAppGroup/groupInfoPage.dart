import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/contactGroup/addContactNumberModel.dart';
import '../../models/contactGroup/deleteContactNumberModel.dart';
import '../../models/contactGroup/deleteContatGroupModel.dart';
import '../../models/contactGroup/editContactGroupModel.dart';
import '../../models/contactGroup/editContactNumberModel.dart';
import '../../models/contactGroup/groupInfoModel.dart';
import '../../screens/whatsAppGroup/groupDetails.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import '../../service/service.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  String? token;
  String? groupId;
  String? groupname;
  String? imgUrl;
   GroupInfoPage(this.token,this.groupId,this.groupname,this.imgUrl, {super.key});

  @override
  _GroupInfoPageState createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  GroupInfoModel? groupInfo;
  bool? result = true;
  bool? result1 = true;
  TextEditingController groupNameEdit = TextEditingController();
  TextEditingController numbers = TextEditingController();
  TextEditingController editNumber = TextEditingController();

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
    groupInfo = await HttpService.groupInfo(widget.token,widget.groupId);
    if (groupInfo != null) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupDetails(
                  widget.token,widget.groupname,widget.imgUrl!,widget.groupId!
              )),
        );
        return true;
      },
      child: SafeArea(
        child: result == true
            ?Scaffold(
          backgroundColor: Colors.white,
          body: groupInfo!=null?
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: WhatsappAppbar(MediaQuery.of(context).size.width,groupInfo!.data!.image.toString(),widget.token!),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children:  [
                    Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        groupInfo!.data!.name.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        groupInfo!.data!.contactNos.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ), Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            showGeneralDialog(
                              barrierLabel: "showGeneralDialog",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.6),
                              transitionDuration: const Duration(milliseconds: 400),
                              context: context,
                              pageBuilder: (context, _, __) {
                                return Align(
                                  alignment: Alignment.center,
                                  child:IntrinsicHeight(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 10),
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
                                                'Add Contacts',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              TextFormField(
                                                maxLines: 10,
                                                controller: numbers,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                validator: (value) {
                                                  if (value!.isEmpty) return "Numbers";
                                                  return null;
                                                },
                                                keyboardType: TextInputType.name,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    //<-- SEE HERE
                                                    fillColor: Colors.white,
                                                    counterText: "",
                                                    hintText: "Numbers with country code (eg:9199476676xx,9195268841xx,etc..)",
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.purple.shade100),
                                                        borderRadius: BorderRadius.circular(10))),
                                              ),
                                              const SizedBox(height: 25,),
                                              Container(
                                                height: 40,
                                                width: double.maxFinite,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF3375e0),
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                ),
                                                child: RawMaterialButton(
                                                  onPressed: () async {
                                                    if(numbers.text.isEmpty){
                                                      Common.toastMessaage('Please Enter Numbers', Colors.red);
                                                    }
                                                    else{
                                                      Common.showProgressDialog(context, "Loading..");
                                                      AddContactNumberModel addContact=await HttpService.addContactNumber(widget.token,numbers.text,widget.groupId);
                                                      if(addContact.data==true)
                                                      {
                                                        Common.toastMessaage(
                                                            addContact.message, Colors.green);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => GroupInfoPage(
                                                                  widget.token,widget.groupId,widget.groupname,widget.imgUrl)),
                                                        );
                                                      }
                                                      else{
                                                        Common.toastMessaage(
                                                            addContact.message, Colors.red);
                                                        Navigator.of(context).pop();
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
                          child: const Column(
                            children: [
                              Icon(
                                Icons.person_add,
                                size: 25,
                                color: Color.fromARGB(255, 8, 141, 125),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: (){
                            groupNameEdit.text=groupInfo!.data!.name.toString();
                            showGeneralDialog(
                              barrierLabel: "showGeneralDialog",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.6),
                              transitionDuration: const Duration(milliseconds: 400),
                              context: context,
                              pageBuilder: (context, _, __) {
                                return Align(
                                  alignment: Alignment.center,
                                  child:IntrinsicHeight(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 10),
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
                                                'Group Name Edit',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              TextFormField(
                                                controller: groupNameEdit,
                                                decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.only(left: 10,top: 2,bottom: 2),
                                                    labelText: 'Group Name',
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    prefixIcon: Icon(Icons.person,
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

                                              const SizedBox(height: 25,),
                                              Container(
                                                height: 40,
                                                width: double.maxFinite,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF3375e0),
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                ),
                                                child: RawMaterialButton(
                                                  onPressed: () async {
                                                    if(groupNameEdit.text.isEmpty){
                                                      Common.toastMessaage('Group Name cannot empty', Colors.red);
                                                    }
                                                    else{
                                                      Common.showProgressDialog(context, "Loading..");
                                                      EditContactGroupModel editGroupName=await HttpService.editContactGroupName(widget.token,groupNameEdit.text,widget.groupId);
                                                      if(editGroupName.data==true)
                                                      {
                                                        Common.toastMessaage(
                                                            editGroupName.message, Colors.green);
                                                        if(mounted){
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => GroupInfoPage(
                                                                    widget.token,widget.groupId,widget.groupname,widget.imgUrl)),
                                                          );
                                                        }

                                                      }
                                                      else{
                                                        Common.toastMessaage(
                                                            editGroupName.message, Colors.red);
                                                        if(mounted){
                                                          Navigator.of(context).pop();
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
                          child: const Column(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 25,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: (){
                            _deleteGroup(context);
                          },
                          child: const Column(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 25,
                                color: Colors.red,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )],
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate( [
                    const SizedBox(height: 20),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date Created",style: TextStyle(color: Colors.grey.shade500,fontWeight: FontWeight.bold)),
                          Text( groupInfo!.data!.createdDate.toString(),style: TextStyle(color: Colors.grey.shade500,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                    ),
                    const ListTile(
                      title: Text("Contacts"),
                      leading: Icon(Icons.person),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groupInfo!.data!.contactNumbers!.length,
                        itemBuilder: (context, i) => Column(
                          children: [
                            ListTile(
                              onTap: () {

                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                radius: 20,
                                child: const Icon(Icons.person,color: Colors.black,),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    groupInfo!.data!.contactNumbers![i].phone.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    // add icon, by default "3 dot" icon
                                      child: const SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: Padding(
                                          padding:
                                          EdgeInsets.all(8.0),
                                          child: Icon(Icons.more_horiz, size: 25),
                                        ),

                                      ),
                                      itemBuilder: (context) {
                                        return [
                                          const PopupMenuItem<int>(
                                              value: 1,
                                              child: Text('Edit')),
                                          const PopupMenuItem<int>(
                                              value: 2,
                                              child: Text('Delete')),

                                        ];
                                      },
                                      onSelected: (value) {
                                        if(value==1)
                                          {
                                            editNumber.text=groupInfo!.data!.contactNumbers![i].phone.toString();
                                            showGeneralDialog(
                                              barrierLabel: "showGeneralDialog",
                                              barrierDismissible: true,
                                              barrierColor: Colors.black.withOpacity(0.6),
                                              transitionDuration: const Duration(milliseconds: 400),
                                              context: context,
                                              pageBuilder: (context, _, __) {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child:IntrinsicHeight(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10,right: 10),
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
                                                                'Edit Phone Number',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 20),
                                                              TextFormField(
                                                                controller: editNumber,
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.only(left: 10,top: 2,bottom: 2),
                                                                    labelText: 'Phone Number',
                                                                    fillColor: Colors.white,
                                                                    filled: true,
                                                                    prefixIcon: Icon(Icons.phone_android_rounded,
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

                                                              const SizedBox(height: 25,),
                                                              Container(
                                                                height: 40,
                                                                width: double.maxFinite,
                                                                decoration: const BoxDecoration(
                                                                  color: Color(0xFF3375e0),
                                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                ),
                                                                child: RawMaterialButton(
                                                                  onPressed: () async {
                                                                    if(editNumber.text.isEmpty){
                                                                      Common.toastMessaage('Number cannot empty', Colors.red);
                                                                    }
                                                                    else{
                                                                      Common.showProgressDialog(context, "Loading..");
                                                                      EditContactNumberModel editNumber1=await HttpService.editContactNumber(widget.token,editNumber.text,groupInfo!.data!.contactNumbers![i].id.toString());
                                                                      if(editNumber1.data==true)
                                                                      {
                                                                        Common.toastMessaage(
                                                                            editNumber1.message, Colors.green);
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => GroupInfoPage(
                                                                                  widget.token,widget.groupId,widget.groupname,widget.imgUrl)),
                                                                        );
                                                                      }
                                                                      else{
                                                                        Common.toastMessaage(
                                                                            editNumber1.message, Colors.red);
                                                                        Navigator.of(context).pop();
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
                                          }
                                        else if(value==2)
                                          {
                                            _deleteNumber(context,groupInfo!.data!.contactNumbers![i].id.toString());
                                          }
                                      })
                                ],
                              ),

                            ),
                            const Divider(
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                  ])),
            ],
          ):Center(
            child: Lottie.asset('assets/main/loading.json',
                fit: BoxFit.fill),
          ),
        ):Scaffold(
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
            ))
      ),
    );
  }
  void _deleteGroup(BuildContext context) {
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
                    Common.showProgressDialog(context, "Loading..");
                    DeleteContactGroupModel delete =
                        await HttpService.deleteContactGroup(widget.token,widget.groupId);
                    if (delete.data == true) {
                      Common.toastMessaage(
                          delete.message,
                          Colors.green);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder:
                                (context) =>
                                GroupList(widget.token!)),
                      );
                    } else {
                      Common.toastMessaage(
                          delete.message,
                          Colors.red);
                      Navigator.of(context)
                          .pop();
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
  void _deleteNumber(BuildContext context,id) {
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
                    Common.showProgressDialog(context, "Loading..");
                    DeleteContactNumberModel delete =
                    await HttpService.deleteContactNumber(widget.token,id);
                    if (delete.data == true) {
                      Common.toastMessaage(
                          delete.message,
                          Colors.green);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder:
                                (context) =>
                                GroupInfoPage(widget.token,widget.groupId,widget.groupname,widget.imgUrl)),
                      );
                    } else {
                      Common.toastMessaage(
                          delete.message,
                          Colors.red);
                      Navigator.of(context)
                          .pop();
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

class WhatsappAppbar extends SliverPersistentHeaderDelegate {
  double screenWidth;
  String imgUrl;
  String token;
  Tween<double>? profilePicTranslateTween;

  WhatsappAppbar(this.screenWidth,this.imgUrl,this.token) {
    profilePicTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 45 - 40 + 15, end: 40.0);
  }
  static final appBarColorTween = ColorTween(
      begin: Colors.white, end: Colors.blue);

  static final appbarIconColorTween =
  ColorTween(begin: Colors.grey[800], end: Colors.white);

  static final phoneNumberTranslateTween = Tween<double>(begin: 20.0, end: 0.0);

  static final phoneNumberFontSizeTween = Tween<double>(begin: 20.0, end: 16.0);
  static final profileImageRadiusTween = Tween<double>(begin: 2, end: 1.0);


  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final relativeScroll = min(shrinkOffset, 45) / 45;
    final relativeScroll70px = min(shrinkOffset, 70) / 70;

    return Container(
      color: appBarColorTween.transform(relativeScroll),
      child: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupList(token
                          )),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, size: 25),
                  color: appbarIconColorTween.transform(relativeScroll),
                ),
              ),
              Positioned(
                  top: 15,
                  left: 100,
                  child: displayPhoneNumber(relativeScroll70px)),
              Positioned(
                  top: 5,
                  left: profilePicTranslateTween!.transform(relativeScroll70px),
                  child: displayProfilePicture(relativeScroll70px)),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayProfilePicture(double relativeFullScrollOffset) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(
          profileImageRadiusTween.transform(relativeFullScrollOffset),
        ),
      child:  Padding(
        padding: const EdgeInsets.only(left: 15),
        child: CircleAvatar(
          backgroundImage: NetworkImage(
              imgUrl.toString()),
        ),
      ),
    );
  }

  Widget displayPhoneNumber(double relativeFullScrollOffset) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            0.0,
            phoneNumberTranslateTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
          ),
        child: Text(
          "Group Name",
          style: TextStyle(
            fontSize: phoneNumberFontSizeTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(WhatsappAppbar oldDelegate) {
    return true;
  }
}




