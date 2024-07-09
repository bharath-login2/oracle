import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/chatHomeScreen.dart';
import '../../../models/officialWhatsapp/campaignsListModel.dart';
import '../../../service/service.dart';
import 'campaignsBubble.dart';
import 'chat_list_item.dart';

const ChatHomeScreen homeScreen = ChatHomeScreen();

Widget campaignsComponent(campaignsListModel) {

  return StatefulBuilder(
      builder: (context,setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: RefreshIndicator(
            onRefresh: ()async{
              await Future.delayed(const Duration(milliseconds: 200));
              CampaignsListModel? campaignsListModel = await HttpService.fetchCampaignsList('');
              if (campaignsListModel != null) {

                setState(() {

                });
              }
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount:campaignsListModel.data.length,
              itemBuilder: (context, index) {
                return campaignsBubble(context,campaignsListModel.data[index]);
              },),
          ),
        );
      }
  );
}



