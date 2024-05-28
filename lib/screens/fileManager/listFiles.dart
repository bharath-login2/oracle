import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';


import '../../core/common.dart';
import '../../models/fileManager/deleteFileModel.dart';
import '../../models/fileManager/fileMagerMOdel.dart';
import '../../models/fileManager/mainFileManagerPermissionModel.dart';
import '../../models/fileManager/renameFileModel.dart';
import '../../models/lead_management/uploadAudioRecoed.dart';
import '../../service/service.dart';
import '../leadManagement/audio_controller.dart';
import '../leadManagement/docViewWebView.dart';
import '../leadManagement/imageUploadController.dart';

class ListFiles extends StatefulWidget {
  String? token;
  String? folderName;

  ListFiles(this.token, this.folderName, {Key? key}) : super(key: key);

  @override
  State<ListFiles> createState() => _ListFilesState();
}

class _ListFilesState extends State<ListFiles> {
  @override
  void initState() {
    super.initState();
    listFolderList(widget.token, widget.folderName);
  }
  @override
  void dispose() {
    super.dispose();
    audioCreateController.audioRecord.dispose();
    audioCreateController.audioPlayer.dispose();
  }

  FileManagerModel? listFolder;
  MainFileManagerPermissionModel? fileManagerPermissionMain;
  bool folderActionEnable = false;
  bool isPlay = false;
  bool isExpanded = false;
  bool isBack = false;
  bool isFile = false;
  PlatformFile? file;
  String rawId = '';
  String selectedRawIndex = '';
  String editableName = '';
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();
  final AudioRecordController audioCreateController =
      Get.put(AudioRecordController());
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());

  getData() async {
    fileManagerPermissionMain =
        await HttpService.fileManagerPermissionMain(widget.token);
    if (fileManagerPermissionMain != null) {
      setState(() {});
    }
  }

  listFolderList(token, path) async {
    listFolder = await HttpService.mainListFolderAndFiles(token, path);
    if (listFolder != null) {
      getData();
      setState(() {});
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    FileMangerList(widget.token)),
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
                    Text(
                      widget.folderName.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                folderActionEnable == true
                    ? Row(
                        children: [
                          InkWell(
                              onTap: () {
                                fileManagerPermissionMain!.data!.renameFile ==
                                        true
                                    ? showGeneralDialog(
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
                                              alignment: Alignment.center,
                                              child: IntrinsicHeight(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Container(
                                                    width: double.maxFinite,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Material(
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 20),
                                                          const Text(
                                                            'Rename File',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          TextFormField(
                                                            controller:
                                                                fileNameEdit,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return "Rename File";
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                    filled:
                                                                        true,
                                                                    //<-- SEE HERE
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    counterText:
                                                                        "",
                                                                    hintText:
                                                                        "File Name",
                                                                    isDense:
                                                                        true,
                                                                    border: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .purple.shade100),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5))),
                                                          ),
                                                          const SizedBox(
                                                            height: 25,
                                                          ),
                                                          Container(
                                                            height: 40,
                                                            width: double
                                                                .maxFinite,
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
                                                                if (fileNameEdit
                                                                    .text
                                                                    .isEmpty) {
                                                                  Common.toastMessaage(
                                                                      'Enter Folder name',
                                                                      Colors
                                                                          .red);
                                                                } else {
                                                                  RenameFileModel
                                                                      renameFile =
                                                                      await HttpService.renameFile(
                                                                          widget
                                                                              .token,
                                                                          widget
                                                                              .folderName,
                                                                          editableName,
                                                                          fileNameEdit
                                                                              .text,
                                                                          rawId);
                                                                  if (renameFile
                                                                          .data ==
                                                                      true) {
                                                                    listFolderList(
                                                                        widget
                                                                            .token,
                                                                        widget
                                                                            .folderName);

                                                                    if (mounted) {
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  }
                                                                }
                                                              },
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  'Rename',
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
                                          });
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
                                      )
                                    : _dialogue(context, 'Rename Folder');
                              },
                              child: const Icon(
                                Icons.mode_edit,
                                color: Colors.white,
                              )),
                          const SizedBox(width: 10),
                          InkWell(
                              onTap: () {
                                fileManagerPermissionMain!.data!.deleteFile ==
                                        true
                                    ? showDialog(
                                        context: context,
                                        builder: (BuildContext ctx) {
                                          return AlertDialog(
                                            title: const Text('Please Confirm'),
                                            content: const Text(
                                                'Are you sure to Delete?'),
                                            actions: [
                                              // The "Yes" button
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No')),
                                              TextButton(
                                                  onPressed: () async {
                                                    DeleteFileModel deleteFile =
                                                        await HttpService
                                                            .deleteFiles(
                                                                widget.token,
                                                                widget
                                                                    .folderName,
                                                                editableName,
                                                                rawId);
                                                    if (deleteFile.data ==
                                                        true) {
                                                      folderActionEnable =
                                                          false;
                                                      selectedRawIndex = '';
                                                      listFolderList(
                                                          widget.token,
                                                          widget.folderName);
                                                    }
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  child: const Text('Yes')),
                                            ],
                                          );
                                        })
                                    : _dialogue(context, 'Delete Folder');
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
      body: listFolder != null
          ? SingleChildScrollView(
            child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Number of columns in the grid
                              crossAxisSpacing: 2, // Spacing between columns
                              mainAxisSpacing: 2, // Spacing between rows
                              childAspectRatio: 1),
                      itemCount: listFolder!.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onLongPress: () {
                            folderActionEnable = true;
                            rawId = listFolder!.data![index].id.toString();
                            selectedRawIndex = index.toString();
                            editableName =
                                listFolder!.data![index].name.toString();
                            fileNameEdit.text = editableName;
                            setState(() {});
                          },
                          onTap: () {
                            fileManagerPermissionMain!.data!.openFile == true
                                ? listFolder!.data![index].extension == 'M4A' ||
                                        listFolder!.data![index].extension ==
                                            'm4a'
                                    ? showGeneralDialog(
                                        barrierLabel: "showGeneralDialog",
                                        barrierDismissible: false,
                                        barrierColor:
                                            Colors.black.withOpacity(0.6),
                                        transitionDuration:
                                            const Duration(milliseconds: 400),
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
                                                        Align(
                                                          alignment:
                                                              Alignment.topRight,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              audioCreateController
                                                                  .stopTimer();
                                                              audioCreateController
                                                                  .audioPlayer
                                                                  .stop();
                                                              audioCreateController
                                                                  .resetTimer();
                                                              isPlay = false;
                                                              Get.back();
                                                            },
                                                            icon: const Icon(Icons
                                                                .close_rounded),
                                                            color:
                                                                Colors.redAccent,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'File Information',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                         Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 20),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 100,
                                                                      child: Text(
                                                                          'File Name :')),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 170,
                                                                      child: Text(
                                                                          listFolder!
                                                                              .data![index].name
                                                                              .toString(),overflow: TextOverflow.ellipsis,),),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                               Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 100,
                                                                      child: Text(
                                                                          'File Size :')),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 170,
                                                                      child: Text(
                                                                          listFolder!
                                                                              .data![index].fileSize
                                                                              .toString(),overflow: TextOverflow.ellipsis,)),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                               Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 100,
                                                                      child: Text(
                                                                          'Created Date :')),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 170,
                                                                      child: Text(
                                                                          listFolder!
                                                                              .data![index].createdAt
                                                                              .toString(),overflow: TextOverflow.ellipsis,)),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                               Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 100,
                                                                      child: Text(
                                                                          'Created By :')),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 170,
                                                                      child: Text(
                                                                          listFolder!
                                                                              .data![index].createdBy
                                                                              .toString(),overflow: TextOverflow.ellipsis,)),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Text(
                                                          '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().toString().padLeft(2, '0')}',
                                                          style: const TextStyle(
                                                              fontSize: 30),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            isPlay == false
                                                                ? FloatingActionButton(
                                                                    heroTag:
                                                                        "play tag",
                                                                    onPressed:
                                                                        () async {
                                                                      isPlay =
                                                                          true;
                                                                      audioCreateController.playVoice(listFolder!
                                                                          .data![
                                                                              index]
                                                                          .path);
                                                                    },
                                                                    shape:
                                                                        const CircleBorder(),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .teal,
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .play_arrow_rounded,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 30,
                                                                    ))
                                                                : const SizedBox(),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            FloatingActionButton(
                                                                heroTag:
                                                                    "stop tag",
                                                                onPressed: () {
                                                                  audioCreateController
                                                                      .stopTimer();
                                                                  audioCreateController
                                                                      .audioPlayer
                                                                      .stop();
                                                                  audioCreateController
                                                                      .resetTimer();
                                                                  isPlay = false;
                                                                },
                                                                shape:
                                                                    const CircleBorder(),
                                                                backgroundColor:
                                                                    Colors.white,
                                                                foregroundColor:
                                                                    Colors.teal,
                                                                child: const Icon(
                                                                  Icons.stop,
                                                                  color:
                                                                      Colors.red,
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
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DocumentViewerScreen(
                                            documentUrl: listFolder!
                                                .data![index].path
                                                .toString(),
                                            title: listFolder!.data![index].name
                                                .toString(),
                                            extension: listFolder!
                                                .data![index].extension
                                                .toString(),
                                                fileSize:listFolder!
                                                    .data![index].fileSize
                                                    .toString(),
                                                createdDate:listFolder!
                                                    .data![index].createdAt
                                                    .toString(),
                                                createdBy:listFolder!
                                                    .data![index].createdBy
                                                    .toString(),
                                          ),
                                        ),
                                      )
                                : _dialogue(context, 'Open Folder');
                          },
                          child: Container(
                            color: selectedRawIndex == index.toString()
                                ? Colors.grey.shade300
                                : Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: listFolder!.data![index].extension ==
                                                  'M4A' ||
                                              listFolder!
                                                      .data![index].extension ==
                                                  'm4a'||listFolder!
                                          .data![index].extension ==
                                          'wav' || listFolder!
                                          .data![index].extension ==
                                          'WAV'
                                          ? const AssetImage(
                                              'assets/icons/audio.png')
                                          : listFolder!.data![index].extension ==
                                                      'doc' ||
                                                  listFolder!.data![index]
                                                          .extension ==
                                                      'docx'
                                              ? const AssetImage(
                                                  'assets/icons/doc.png')
                                              : listFolder!.data![index]
                                                              .extension ==
                                                          'pdf' ||
                                                      listFolder!.data![index]
                                                              .extension ==
                                                          'PDF'
                                                  ? const AssetImage(
                                                      'assets/icons/pdf.png'):
                                      listFolder!.data![index].extension ==
                                          'pptx' || listFolder!.data![index]
                                          .extension ==
                                          'pptm'||
                                          listFolder!.data![index]
                                              .extension ==
                                              'ppt'?const AssetImage(
                                          'assets/icons/ppt.png'):
                                      listFolder!.data![index].extension ==
                                          'csv' || listFolder!.data![index]
                                          .extension ==
                                          'xls'||
                                          listFolder!.data![index]
                                              .extension ==
                                              'xlsx'?const AssetImage(
                                          'assets/icons/xls.png'):
                                      listFolder!.data![index].extension ==
                                          'mp4' || listFolder!.data![index]
                                          .extension ==
                                          'mkv'||
                                          listFolder!.data![index]
                                              .extension ==
                                              'webm'?const AssetImage(
                                          'assets/icons/mp4.png')
                                                  : const AssetImage(
                                                      'assets/icons/picture.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      listFolder!.data![index].name.toString(),
                                      overflow: TextOverflow.ellipsis,
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
              ),
          )
          :  Center(
        child: Lottie.asset('assets/main/loading.json',
            fit: BoxFit.fill),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: fileManagerPermissionMain != null
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
                            fileManagerPermissionMain!.data!.createFile == true
                                ? showGeneralDialog(
                                    barrierLabel: "showGeneralDialog",
                                    barrierDismissible: false,
                                    barrierColor: Colors.black.withOpacity(0.6),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    context: context,
                                    pageBuilder: (context, _, __) {
                                      return Obx(() {
                                        return AlertDialog(
                                          content: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                audioCreateController
                                                            .isRecording.value |
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
                                                                const TextStyle(
                                                                    fontSize:
                                                                        30),
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
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            'Voice Record ',
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                              "Do you want to record voice?"),
                                                        ],
                                                      ),
                                                const SizedBox(height: 20.0),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 20.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (audioCreateController
                                                                  .isRecording
                                                                  .value ==
                                                              false &&
                                                          audioCreateController
                                                              .audioPath
                                                              .isNotEmpty)
                                                        FloatingActionButton(
                                                            heroTag: "play tag",
                                                            onPressed: () {
                                                              audioCreateController
                                                                  .resetTimer();
                                                              audioCreateController
                                                                  .playRcording();
                                                            },
                                                            shape:
                                                                const CircleBorder(),
                                                            backgroundColor:
                                                                Colors.white,
                                                            foregroundColor:
                                                                Colors.teal,
                                                            child: const Icon(
                                                              Icons
                                                                  .play_arrow_rounded,
                                                              color:
                                                                  Colors.green,
                                                              size: 30,
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
                                                            onPressed: () {
                                                              audioCreateController
                                                                  .stopRecording();
                                                              // recordController.stopTimer();
                                                            },
                                                            shape:
                                                                const CircleBorder(),
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            foregroundColor:
                                                                Colors.white,
                                                            child: const Text(
                                                                "Stop")),
                                                      const SizedBox(
                                                        width: 25,
                                                      ),
                                                      if (audioCreateController
                                                                  .isRecording
                                                                  .value ==
                                                              false &&
                                                          audioCreateController
                                                              .audioPath
                                                              .isNotEmpty)
                                                        FloatingActionButton(
                                                            heroTag:
                                                                "delete tag",
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Are You Sure'),
                                                                      iconColor:
                                                                          Colors
                                                                              .blue,
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Get.back();
                                                                          },
                                                                          child:
                                                                              const Text('Cancel'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            audioCreateController.resetTimer();
                                                                            audioCreateController.audioPath.value =
                                                                                "";
                                                                            Get.back();
                                                                          },
                                                                          child:
                                                                              const Text('Delete'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            shape:
                                                                const CircleBorder(),
                                                            backgroundColor:
                                                                Colors.white,
                                                            foregroundColor:
                                                                Colors.red,
                                                            child: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 30,
                                                            )),
                                                    ],
                                                  ),
                                                ),
                                                if (audioCreateController
                                                            .isRecording
                                                            .value ==
                                                        false &&
                                                    audioCreateController
                                                        .audioPath.isNotEmpty)
                                                  TextFormField(
                                                    controller: fileName,
                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    top: 2,
                                                                    bottom: 2),
                                                            labelText:
                                                                'File Name',
                                                            fillColor:
                                                                Colors.white,
                                                            filled: true,
                                                            prefixIcon: Icon(
                                                                Icons.file_copy,
                                                                color: Colors
                                                                    .grey),
                                                            border:
                                                                OutlineInputBorder(),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                            ),
                                                            labelStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            audioCreateController
                                                        .isRecording.value ==
                                                    false
                                                ? TextButton(
                                                    onPressed: () async {
                                                      if (audioCreateController
                                                              .isBack.value ==
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
                                                        fileName.text = '';
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
                                                    child: const Text(
                                                      'Back',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            audioCreateController.isRecording
                                                            .value ==
                                                        false &&
                                                    audioCreateController
                                                        .audioPath.isNotEmpty
                                                ? TextButton(
                                                    onPressed: () async {

                                                      bool containsString = json
                                                          .encode(
                                                          listFolder!.data)
                                                          .contains(
                                                          audioCreateController
                                                              .audioPath.value.split('/').last);
                                                      bool containsString1;
                                                      if (fileName
                                                          .text.isNotEmpty) {
                                                        containsString1 = json
                                                            .encode(listFolder!
                                                            .data)
                                                            .contains(
                                                            fileName.text+extension(audioCreateController
                                                                .audioPath.value));
                                                      } else {
                                                        containsString1 = false;
                                                      }
                                                      //print(Uri.parse(audioCreateController.audioPath.value.toString()));
                                                      File file = File.fromUri(Uri.parse(audioCreateController.audioPath.value.toString()));





                                                      // File(
                                                      //     audioCreateController.audioPath.value.toString());
                                                      int fileSizeInBytes =
                                                          await file.length();
                                                      double fileSizeInKB =
                                                          fileSizeInBytes /
                                                              1024;
                                                      double fileSizeInMB =
                                                          fileSizeInKB / 1024;

                                                      //print('file Size :$fileSizeInMB');
                                                      if (fileName
                                                          .text.isEmpty &&
                                                          containsString ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      } else if (fileName.text
                                                          .isNotEmpty &&
                                                          containsString1 ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      }
                                                      else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .maxFileSize
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Maximum Size 5 MB',
                                                            Colors.red);
                                                      } else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .remainingStorage
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Insufficient Storage',
                                                            Colors.red);
                                                      } else {


                                                        if (mounted) {
                                                          Common
                                                              .showProgressDialog(
                                                                  context,
                                                                  "Uploading..");
                                                        }
                                                        UploadAudioRecord uploadAudio =
                                                            await HttpService.fileUpload(
                                                                widget.token,
                                                                widget
                                                                    .folderName,
                                                                audioCreateController
                                                                    .audioPath
                                                                    .value.toString(),
                                                                fileName.text);
                                                        if (uploadAudio.data ==
                                                            true) {
                                                          audioCreateController
                                                              .audioPath
                                                              .value = '';
                                                          fileName.text = '';
                                                          audioCreateController
                                                              .resetTimer();
                                                          Common.toastMessaage(
                                                              uploadAudio
                                                                  .message,
                                                              Colors.green);
                                                          listFolderList(
                                                              widget.token,
                                                              widget
                                                                  .folderName);
                                                          if (mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Save',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                                  )
                                                : audioCreateController
                                                            .isRecording
                                                            .value ==
                                                        false
                                                    ? TextButton(
                                                        onPressed: () {
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
                                                          isBack = true;
                                                        },
                                                        child: const Text(
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
                                  )
                                : _dialogue(context, 'Create File');
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
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
                            fileManagerPermissionMain!.data!.createFile == true
                                ? showGeneralDialog(
                                    barrierLabel: "showGeneralDialog",
                                    barrierDismissible: false,
                                    barrierColor: Colors.black.withOpacity(0.6),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    context: context,
                                    pageBuilder: (context, _, __) {
                                      return Obx(() {
                                        return AlertDialog(
                                          content: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      'Upload Image',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    imageUploadController
                                                                .file.value ==
                                                            ''
                                                        ? const Text(
                                                            "Do you want to upload image?")
                                                        : Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                  child: Center(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          150,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        color: Colors
                                                                            .transparent,
                                                                        image:
                                                                            DecorationImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          image: FileImage(File(imageUploadController
                                                                              .file
                                                                              .value)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    imageUploadController
                                                                        .file
                                                                        .value = '';
                                                                  });
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              TextFormField(
                                                                controller:
                                                                    fileName,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                2,
                                                                            bottom:
                                                                                2),
                                                                        labelText:
                                                                            'File Name',
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        prefixIcon: Icon(
                                                                            Icons
                                                                                .file_copy,
                                                                            color: Colors
                                                                                .grey),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.grey),
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(color: Colors.grey)),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20.0),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                imageUploadController
                                                    .file.value = '';
                                                fileName.text = '';
                                                Get.back();
                                              },
                                              child: const Text(
                                                'Back',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            imageUploadController.file.value !=
                                                    ''
                                                ? TextButton(
                                                    onPressed: () async {
                                                      bool containsString = json
                                                          .encode(
                                                              listFolder!.data)
                                                          .contains(
                                                              imageUploadController
                                                                  .fileName
                                                                  .value);
                                                      bool containsString1;
                                                      if (fileName
                                                          .text.isNotEmpty) {
                                                        containsString1 = json
                                                            .encode(listFolder!
                                                                .data)
                                                            .contains(
                                                                fileName.text+extension(imageUploadController
                                                                    .file.value));
                                                      } else {
                                                        containsString1 = false;
                                                      }

                                                      File file = File(
                                                          imageUploadController
                                                              .file.value);
                                                      int fileSizeInBytes =
                                                          await file.length();
                                                      double fileSizeInKB =
                                                          fileSizeInBytes /
                                                              1024;
                                                      double fileSizeInMB =
                                                          fileSizeInKB / 1024;

                                                      if (fileName
                                                              .text.isEmpty &&
                                                          containsString ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      } else if (fileName.text
                                                              .isNotEmpty &&
                                                          containsString1 ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      } else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .maxFileSize
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Maximum Size 5 MB',
                                                            Colors.red);
                                                      } else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .remainingStorage
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Insufficient Storage',
                                                            Colors.red);
                                                      } else {
                                                        if (mounted) {
                                                          Common
                                                              .showProgressDialog(
                                                                  context,
                                                                  "Uploading..");
                                                        }

                                                        UploadAudioRecord uploadAudio =
                                                            await HttpService
                                                                .fileUpload(
                                                                    widget
                                                                        .token,
                                                                    widget
                                                                        .folderName,
                                                                    imageUploadController
                                                                        .file
                                                                        .value,
                                                                    fileName
                                                                        .text);
                                                        if (uploadAudio.data ==
                                                            true) {
                                                          imageUploadController
                                                              .file.value = '';
                                                          fileName.text = '';
                                                          Common.toastMessaage(
                                                              uploadAudio
                                                                  .message,
                                                              Colors.green);
                                                          listFolderList(
                                                              widget.token,
                                                              widget
                                                                  .folderName);
                                                          if (mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Save',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                                  )
                                                : TextButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: ((builder) {
                                                          return Container(
                                                            height: 100.0,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 20,
                                                              vertical: 20,
                                                            ),
                                                            child: Column(
                                                              children: <Widget>[
                                                                const Text(
                                                                  "Choose Profile photo",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20.0,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          imageUploadController
                                                                              .takePhoto(ImageSource.camera);
                                                                          Get.back();
                                                                        },
                                                                        child:
                                                                            const Column(
                                                                          children: [
                                                                            Icon(Icons.camera),
                                                                            Text('Camera')
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            30,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          imageUploadController
                                                                              .takePhoto(ImageSource.gallery);
                                                                          Get.back();
                                                                        },
                                                                        child:
                                                                            const Column(
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
                                                    child: const Text(
                                                      'Upload',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                          ],
                                        );
                                      });
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
                                  )
                                : _dialogue(context, 'Create File');
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
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
                            fileManagerPermissionMain!.data!.createFile == true
                                ? showGeneralDialog(
                                    barrierLabel: "showGeneralDialog",
                                    barrierDismissible: false,
                                    barrierColor: Colors.black.withOpacity(0.6),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    context: context,
                                    pageBuilder: (context, _, __) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          content: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      'Upload Docs/Pdf',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    isFile == true
                                                        ? Column(
                                                          children: [
                                                            DottedBorder(
                                                                borderType:
                                                                    BorderType
                                                                        .RRect,
                                                                radius: const Radius
                                                                    .circular(5),
                                                                dashPattern: const [
                                                                  8,
                                                                  4
                                                                ],
                                                                strokeCap:
                                                                    StrokeCap.round,
                                                                color: Colors.black,
                                                                child: Container(
                                                                  width: 100,
                                                                  height: 100,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .blue
                                                                          .shade50
                                                                          .withOpacity(
                                                                              .3),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                                  10)),
                                                                  child:
                                                                      const Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .upload,
                                                                          color: Colors
                                                                              .black,
                                                                          size: 50),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      Text(
                                                                          'Doc/Pdf')
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(height: 10,),
                                                            TextFormField(
                                                              controller:
                                                              fileName,
                                                              decoration:
                                                              const InputDecoration(
                                                                  contentPadding: EdgeInsets.only(
                                                                      left:
                                                                      10,
                                                                      top:
                                                                      2,
                                                                      bottom:
                                                                      2),
                                                                  labelText:
                                                                  'File Name',
                                                                  fillColor:
                                                                  Colors
                                                                      .white,
                                                                  filled:
                                                                  true,
                                                                  prefixIcon: Icon(
                                                                      Icons
                                                                          .file_copy,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                  focusedBorder:
                                                                  OutlineInputBorder(
                                                                    borderSide:
                                                                    BorderSide(color: Colors.grey),
                                                                  ),
                                                                  labelStyle:
                                                                  TextStyle(color: Colors.grey)),
                                                            ),
                                                          ],
                                                        )
                                                        : const Text(
                                                            'Do you want to upload document?'),
                                                  ],
                                                ),
                                                const SizedBox(height: 20.0),
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
                                                    color: Colors.black),
                                              ),
                                            ),
                                            isFile == false
                                                ? TextButton(
                                                    onPressed: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'pdf',
                                                          'doc',
                                                          'docx'
                                                        ],
                                                      );

                                                      if (result != null) {
                                                        isFile = true;
                                                        file =
                                                            result.files.first;
                                                      } else {
                                                        isFile = false;
                                                        // User cance
                                                        // isled the file selection.
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        "Pick a Document"),
                                                  )
                                                : TextButton(
                                                    onPressed: () async {
                                                      String fileName1 = file!
                                                          .path!
                                                          .split('/')
                                                          .last;
                                                      bool containsString = json
                                                          .encode(
                                                              listFolder!.data)
                                                          .contains(fileName1);
                                                      bool containsString1;
                                                      if (fileName
                                                          .text.isNotEmpty) {
                                                        containsString1 = json
                                                            .encode(listFolder!
                                                                .data)
                                                            .contains(
                                                                fileName.text+extension(file!.path.toString()));
                                                      } else {
                                                        containsString1 = false;
                                                      }

                                                      int sizeInBytes =
                                                          await File(file!.path
                                                                  .toString())
                                                              .length();
                                                      double fileSizeInKB =
                                                          sizeInBytes / 1024;
                                                      double fileSizeInMB =
                                                          fileSizeInKB / 1024;
                                                      if (fileName
                                                              .text.isEmpty &&
                                                          containsString ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      } else if (fileName.text
                                                              .isNotEmpty &&
                                                          containsString1 ==
                                                              true) {
                                                        Common.toastMessaage(
                                                            'File Name already exist',
                                                            Colors.red);
                                                      } else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .maxFileSize
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Maximum Size 5 MB',
                                                            Colors.red);
                                                      } else if (fileSizeInMB >
                                                          double.parse(
                                                              fileManagerPermissionMain!
                                                                  .data!
                                                                  .remainingStorage
                                                                  .toString())) {
                                                        Common.toastMessaage(
                                                            'Insufficient Storage',
                                                            Colors.red);
                                                      } else {
                                                        if (mounted) {
                                                          Common
                                                              .showProgressDialog(
                                                                  context,
                                                                  "Uploading..");
                                                        }
                                                        UploadAudioRecord
                                                            uploadAudio =
                                                            await HttpService
                                                                .fileUpload(
                                                                    widget
                                                                        .token,
                                                                    widget
                                                                        .folderName,
                                                                    file!.path
                                                                        .toString(),
                                                                    fileName
                                                                        .text);
                                                        if (uploadAudio.data ==
                                                            true) {
                                                          isFile = false;
                                                          imageUploadController
                                                              .file.value = '';
                                                          fileName.text = '';
                                                          Common.toastMessaage(
                                                              uploadAudio
                                                                  .message,
                                                              Colors.green);
                                                          listFolderList(
                                                              widget.token,
                                                              widget
                                                                  .folderName);
                                                          if (mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                          setState(() {});
                                                        }
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Upload',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                                  )
                                          ],
                                        );
                                      });
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
                                  )
                                : _dialogue(context, 'Create File');
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
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
                    child: Icon(isExpanded ? Icons.close : Icons.upload),
                  ),
                ],
              )
            : const SizedBox(),
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
