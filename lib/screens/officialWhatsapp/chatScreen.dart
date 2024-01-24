import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/officialWhatsapp/chatHomeScreen.dart';
import '../../models/officialWhatsapp/officialMessageModel.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../../models/officialWhatsapp/templateContentModel.dart';
import '../../models/officialWhatsapp/templateModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';
import 'components/chatBubble.dart';
import 'components/imageHelper.dart';
import 'imageViewScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String groupId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List list = [];
  String? userImage;
  OfficialMessageModel? officialMessageModel;
  bool isTyped = false;
  bool isLoading = true;
  TemplateModel? templateModel;
  String selectedTemp = '';
  String selectTemplate = '';
  String templateImage = '';
  double dropDownHeight = 70;
  bool templateSelected = false;
  TemplateContentModel? templateContentModel;
  SendTemplateMesaageModel? sendTemplateMessageModel;
  bool buttonStatus = false;
  SendMesaageModel? sendMessageModel;
  bool isImage = false;

  @override
  void initState() {
    getchat(widget.groupId);

    super.initState();
  }

  final imageHelper = ImageHelper();

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: officialMessageModel == null && templateModel == null
          ? null
          : AppBar(
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatHomeScreen(),));
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Container(
          padding: EdgeInsets.zero, // Set padding to zero
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {

                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            officialMessageModel!.profilePhoto)),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ChatingScreen(),
                  //   ),
                  // );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officialMessageModel!.groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'last seen today at 3:35 PM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: ColorConstant.barGreen,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showMenu(
                  color: ColorConstant.white,
                  context: context,
                  position: const RelativeRect.fromLTRB(
                      1000.0, 0.0, 1000.0, 0.0),
                  items: [
                    const PopupMenuItem<String>(
                      value: '1',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: '2',
                      child: Text('Refresh'),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    if (value == '1') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                              height: 220,
                              child: Column(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            officialMessageModel!
                                                .profilePhoto),
                                      ),
                                      color: ColorConstant.grey,
                                      borderRadius:
                                      BorderRadius.circular(60),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 22,
                                  ),
                                  Text(
                                    officialMessageModel!.groupName,
                                    style: const TextStyle(
                                      color: ColorConstant.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    officialMessageModel!.phoneNumber,
                                    style: const TextStyle(
                                      color: ColorConstant.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    "Created By :${officialMessageModel!.createdBy}",
                                    style: const TextStyle(
                                      color: ColorConstant.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    "Created Date : ${DateFormat('dd-MM-yyyy').format(officialMessageModel!.createdTime)}",
                                    style: const TextStyle(
                                      color: ColorConstant.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('close'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == '2') {
                      getchat(widget.groupId);
                      setState(() {});
                    }
                  }
                });
              },
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: officialMessageModel == null && templateModel == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        decoration: const BoxDecoration(
          color: ColorConstant.backgroundColor,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/main/officialBackground.png'),
          ),
        ),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: officialMessageModel!.messages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      chatBubble(
                          officialMessageModel!.messages[index], context),
                    ],
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              )
            ],
          ),
        ),
      ),
      bottomSheet: officialMessageModel == null && templateModel == null
          ? null
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: officialMessageModel!.canSend == true
              ? SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(1, 1),
                          )
                        ],
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(25)),
                    child: TextFormField(
                      onChanged: (value) {
                        isTyped = true;
                        setState(() {});
                      },
                      style: const TextStyle(
                        color: ColorConstant.black,
                      ),
                      controller: messageController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        hintStyle:
                        const TextStyle(color: Colors.grey),
                        hintText: 'Message',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide
                              .none, // Set the border color to none
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text('Select Source'),
                                        content: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                await pickedImage(
                                                    context, ImageSource.camera);
                                                if (userImage == null) {


                                                }
                                                else {

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ImageViewScreen(
                                                              image: userImage,
                                                              val: '1',
                                                              groupId: widget.groupId,
                                                            ),
                                                      ));
                                                }
                                              },
                                              child: const Text("Camera"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await pickedImage(
                                                    context, ImageSource.gallery);
                                                if (userImage == null) {


                                                }
                                                else {

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ImageViewScreen(
                                                              image: userImage,
                                                              val: '1',
                                                              groupId: widget.groupId,
                                                            ),
                                                      ));
                                                }
                                              },
                                              child: const Text("Gallery"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );



                                },
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: ColorConstant.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                  ColorConstant.barGreen,
                  child: IconButton(
                      color:
                      const Color.fromARGB(255, 255, 255, 255),
                      onPressed: () async {
                        if (list.isNotEmpty) {
                          isImage = true;
                        }
                        await sendingMessage(widget.groupId,
                            messageController.text, list, isImage);
                        messageController.clear();
                        setState(() {});
                      },
                      icon: isTyped == false &&
                          messageController.text.isEmpty
                          ? const Icon(Icons.mic)
                          : const Icon(Icons.send)),
                ),
              ],
            ),
          )
              : GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          content: SizedBox(
                            height: dropDownHeight,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  templateModel == null
                                      ? const Center(
                                      child:
                                      CircularProgressIndicator())
                                      : DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: selectedTemp == ''
                                          ? null
                                          : selectedTemp,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                      autofocus: false,
                                      items: templateModel!.data
                                          .map<
                                          DropdownMenuItem<
                                              String>>((e) {
                                        return DropdownMenuItem<
                                            String>(
                                          onTap: () {
                                            selectTemplate =
                                                e.name;
                                          },
                                          value: e.id,
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                                context)
                                                .size
                                                .width *
                                                0.35,
                                            child: Text(
                                              e.name,
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (res) async {
                                        selectedTemp =
                                            res.toString();

                                        await getTemplateContents(
                                            selectedTemp);
                                        setState(() {});
                                      },
                                      hint: const Text(
                                        'Select template',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  templateSelected == true
                                      ? Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      templateContentModel!
                                          .data.format ==
                                          'VIDEO'
                                          ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context:
                                            context,
                                            builder:
                                                (BuildContext
                                            context) {
                                              return StatefulBuilder(
                                                  builder:
                                                      (context,
                                                      setState) {
                                                    return AlertDialog(
                                                      scrollable:
                                                      true,
                                                      title: const Text(
                                                          'Select Source'),
                                                      content:
                                                      Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              // Get.back();
                                                              Navigator.pop(context);
                                                              await pickTemplateImage(context, ImageSource.camera);
                                                              dropDownHeight = 510;
                                                              setState(() {});
                                                            },
                                                            child:
                                                            const Text("Camera"),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              // Get.back();
                                                              Navigator.pop(context);
                                                              await pickTemplateImage(context, ImageSource.gallery);
                                                              dropDownHeight = 510;
                                                              setState(() {});
                                                            },
                                                            child:
                                                            const Text("Gallery"),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () {
                                                              // Get.back();
                                                            },
                                                            child:
                                                            const Text("Cancel"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(
                                              context)
                                              .size
                                              .width *
                                              0.7,
                                          decoration:
                                          BoxDecoration(
                                            border: Border
                                                .all(),
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                5),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(8),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.2,
                                                  child: templateImage ==
                                                      ''
                                                      ? const Text(
                                                      'Upload ')
                                                      : Container(
                                                    height: 80,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: ColorConstant.white,
                                                      image: DecorationImage(
                                                        image: FileImage(
                                                          File(templateImage),
                                                        ),
                                                      ),
                                                    ),
                                                    // Add your image widget here
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      decoration:
                                                      BoxDecoration(
                                                        color:
                                                        ColorConstant.grey,
                                                        borderRadius:
                                                        BorderRadius.circular(3),
                                                      ),
                                                      child:
                                                      const Padding(
                                                        padding:
                                                        EdgeInsets.all(4.0),
                                                        child:
                                                        Text(
                                                          'Choose file',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      templateImage == ''
                                                          ? '*No file selected'
                                                          : '',
                                                      style:
                                                      const TextStyle(
                                                        fontSize:
                                                        12,
                                                        color:
                                                        Colors.black,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                          : templateContentModel!
                                          .data
                                          .format ==
                                          'TEXT'
                                          ? SizedBox(
                                        child: Text(
                                          templateContentModel!
                                              .data
                                              .header,
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            16,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),
                                      )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius
                                                .circular(8),
                                            color: ColorConstant
                                                .white),
                                        child:
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(8.0),
                                            child: Text(
                                              templateContentModel!
                                                  .data
                                                  .messageBody,
                                              textAlign:
                                              TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        templateContentModel!
                                            .data.footer,
                                        style: const TextStyle(
                                          color:
                                          ColorConstant.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      templateContentModel!.data
                                          .buttons.isEmpty
                                          ? const SizedBox()
                                          : SizedBox(
                                        height: 50,
                                        width:
                                        MediaQuery.of(
                                            context)
                                            .size
                                            .width,
                                        child: ListView
                                            .builder(
                                          scrollDirection:
                                          Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount:
                                          templateContentModel!
                                              .data
                                              .buttons
                                              .length,
                                          itemBuilder:
                                              (context,
                                              index) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(
                                                  8.0),
                                              child:
                                              Container(
                                                decoration:
                                                BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors
                                                          .grey
                                                          .withOpacity(0.2),
                                                      spreadRadius:
                                                      1,
                                                      blurRadius:
                                                      1,
                                                      offset: const Offset(
                                                          1,
                                                          1),
                                                    )
                                                  ],
                                                  color: ColorConstant
                                                      .white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      3),
                                                ),
                                                child:
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      top:
                                                      8,
                                                      left:
                                                      8,
                                                      right:
                                                      8),
                                                  child:
                                                  Text(
                                                    templateContentModel!
                                                        .data
                                                        .buttons[index]
                                                        .text,
                                                    style:
                                                    const TextStyle(
                                                      fontSize:
                                                      12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            buttonStatus == false
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                ColorConstant.black,
                              ),
                              onPressed: () async {
                                if (templateContentModel!
                                    .data.format ==
                                    'TEXT' &&
                                    templateSelected == true) {

                                  buttonStatus = true;
                                  await sendingTemplateMessage(
                                      widget.groupId,
                                      templateContentModel!
                                          .data.format,
                                      selectTemplate,
                                      templateContentModel!
                                          .data.language,
                                      selectedTemp,
                                      templateImage);
                                  setState(() {});
                                } else {
                                  //---------------------------   //Next video and image sending fuction call here ----------------------------------------------
                                }
                              },
                              child: const Text(
                                'Send',
                                style: TextStyle(
                                  color: ColorConstant.white,
                                ),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: ColorConstant.black,
                                  borderRadius:
                                  BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Sending...',
                                  style: TextStyle(
                                      color: ColorConstant.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                },
              );
            },
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: ColorConstant.white,
                      border: Border.all(
                          color: ColorConstant.barGreen,
                          width: 2.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        color: ColorConstant.barGreen,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Send Template',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConstant.barGreen),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickTemplateImage(context, source) async {
    final image1 =
    await ImagePicker().pickImage(source: source, imageQuality: 80);

    try {
      if (image1 != null) {
        setState(() {
          templateImage = image1.path;
        });
        print('Template Image Path after setState: $templateImage');
      }
    } on PlatformException catch (e) {
      // Get.snackbar('Permission Denied',
      //     'Please grant access to the gallery to pick an image.');
    }
  }

  pickedImage(context, source) async {
    final image1 =
    await ImagePicker().pickImage(source: source, imageQuality: 80);

    try {
      if (image1 != null) {
        userImage = image1.path;
      }
    } on PlatformException catch (e) {
      // Get.snackbar('Permission Denied',
      //     'Please grant access to the gallery to pick an image.');
    }
  }

  selectMultiImage(
      ImageSource? source,
      ) async {
    if (source != null) {
      final XFile? selectedImages =
      await ImagePicker().pickImage(source: source);
      if (selectedImages != null) {
        list?.add(selectedImages);
        // isLoading.value = true;
        // isLoading.value = false;
      }
      return list;
    } else {
      final List<XFile> images = await ImagePicker().pickMultiImage();
      if (images.isNotEmpty) {
        list.addAll(images);
        // isLoading.value = true;
        // isLoading.value = false;
      }
      return list;
    }
  }

  getTemplates() async {
    templateModel = await HttpService.getTemplate();
    if (templateModel != null) {
      isLoading = false;
      setState(() {});
    }
  }

  getchat(groupId) async {
    isLoading = true;
    officialMessageModel = await HttpService.officialMessage(groupId);
    if (officialMessageModel != null) {
      getTemplates();
      setState(() {});
    }
  }

  getTemplateContents(templateId) async {
    templateContentModel = await HttpService.getTemplateContent(templateId);
    if (templateContentModel != null) {
      if (templateContentModel!.data.format == 'VIDEO') {
        setState(() {
          dropDownHeight = 470;
          templateSelected = true;
        });
      } else if (templateContentModel!.data.format == 'TEXT') {
        setState(() {
          dropDownHeight = 400;
          templateSelected = true;

        });
      }
    } else {
      setState(() {});
    }
  }

  sendingTemplateMessage(
      groupId, format, templateName, language, template, fileName) async {
    sendTemplateMessageModel = await HttpService.sendTemplateMessage(
        groupId, format, templateName, language, template, fileName);
    if (sendTemplateMessageModel != null &&
        sendTemplateMessageModel!.status == true) {
      await getchat(groupId);
      Navigator.pop(context);
    }
  }

  sendingMessage(groupId, messageData, fileName, isImage) async {
    sendMessageModel =
    await HttpService.sendMessage(groupId, messageData, fileName, isImage);
    if (sendMessageModel != null && sendMessageModel!.status == true) {
      await getchat(groupId);
      setState(() {});
    }
  }
}
