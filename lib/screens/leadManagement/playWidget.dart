import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'leadDetails.dart';

class AudioItems extends StatefulWidget {
  String direction;
  String time;
  bool isAttend;
  String startTime;
  String status;
  String resourceUrl;
  String duration;
  bool accessCallRecord;
  String clientName;
  String leadType;
  String? leadStatus;
  String imageUrl;
  String fromDate;
  String toDate;
  bool? editLead;
  bool? deleteLead;
  bool? cloudCall;
  String? masterId;
  String? token;
  String? name;
  String? userId;

  AudioItems(
      this.direction,
      this.time,
      this.isAttend,
      this.startTime,
      this.status,
      this.resourceUrl,
      this.duration,
      this.accessCallRecord,
      this.clientName,
      this.leadType,
      this.leadStatus,
      this.imageUrl,
      this.fromDate,
      this.toDate,
      this.editLead,
      this.deleteLead,
      this.cloudCall,
      this.masterId,
      this.token,
      this.name,
      this.userId,
      {super.key});

  @override
  State<AudioItems> createState() => AudioItemsState();
}

class AudioItemsState extends State<AudioItems> {
  var dio = Dio();
  DateTime currentSDate = DateTime.now();
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int maxDuration = 100;
  int currentPos = 0;
  String currentPostLabel = "00:00";
  bool audioPlayed = false;
  Duration duration = Duration.zero; // For total duration
  Duration position = Duration.zero; // For the current position
  int index=0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      audioPlayer.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxDuration = d.inMilliseconds;
        setState(() {});
      });

      audioPlayer.onPositionChanged.listen((Duration p) {
        currentPos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentPos).inHours;
        int sminutes = Duration(milliseconds: currentPos).inMinutes;
        int sseconds = Duration(milliseconds: currentPos).inSeconds;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);
        currentPostLabel = "$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {

          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }
  @override
  void dispose() {
    audioPlayer.dispose(); // Dispose of a TextEditingController
    super.dispose();
    // setState(() {
    //
    // });
  }


  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      // ignore: empty_catches
    } catch (e) {}
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {}
  }

  // Future<void> setAudioPlayer() async {
  //   super.initState();
  //   // audioPlayer.play(UrlSource(widget.resourceUrl));
  //   audioPlayer.setReleaseMode(ReleaseMode.stop);
  // }
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        InkWell(
          onTap: () {
            audioPlayer.dispose();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LeadDetails(
                    widget.token!,
                    widget.editLead!,
                    widget.deleteLead!,
                    widget.cloudCall!,
                    widget.masterId!,
                    pageName: 'callHistory',
                    fromDate: widget.fromDate,
                    toDate: widget.toDate,
                    name: widget.name,
                    userId: widget.userId,
                    recordAccessPermission: widget.accessCallRecord,
                  )),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Card(
              margin: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.green.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 4,
                      blurRadius: 6,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                widget.direction.toString() == 'Incoming Call'
                                    ? const Icon(Icons.phone_callback_sharp,
                                    color: Colors.green, size: 20)
                                    : widget.direction.toString() ==
                                    'Missed Call'
                                    ? const Icon(
                                  Icons.phone_missed,
                                  color: Colors.red,
                                  size: 20,
                                )
                                    : const Icon(
                                    Icons.phone_forwarded_sharp,
                                    color: Colors.blueAccent,
                                    size: 20),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.direction.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: SizedBox(
                                    width: 76,
                                    child: Center(
                                      child: Text(
                                        widget.status,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: widget.status.toString() ==
                                              'ANSWERED'
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Client Name: ${widget.clientName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 14)),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Lead Category: ${widget.leadType}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 14)),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Status: ${widget.leadStatus}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 14)),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(widget.time.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                                fontSize: 14)),
                      ),
                      widget.isAttend == true && widget.accessCallRecord
                          ? Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  isPlaying == false
                                      ? audioPlayer.play(
                                      UrlSource(widget.resourceUrl))
                                      : await audioPlayer.pause();
                                  setState(() {

                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 15,
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '$currentPostLabel/${widget.duration}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              SizedBox(
                                height: 25,
                                width: 135,
                                child: Slider(
                                  min: 0,
                                  value: position.inMilliseconds.toDouble(),
                                  max: duration.inMilliseconds.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      position = Duration(
                                          milliseconds: value.toInt());
                                    });
                                    audioPlayer.seek(position);
                                  },
                                ),
                              ),

                            ],
                          ),

                        ],
                      )
                          : const SizedBox(),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          bottom: 0.0,
          left: 35.0,
          child: Container(
            height: double.infinity,
            width: 1.0,
            color: Colors.blue,
          ),
        ),
        Positioned(
          top: 30.0,
          left: 10.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 60,
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 20,
                    minWidth: 20,
                    maxHeight: 50,
                    maxWidth: 50,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(1, 1)),
                    ],
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.imageUrl)),
                    // image: AssetImage(
                    //     'assets/images/img.jpeg')),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                width: 80.0,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        offset: Offset(1, 1)),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                    child: Text(
                      widget.startTime.toString(),
                    )),
              ),
            ],
          ),
        )
      ],
    );
  }


}