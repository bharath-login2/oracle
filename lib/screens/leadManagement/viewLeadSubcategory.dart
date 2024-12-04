import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login2/models/lead_management/viewLeadSubCategoryModel.dart';
import 'package:login2/screens/leadManagement/viewLeadCategory.dart';
import 'package:lottie/lottie.dart';

import '../../core/common.dart';
import '../../models/lead_management/addLeadSubCategoryModel.dart';
import '../../models/lead_management/editLeadSubCategoryModel.dart';
import '../../models/lead_management/leadSubCategoryDeleteModel.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';

import 'package:flutter/material.dart';

import '../../widgets/inputTextFeildWidget.dart';

// ignore: must_be_immutable
class ViewLeadSubCategory extends StatefulWidget {
  String token;
  bool createLeads;
  bool updateLeads;
  bool deleteLeads;
  String categoryId;
  ViewLeadSubCategory(this.token, this.createLeads, this.updateLeads,
      this.deleteLeads, this.categoryId,
      {super.key});
  @override
  State<ViewLeadSubCategory> createState() => _ViewLeadSubCategoryState();
}

class _ViewLeadSubCategoryState extends State<ViewLeadSubCategory> {
  bool? result = true;
  bool? result1 = true;
  ViewLeadSubCategoryModel? viewSubLeadsCategory;
  TextEditingController subcategory = TextEditingController();
  TextEditingController subcategoryEdit = TextEditingController();
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
    viewSubLeadsCategory =
        await HttpService.viewLeadsSubCategory(widget.token, widget.categoryId);
    if (viewSubLeadsCategory != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          getData();
          return;
        },
        child: result == true
            ? Scaffold(
                backgroundColor: Colors.grey.shade200,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.08),
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
                                'Lead Sub Category',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                          widget.createLeads == true
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      showGeneralDialog(
                                        barrierLabel: "showGeneralDialog",
                                        barrierDismissible: true,
                                        barrierColor:
                                            Colors.black.withOpacity(0.6),
                                        transitionDuration:
                                            const Duration(milliseconds: 400),
                                        context: context,
                                        pageBuilder: (context, _, __) {
                                          return Align(
                                            alignment: Alignment.center,
                                            child: IntrinsicHeight(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Container(
                                                  width: double.maxFinite,
                                                  clipBehavior: Clip.antiAlias,
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Material(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 20),
                                                        const Text(
                                                          'Add Lead Sub Category',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        InputTextField(
                                                          hintText:
                                                              'Lead Sub Category',
                                                          hintTextColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.white,
                                                          controller:
                                                              subcategory,
                                                          width: 1,
                                                          iconData: Icons
                                                              .playlist_add_check_circle_outlined,
                                                        ),
                                                        const SizedBox(
                                                          height: 25,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          width:
                                                              double.maxFinite,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF3375e0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                          child:
                                                              RawMaterialButton(
                                                            onPressed:
                                                                () async {
                                                              if (subcategory
                                                                  .text
                                                                  .isEmpty) {
                                                                Common.toastMessaage(
                                                                    'Sub Category Name cannot be empty',
                                                                    Colors.red);
                                                              } else {
                                                                Common.showProgressDialog(
                                                                    context,
                                                                    "Loading..");
                                                                AddLeadSubCategoryModel
                                                                    addCategory =
                                                                    await HttpService.addLeadSubCategory(
                                                                        widget
                                                                            .token,
                                                                        subcategory
                                                                            .text,
                                                                        widget
                                                                            .categoryId);
                                                                if (addCategory
                                                                        .data ==
                                                                    true) {
                                                                  Common.toastMessaage(
                                                                      addCategory
                                                                          .message,
                                                                      Colors
                                                                          .green);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                    getData();
                                                                  }
                                                                } else {
                                                                  Common.toastMessaage(
                                                                      addCategory
                                                                          .message,
                                                                      Colors
                                                                          .red);
                                                                  if (context
                                                                      .mounted) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                }
                                                              }
                                                            },
                                                            child: const Center(
                                                              child: Text(
                                                                'Continue',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        transitionBuilder:
                                            (_, animation1, __, child) {
                                          return SlideTransition(
                                            position: Tween(
                                              begin: const Offset(0, 1),
                                              end: const Offset(0, 0),
                                            ).animate(animation1),
                                            child: child,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .2,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: const Color(0xFFd5f5f4),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(6))),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Color(0xFF3c9f9a),
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Add',
                                              style: TextStyle(
                                                  color: Color(0xFF3c9f9a)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
                body: viewSubLeadsCategory != null
                    ? Container(
                        child: viewSubLeadsCategory!.data!.isNotEmpty
                            ? ListView.separated(
                                itemCount: viewSubLeadsCategory!.data!.length,
                                separatorBuilder: (_, __) => const Divider(
                                      height: 0,
                                    ),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: SizedBox(
                                        height: 60,
                                        child: Center(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                viewSubLeadsCategory!
                                                    .data![index]
                                                    .leadSubCategory
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            Row(
                                              children: [
                                                widget.updateLeads == true
                                                    ? InkWell(
                                                        onTap: () {
                                                          subcategoryEdit.text =
                                                              viewSubLeadsCategory!
                                                                  .data![index]
                                                                  .leadSubCategory
                                                                  .toString();
                                                          showGeneralDialog(
                                                            barrierLabel:
                                                                "showGeneralDialog",
                                                            barrierDismissible:
                                                                true,
                                                            barrierColor: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.6),
                                                            transitionDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        400),
                                                            context: context,
                                                            pageBuilder:
                                                                (context, _,
                                                                    __) {
                                                              return Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    IntrinsicHeight(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .maxFinite,
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(10),
                                                                          topRight:
                                                                              Radius.circular(10),
                                                                          bottomRight:
                                                                              Radius.circular(10),
                                                                          bottomLeft:
                                                                              Radius.circular(10),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Material(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            const SizedBox(height: 20),
                                                                            const Text(
                                                                              'Edit Lead Sub Category',
                                                                              style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 20),
                                                                            InputTextField(
                                                                              hintText: 'Lead Category',
                                                                              hintTextColor: Colors.white,
                                                                              backgroundColor: Colors.white,
                                                                              controller: subcategoryEdit,
                                                                              width: 1,
                                                                              iconData: Icons.playlist_add_check_circle_outlined,
                                                                              obscureText: true,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 25,
                                                                            ),
                                                                            Container(
                                                                              height: 40,
                                                                              width: double.maxFinite,
                                                                              decoration: const BoxDecoration(
                                                                                color: Color(0xFF3375e0),
                                                                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                              ),
                                                                              child: RawMaterialButton(
                                                                                onPressed: () async {
                                                                                  if (subcategoryEdit.text.isEmpty) {
                                                                                    Common.toastMessaage('Sub Category Name cannot be empty', Colors.red);
                                                                                  } else {
                                                                                    Common.showProgressDialog(context, "Loading..");
                                                                                    EditLeadSubCategoryModel editSubCategory = await HttpService.editLeadSubCategory(widget.token, subcategoryEdit.text, viewSubLeadsCategory!.data![index].leadSubCategoryId);
                                                                                    if (editSubCategory.data == true) {
                                                                                      Common.toastMessaage(editSubCategory.message, Colors.green);
                                                                                      if (context.mounted) {
                                                                                        getData();
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    } else {
                                                                                      Common.toastMessaage(editSubCategory.message, Colors.red);
                                                                                      if (context.mounted) {
                                                                                        Navigator.of(context).pop();
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: const Center(
                                                                                  child: Text(
                                                                                    'Continue',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            transitionBuilder:
                                                                (_, animation1,
                                                                    __, child) {
                                                              return SlideTransition(
                                                                position: Tween(
                                                                  begin:
                                                                      const Offset(
                                                                          0, 1),
                                                                  end:
                                                                      const Offset(
                                                                          0, 0),
                                                                ).animate(
                                                                    animation1),
                                                                child: child,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              Colors.blueAccent,
                                                        ))
                                                    : const SizedBox(),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                widget.deleteLeads == true
                                                    ? InkWell(
                                                        onTap: () {
                                                          _deleteSubCategory(
                                                              context,
                                                              viewSubLeadsCategory!
                                                                  .data![index]
                                                                  .leadSubCategoryId);
                                                        },
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ))
                                                    : const SizedBox(),
                                              ],
                                            )
                                          ],
                                        ))),
                                  );
                                })
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 1,
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      )
                    : Center(
                        child: Lottie.asset('assets/main/loading.json',
                            fit: BoxFit.fill),
                      ))
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
                )));
  }

  void _deleteSubCategory(BuildContext context, categoryId) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    LeadSubCategoryDeleteModel deleteCategory =
                        await HttpService.deleteLeadSubCategory(
                            widget.token, categoryId);
                    if (deleteCategory.data == true) {
                      Common.toastMessaage(
                          deleteCategory.message, Colors.green);
                      if (context.mounted) {
                        getData();
                        Navigator.pop(ctx);
                      }
                    } else {
                      Common.toastMessaage(deleteCategory.message, Colors.red);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }
}
