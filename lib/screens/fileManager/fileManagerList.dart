import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login2/screens/fileManager/listFiles.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../models/fileManager/fileMagerMOdel.dart';
import '../../models/fileManager/mainFileManagerPermissionModel.dart';
import '../../service/service.dart';
import '../leadManagement/audio_controller.dart';
import '../leadManagement/imageUploadController.dart';

class FileMangerList extends StatefulWidget {
  String? token;

  FileMangerList(this.token, {Key? key}) : super(key: key);

  @override
  State<FileMangerList> createState() => _FileMangerListState();
}

class _FileMangerListState extends State<FileMangerList> {
  @override
  void initState() {
    super.initState();
    listFolderList(widget.token, path);
  }

  @override
  void dispose() {
    super.dispose();
    audioCreateController.audioRecord.dispose();
    audioCreateController.audioPlayer.dispose();
  }

  FileManagerModel? listFolder;
  MainFileManagerPermissionModel? fileManagerPermissionMain;
  String path = '';
  bool isRunning = true;
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
                        'File Manager',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: listFolder != null && fileManagerPermissionMain != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.shade100),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Storage Status',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/database.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LinearPercentIndicator(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          animation: isRunning,
                                          lineHeight: 5,
                                          animationDuration: 3000,
                                          percent: double.parse(
                                              fileManagerPermissionMain!
                                                  .data!.percentageComplete
                                                  .toString()),
                                          animateFromLastPercent: true,
                                          center: const Text(""),
                                          progressColor: double.parse(
                                                      fileManagerPermissionMain!
                                                          .data!
                                                          .percentageComplete
                                                          .toString()) >
                                                  0.8
                                              ? Colors.red
                                              : Colors.green),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(fileManagerPermissionMain!
                                            .data!.totalStorage
                                            .toString()),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'My Drive',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                      itemCount: listFolder!.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            fileManagerPermissionMain!.data!.openFile == true
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ListFiles(
                                            widget.token,
                                            listFolder!.data![index].path)),
                                  )
                                : _dialogue(context, 'Open Folder');
                          },
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/icons/folder.png'),
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
              )
            : Center(
                child:
                    Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
              ));
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
