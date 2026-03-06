import 'package:flutter/material.dart';
import '../../../models/officialWhatsapp/chat_list_model.dart';
import '../colorConst.dart';

Widget chatListItem(context, ChatData items) {
  debugPrint('═══════════════════════════════════════════');
  debugPrint('🟢 BUILDING CHAT LIST ITEM');
  debugPrint('📱 Group Name: ${items.groupName}');
  debugPrint('🆔 Group ID: ${items.groupId}');
  debugPrint('🔢 Chat Type: ${items.chatType}');
  debugPrint('👤 From Me: ${items.fromMe}');
  debugPrint('📝 Last Message: ${items.lastMessage}');
  debugPrint('⏰ Last Message Time: ${items.lastMsgTime}');
  debugPrint('📊 Message Status: ${items.msgStatus}');
  debugPrint('🔔 Unread Count: ${items.unreadMessageCount}');
  debugPrint('🖼️ Profile Pic: ${items.profilePic}');
  return Column(
    children: [
      ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 5, right: 0.0),
        tileColor: Colors.white,
        leading: GestureDetector(
          onTap: () {},
          child: Stack(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(items.profilePic),
                    ),
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(30)),
              ),
              // Add transferred icon overlay if chatType is 2
              if (items.chatType == "2")
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_horiz, // Icon for transferred/forwarded chats
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                items.groupName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Add chat type indicator near the name
            // if (items.chatType == )
            //   Container(
            //     margin: const EdgeInsets.only(right: 8),
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //     decoration: BoxDecoration(
            //       color: Colors.blue.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: const Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.swap_horiz,
            //           color: Colors.blue,
            //           size: 12,
            //         ),
            //         SizedBox(width: 2),
            //         Text(
            //           'Transferred',
            //           style: TextStyle(
            //             color: Colors.blue,
            //             fontSize: 10,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),
        subtitle: Row(
          children: [
            items.fromMe == true
                ? items.msgStatus == 'send'
                    ? const Icon(
                        Icons.check,
                        color: ColorConstant.grey,
                        size: 18,
                      )
                    : items.msgStatus == 'delivered'
                        ? const Icon(
                            Icons.done_all_sharp,
                            color: ColorConstant.grey,
                            size: 18,
                          )
                        : items.msgStatus == 'read'
                            ? const Icon(
                                Icons.done_all_sharp,
                                color: ColorConstant.messageSeen,
                                size: 18,
                              )
                            : items.msgStatus == 'failed'
                                ? const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: ColorConstant.grey,
                                    size: 18,
                                  )
                : const SizedBox(),
            const SizedBox(
              width: 5,
            ),
            // Add transferred icon in message preview
            if (items.chatType == 2)
              const Icon(
                Icons.swap_horiz,
                color: Colors.blue,
                size: 14,
              ),
            if (items.chatType == 2) const SizedBox(width: 3),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  items.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                items.lastMsgTime,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
              const SizedBox(
                height: 4,
              ),
              if (items.unreadMessageCount != 0)
                CircleAvatar(
                  radius: 8,
                  backgroundColor: ColorConstant.barGreen,
                  child: Center(
                      child: Text(
                    items.unreadMessageCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  )),
                )
            ],
          ),
        ),
      ),
    ],
  );
}
