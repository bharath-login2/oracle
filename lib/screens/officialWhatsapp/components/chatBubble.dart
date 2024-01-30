
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../colorConst.dart';
import '../viewerScreen.dart';


Widget chatBubble(msg, context
    // DocumentSnapshot doc
    ) {
  // var creation =
  // doc['created_on'] == null ? DateTime.now() : doc['created_on'].toDate();
  // var time = intl.DateFormat("h:mma").format(creation);
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  return Directionality(
    textDirection:
    // doc['uid'] == auth.currentUser!.uid
    //     ? TextDirection.rtl
    //     :
    msg.fromMe == true ? TextDirection.rtl : TextDirection.ltr,
    child: Column(
      children: [
        GestureDetector(
          onTap: () {
            if (msg.messageText.format == 'VIDEO') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewerScreen(
                      myUrl: msg.messageText.url,
                      type: msg.messageText.format,
                      title: msg.messageText.format,
                    ),
                  ));
            } else {}
          },
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, bottom: 4, top: 12),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(-1, 1),
                      )
                    ],
                    color: msg.fromMe == false
                        ? ColorConstant.white
                        : ColorConstant.greenChat,
                    // doc['uid'] == auth.currentUser!.uid
                    //     ? const Color.fromARGB(255, 184, 236, 123)
                    //     :

                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      msg.messageText.format == 'IMAGE'
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewerScreen(
                                  myUrl: msg.messageText.url,
                                  type: msg.messageText.format,
                                  title: msg.messageText.format,
                                ),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Container(
                            height:
                            MediaQuery.of(context).size.height * 0.35,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: NetworkImage(msg.messageText.url),
                              ),
                            ),
                          ),
                        ),
                      )
                          : msg.messageText.format == 'VIDEO'
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          //height: MediaQuery.of(context).size.height * 0.38,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              color: Colors.white),
                          child:  Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // AspectRatio(
                              //   aspectRatio: 16 / 10,
                              //   child: Stack(
                              //     alignment: Alignment.bottomCenter,
                              //     children: <Widget>[
                              //       VideoPlayer(_controller),
                              //       _ControlsOverlay(controller: _controller),
                              //       VideoProgressIndicator(_controller, allowScrubbing: true),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )
                          : msg.messageText.format == 'TEXT'
                          ? msg.messageText.url == ''
                          ? const SizedBox()
                          : Padding(
                        padding:
                        const EdgeInsets.only(bottom: 8),
                        child: Text(
                          msg.messageText.url,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : const SizedBox(),
                      Text(
                        msg.messageText.messageBody,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      msg.messageText.footer == ""
                          ? const SizedBox()
                          : Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          msg.messageText.footer,
                          style: const TextStyle(
                              fontSize: 12, color: ColorConstant.grey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            msg.sentTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          msg.fromMe == true
                              ? msg.status == 'send'
                              ? const Icon(
                            Icons.check,
                            color: ColorConstant.grey,
                            size: 18,
                          )
                              : msg.status == 'delivered'
                              ? const Icon(
                            Icons.done_all_sharp,
                            color: ColorConstant.grey,
                            size: 18,
                          )
                              : msg.status == 'read'
                              ? const Icon(
                            Icons.done_all_sharp,
                            color: ColorConstant.messageSeen,
                            size: 18,
                          )
                              : msg.status == 'failed'
                              ? const Icon(
                            Icons.access_time_rounded,
                            color: ColorConstant.grey,
                            size: 18,
                          )
                              : const Icon(
                            Icons.check,
                            color: ColorConstant.grey,
                            size: 18,
                          )
                              : const SizedBox()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 8, left: 8),
          child: msg.messageText.buttons.length == 2
              ? Row(
            children: [
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Center(
                  child: Text(
                    msg.messageText.buttons[1].text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Center(
                  child: Text(
                    msg.messageText.buttons[0].text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.644,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: msg.messageText.buttons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (msg.messageText.buttons[index].type ==
                            "URL") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewerScreen(
                                myUrl: msg
                                    .messageText.buttons[index].buttonUrl,
                                type: msg.messageText.format,
                                title: msg.messageText.format,
                              ),
                            ),
                          );
                        } else if (msg.messageText.buttons[index].type ==
                            "PHONE_NUMBER") {
                          await launch(
                            "tel:/${msg.messageText.buttons[index].buttonUrl}",
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              msg.messageText.buttons[index].text,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
