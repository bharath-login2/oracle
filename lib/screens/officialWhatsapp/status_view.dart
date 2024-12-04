import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/officialWhatsapp/message_view_status.dart';

// ignore: must_be_immutable
class MessageViewStatus extends StatefulWidget {
  String groupId;
  String messageId;
  MessageViewStatus(
      {super.key, required this.groupId, required this.messageId});

  @override
  State<MessageViewStatus> createState() => _MessageViewStatusState();
}

class _MessageViewStatusState extends State<MessageViewStatus> {
  MessageViewStatusModel? response;
  getData() async {
    response =
        await HttpService.viewMessageStatus(widget.groupId, widget.messageId);
    if (response != null && response!.status == true) {
    } else {
      Common.toastMessaage("Something went wrong", Colors.red);
    }
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.barGreen,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          "Campaign Status",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: response == null
          ? const LinearProgressIndicator(
              color: ColorConstant.barGreen,
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: response!.data.totalCounts.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 26),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  response!.data.totalCounts[index].status ==
                                          "sent"
                                      ? const Icon(Icons.check,
                                          color: Colors.grey)
                                      : response!.data.totalCounts[index]
                                                  .status ==
                                              "delivered"
                                          ? const Icon(
                                              Icons.done_all_sharp,
                                              color: Colors.grey,
                                            )
                                          : response!.data.totalCounts[index]
                                                      .status ==
                                                  "read"
                                              ? const Icon(
                                                  Icons.done_all_sharp,
                                                  color:
                                                      ColorConstant.messageSeen,
                                                )
                                              : response!
                                                          .data
                                                          .totalCounts[index]
                                                          .status ==
                                                      "pending"
                                                  ? const Icon(
                                                      Icons.access_time_rounded,
                                                      color: Colors.grey)
                                                  : const Icon(
                                                      Icons.priority_high,
                                                      color: Colors.red),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                      response!.data.totalCounts[index].status),
                                ],
                              ),
                              Text(response!.data.totalCounts[index].dataCount)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(
                    indent: 15,
                    endIndent: 15,
                    thickness: .5,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "CONTACTS",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: response!.data.contacts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListTile(
                            onTap: () async {
                              // final whatsappLink =
                              //     "https://wa.me/${widget.contacts![index].phoneNumber}";
                              // await launch(whatsappLink);
                            },
                            leading: const CircleAvatar(
                              backgroundColor: ColorConstant.barGreen,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title:
                                Text(response!.data.contacts[index].clientName),
                            subtitle:
                                Text(response!.data.contacts[index].phone),
                            trailing: Container(
                              decoration: BoxDecoration(
                                  color: response!
                                              .data.contacts[index].msgStatus ==
                                          "read"
                                      ? ColorConstant.messageSeen
                                      // : response!.data.contacts[index]
                                      //             .msgStatus ==
                                      //         "delivered"
                                      //     ? ColorConstant.barGreen
                                      : response!.data.contacts[index]
                                                  .msgStatus ==
                                              "failed"
                                          ? Colors.red
                                          : Colors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 8.0),
                                child: Text(
                                  response!.data.contacts[index].msgStatus,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            )),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}
