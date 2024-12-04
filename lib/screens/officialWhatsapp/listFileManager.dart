// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/fileSendingScreen.dart';
import 'package:lottie/lottie.dart';
import '../../models/officialWhatsapp/mediaModel.dart';
import '../../service/service.dart';

class ListFileManager extends StatefulWidget {
  String? format;
  String groupId;

  ListFileManager(this.format, this.groupId, {Key? key}) : super(key: key);

  @override
  State<ListFileManager> createState() => _ListFileManagerState();
}

class _ListFileManagerState extends State<ListFileManager> {
  MediaModel? mediaDetails;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData(widget.format);
  }

  getData(format) async {
    mediaDetails = await HttpService.getTemplateMedia(format);
    if (mediaDetails != null) {
      setState(() {});
    } else {
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
                      'Upload',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: mediaDetails != null
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
                              crossAxisCount:
                                  4, // Number of columns in the grid
                              crossAxisSpacing: 2, // Spacing between columns
                              mainAxisSpacing: 2, // Spacing between rows
                              childAspectRatio: 1),
                      itemCount: mediaDetails!.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileSendingScreen(
                                  documentUrl:
                                      mediaDetails!.data![index].url.toString(),
                                  title: mediaDetails!.data![index].fileName
                                      .toString(),
                                  extension: mediaDetails!
                                      .data![index].extension
                                      .toString(),
                                  groupId: widget.groupId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: mediaDetails!.data![index].extension == 'M4A' ||
                                              mediaDetails!.data![index].extension ==
                                                  'm4a' ||
                                              mediaDetails!.data![index].extension ==
                                                  'wav' ||
                                              mediaDetails!.data![index].extension ==
                                                  'WAV'
                                          ? const AssetImage(
                                              'assets/icons/audio.png')
                                          : mediaDetails!.data![index].extension == 'doc' ||
                                                  mediaDetails!.data![index].extension ==
                                                      'docx'
                                              ? const AssetImage(
                                                  'assets/icons/doc.png')
                                              : mediaDetails!.data![index].extension == 'pdf' ||
                                                      mediaDetails!.data![index]
                                                              .extension ==
                                                          'PDF'
                                                  ? const AssetImage(
                                                      'assets/icons/pdf.png')
                                                  : mediaDetails!.data![index].extension == 'pptx' ||
                                                          mediaDetails!
                                                                  .data![index]
                                                                  .extension ==
                                                              'pptm' ||
                                                          mediaDetails!
                                                                  .data![index]
                                                                  .extension ==
                                                              'ppt'
                                                      ? const AssetImage(
                                                          'assets/icons/ppt.png')
                                                      : mediaDetails!.data![index].extension == 'csv' ||
                                                              mediaDetails!
                                                                      .data![index]
                                                                      .extension ==
                                                                  'xls' ||
                                                              mediaDetails!.data![index].extension == 'xlsx'
                                                          ? const AssetImage('assets/icons/xls.png')
                                                          : mediaDetails!.data![index].extension == 'mp4' || mediaDetails!.data![index].extension == 'mkv' || mediaDetails!.data![index].extension == 'webm'
                                                              ? const AssetImage('assets/icons/mp4.png')
                                                              : const AssetImage('assets/icons/picture.png'),
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
                                      mediaDetails!.data![index].fileName
                                          .toString(),
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
          : Center(
              child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
            ),
    );
  }
}
