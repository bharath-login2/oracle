import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';

import '../../models/commonConfigureModel.dart';
import '../../models/contactGroup/contactFGroupModel.dart';
import '../../screens/homePage.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../screens/whatsAppGroup/addContactGroup.dart';
import '../../screens/whatsAppGroup/groupDetails.dart';
import '../../service/service.dart';

import '../../widgets/singleGroupWidget.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupList extends StatefulWidget {
  String? token;
  GroupList(this.token);

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  ContactGroupModel? contactGroup;
  CommonConfigureModel? configure;
  bool? result = true;
  bool? result1 = true;
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        result = true;
      });
    } else {
      setState(() {
        result = false;
      });
    }
    contactGroup = await HttpService.contactGroup(widget.token);
    if (contactGroup != null) {
      setState(() {

      });
    }
    configure = await HttpService.configure(widget.token);
    if(configure!=null)
    {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => HomePage(widget.token)));
        return true;
      },
      child:result == true
          ?Scaffold(
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, top: 10.0, bottom: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => HomePage(widget.token)));
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        'Whatsapp Group',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WhatsappSettings(
                                    widget.token)),
                      );
                    },
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: Padding(
                        padding:
                        const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/icons/settings.png",
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: contactGroup!=null && configure!=null?
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
          ),
          child:contactGroup!.data!.isConfigured==true? Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
              child: configure!.data!.isExpired==false?
              SizedBox(
                child: contactGroup!.data!.listGroup!.isNotEmpty?
                ListView.builder(
                  itemCount: contactGroup!.data!.listGroup!.length,
                  itemBuilder: (context, i) => Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetails(
                                  widget.token,
                                  contactGroup!.data!.listGroup![i].name,contactGroup!.data!.listGroup![i].image.toString(),
                                  contactGroup!.data!.listGroup![i].id.toString()
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            contactGroup!.data!.listGroup![i].image.toString(),
                          ),
                          radius: 26,

                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              contactGroup!.data!.listGroup![i].name.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              contactGroup!.data!.listGroup![i].timePost.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [

                                Icon(
                                  Icons.done_all,
                                  size: 18,
                                  color: Colors.blue[600],
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    contactGroup!.data!.listGroup![i].lastMessage.toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 70,
                        endIndent: 20,
                      ),
                    ],
                  ),
                ):
                SizedBox(
                  width: MediaQuery.of(
                      context)
                      .size
                      .width *1,
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          "assets/icons/nodatafound.png",
                        ),
                      ),
                      const Text(
                        'Result Not Found',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Whoops... this information is \n not available for a moment',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => HomePage(widget.token)));
                        },
                        child: Container(
                          width: MediaQuery.of(context)
                              .size
                              .width *
                              0.4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Go Back',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w500)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ):
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .center,
                  children: [
                    Container(
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(8),
                        color: Colors.grey,
                      ),

                      child: Padding(
                        padding:
                        const EdgeInsets
                            .all(0.1),
                        child: Card(
                          // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                8),
                          ),
                          // Set the clip behavior of the card
                          clipBehavior: Clip
                              .antiAliasWithSaveLayer,
                          // Define the child widgets of the card
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: <
                                Widget>[
                              // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                              Image.asset(
                                'assets/main/packageimage.png',
                                height: 160,
                                width: double
                                    .infinity,
                                fit: BoxFit
                                    .cover,
                              ),
                              // Add a container with padding that contains the card's title, text, and buttons
                              Container(
                                padding:
                                const EdgeInsets
                                    .fromLTRB(
                                    15,
                                    15,
                                    15,
                                    0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center,
                                  children: <
                                      Widget>[
                                    const Text(
                                      'Package Expired..',
                                      style:
                                      TextStyle(
                                        fontSize:
                                        18,
                                        color:
                                        Colors.red,
                                      ),
                                    ),

                                    // Add a row with two buttons spaced apart and aligned to the right side of the card
                                    Row(
                                      children: <
                                          Widget>[
                                        // Add a spacer to push the buttons to the right side of the card
                                        const Spacer(),
                                        // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                        // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                        TextButton(
                                          child:
                                          const Text(
                                            "UPGRADE",
                                          ),
                                          onPressed:
                                              () {
                                            _upgrade(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Add a small space between the card and the next widget
                              Container(
                                  height: 5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ):Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              crossAxisAlignment:
              CrossAxisAlignment
                  .center,
              children: [
                Container(
                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius
                        .circular(8),
                    color: Colors.grey,
                  ),

                  child: Padding(
                    padding:
                    const EdgeInsets
                        .all(0.1),
                    child: Card(
                      // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            8),
                      ),
                      // Set the clip behavior of the card
                      clipBehavior: Clip
                          .antiAliasWithSaveLayer,
                      // Define the child widgets of the card
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: <
                            Widget>[
                          // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                          Image.asset(
                            'assets/main/packageimage.png',
                            height: 160,
                            width: double
                                .infinity,
                            fit: BoxFit
                                .cover,
                          ),
                          // Add a container with padding that contains the card's title, text, and buttons
                          Container(
                            padding:
                            const EdgeInsets
                                .fromLTRB(
                                15,
                                15,
                                15,
                                0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <
                                  Widget>[
                                const Text(
                                  'Configuration Failed',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    18,
                                    color:
                                    Colors.red,
                                  ),
                                ),

                                // Add a row with two buttons spaced apart and aligned to the right side of the card
                                Row(
                                  children: <
                                      Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      child:
                                      const Text(
                                        "Settings",
                                      ),
                                      onPressed:
                                          () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WhatsappSettings(
                                                      widget.token)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Add a small space between the card and the next widget
                          Container(
                              height: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ):
        Center(
          child: Lottie.asset('assets/main/loading.json',
              fit: BoxFit.fill),
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.endDocked,
        floatingActionButton:  configure!=null&&contactGroup!=null&&contactGroup!.data!.isConfigured==true?Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: configure!.data!.isExpired==false?FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddContactGroup(widget.token)),
                );
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ), //icon inside button
            ):const SizedBox()
        ):const Center(
          child: SizedBox(),
        ),):
      Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/noNetwork.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Text(
                  'No Network Found !',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    getData();
                  },
                  child: SizedBox(
                    width: 120,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            'Try Again',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
  void _upgrade(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Upgrade Package !!!'),
            content: const Text('Please contact the support team to upgrade your current plan'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
              TextButton(
                  onPressed: () async {
                    String url = 'tel:${configure!.data!.supportTeamNumber}';
                    await launch(url);
                  },
                  child: const Text('Call'))
            ],
          );
        });
  }
}
