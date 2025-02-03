import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordController extends GetxController {
  final audioRecord = AudioRecorder();
  late AudioPlayer audioPlayer;
  RxBool isRecording = false.obs;
  RxString audioPath = "".obs;
  RxBool isBack = false.obs;
  @override
  void onInit() {
    // audioRecord = Record();
    audioPlayer = AudioPlayer();
    super.onInit();
  }

  @override
  void onClose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    audioPlayer = AudioPlayer();
    super.onClose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        Directory? dir = await getApplicationDocumentsDirectory();
        String path =
            '${dir.path}/my_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        startTimer();
        await audioRecord.start(const RecordConfig(), path: path);
        isRecording.value = true;
      }
    } catch (e) {
      // print("error");
    }
  }

  RxInt totalDuration = 0.obs;

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      isRecording.value = false;
      audioPath.value = path!;
      stopTimer();
      int minutesElapsed = minutes.value * 60;
      totalDuration.value = minutesElapsed + seconds.value;
    } catch (e) {
      // print("error $e");
    }
  }

  Future<void> playRcording() async {
    try {
      Source urlSourse = UrlSource(audioPath.value);

      await audioPlayer.play(urlSourse);
      startTimer();
      audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          stopTimer();
          resetTimer();
        }
      });
    } catch (e) {
      // print("error");
    }
  }

  var minutes = 0.obs;
  var seconds = 0.obs;
  late Timer? _timer;
  bool isRunning = false;

  void startTimer() {
    if (!isRunning) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds.value < 59) {
          seconds.value++;
        } else {
          seconds.value = 0;
          minutes.value++;
        }
      });
    }
  }

  void stopTimer() {
    if (isRunning) {
      isRunning = false;
      _timer!.cancel();
    }
  }

  void resetTimer() {
    isRunning = false;
    _timer!.cancel();
    minutes.value = 0;
    seconds.value = 0;
  }

  Future<void> playVoice(url) async {
    try {
      Source urlSourse = UrlSource(url);
      await audioPlayer.play(urlSourse);
      startTimer();
      audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          stopTimer();
        }
      });
    } catch (e) {
      // print("error");
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
  }
}
