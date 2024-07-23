import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/officialWhatsapp/ChatListModel.dart';
import '../chatScreen.dart';
import '../colorConst.dart';

Widget chatListItem(context, ChatData items) {
  return Column(
    children: [
      ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 5, right: 0.0),
        tileColor: Colors.white,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  groupId: items.groupId,
                  nav: "",
                ),
              ));
        },
        leading: GestureDetector(
          onTap: () {},
          child: Container(
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
        ),
        title: Text(
          items.groupName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  items.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              items.lastMsgTime,
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    ],
  );
}
