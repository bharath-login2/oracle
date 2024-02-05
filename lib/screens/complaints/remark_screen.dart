// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:login2/models/complaints/details_model.dart';
import 'package:login2/models/complaints/post_remark_model.dart';
import 'package:login2/screens/complaints/complaint_update_screen.dart';
import 'package:login2/service/service.dart';

class RemarkScreen extends StatefulWidget {
  String compId;
  RemarkScreen({super.key, required this.compId});

  @override
  State<RemarkScreen> createState() => _RemarkScreenState();
}

class _RemarkScreenState extends State<RemarkScreen> {
  final TextEditingController remarksController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List status = [true, false, true, false, true, false, true];
  DetailsModel? getResponse;
  PostRemarkModel? remarkResponse;
  bool isLoading = true;
  bool sendLoading = false;

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    getResponse = await HttpService.getDetails(widget.compId);

    if (getResponse != null && getResponse!.status == true) {
      setState(() {
        isLoading = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  postRemarks() async {
    setState(() {
      sendLoading = true;
    });
    remarkResponse =
        await HttpService.postRemark(widget.compId, remarksController.text);

    if (remarkResponse != null && remarkResponse!.status == true) {
      await getDetails();
      setState(() {
        sendLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    } else {
      setState(() {
        sendLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remarks',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                               await getDetails();

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  scrollController.jumpTo(scrollController
                                      .position.maxScrollExtent);
                                });
                              },
                              child: const Icon(
                                Icons.replay_outlined,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(1, 1),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child:
                                    Text("Complaint No:${getResponse!.data.id}",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: const Color(0xfffcbcbc)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12, top: 6, bottom: 6),
                                    child:
                                        Text(getResponse!.data.complaintStatus,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            )),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.41,
                              child: Text(
                                "Incident Date : ${getResponse!.data.incidentDate}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.41,
                              child: Text(
                                "Complaint type :${List.generate(getResponse!.data.complaintType.length, (index) => getResponse!.data.complaintType[index].complaintType)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.41,
                              child: Text(
                                "Description : ${getResponse!.data.complaintDescription}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(getResponse!.data.incidentDate,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ComplaintUpdateScreen(
                                                    compId: widget.compId),
                                          ));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: const Color(0xffaedcf4)),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.mode_edit_outlined,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 75.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: getResponse!.data.remarksList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                                getResponse!.data.remarksList[index].isSent ==
                                        true
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: getResponse!.data
                                                .remarksList[index].isSent ==
                                            false
                                        ? const LinearGradient(colors: [
                                            Color(0xFF2a86c9),
                                            Color(0xFF406dbe)
                                          ])
                                        : const LinearGradient(colors: [
                                            Color.fromARGB(255, 189, 204, 233),
                                            Color.fromARGB(255, 166, 194, 212),
                                          ]),
                                  ),
                                  width: MediaQuery.of(context).size.width * .6,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              getResponse!.data
                                                  .remarksList[index].staffName,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .555,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Remark:  ${getResponse!.data.remarksList[index].receiverRemarks}"),
                                              Visibility(
                                                visible: getResponse!
                                                        .data
                                                        .remarksList[index]
                                                        .receiverName !=
                                                    "",
                                                child: Text(
                                                    "@${getResponse!.data.remarksList[index].receiverName}"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                getResponse!
                                                    .data
                                                    .remarksList[index]
                                                    .createdDate,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomSheet: Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, bottom: 16.0, top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: TextFormField(
                  controller: remarksController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(5),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelText: 'Remarks',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 6, 52, 47),
                child: sendLoading == true
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 5,
                      )
                    : IconButton(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        onPressed: () async {
                          if (remarksController.text.isNotEmpty) {
                            postRemarks();
                            remarksController.clear();
                          }
                        },
                        icon: const Icon(Icons.send)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
