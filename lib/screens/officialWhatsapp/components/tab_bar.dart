import 'package:flutter/material.dart';

import '../colorConst.dart';


Widget tabbar() {
  return Container(
    color:ColorConstant.barGreen,
    child: const TabBar(
      indicatorSize: TabBarIndicatorSize.tab,
    indicatorColor: Colors.white,

      dividerColor: Colors.white,
      dividerHeight: 0,
      labelColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelColor: Colors.white70,

      tabs: [
        Tab(
          text: 'Chats',
        ),
        Tab(
          text: 'Campaign',
        ),
      ],
    ),

  );
}