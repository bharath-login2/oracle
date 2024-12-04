import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/screens/userManagement/branches.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/userManagement/viewStaffModel.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/userManagement/addDesignationPage.dart';
import '../../screens/userManagement/addUserManagement.dart';
import '../../screens/userManagement/designationList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ViewUsers extends StatefulWidget {
  String? token;
  ViewUsers(this.token, {super.key});
  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  ViewStaffModel? viewStaff;
  CommonConfigureModel? configure;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool? result = true;
  bool? result1 = true;
  String name = '';
  String role = '';
  String roleId = '';
  String? createStaffPermission;
  String? viewStaffPermission;
  String? updateStaffPermission;
  String? deleteStaffPermission;
  String? viewStaffReportPermission;
  String? createStaffDesignationPermission;
  String? viewStaffDesignationPermission;
  String? updateStaffDesignationPermission;
  String? deleteStaffDesignationPermission;
  String? updateStaffPasswordPermission;
  String phoneCallLogPermission = '';
  String multiBranch = '';
  String userId = '';
  List<StaffList> filteredStaffs = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    roleId = await Common.getSharedPref("roleId");
    userId = await Common.getSharedPref("userId");
    multiBranch = await Common.getSharedPref("multiBranch");
    createStaffPermission = await Common.getSharedPref("createStaffPermission");
    viewStaffPermission = await Common.getSharedPref("viewStaffPermission");
    updateStaffPermission = await Common.getSharedPref("updateStaffPermission");
    deleteStaffPermission = await Common.getSharedPref("deleteStaffPermission");
    viewStaffReportPermission =
        await Common.getSharedPref("viewStaffReportPermission");
    createStaffDesignationPermission =
        await Common.getSharedPref("createStaffDesignationPermission");
    viewStaffDesignationPermission =
        await Common.getSharedPref("viewStaffDesignationPermission");
    updateStaffDesignationPermission =
        await Common.getSharedPref("updateStaffDesignationPermission");
    deleteStaffDesignationPermission =
        await Common.getSharedPref("deleteStaffDesignationPermission");
    updateStaffPasswordPermission =
        await Common.getSharedPref("updateStaffPasswordPermission");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");

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

    viewStaff = await HttpService.viewStaffs(widget.token);
    if (viewStaff != null) {
      filteredStaffs.clear();
      filteredStaffs.addAll(viewStaff!.data!.staffList!);
      setState(() {});
      configure = await HttpService.configure(widget.token);
      if (configure != null) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        getData();
        return;
      },
      child: result == true
          ? Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.grey.shade200,
              appBar: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
                child: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, top: 10.0, bottom: 10.0, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => logout(context),
                              child: Container(
                                width: 43,
                                height: 43,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        color: Colors.grey.shade800,
                                        offset: const Offset(0, 2.0),
                                      )
                                    ],
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF2191ce)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    "assets/icons/user.png",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  role,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                            child:
                                Image.asset("assets/icons/menu.png", width: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: viewStaff != null && configure != null
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .8,
                                  child: TextField(
                                    autocorrect: false,
                                    keyboardType: TextInputType.visiblePassword,
                                    onChanged: (value) {
                                      setState(() {
                                        filteredStaffs = viewStaff!
                                            .data!.staffList!
                                            .where((item) => item.name!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(8),
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      hintText: 'search',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide
                                            .none, // Set the border color to none
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                configure!.data!.isExpired == false
                                    ? PopupMenuButton(
                                        // add icon, by default "3 dot" icon
                                        child: Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  color: Colors.grey.shade800,
                                                )
                                              ],
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/icons/settings.png",
                                            ),
                                          ),
                                        ),
                                        itemBuilder: (context) {
                                          return [
                                            const PopupMenuItem<int>(
                                                value: 1,
                                                child: Text('Add Designation')),
                                            const PopupMenuItem<int>(
                                                value: 2,
                                                child:
                                                    Text('List Designation')),
                                            const PopupMenuItem<int>(
                                                value: 3,
                                                child: Text('Add User')),
                                            if (multiBranch == 'true' &&
                                                roleId == "2")
                                              const PopupMenuItem<int>(
                                                  value: 4,
                                                  child: Text('Branches'))
                                          ];
                                        },
                                        onSelected: (value) {
                                          if (value == 1) {
                                            createStaffDesignationPermission ==
                                                    'true'
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddDesignationPage(
                                                                widget.token!)),
                                                  )
                                                : _permissionDialogue(context,
                                                    'Create Designation');
                                          } else if (value == 2) {
                                            viewStaffDesignationPermission ==
                                                    'true'
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DesignationList(
                                                                widget.token!)),
                                                  )
                                                : _permissionDialogue(context,
                                                    'Designation List');
                                          } else if (value == 3) {
                                            createStaffPermission == 'true'
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddUser(
                                                                widget.token!)),
                                                  ).then((r) {
                                                    getData();
                                                  })
                                                : _permissionDialogue(
                                                    context, 'Add User');
                                          } else if (value == 4) {
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Branches()))
                                                .then((r) {
                                              getData();
                                            });
                                          }
                                        })
                                    : const SizedBox()
                              ],
                            ),
                          ),
                          configure!.data!.isExpired == false
                              ? MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 30, left: 16.0, right: 16.0),
                                    child: filteredStaffs.isNotEmpty
                                        ? GridView.builder(
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 12,
                                                    mainAxisSpacing: 12,
                                                    childAspectRatio: 1.15),
                                            itemCount: filteredStaffs.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, i) {
                                              return InkWell(
                                                  onTap: () {
                                                    viewStaffReportPermission ==
                                                            'true'
                                                        ? Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) =>
                                                                StaffReportDashboard(
                                                                    id: filteredStaffs[
                                                                            i]
                                                                        .staffId
                                                                        .toString())))
                                                        : _permissionDialogue(
                                                            context,
                                                            'Staff Report');
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          offset:
                                                              Offset(2.0, 2.0),
                                                        )
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      maxHeight:
                                                                          60,
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      constraints:
                                                                          const BoxConstraints(
                                                                        minHeight:
                                                                            20,
                                                                        minWidth:
                                                                            20,
                                                                        maxHeight:
                                                                            50,
                                                                        maxWidth:
                                                                            50,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width: 0),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                              color: Colors.grey,
                                                                              blurRadius: 5,
                                                                              offset: Offset(1, 1)),
                                                                        ],
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        image: DecorationImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            image: NetworkImage(filteredStaffs[i].imageUrl.toString())),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                      child: SizedBox(
                                                                          width: 76,
                                                                          child: Center(
                                                                            child:
                                                                                Text(
                                                                              filteredStaffs[i].designation.toString(),
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ],
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
                                                                          left:
                                                                              10),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Text(
                                                                          filteredStaffs[i]
                                                                              .name
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w500),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            Text(
                                                                          filteredStaffs[i]
                                                                              .phoneNo
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.black54,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      filteredStaffs[i].branchName !=
                                                                              ''
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.only(bottom: 5),
                                                                              child: SizedBox(
                                                                                width: 150,
                                                                                child: Text(
                                                                                  'Branch:${filteredStaffs[i].branchName}',
                                                                                  style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        // Row(
                                                        //   mainAxisAlignment:
                                                        //       MainAxisAlignment.end,
                                                        //   children: [
                                                        //     Padding(
                                                        //       padding:
                                                        //           const EdgeInsets
                                                        //               .only(
                                                        //               right: 10),
                                                        //       child: InkWell(
                                                        //         onTap: () {
                                                        //           updateStaffPermission ==
                                                        //                       'false' ||
                                                        //                   viewStaff!
                                                        //                           .data!
                                                        //                           .staffList![
                                                        //                               i]
                                                        //                           .editPermission ==
                                                        //                       false
                                                        //               ? _permissionDialogue(
                                                        //                   context,
                                                        //                   'Edit User')
                                                        //               : Navigator.of(
                                                        //                       context)
                                                        //                   .push(MaterialPageRoute(
                                                        //                       builder: (context) => EditProfilePage(
                                                        //                             token: widget.token,
                                                        //                             staffId: viewStaff!.data!.staffList![i].staffId,
                                                        //                           )));
                                                        //         },
                                                        //         child: Container(
                                                        //             height: 30,
                                                        //             width: 30,
                                                        //             decoration: BoxDecoration(
                                                        //                 color: Colors
                                                        //                     .green
                                                        //                     .shade100,
                                                        //                 borderRadius:
                                                        //                     BorderRadius.circular(
                                                        //                         5)),
                                                        //             child:
                                                        //                 const Icon(
                                                        //               Icons.edit,
                                                        //               color: Colors
                                                        //                   .green,
                                                        //               size: 18,
                                                        //             )),
                                                        //       ),
                                                        //     ),
                                                        //     Padding(
                                                        //       padding:
                                                        //           const EdgeInsets
                                                        //               .only(
                                                        //               right: 10),
                                                        //       child: InkWell(
                                                        //         onTap: () {
                                                        //           deleteStaffPermission ==
                                                        //                       'true' &&
                                                        //                   viewStaff!
                                                        //                           .data!
                                                        //                           .staffList![
                                                        //                               i]
                                                        //                           .deletePermission ==
                                                        //                       true
                                                        //               ? deleteDialog(
                                                        //                   context,
                                                        //                   i)
                                                        //               : _permissionDialogue(
                                                        //                   context,
                                                        //                   'Delete User');
                                                        //         },
                                                        //         child: Container(
                                                        //             height: 30,
                                                        //             width: 30,
                                                        //             decoration: BoxDecoration(
                                                        //                 color: Colors
                                                        //                     .pink
                                                        //                     .shade100,
                                                        //                 borderRadius:
                                                        //                     BorderRadius.circular(
                                                        //                         5)),
                                                        //             child: const Icon(
                                                        //                 Icons
                                                        //                     .delete,
                                                        //                 color: Colors
                                                        //                     .red,
                                                        //                 size: 18)),
                                                        //       ),
                                                        //     ),
                                                        //     InkWell(
                                                        //       onTap: () {
                                                        //         updateStaffPasswordPermission ==
                                                        //                     'true' &&
                                                        //                 viewStaff!
                                                        //                         .data!
                                                        //                         .staffList![
                                                        //                             i]
                                                        //                         .changePasswordPermission ==
                                                        //                     true
                                                        //             ? Navigator
                                                        //                 .push(
                                                        //                 context,
                                                        //                 MaterialPageRoute(
                                                        //                     builder: (context) => ChangePassword(
                                                        //                         widget.token!,
                                                        //                         viewStaff!.data!.staffList![i].staffId.toString())),
                                                        //               )
                                                        //             : _permissionDialogue(
                                                        //                 context,
                                                        //                 'Change Password');
                                                        //       },
                                                        //       child: Container(
                                                        //           height: 30,
                                                        //           width: 30,
                                                        //           decoration: BoxDecoration(
                                                        //               color: Colors
                                                        //                   .lightBlueAccent
                                                        //                   .shade100,
                                                        //               borderRadius:
                                                        //                   BorderRadius
                                                        //                       .circular(
                                                        //                           5)),
                                                        //           child: const Icon(
                                                        //               Icons
                                                        //                   .vpn_key_outlined,
                                                        //               color: Colors
                                                        //                   .blueAccent,
                                                        //               size: 18)),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                          )
                                        : noResultWidget(
                                            context, "No search reults..!"),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.1),
                                          child: Card(
                                            // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            // Set the clip behavior of the card
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            // Define the child widgets of the card
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                                Image.asset(
                                                  'assets/main/packageimage.png',
                                                  height: 160,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                                // Add a container with padding that contains the card's title, text, and buttons
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 15, 15, 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      const Text(
                                                        'Package Expired..',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.red,
                                                        ),
                                                      ),

                                                      // Add a row with two buttons spaced apart and aligned to the right side of the card
                                                      Row(
                                                        children: <Widget>[
                                                          // Add a spacer to push the buttons to the right side of the card
                                                          const Spacer(),
                                                          // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                                          // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                                          TextButton(
                                                            child: const Text(
                                                              "UPGRADE",
                                                            ),
                                                            onPressed: () {
                                                              _upgrade(context);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Add a small space between the card and the next widget
                                                Container(height: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    ),
              endDrawer: DraweScreen(widget.token!),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(widget.token)),
                  );
                },
                child: Image.asset("assets/icons/menu.png",
                    width: 25), //icon inside button
              ),
              bottomNavigationBar: configure != null
                  ? BottomNavigation(
                      widget.token!,
                      phoneCallLogPermission: phoneCallLogPermission,
                      name: name,
                      userId: userId,
                    )
                  : const SizedBox())
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        //getData();
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

  void _permissionDialogue(BuildContext context, title) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: const Text(
                'You have no permission to access the feature please contact the support team'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }

  void _upgrade(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Upgrade Package !!!'),
            content: const Text(
                'Please contact the support team to upgrade your current plan'),
            actions: [
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

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Text(label));
  }
}
