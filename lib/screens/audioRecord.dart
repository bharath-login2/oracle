// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class AudioRecord extends StatefulWidget {
//   String callMasterId;
//   AudioRecord(this.callMasterId,{super.key});
//   @override
//   _AudioRecordState createState() => _AudioRecordState();
// }
// class _AudioRecordState extends State<AudioRecord> {
//   late FlutterSoundRecorder _recordingSession;
//   late String pathToAudio;
//   String _timerText = '00:00:00';
//   @override
//   void initState() {
//     super.initState();
//     initializer();
//   }
//   void initializer() async {
//     pathToAudio = '/storage/emulated/0/Download/${widget.callMasterId}.wav';
//     _recordingSession = FlutterSoundRecorder();
//     await _recordingSession.openAudioSession(
//         focus: AudioFocus.requestFocusAndStopOthers,
//         category: SessionCategory.playAndRecord,
//         mode: SessionMode.modeDefault,
//         device: AudioDevice.speaker);
//     await _recordingSession.setSubscriptionDuration(const Duration(milliseconds: 10));
//
//     await Permission.microphone.request();
//     await Permission.storage.request();
//     await Permission.manageExternalStorage.request();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize:
//         Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
//         child: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           decoration: const BoxDecoration(
//             gradient:
//             LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(
//                 left: 10.0, top: 10.0, bottom: 10.0, right: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                         height: 25,
//                         width: 25,
//                         decoration: BoxDecoration(
//                             border: Border.all(color: Colors.white),
//                             shape: BoxShape.circle),
//                         child: const Icon(
//                           Icons.arrow_back_ios_outlined,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 25,
//                     ),
//                     const Text(
//                       'Recording',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             const SizedBox(
//               height: 40,
//             ),
//             Center(
//               child: Text(
//                 _timerText,
//                 style: const TextStyle(fontSize: 25, color: Colors.black),
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10,right: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton.icon(
//                     style:
//                     ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.blue),
//                     onPressed: () {
//                       startRecording();
//                     },
//                     icon: const Icon(
//                       Icons.start,
//                     ),
//                       label:  const Text(
//                       "Start",
//                       style: TextStyle(
//                         fontSize: 15,
//                       ),
//                     )
//
//                   ),
//                   ElevatedButton.icon(
//                       style:
//                       ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
//                       onPressed: () {
//                         stopRecording();
//                       },
//                       icon: const Icon(
//                         Icons.stop,
//                       ),
//                       label:  const Text(
//                         "Stop",
//                         style: TextStyle(
//                           fontSize: 15,
//                         ),
//                       )
//
//                   ),
//
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//   ElevatedButton createElevatedButton(
//       {required IconData icon, required Color iconColor, required Function onPressFunc}) {
//     return ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.all(6.0),
//         side: const BorderSide(
//           color: Colors.red,
//           width: 4.0,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         primary: Colors.white,
//         elevation: 9.0,
//       ),
//       onPressed:(){
//         onPressFunc;
//       },
//       icon: Icon(
//         icon,
//         color: iconColor,
//         size: 38.0,
//       ),
//       label: const Text(''),
//     );
//   }
//   Future<void> startRecording() async {
//     _recordingSession.openAudioSession();
//     await _recordingSession.startRecorder(
//       toFile: pathToAudio,
//       codec: Codec.pcm16WAV,
//     );
//     StreamSubscription recorderSubscription =
//     _recordingSession.onProgress!.listen((e) {
//
//       var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
//           isUtc: true);
//       var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
//       setState(() {
//         _timerText = timeText.substring(0, 8);
//       });
//     });
//     recorderSubscription.cancel();
//   }
//   Future<String?> stopRecording() async {
//     _recordingSession.closeAudioSession();
//     return await _recordingSession.stopRecorder();
//   }
//
//
// }