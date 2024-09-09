import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/leadDetailsModel.dart';
import 'package:login2/service/service.dart';

class RenewalDetails extends StatefulWidget {
  const RenewalDetails({super.key});

  @override
  State<RenewalDetails> createState() => _RenewalDetailsState();
}

class _RenewalDetailsState extends State<RenewalDetails> {
  LeadDeatailsModel? leadDetails;
  String token = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    // setState(() {
    //   timeOut = false;
    // });
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // setState(() {
        //   result = true;
        // });
      } else {
        // setState(() {
        //   result = false;
        // });
      }

      token = await Common.getSharedPref("token");
      leadDetails = await HttpService.leadDetails(token, "718042");
      if (leadDetails != null) {
        setState(() {});
      } else {
        // setState(() {
        //   timeOut = true;
        // });
      }
    } catch (e) {
      // log(e.toString());
      // setState(() {
      //   timeOut = true;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const Text(
                      'Renewal Details',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: leadDetails!.data!.priorityId == '1'
                                    ? Colors.grey
                                    : leadDetails!.data!.priorityId == '2'
                                        ? Colors.green
                                        : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: 170,
                              //width: MediaQuery.of(context).size.width * 0.1,
                              child: Text(
                                leadDetails!.data!.clientName.toString(),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      leadDetails!.data!.contactNumber1.toString(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 220,
                          child: Text(
                            'Assigned to : ${leadDetails!.data!.staffName}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        //   Container(
                        //     decoration: BoxDecoration(
                        //         color: _colors[int.parse(
                        //             leadDetails!.data!
                        //                 .callResultId
                        //                 .toString())],
                        //         borderRadius:
                        //             BorderRadius.circular(
                        //                 5)),
                        //     child: Padding(
                        //       padding:
                        //           const EdgeInsets.only(
                        //               left: 5,
                        //               right: 5,
                        //               top: 2,
                        //               bottom: 2),
                        //       child: Text(
                        //         leadDetails!
                        //             .data!.callResult
                        //             .toString(),
                        //         style: const TextStyle(
                        //             fontSize: 13,
                        //             color: Colors.white,
                        //             fontWeight:
                        //                 FontWeight.w500),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Created date: ${leadDetails!.data!.createdDate}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                        ),
                        leadDetails!.data!.address.toString() != ''
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      leadDetails!.data!.address.toString(),
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
