import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/userManagement/deleteStaffModel.dart';
import 'package:login2/models/userManagement/viewStaffModel.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/screens/userManagement/viewUsers.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffListScreen extends StatefulWidget {
  String token;
  StaffListScreen({super.key, required this.token});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  ViewStaffModel? viewStaff;
  bool isLoading = true;

  getData() async {
    setState(() {
      isLoading = true;
    });

    viewStaff =
        await HttpService.viewStaffs(await Common.getSharedPref("token"));
    if (viewStaff != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                          "Staff Reports",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
        body: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(color: Colors.grey),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: viewStaff!.data.staffList.isEmpty
                      ? const Center(
                          child: Text("No Staff"),
                        )
                      : ListView.builder(
                          itemCount: viewStaff!.data.staffList.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: const Key('0'),
                              background: Container(
                                color: Colors.green,
                                child: const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Call",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          title: const Text('Please Confirm'),
                                          content: const Text(
                                              'Are you sure to Delete?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('No')),
                                            TextButton(
                                                onPressed: () async {
                                                  DeleteStaffModel delete =
                                                      await HttpService
                                                          .deleteStaff(
                                                              viewStaff!
                                                                  .data
                                                                  .staffList[
                                                                      index]
                                                                  .staffId);
                                                  if (delete.data == true) {
                                                    Common.toastMessaage(
                                                        delete.message,
                                                        Colors.green);
                                                    if (mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewUsers(widget
                                                                    .token)),
                                                      );
                                                    }
                                                  } else {
                                                    Common.toastMessaage(
                                                        delete.message,
                                                        Colors.red);
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  }
                                                },
                                                child: const Text('Yes')),
                                          ],
                                        );
                                      });
                                } else {
                                  String url =
                                      'tel:${viewStaff!.data.staffList[index].phoneNo}';
                                  await launch(url);
                                }
                                return null;
                              },
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StaffReportDashboard(
                                                    id: viewStaff!
                                                        .data
                                                        .staffList[index]
                                                        .staffId
                                                        .toString())));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      width:
                                          MediaQuery.of(context).size.width * 1,
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxHeight: 60,
                                                      ),
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                          minHeight: 20,
                                                          minWidth: 20,
                                                          maxHeight: 50,
                                                          maxWidth: 50,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 0),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    1, 1)),
                                                          ],
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(
                                                                  viewStaff!
                                                                      .data
                                                                      .staffList[
                                                                          index]
                                                                      .imageUrl
                                                                      .toString())),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 150,
                                                                child: Text(
                                                                  viewStaff!
                                                                      .data
                                                                      .staffList[
                                                                          index]
                                                                      .name
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 150,
                                                                child: Text(
                                                                  viewStaff!
                                                                      .data
                                                                      .staffList[
                                                                          index]
                                                                      .phoneNo
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black54,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              viewStaff!
                                                                          .data
                                                                          .staffList[
                                                                              index]
                                                                          .branchName !=
                                                                      ''
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Text(
                                                                          'Branch:${viewStaff!.data.staffList[index].branchName}',
                                                                          style: const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.black54,
                                                                              fontWeight: FontWeight.w500),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                              SizedBox(
                                                                width: 150,
                                                                child: Text(
                                                                  viewStaff!
                                                                      .data
                                                                      .staffList[
                                                                          index]
                                                                      .email
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black54,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            right: 5,
                                                            top: 2,
                                                            bottom: 2),
                                                    child: SizedBox(
                                                        width: 76,
                                                        child: Center(
                                                          child: Text(
                                                            viewStaff!
                                                                .data
                                                                .staffList[
                                                                    index]
                                                                .designation
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                ),
              ));
  }
}
