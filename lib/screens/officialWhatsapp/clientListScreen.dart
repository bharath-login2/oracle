import 'package:flutter/material.dart';

import 'colorConst.dart';
class ClientListScreen extends StatelessWidget {
  ClientListScreen({super.key});

  TextEditingController searchController = TextEditingController();

  String fDate = '';
  String tDate = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xff2b91f7),
                Color(0xff6eabe8)
              ], // Adjust the colors as needed
            ),
          ),
        ),
        title: const Text(
          'Client List',
          style: TextStyle(color: Colors.white),
        ),

      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[400],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final selctedDatetimetemp = await showDatePicker(
                            context: context,
                            initialDate: DateTime(
                                DateTime.now().year, DateTime.now().month, 1),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          // fDate =
                          //     DateFormat('dd-MM-yyyy').format(selctedDatetimetemp!);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  fDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: ColorConstant.black,
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final toDateSelectTemp = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          // tDate=
                          //     DateFormat('dd-MM-yyyy').format(toDateSelectTemp!);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  tDate,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          // child: DropdownButtonHideUnderline(
                          //   child: DropdownButton(
                          //     isExpanded: true,
                          //     value:
                          //         // billListController
                          //         //     .selectSatus.value ==
                          //         'ok',
                          //     // ? null
                          //     // : billListController
                          //     // .selectSatus.value,
                          //     borderRadius: BorderRadius.circular(8),
                          //     autofocus: false,
                          //     items: billListController
                          //         .billStatusModel!.data.status
                          //         .map<DropdownMenuItem<String>>((e) {
                          //       return DropdownMenuItem<String>(
                          //         value: e.stsId,
                          //         child: SizedBox(
                          //           width:
                          //               MediaQuery.of(context).size.width * .35,
                          //           child: Text(
                          //             e.displayValue,
                          //             overflow: TextOverflow.ellipsis,
                          //           ),
                          //         ),
                          //       );
                          //     }).toList(),
                          //     onChanged: (res) {
                          //       // billListController.selectSatus
                          //       //     .value = res.toString();
                          //     },
                          //     hint: const Text(
                          //       'Select Status',
                          //       textAlign: TextAlign.left,
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.w400,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xff2590cf)),
                          child: const Center(
                            child: Text("Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ))
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child:
                                      const Text("Shiju Shashidaran kurup ",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(2),
                                          color: const Color(0xffe6fbec)),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 6,
                                              bottom: 6),
                                          child: Text("10000000",
                                              style: TextStyle(
                                                color: Colors.green,
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
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: const Text(
                                        "Receipt No : #REC007",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.6,
                                  child:  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.41,
                                    child: const Text(
                                      "Bill No : #REC007",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.41,
                                      child: const Text(
                                          "Collected by : Moby ",
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w400,
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [

                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text("25-01-2023",
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              color: const Color(0xffe9d9fd)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_print_shop_outlined,
                                                color: Color(0xff9747FF)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              color: const Color(0xffaedcf4)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                                Icons.mode_edit_outlined,
                                                color: Colors.blue),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              color: const Color(0xfffcbcbc)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.delete_outline,
                                                color: Colors.red),
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
                      );
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
