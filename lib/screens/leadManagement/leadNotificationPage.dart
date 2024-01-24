import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/lead_management/leadNotificationListModel.dart';
import '../../models/lead_management/readLeadNotificationModel.dart';
import '../../service/service.dart';
import 'dashboard.dart';
import 'leadDetails.dart';

class LeadNotificationPage extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  LeadNotificationPage(this.token,this.editLead,this.deleteLead,this.cloudCall,{Key? key}) : super(key: key);
  @override
  State<LeadNotificationPage> createState() => _LeadNotificationPageState();
}

class _LeadNotificationPageState extends State<LeadNotificationPage> {
  LeadNotificationListModel? leadNotification;
  bool result = true;

  @override
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

    leadNotification = await HttpService.leadNotificationList(widget.token);
    if (leadNotification != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard(widget.token)),
        );
        return true;
      },
          child: Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
                child: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Dashboard(widget.token)),
                                );
                              },
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
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
                              'Notification',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: leadNotification != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: leadNotification!.data!.isNotEmpty?
                      ListView.builder(
                        itemCount: leadNotification!.data!.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InkWell(
                              onTap: () async {
                                if(leadNotification!.data![i].isRead==false){
                                  ReadLeadNotificationModel? readLeadNotification = await HttpService.readLeadNotification(widget.token,
                                      leadNotification!.data![i].notificationId);}
                                if(mounted){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LeadDetails(
                                            widget.token!,
                                            widget.editLead,
                                            widget.deleteLead,
                                            widget.cloudCall,leadNotification!.data![i].leadMasterId.toString(),
                                            pageName: 'LeadNotification',)),
                                  );
                                }

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(leadNotification!.data![i].title.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      Text(leadNotification!.data![i].dateTime.toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade400)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width *
                                            0.7,
                                        child:  Text(
                                            leadNotification!.data![i].content.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      leadNotification!.data![i].isRead==false?
                                      Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          color: Colors.red,
                                        ),
                                        child: const Center(
                                            child: Text(
                                          "1",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.white),
                                        )),
                                      ):const SizedBox(),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      height: 1,
                                      decoration: const BoxDecoration(
                                          color: Color(0xffe8e6ea))),
                                ],
                              ),
                            ),
                          );
                        },
                      ):SizedBox(
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
                                  image: AssetImage('assets/icons/no_alarm.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Text(
                              'No Notification Found !',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      )
              )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    )),
        )
        : Scaffold(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            ));
  }
}
