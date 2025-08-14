import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/workMessageModel.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/service/service.dart';

class ChatScreenWork extends StatefulWidget {
  final String groupId;
  final String nav;
  final String assignedTo;
  final String project;
  final String assignedToId;

  const ChatScreenWork({
    super.key,
    required this.groupId,
    required this.nav,
    required this.assignedTo,
    required this.project,
    required this.assignedToId,
  });

  @override
  State<ChatScreenWork> createState() => _ChatScreenWorkState();
}

class _ChatScreenWorkState extends State<ChatScreenWork> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  Timer? _timer;
  String currentUserId = '';
  bool _showEmojiPicker = false;
  bool _sendWhatsappMessage = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchMessages();
    _startPolling();
    _startReading();
  }

  void _loadUserId() async {
    final uid = await Common.getSharedPref('user_id');
    setState(() {
      currentUserId = uid ?? '';
    });
  }

  void _startPolling() {
    _timer =
        Timer.periodic(const Duration(seconds: 2), (_) => _fetchMessages());
  }

  void _startReading() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _markRead());
  }

  Future<void> _fetchMessages() async {
    final result = await HttpService.getWorkChatMessages(widget.groupId);
    if (result != null && mounted) {
      setState(() {
        _messages = result.data;
      });
    }
  }

  Future<void> _markRead() async {
    final result = await HttpService.markRead(widget.groupId);
    if (result != null && mounted) {
      setState(() {
        _messages = result.data;
      });
    }
  }

  void _sendMessage() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) return;

    final whatsappMessage = _sendWhatsappMessage ? '1' : '0';

    final success = await HttpService.sendWorkChatMessage(
      widget.groupId,
      msg,
      widget.assignedToId,
      whatsappMessage: whatsappMessage,
    );

    if (success) {
      _messageController.clear();
      _fetchMessages();
    } else {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to send message")),
      );
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void _insertEmoji(Emoji emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.code,
    );
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.code.length,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildMyMessageBubble(Message msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 179, 231, 205),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg.message,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 10, 10, 10),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateTime(msg.createdAt.toString()),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(179, 12, 12, 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    msg.isRead == 'Y'
                        ? const Icon(Icons.done_all,
                            size: 14, color: Color.fromARGB(255, 12, 192, 12))
                        : const Icon(Icons.done,
                            size: 14, color: Color.fromARGB(179, 14, 14, 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessageBubble(Message msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.sendBy,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(msg.createdAt.toString()),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime =
          DateTime.parse(dateTimeString.replaceFirst(RegExp(r':\d+$'), ''));
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day-$month-$year $hour:$minute';
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Chat'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignReport(
                      preselectedWorkId:widget.groupId,
                      workId: widget.groupId,
                      sectionId: ""),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chat for Project:"${widget.project}" with ${widget.assignedTo}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                if (msg.added == "isme") {
                  return _buildMyMessageBubble(msg);
                } else {
                  return _buildOtherMessageBubble(msg);
                }
              },
            ),
          ),

          const Divider(height: 1),
          // CheckboxListTile(
          //   value: _sendWhatsappMessage,
          //   onChanged: (value) {
          //     setState(() {
          //       _sendWhatsappMessage = value ?? false;
          //     });
          //   },
          //   title: const Text('Also send via WhatsApp'),
          //   controlAffinity: ListTileControlAffinity.leading,
          //   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          //   dense: true,
          // ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _sendWhatsappMessage = !_sendWhatsappMessage;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Image.asset(
                              'assets/icons/whatsapp_white.png',
                              color: _sendWhatsappMessage
                                  ? Colors.green
                                  : Colors.grey,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
