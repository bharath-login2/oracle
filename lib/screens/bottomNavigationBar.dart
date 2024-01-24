import '../../screens/homePage.dart';
import '../../screens/leadManagement/addLeads.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  String token;
  bool? whatsappConfigaure;

  BottomNavigation(this.token, this.whatsappConfigaure, {super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 55,
      //bottom navigation bar on scaffold
      color: const Color(0xFF406dbe),
      shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)))),
      //shape of notch

      //notche margin between floating button and bottom appbar
      child: Row(
        //children inside bottom appbar
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => HomePage(widget.token)),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddLeads(widget.token, page: 'NavigationBar'),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                widget.whatsappConfigaure == true
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupList(widget.token),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhatsappSettings(widget.token),
                        ),
                      );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: Image.asset(
                  "assets/main/whatsappIcon.png",
                  width: 21,
                  height: 21,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewUsers(widget.token),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
