import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/chatHomeScreen.dart';
import '../../../models/officialWhatsapp/ChatListModel.dart';
import '../../../service/service.dart';
import 'messageBubble.dart';

const ChatHomeScreen homeScreen = ChatHomeScreen();

Widget chatComponent(chatListModel) {

  return StatefulBuilder(
    builder: (context,setState) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: RefreshIndicator(
            onRefresh: ()async{
                await Future.delayed(const Duration(milliseconds: 200));
                ChatListModel? chatListModel = await HttpService.fetchChatList('');
                if (chatListModel != null) {

                  setState(() {

                  });
                }
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
                itemCount:chatListModel.data.length,
                itemBuilder: (context, index) {
                return messageBubble(context,chatListModel.data[index]);
              },),
          ),
          );
    }
  );
}



