import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../models/contactGroup/contactGroupDeatailsModel.dart';
import '../../models/contactGroup/sendMessageModel.dart';
import '../../screens/whatsAppGroup/groupInfoPage.dart';
import '../../service/service.dart';
import '../../widgets/messageBox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class GroupDetails extends StatefulWidget {
  String? token;
  String? groupName;
  String imageUrl;
  String id;
  GroupDetails(this.token,this.groupName,this.imageUrl,this.id, {super.key});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  final TextEditingController _sendMessageController = TextEditingController();
  ContactGroupDeatailsModel? contactGroupDetails;
  bool? result = true;
  bool? result1 = true;
  ScrollController scrollController = ScrollController();
  TextEditingController scheduledDate = TextEditingController();
  TextEditingController minDelay = TextEditingController(text: '30');
  TextEditingController maxDeley = TextEditingController(text: '60');
  bool showbtn = false;
  String noOfContact='';
  String? _imageFile;
  bool? imageSts = false;
  final ImagePicker _picker = ImagePicker();

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
    } else {

    }
  }
  @override
  void initState() {
    scrollController.addListener(() { //scroll listener
      double showoffset = 10.0; //Back to top botton will show on scroll offset 10.0

      if(scrollController.offset > showoffset){
        showbtn = true;
        setState(() {
          //update state
        });
      }else{
        showbtn = false;
        setState(() {
          //update state
        });
      }
    });
    // TODO: implement initState
    super.initState();
    getData();
  }
  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
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
    contactGroupDetails = await HttpService.contactGroupDetails(widget.token,widget.id);
    if (contactGroupDetails != null) {
      setState(() {
noOfContact=contactGroupDetails!.data!.contactNos.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    scheduledDate.text = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now().add(const Duration(minutes: 5)));
    return result == true
        ?Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/main/whatsappBg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
      appBar:PreferredSize(
        preferredSize:
        Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoPage(widget.token,widget.id,widget.groupName,widget.imageUrl
                ),
              ),
            );
          },
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
              child:  Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.groupName.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        noOfContact,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
    
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: contactGroupDetails!=null?
      Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                children: List.generate(
                  contactGroupDetails!.data!.messages!.length,
                      (index) {
                    return MessageBox(
                      message: contactGroupDetails!.data!.messages![index].caption,
                      isImage: contactGroupDetails!.data!.messages![index].isImage,
                      imgUrl: contactGroupDetails!.data!.messages![index].media,
                    );
                  },
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Image.file(File(_imageFile!)),
            // )
            _imageFile != null?
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: Container(width: MediaQuery.of(context).size.width * 1,
              height: 100,
              color: Colors.grey.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 5),
                    child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.file(File(_imageFile!))),
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
                ],
              ),
                ),
            ):const SizedBox(),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: TextField(
                              cursorColor: Colors.black,
                              controller: _sendMessageController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "  Type Here....",
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _selectFile,
                          child: Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        InkWell(
                          onTap:(){
                            if(_sendMessageController.text.isEmpty && _imageFile==null)
                              {
                                Common.toastMessaage(
                                    'Please Type a message', Colors.red);
                              }
                            else{
                              showGeneralDialog(
                                barrierLabel: "showGeneralDialog",
                                barrierDismissible: true,
                                barrierColor:
                                Colors.black.withOpacity(0.6),
                                transitionDuration:
                                const Duration(milliseconds: 400),
                                context: context,
                                pageBuilder: (context, _, __) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding:  EdgeInsets.only(bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                          child: IntrinsicHeight(
                                            child: Container(
                                              width: double.maxFinite,
                                              clipBehavior: Clip.antiAlias,
                                              padding:
                                              const EdgeInsets.all(16),
                                              decoration: const BoxDecoration(
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
                                                      'Send Message',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 20),
    
    
                                                    Row(
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            const Text('Min Delay',
                                                                style:
                                                                TextStyle(
                                                                  fontSize:
                                                                  15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.43,
                                                              child: TextFormField(
                                                                controller: minDelay,
                                                                style: const TextStyle(
                                                                  color: Colors.black,
                                                                ),
                                                                validator: (value) {
                                                                  if (value!.isEmpty) return "Min Delay";
                                                                  return null;
                                                                },
                                                                keyboardType: TextInputType.name,
                                                                decoration: InputDecoration(
                                                                    filled: true,
                                                                    //<-- SEE HERE
                                                                    fillColor: Colors.white,
                                                                    prefixIcon: const Icon(
                                                                      Icons.arrow_right,
                                                                      color: Colors.grey,
                                                                    ),
                                                                    counterText: "",
                                                                    hintText: "Min Delay",
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.purple.shade100),
                                                                        borderRadius: BorderRadius.circular(10))),
                                                              ),
                                                            ),
    
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            const Text('Max Delay',
                                                                style:
                                                                TextStyle(
                                                                  fontSize:
                                                                  15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.43,
                                                              child: TextFormField(
                                                                controller: maxDeley,
                                                                style: const TextStyle(
                                                                  color: Colors.black,
                                                                ),
                                                                validator: (value) {
                                                                  if (value!.isEmpty) return "Max Delay";
                                                                  return null;
                                                                },
                                                                keyboardType: TextInputType.name,
                                                                decoration: InputDecoration(
                                                                    filled: true,
                                                                    //<-- SEE HERE
                                                                    fillColor: Colors.white,
                                                                    prefixIcon:  const Icon(
                                                                      Icons.arrow_right,
                                                                      color: Colors.grey,
                                                                    ),
                                                                    counterText: "",
                                                                    hintText: "Max Delay",
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.purple.shade100),
                                                                        borderRadius: BorderRadius.circular(10))),
                                                              ),
                                                            ),
    
    
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 13,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        const Text('Schedule Time',
                                                            style:
                                                            TextStyle(
                                                              fontSize:
                                                              15,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                            )),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.9,
                                                          child: TextFormField(
                                                            controller: scheduledDate,
                                                            readOnly: true,
                                                            onTap: () async {
                                                              await showDatePicker(
                                                                  context: context,
                                                                  initialDate: DateTime.now(),
                                                                  firstDate: DateTime.now(),
                                                                  lastDate: DateTime(2100))
                                                                  .then((selectedDate) {
                                                                if (selectedDate != null) {
                                                                  showTimePicker(
                                                                      context: context,
                                                                      initialTime: TimeOfDay.now())
                                                                      .then((selectedTime) {
                                                                    String newDate = selectedDate.toString();
                                                                    newDate = newDate.substring(
                                                                        0, newDate.indexOf(" "));
                                                                    String convertedNewDate =
                                                                    getYmdFromDmy(newDate);
                                                                    if (selectedTime != null) {
                                                                      scheduledDate.text =
                                                                      "$convertedNewDate ${selectedTime.format(context)}";
                                                                    } else {}
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                            ),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                //<-- SEE HERE
                                                                fillColor: Colors.white,
                                                                prefixIcon: const Icon(
                                                                  Icons.arrow_right,
                                                                  color: Colors.grey,
                                                                ),
                                                                counterText: "",
                                                                hintText: "Scheduled Date",
                                                                isDense: true,
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors.purple.shade100),
                                                                    borderRadius: BorderRadius.circular(10))),
                                                          ),
                                                        ),
    
    
                                                      ],
                                                    ),
    
    
                                                    const SizedBox(
                                                        height: 16),
                                                    Container(
                                                      height: 40,
                                                      width: double.maxFinite,
                                                      decoration:
                                                      const BoxDecoration(
                                                        color:
                                                        Color(0xFF3375e0),
                                                        borderRadius:
                                                        BorderRadius.all(
                                                            Radius
                                                                .circular(
                                                                8)),
                                                      ),
                                                      child:
                                                      RawMaterialButton(
                                                        onPressed: () async {
                                                          if (_sendMessageController.text.isEmpty && _imageFile==null) {
                                                            Common.toastMessaage(
                                                                'Type your message', Colors.red);
                                                          }
                                                          else if (minDelay.text.isEmpty) {
                                                            Common.toastMessaage(
                                                                'Type Minimum Delay', Colors.red);
                                                          }
                                                          else if (maxDeley.text.isEmpty) {
                                                            Common.toastMessaage(
                                                                'Type Maximum Delay', Colors.red);
                                                          }
                                                          else if (scheduledDate.text.isEmpty) {
                                                            Common.toastMessaage(
                                                                'Type Scheduled Date', Colors.red);
                                                          }
                                                          else{
                                                            print(imageSts);
                                                            print(_imageFile);
                                                            Common.showProgressDialog(context, "Loading..");
                                                            var formData = FormData.fromMap({
                                                              "token": widget.token,
                                                              "group_id": widget.id,
                                                              "scheduled_time": scheduledDate.text,
                                                              "min_delay": minDelay.text,
                                                              "max_delay": maxDeley.text,
                                                              "message": _sendMessageController.text,
                                                              'image_status': imageSts,
                                                              if (_imageFile == null)
                                                                "imageName": _imageFile
                                                              else
                                                                "imageName": await MultipartFile.fromFile(
                                                                    _imageFile!)
                                                            });
    
                                                            SendMessageModel object1 =
                                                                await HttpService.sendWhatsappBulkMessage(formData);
                                                            if (object1.data == true) {
                                                              Common.toastMessaage(
                                                                 object1.message, Colors.green);
                                                                 getData();
                                                              if(mounted) {
                                                                Navigator.pop(context);
                                                                
                                                              }
                                                            }
                                                            else {
                                                              Common.toastMessaage(
                                                                  object1.message, Colors.red);
                                                              if(mounted) {
                                                                Navigator.pop(context);
                                                              }
                                                            }
                                                          }
                                                        },
                                                        child: const Center(
                                                          child: Text(
                                                            'Continue',
                                                            style: TextStyle(
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
                            }
    
                          } ,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF177767),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
      )
    
    
    
    
      :Center(
        child: Lottie.asset('assets/main/loading.json',
            fit: BoxFit.fill),
      )
    
    ),
        ):
    Scaffold(
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
        ));
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
    try {
      Navigator.pop(context);

      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      setState(() {
        _imageFile = pickedFile!.path;
      });
      // ignore: empty_catches
    } catch (e) {
    }
  }
  void _captureImage() async {
    try {
      Navigator.pop(context);
      final pickedFile =
      await _picker.pickImage(source: ImageSource.camera);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        _imageFile = pickedFile!.path;
        imageSts = true;

      });
      // ignore: empty_catches
    } catch (e) {
    }
  }
}
