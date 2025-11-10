// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/officialWhatsapp/mediaModel.dart';
import '../../service/service.dart';
import 'fileSendingScreen.dart';

class ListFileManager extends StatefulWidget {
  String? format;
  String groupId;

  ListFileManager(this.format, this.groupId, {super.key});

  @override
  State<ListFileManager> createState() => _ListFileManagerState();
}

class _ListFileManagerState extends State<ListFileManager> {
  MediaModel? mediaDetails;
  bool isRecording = false;
  FlutterSoundRecorder? _recorder;
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _recorder!.openRecorder();
    getData(widget.format);
  }

  Future<void> getData(String? format) async {
    mediaDetails = await HttpService.getTemplateMedia(format);
    setState(() {});
  }

  Future<void> startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
    setState(() {
      isRecording = true;
      recordedFilePath = path;
    });
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      isRecording = false;
    });

    if (recordedFilePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileSendingScreen(
            documentUrl: recordedFilePath!,
            title: "Recorded Audio",
            extension: 'aac',
            groupId: widget.groupId,
          ),
        ),
      ).then((_) => getData(widget.format));
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_outlined,
                        color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 20),
                const Text('Upload',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
      body: mediaDetails != null
          ? Column(
              children: [
                if (widget.format == 'audio')
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              isRecording ? stopRecording : startRecording,
                          icon: Icon(isRecording ? Icons.stop : Icons.mic),
                          label: Text(
                              isRecording ? "Stop Recording" : "Record Audio"),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: mediaDetails!.data!.length,
                    itemBuilder: (context, index) {
                      final file = mediaDetails!.data![index];
                      String extension = file.extension!.toLowerCase();
                      String iconPath = 'assets/icons/picture.png';

                      if (['aac', 'm4a', 'wav', 'mp3'].contains(extension))
                        iconPath = 'assets/icons/audio.png';
                      else if (['doc', 'docx'].contains(extension))
                        iconPath = 'assets/icons/doc.png';
                      else if (['pdf'].contains(extension))
                        iconPath = 'assets/icons/pdf.png';
                      else if (['ppt', 'pptx', 'pptm'].contains(extension))
                        iconPath = 'assets/icons/ppt.png';
                      else if (['xls', 'xlsx', 'csv'].contains(extension))
                        iconPath = 'assets/icons/xls.png';
                      else if (['mp4', 'mkv', 'webm'].contains(extension))
                        iconPath = 'assets/icons/mp4.png';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FileSendingScreen(
                                documentUrl: file.url,
                                title: file.fileName,
                                extension: file.extension,
                                groupId: widget.groupId,
                              ),
                            ),
                          ).then((_) => getData(widget.format));
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(iconPath),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  file.fileName ?? "Unknown",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
            ),
    );
  }
}
