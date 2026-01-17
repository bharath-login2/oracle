import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';

// ignore: must_be_immutable
class ImageViewScreenBottom extends StatefulWidget {
  final List<XFile>? listFiles; // Changed to List<XFile>
  final String? filePath;
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
  String? viewFile;
  bool isImage = true;
  int currentIndex = 0;
  TextEditingController messageController = TextEditingController();
  SendMesaageModel? sendMessageModel;

  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isSending = false;
  bool _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();

  //   if (widget.val == '1' && widget.filePath != null) {
  //     viewFile = widget.filePath;
  //   } else if (widget.val == '2' &&
  //       widget.listFiles != null &&
  //       widget.listFiles!.isNotEmpty) {
  //     viewFile = widget.listFiles![0].path;
  //   }

  //   _initializeMedia();
  // }
  @override
  void initState() {
    super.initState();
    if (widget.val == '1') {
      if (widget.filePath != null) {
        viewFile = widget.filePath;
      } else if (widget.listFiles != null && widget.listFiles!.isNotEmpty) {
        viewFile = widget.listFiles![0].path;
      }
    } else if (widget.val == '2' &&
        widget.listFiles != null &&
        widget.listFiles!.isNotEmpty) {
      viewFile = widget.listFiles![0].path;
    }

    if (viewFile != null) {
      _initializeMedia();
    }
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
        ext.endsWith('.gif') ||
        ext.endsWith('.bmp') ||
        ext.endsWith('.webp');
  }

  bool isVideoFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.avi') ||
        ext.endsWith('.mkv') ||
        ext.endsWith('.wmv') ||
        ext.endsWith('.flv') ||
        ext.endsWith('.3gp');
  }

  bool isAudioFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp3') ||
        ext.endsWith('.wav') ||
        ext.endsWith('.m4a') ||
        ext.endsWith('.aac') ||
        ext.endsWith('.ogg') ||
        ext.endsWith('.flac');
  }

  bool isDocumentFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.txt') ||
        ext.endsWith('.rtf') ||
        ext.endsWith('.odt') ||
        ext.endsWith('.xls') ||
        ext.endsWith('.xlsx') ||
        ext.endsWith('.ppt') ||
        ext.endsWith('.pptx');
  }

  String getFileTypeIcon(String path) {
    if (isImageFile(path)) return '📷';
    if (isVideoFile(path)) return '🎥';
    if (isAudioFile(path)) return '🎵';
    if (isDocumentFile(path)) return '📄';
    return '📁';
  }

  String getFileName(String path) {
    return path.split('/').last;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }



  void _onSend() async {
  if (_isSending) return;
  
  setState(() => _isSending = true);

  try {
    // Prepare files to send
    List<String> filePaths = [];

    // Check all possible cases for files
    if (widget.val == '1') {
      // Single file - check both filePath and listFiles
      if (widget.filePath != null && widget.filePath!.isNotEmpty) {
        filePaths.add(widget.filePath!);
        log('Single file from filePath: ${widget.filePath}');
      } else if (widget.listFiles != null && widget.listFiles!.isNotEmpty) {
        filePaths.add(widget.listFiles![0].path);
        log('Single file from listFiles: ${widget.listFiles![0].path}');
      } else if (viewFile != null && viewFile!.isNotEmpty) {
        // Fallback to current viewFile
        filePaths.add(viewFile!);
        log('Single file from viewFile: $viewFile');
      }
    } else if (widget.val == '2' && widget.listFiles != null && widget.listFiles!.isNotEmpty) {
      // Multiple files
      for (var file in widget.listFiles!) {
        if (file.path.isNotEmpty && File(file.path).existsSync()) {
          filePaths.add(file.path);
        }
      }
      log('Multiple files: ${filePaths.length}');
    }

    // Debug log
    log('Files to send: $filePaths');
    log('Message text: ${messageController.text}');

    if (filePaths.isEmpty && messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a file or add a message'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isSending = false);
      return;
    }

    // Determine if files are images
    bool filesAreImages = false;
    if (filePaths.isNotEmpty) {
      // Check if ALL files are images
      filesAreImages = filePaths.every((path) => isImageFile(path));
      log('Are all files images? $filesAreImages');
    }

    // Send message
    sendMessageModel = await HttpService.sendMessage(
      widget.groupId,
      messageController.text,
      filePaths,
      filesAreImages,
    );

    log('Send response: ${sendMessageModel?.toJson()}');

    if (sendMessageModel != null && sendMessageModel!.status == true) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sendMessageModel!.message ?? 'Message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Delay before popping to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      throw Exception(sendMessageModel?.message ?? 'Failed to send message');
    }
  } catch (e) {
    log('Error sending message: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSending = false);
    }
  }
}

  // void _onSend() async {
  //   if (_isSending) return;
  //   if (viewFile == null && messageController.text.isEmpty) return;

  //   setState(() => _isSending = true);

  //   try {
  //     // Prepare files to send
  //     List<String> filePaths = [];

  //     if (widget.val == '1' && widget.filePath != null) {
  //       filePaths.add(widget.filePath!);
  //     } else if (widget.val == '2' && widget.listFiles != null) {
  //       filePaths.addAll(widget.listFiles!.map((file) => file.path));
  //     }

  //     // Determine if files are images
  //     bool filesAreImages =
  //         filePaths.isNotEmpty && filePaths.every((path) => isImageFile(path));

  //     // Send message
  //     sendMessageModel = await HttpService.sendMessage(
  //       widget.groupId,
  //       messageController.text,
  //       filePaths,
  //       filesAreImages,
  //     );

  //     if (sendMessageModel != null && sendMessageModel!.status == true) {
  //       if (mounted) {
  //         Navigator.pop(context);
  //       }
  //     } else {
  //       throw Exception('Failed to send message');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to send: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isSending = false);
  //   }
  // }

  Widget _buildMediaPreview() {
    if (viewFile == null) {
      return const Center(
        child: Text(
          "No file selected",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    if (isImageFile(viewFile!)) {
      return InteractiveViewer(
        minScale: 0.1,
        maxScale: 5.0,
        child: Center(
          child: Image.file(
            File(viewFile!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 80, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      'Cannot load image\n${getFileName(viewFile!)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else if (isVideoFile(viewFile!)) {
      return _videoController != null && _videoController!.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        _videoController!.seekTo(Duration.zero);
                        _videoController!.play();
                      },
                    ),
                  ],
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            );
    } else if (isAudioFile(viewFile!)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.audiotrack, size: 100, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            getFileName(viewFile!),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _audioPlayer!.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () async {
                  if (_audioPlayer!.playing) {
                    await _audioPlayer!.pause();
                  } else {
                    await _audioPlayer!.play();
                  }
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white, size: 40),
                onPressed: () async {
                  await _audioPlayer!.stop();
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      );
    } else {
      // Document or other file type
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getFileTypeIcon(viewFile!),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              getFileName(viewFile!),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Preview not available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preview ${widget.val == '2' ? '(${widget.listFiles?.length ?? 0} files)' : ''}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (viewFile != null)
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('File Info'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${getFileName(viewFile!)}'),
                        const SizedBox(height: 5),
                        Text('Type: ${_getFileType(viewFile!)}'),
                        const SizedBox(height: 5),
                        Text(
                            'Path: ${viewFile!.substring(0, viewFile!.length > 50 ? 50 : viewFile!.length)}${viewFile!.length > 50 ? '...' : ''}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMediaPreview(),
          ),
          if (widget.val == '2' &&
              widget.listFiles != null &&
              widget.listFiles!.length > 1)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black87,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.listFiles!.length,
                itemBuilder: (context, index) {
                  final file = widget.listFiles![index];
                  final isSelected = index == currentIndex;

                  return GestureDetector(
                    onTap: () {
                      viewFile = file.path;
                      currentIndex = index;
                      _initializeMedia();
                      setState(() {});
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[900],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getFileTypeIcon(file.path),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              getFileName(file.path).length > 10
                                  ? '${getFileName(file.path).substring(0, 10)}...'
                                  : getFileName(file.path),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Add a message...',
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
                const SizedBox(width: 12),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : FloatingActionButton(
                        backgroundColor: ColorConstant.barGreen,
                        onPressed: _onSend,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFileType(String path) {
    if (isImageFile(path)) return 'Image';
    if (isVideoFile(path)) return 'Video';
    if (isAudioFile(path)) return 'Audio';
    if (isDocumentFile(path)) return 'Document';
    return 'Unknown';
  }
}
