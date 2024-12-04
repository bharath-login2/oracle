import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/complaints/add_item_model.dart';
import 'package:login2/models/complaints/get_model.dart';
import 'package:login2/models/complaints/post_model.dart';
import 'package:login2/screens/complaints/complaint_list_screen.dart';
import 'package:login2/service/service.dart';

class ComplaintRegisterScreen extends StatefulWidget {
  const ComplaintRegisterScreen({super.key});

  @override
  State<ComplaintRegisterScreen> createState() =>
      ComplaintRegisterScreenState();
}

class ComplaintRegisterScreenState extends State<ComplaintRegisterScreen> {
  List selectedTypes = [];
  // List selectedEmployies = [];
  String selectedStatus = "";
  String selectedCustomer = "";
  List selectedNature = [];
  GetModel? getResponse;
  AddItemModel? addResponse;

  PostModel? postResponse;
  bool isLoading = true;
  List remarks = [];
  String? selectedDropValue;
  String selectedDropName = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController addController = TextEditingController();
  final remarkKey = GlobalKey<FormState>();

  @override
  void initState() {
    getData();
    super.initState();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  getData() async {
    isLoading = true;
    getResponse = await HttpService.getComplaintDetails();

    if (getResponse != null && getResponse!.status == true) {
      // if (getResponse!.data.staffLists.isNotEmpty) {
      //   selectedDropValue = getResponse!.data.staffLists[0].userId;
      //   selectedDropName = getResponse!.data.staffLists[0].staffName;
      // }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  addItem(String status) async {
    addResponse = await HttpService.addItems(status, addController.text);

    if (addResponse != null && addResponse!.status == true) {
      getData();
      addController.clear();
    } else {}
  }

  postData() async {
    isLoading = true;
    postResponse = await HttpService.postComplaint(
        selectedTypes,
        selectedCustomer,
        nameController.text,
        phoneController.text,
        emailController.text,
        dateController.text,
        descriptionController.text,
        // selectedEmployies,
        remarks,
        selectedStatus,
        selectedNature);

    if (getResponse != null && getResponse!.status == true) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ComplaintListScreen()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
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
                    const Text(
                      'Complaint Register',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading == false
          ? SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: const BoxDecoration(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Select Complaint Types "),
                                  Icon(
                                    Icons.star,
                                    color: Colors.red,
                                    size: 16,
                                  )
                                ],
                              ),
                            ],
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(05.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              getResponse!.data.complaintType.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(25.0),
                                      child: Text(
                                        "Please Add Complaint Types",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: getResponse!
                                          .data.complaintType.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (selectedTypes.contains(
                                                    getResponse!
                                                        .data
                                                        .complaintType[index]
                                                        .typeId)) {
                                                  selectedTypes.remove(
                                                      getResponse!
                                                          .data
                                                          .complaintType[index]
                                                          .typeId);
                                                } else {
                                                  selectedTypes.add(getResponse!
                                                      .data
                                                      .complaintType[index]
                                                      .typeId);
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 18,
                                                  width: 18,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: Visibility(
                                                    visible: selectedTypes
                                                        .contains(getResponse!
                                                            .data
                                                            .complaintType[
                                                                index]
                                                            .typeId),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .65,
                                                    child: Text(getResponse!
                                                        .data
                                                        .complaintType[index]
                                                        .type))
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      addDialog("Types", "1");
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.green,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),

                    Container(
                        decoration: const BoxDecoration(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Customer Details"),
                            ],
                          ),
                        )),
                    Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: TextFormField(
                                controller: nameController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Name can't be empty";
                                  }
                                  return null;
                                },
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
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Name',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Phone number can't be empty";
                                  }
                                  return null;
                                },
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
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    prefixIcon: const Icon(Icons.phone),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Phone number',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email can't be empty";
                                  }
                                  return null;
                                },
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
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    prefixIcon: const Icon(Icons.email),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: TextFormField(
                                readOnly: true,
                                onTap: () async {
                                  final toDateSelectTemp = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  setState(() {
                                    dateController.text =
                                        DateFormat('dd-MM-yyyy')
                                            .format(toDateSelectTemp!);
                                  });
                                },
                                controller: dateController,
                                keyboardType: TextInputType.number,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Date can't be empty";
                                  }
                                  return null;
                                },
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
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.calendar_month),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Incident date',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: TextFormField(
                                controller: descriptionController,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Description can't be empty";
                                  }
                                  return null;
                                },
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
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    prefixIcon: const Icon(Icons.description),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Complaint Description',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                          ],
                        )),

                    Container(
                        decoration: const BoxDecoration(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Complaint reported by"),
                            ],
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(05.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              getResponse!.data.complaintReporter.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(25.0),
                                      child: Text("Please Add Reporters Type",
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: getResponse!
                                          .data.complaintReporter.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (selectedCustomer ==
                                                  getResponse!
                                                      .data
                                                      .complaintReporter[index]
                                                      .reporterId) {
                                                selectedCustomer = "";
                                              } else {
                                                selectedCustomer = getResponse!
                                                    .data
                                                    .complaintReporter[index]
                                                    .reporterId;
                                              }
                                              setState(() {});
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 18,
                                                  width: 18,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: selectedCustomer ==
                                                          getResponse!
                                                              .data
                                                              .complaintReporter[
                                                                  index]
                                                              .reporterId
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 15,
                                                        )
                                                      : const SizedBox(),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .65,
                                                  child: Text(getResponse!
                                                      .data
                                                      .complaintReporter[index]
                                                      .reporterName),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      addDialog("Reported By", "2");
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.green,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),

                    Container(
                        decoration: const BoxDecoration(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Nature of complaint"),
                            ],
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(05.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              getResponse!.data.complaintNature.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(25.0),
                                      child: Text("Please Add Complaint Nature",
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: getResponse!
                                          .data.complaintNature.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (selectedNature.contains(
                                                  getResponse!
                                                      .data
                                                      .complaintNature[index]
                                                      .natureId)) {
                                                selectedNature.remove(
                                                    getResponse!
                                                        .data
                                                        .complaintNature[index]
                                                        .natureId);
                                              } else {
                                                selectedNature.add(getResponse!
                                                    .data
                                                    .complaintNature[index]
                                                    .natureId);
                                              }
                                              setState(() {});
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 18,
                                                  width: 18,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: Visibility(
                                                    visible: selectedNature
                                                        .contains(getResponse!
                                                            .data
                                                            .complaintNature[
                                                                index]
                                                            .natureId),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .65,
                                                  child: Text(getResponse!
                                                      .data
                                                      .complaintNature[index]
                                                      .natureName),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      addDialog("Nature", "3");
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.green,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //     decoration:
                    //         const BoxDecoration(color: Colors.white),
                    //     child: const Padding(
                    //       padding: EdgeInsets.all(16.0),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text("Complaint Participants"),
                    //           Icon(Icons.arrow_drop_down)
                    //         ],
                    //       ),
                    //     )),
                    // Container(
                    //     decoration: const BoxDecoration(color: Colors.white),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16.0),
                    //       child: Column(
                    //         children: [
                    //           ListView.builder(
                    //               shrinkWrap: true,
                    //               physics: const NeverScrollableScrollPhysics(),
                    //               itemCount:
                    //                   getResponse!.data.staffLists.length,
                    //               itemBuilder: (context, index) {
                    //                 return Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: GestureDetector(
                    //                     onTap: () {
                    //                       if (selectedEmployies.contains(
                    //                           getResponse!.data
                    //                               .staffLists[index].userId)) {
                    //                         selectedEmployies.remove(
                    //                             getResponse!.data
                    //                                 .staffLists[index].userId);
                    //                       } else {
                    //                         selectedEmployies.add(getResponse!
                    //                             .data.staffLists[index].userId);
                    //                       }
                    //                       setState(() {});
                    //                     },
                    //                     child: Row(
                    //                       children: [
                    //                         Container(
                    //                           height: 18,
                    //                           width: 18,
                    //                           decoration: BoxDecoration(
                    //                               border: Border.all(
                    //                                   color: Colors.grey)),
                    //                           child: Visibility(
                    //                             visible: selectedEmployies
                    //                                 .contains(getResponse!
                    //                                     .data
                    //                                     .staffLists[index]
                    //                                     .userId),
                    //                             child: const Icon(
                    //                               Icons.check,
                    //                               size: 15,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         const SizedBox(
                    //                           width: 15,
                    //                         ),
                    //                         SizedBox(
                    //                           width: MediaQuery.of(context)
                    //                                   .size
                    //                                   .width *
                    //                               .65,
                    //                           child: Text(getResponse!.data
                    //                               .staffLists[index].staffName),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 );
                    //               }),
                    //           Row(
                    //             mainAxisAlignment: MainAxisAlignment.end,
                    //             children: [
                    //               GestureDetector(
                    //                 onTap: () {
                    //                   addDialog("Staff Name", "4");
                    //                 },
                    //                 child: Container(
                    //                   height: 40,
                    //                   width: 40,
                    //                   color: Colors.green,
                    //                   child: const Icon(Icons.add,color: Colors.white,),
                    //                 ),
                    //               ),
                    //             ],
                    //           )
                    //         ],
                    //       ),
                    //     )),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Text("Complaint Status "),
                          Icon(
                            Icons.star,
                            color: Colors.red,
                            size: 16,
                          )
                        ],
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(05.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              getResponse!.data.complaintStatus.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(25.0),
                                      child: Text("Please Add Complaint Status",
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: getResponse!
                                          .data.complaintStatus.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (selectedStatus ==
                                                  getResponse!
                                                      .data
                                                      .complaintStatus[index]
                                                      .statusId) {
                                                selectedStatus = "";
                                              } else {
                                                selectedStatus = getResponse!
                                                    .data
                                                    .complaintStatus[index]
                                                    .statusId;
                                              }
                                              setState(() {});
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 18,
                                                  width: 18,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: Visibility(
                                                    visible: selectedStatus ==
                                                        getResponse!
                                                            .data
                                                            .complaintStatus[
                                                                index]
                                                            .statusId,
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .65,
                                                  child: Text(getResponse!
                                                      .data
                                                      .complaintStatus[index]
                                                      .statusName),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      addDialog("Status", "4");
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.green,
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Comlpaint Participants"),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: remarkKey,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .85,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(05.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  value: selectedDropValue,
                                  borderRadius: BorderRadius.circular(8),
                                  autofocus: false,
                                  items: getResponse!.data.staffLists
                                      .map<DropdownMenuItem<String>>((e) {
                                    return DropdownMenuItem<String>(
                                      onTap: () {
                                        selectedDropName = e.staffName;
                                      },
                                      value: e.userId,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .7,
                                          child: Text(
                                            e.staffName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (res) {
                                    setState(() {
                                      selectedDropValue = res.toString();
                                    });
                                  },
                                  hint: Text(
                                    getResponse!.data.staffLists.isNotEmpty
                                        ? " Tap to select"
                                        : " Staff details is Empty",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  child: TextFormField(
                                    controller: remarksController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    onChanged: (value) {},
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "remarks can't be empty";
                                      }
                                      return null;
                                    },
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
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        labelText: 'Remark',
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.edit_note),
                                        labelStyle: const TextStyle(
                                          color: Colors.grey,
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    bool containsDuplicate = remarks.any(
                                        (remark) =>
                                            remark['id'] == selectedDropValue);
                                    if (containsDuplicate) {
                                      Common.toastMessaage(
                                          'This Staff is Already Selected',
                                          Colors.red);
                                    } else {
                                      setState(() {
                                        remarks.add({
                                          "id": selectedDropValue,
                                          "value": remarksController.text,
                                          "name": selectedDropName
                                        });
                                        remarksController.text = "";
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    color: Colors.green,
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: remarks.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .65,
                                          child: Text(
                                              "${index + 1} ${remarks[index]["name"]} Remark:${remarks[index]["value"]}"),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              remarks.removeAt(index);
                                              setState(() {});
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                      child: GestureDetector(
                        onTap: () async {
                          if (selectedStatus.isNotEmpty ||
                              selectedTypes.isNotEmpty) {
                            if (remarksController.text != "" &&
                                selectedDropValue != "") {
                              remarks.add({
                                "id": selectedDropValue,
                                "value": remarksController.text,
                                "name": selectedDropName
                              });
                              remarksController.text = "";
                            }
                            await postData();
                          } else {
                            const snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Select Status and Type'),
                              duration: Duration(seconds: 2),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Submit',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  addDialog(String type, String status) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add $type"),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * .170,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      controller: addController,
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
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          labelText: type,
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              Navigator.pop(context);
                              addItem(status);
                            },
                            child: const Text(
                              "Add",
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
