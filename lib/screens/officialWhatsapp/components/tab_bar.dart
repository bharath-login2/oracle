import 'package:flutter/material.dart';

import '../colorConst.dart';

Widget tabbar() {
  return Container(
    color: ColorConstant.barGreen,
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
          icon: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat),
              SizedBox(
                width: 5,
              ),
              Text("Chats")
            ],
          ),
        ),
        Tab(
          icon: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups),
              SizedBox(
                width: 5,
              ),
              Text("Campaign")
            ],
          ),
        ),
      ],
    ),
  );
}
