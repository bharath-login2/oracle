import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';

// ignore: must_be_immutable
class ImageViewScreenBottom extends StatefulWidget {
  final List? listFiles; // Can be XFile or File
  final String? filePath; // Single file path
  final String val; // '1' = single, '2' = multiple
  final String groupId;

  ImageViewScreenBottom({
    super.key,
    this.listFiles,
    this.filePath,
    required this.val,
    required this.groupId,
  });

  @override
  State<ImageViewScreenBottom> createState() => _ImageViewScreenBottomState();
}

class _ImageViewScreenBottomState extends State<ImageViewScreenBottom> {
  String? viewFile; // Current selected file
  bool isImage = true;
  int currentIndex = 0;
  TextEditingController messageController = TextEditingController();
  SendMesaageModel? sendMessageModel;

  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isSending = false;
  @override
  void initState() {
    super.initState();

    // Initialize selected file
    if (widget.val == '1' && widget.filePath != null) {
      viewFile = widget.filePath;
    } else if (widget.val == '2' &&
        widget.listFiles != null &&
        widget.listFiles!.isNotEmpty) {
      viewFile = widget.listFiles![0].path;
    }

    _initializeMedia();
  }

  void _initializeMedia() {
    if (viewFile == null) return;

    if (isVideoFile(viewFile!)) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(viewFile!))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
      isImage = false;
    } else if (isAudioFile(viewFile!)) {
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      _audioPlayer!.setFilePath(viewFile!);
      isImage = false;
    } else {
      isImage = true;
    }
  }

  bool isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.png') ||
        ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.gif');
  }

  bool isVideoFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }

  bool isAudioFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp3') || ext.endsWith('.wav') || ext.endsWith('.m4a');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _onSend() async {
    if (_isSending) return;
    if (viewFile == null && messageController.text.isEmpty) return;
    setState(() => _isSending = true);
    bool fileIsImage = viewFile != null ? isImageFile(viewFile!) : false;
    await sendingMessage(
        widget.groupId, messageController.text, viewFile, fileIsImage);
    setState(() {
      viewFile = null;
      messageController.clear();
      _videoController?.dispose();
      _videoController = null;
      _audioPlayer?.dispose();
      _audioPlayer = null;
      _isSending = false;
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: ColorConstant.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: viewFile == null
                  ? const Text("No file selected",
                      style: TextStyle(color: Colors.white))
                  : isImage
                      ? Image.file(File(viewFile!), fit: BoxFit.contain)
                      : isVideoFile(viewFile!)
                          ? _videoController != null &&
                                  _videoController!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                )
                              : const CircularProgressIndicator()
                          : isAudioFile(viewFile!)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.audiotrack,
                                        size: 80, color: Colors.white),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_audioPlayer!.playing) {
                                          await _audioPlayer!.pause();
                                        } else {
                                          await _audioPlayer!.play();
                                        }
                                        setState(() {});
                                      },
                                      child: Text(_audioPlayer!.playing
                                          ? "Pause"
                                          : "Play"),
                                    ),
                                  ],
                                )
                              : const Text("Unsupported file",
                                  style: TextStyle(color: Colors.white)),
            ),
          ),
          if (widget.val == '2' &&
              widget.listFiles != null &&
              widget.listFiles!.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.listFiles!.length,
                itemBuilder: (context, index) {
                  final xFile = widget.listFiles![index];
                  return GestureDetector(
                    onTap: () {
                      viewFile = xFile.path;
                      currentIndex = index;
                      _initializeMedia();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentIndex == index
                              ? ColorConstant.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        image: isImageFile(xFile.path)
                            ? DecorationImage(
                                image: FileImage(File(xFile.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color:
                            isVideoFile(xFile.path) || isAudioFile(xFile.path)
                                ? Colors.grey[800]
                                : null,
                      ),
                      child: Center(
                        child: isVideoFile(xFile.path)
                            ? const Icon(Icons.videocam, color: Colors.white)
                            : isAudioFile(xFile.path)
                                ? const Icon(Icons.audiotrack,
                                    color: Colors.white)
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: ColorConstant.barGreen,
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _onSend,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendingMessage(String groupId, String messageData,
      String? filePath, bool isImageFile) async {
    sendMessageModel = await HttpService.sendMessage(
        groupId, messageData, filePath, isImageFile);
  }
}
