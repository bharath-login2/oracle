// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/models/renewal/reminder_history_model.dart';
import 'package:login2/service/service.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ViewHistory extends StatefulWidget {
  String id;
  String title;
  ViewHistory({super.key, required this.id, required this.title});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  bool isLoading = true;
  ReminderHistoryModel? response;

  getHistory() async {
    setState(() {
      isLoading = true;
    });
    response = await HttpService.viewHistory(widget.id);
    if (response != null && response!.status == true) {
      setState(() {
        isLoading = false;
      });
    }{
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
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
                          Navigator.pop(context);
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
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.grey,
            ))
          : response!.data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset("assets/icons/nodatafound.png")),
                      const Text("No Reminders Yet")
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: response!.data.length,
                    shrinkWrap: true,
                    itemBuilder: ((context, index) {
                      return SizedBox(
                        child: TimelineTile(
                            isFirst: false,
                            isLast: index == response!.data.length - 1
                                ? true
                                : false,
                            beforeLineStyle:
                                const LineStyle(color: Colors.blue),
                            indicatorStyle: IndicatorStyle(
                                width: 20,
                                color: Colors.blue,
                                iconStyle: IconStyle(
                                    iconData: Icons.done, color: Colors.blue)),
                            endChild: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: const EdgeInsets.all(15),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0, bottom: 8.0),
                                          child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  response!.data[index]
                                                      .profileImage)),
                                        ),
                                        Text(
                                          response!.data[index].staffName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      response!.data[index].content,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          response!.data[index].createdAt,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      );
                    }),
                  ),
                ),
    );
  }
}
