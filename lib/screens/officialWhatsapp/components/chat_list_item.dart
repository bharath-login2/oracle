import 'package:flutter/material.dart';

import '../chatScreen.dart';
import '../colorConst.dart';

Widget chatListItem(context, items) {
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
                ),
              ));
        },
        leading: Container(
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
                ? const Icon(
                    Icons.done_all,
                    size: 18,
                    color: ColorConstant.messageSeen,
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
