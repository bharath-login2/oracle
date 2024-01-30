import 'package:flutter/material.dart';

import 'campaignsComponent.dart';
import 'chat_component.dart';


Widget tabbarView(chatListModel,campaignsListModel) {
  return Expanded(
    child: TabBarView(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: chatComponent(chatListModel),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,),
          child: campaignsComponent(campaignsListModel),
        ),
      ],
    ),
  );
}



