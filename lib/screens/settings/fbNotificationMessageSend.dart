//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'facebookSettings.dart';
//
// class FbNotificationMessageSend extends StatefulWidget {
//   String token;
//    FbNotificationMessageSend(this.token,{Key? key}) : super(key: key);
//
//   @override
//   State<FbNotificationMessageSend> createState() => _FbNotificationMessageSendState();
// }
//
// class _FbNotificationMessageSendState extends State<FbNotificationMessageSend> {
//   String sendThrough = 'Send Through';
//   String sendThroughId = '';
//   TextEditingController sendThroughVal = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: PreferredSize(
//         preferredSize:
//         Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
//         child: Container(
//           padding:
//           EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(
//                 left: 10.0, top: 10.0, bottom: 10.0, right: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   FacebookSettings(widget.token)),
//                         );
//                       },
//                       child: Container(
//                         height: 25,
//                         width: 25,
//                         decoration: BoxDecoration(
//                             border: Border.all(color: Colors.white),
//                             shape: BoxShape.circle),
//                         child: const Icon(
//                           Icons.arrow_back_ios_outlined,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 25,
//                     ),
//                     const Text(
//                       'Send Message',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 30,),
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 10, right: 10),
//             child: TextFormField(
//               controller: sendThroughVal,
//               onTap: () {
//                 showDialog(
//                     barrierColor: Colors.white.withOpacity(.2),
//                     context: context,
//                     builder: (BuildContext context) {
//                       return Material(
//                         type: MaterialType.transparency,
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 50),
//                           child: Center(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.grey,
//                               ),
//                               width: 295,
//                               height: 183,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 20, right: 20),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       'Send Through',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                         // decoration: TextDecoration.none,
//                                         //fontFamily: Theme.of(context).textTheme,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 20,
//                                     ),
//                                     Row(
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//
//                                           },
//                                           child: Container(
//                                             width: 100,
//                                             height: 40,
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(5),
//                                                 color: const Color(0xffe94040)),
//                                             child: const Center(
//                                               child: Text("Official",
//                                                   style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight: FontWeight.w700,
//                                                       decoration: TextDecoration.none,
//                                                       color: Colors.white)),
//                                             ),
//                                           ),
//                                         ),
//
//                                         InkWell(
//                                           onTap: () {
//
//                                           },
//                                           child: Container(
//                                             width: 100,
//                                             height: 40,
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(5),
//                                                 color: const Color(0xffe94040)),
//                                             child: const Center(
//                                               child: Text("Un Official",
//                                                   style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight: FontWeight.w700,
//                                                       decoration: TextDecoration.none,
//                                                       color: Colors.white)),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     });
//                 // showDialog(
//                 //     context: context,
//                 //     builder: (BuildContext context) {
//                 //       return AlertDialog(
//                 //         scrollable: true,
//                 //         title:
//                 //         const Text('Send Through1'),
//                 //         content: ListView.builder(
//                 //           shrinkWrap: true,
//                 //           itemCount: 2,
//                 //           scrollDirection: Axis.horizontal,
//                 //           itemBuilder: (context, ind) {
//                 //             return InkWell(
//                 //               onTap: () async {
//                 //                 // leadSubTypeList =
//                 //                 // await HttpService.leadSubType(
//                 //                 //     commonDetails!
//                 //                 //         .data!
//                 //                 //         .leadCategory![
//                 //                 //     ind]
//                 //                 //         .leadCategoryId
//                 //                 //         .toString());
//                 //                 // setState(() {
//                 //                 //   leadSubType =
//                 //                 //   'Lead Sub Category';
//                 //                 //   leadSubTypeId = '';
//                 //                 //   leadType =
//                 //                 //       commonDetails!
//                 //                 //           .data!
//                 //                 //           .leadCategory![
//                 //                 //       ind]
//                 //                 //           .leadCategory
//                 //                 //           .toString();
//                 //                 //   leadTypeId =
//                 //                 //       commonDetails!
//                 //                 //           .data!
//                 //                 //           .leadCategory![
//                 //                 //       ind]
//                 //                 //           .leadCategoryId
//                 //                 //           .toString();
//                 //                 //   Navigator.pop(
//                 //                 //       context, true);
//                 //                 // });
//                 //               },
//                 //               child: const SizedBox(
//                 //                 height: 50,
//                 //                 child: Text(
//                 //                   'Official',
//                 //                   style:
//                 //                   TextStyle(
//                 //                       fontSize: 18),
//                 //                 ),
//                 //               ),
//                 //             );
//                 //           },
//                 //         ),
//                 //       );
//                 //     });
//               },
//               maxLines: 1,
//               readOnly: true,
//               decoration: const InputDecoration(
//                   contentPadding:  EdgeInsets.only(left: 10,top: 2,bottom: 2),
//                   labelText: 'Send Through',
//                   fillColor: Colors.white,
//                   filled: true,
//                   prefixIcon: Icon(
//                       Icons.arrow_drop_down_circle_outlined,
//                       color: Colors.grey),
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey),
//                   ),
//                   labelStyle:
//                   TextStyle(color: Colors.grey)),
//             ),
//           ),
//           const SizedBox(height: 10,),
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 10, right: 10),
//             child: TextFormField(
//               controller: sendThroughVal,
//               onTap: () {
//                 showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         scrollable: true,
//                         title:
//                         const Text('Send Through'),
//                         content: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: 3,
//                           itemBuilder: (context, ind) {
//                             return InkWell(
//                               onTap: () async {
//                                 // leadSubTypeList =
//                                 // await HttpService.leadSubType(
//                                 //     commonDetails!
//                                 //         .data!
//                                 //         .leadCategory![
//                                 //     ind]
//                                 //         .leadCategoryId
//                                 //         .toString());
//                                 // setState(() {
//                                 //   leadSubType =
//                                 //   'Lead Sub Category';
//                                 //   leadSubTypeId = '';
//                                 //   leadType =
//                                 //       commonDetails!
//                                 //           .data!
//                                 //           .leadCategory![
//                                 //       ind]
//                                 //           .leadCategory
//                                 //           .toString();
//                                 //   leadTypeId =
//                                 //       commonDetails!
//                                 //           .data!
//                                 //           .leadCategory![
//                                 //       ind]
//                                 //           .leadCategoryId
//                                 //           .toString();
//                                 //   Navigator.pop(
//                                 //       context, true);
//                                 // });
//                               },
//                               child: const SizedBox(
//                                 height: 50,
//                                 child: Text(
//                                   'Official',
//                                   style:
//                                   TextStyle(
//                                       fontSize: 18),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     });
//               },
//               maxLines: 1,
//               readOnly: true,
//               decoration: const InputDecoration(
//                   contentPadding:  EdgeInsets.only(left: 10,top: 2,bottom: 2),
//                   labelText: 'Send Through',
//                   fillColor: Colors.white,
//                   filled: true,
//                   prefixIcon: Icon(
//                       Icons.arrow_drop_down_circle_outlined,
//                       color: Colors.grey),
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey),
//                   ),
//                   labelStyle:
//                   TextStyle(color: Colors.grey)),
//             ),
//           ),
//           const SizedBox(height: 10,),
//           Padding(
//             padding: const EdgeInsets.only(left: 10,right: 10),
//             child: TextFormField(
//               //controller: remarks,
//               maxLines: 2,
//               decoration: const InputDecoration(
//                   labelText: 'Message Content',
//                   fillColor: Colors.white,
//                   filled: true,
//                   //prefixIcon: Icon(myIcon, color: prefixIconColor),
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey),
//                   ),
//                   labelStyle: TextStyle(color: Colors.grey)),
//             ),
//           ),
//           const SizedBox(height: 10,),
//           Padding(
//             padding: const EdgeInsets.only(left: 10,right: 10),
//             child: TextFormField(
//               //controller: remarks,
//               decoration: const InputDecoration(
//                   labelText: 'Image Url',
//                   fillColor: Colors.white,
//                   filled: true,
//                   //prefixIcon: Icon(myIcon, color: prefixIconColor),
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey),
//                   ),
//                   labelStyle: TextStyle(color: Colors.grey)),
//             ),
//           ),
//           const SizedBox(height: 20,),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.45,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Center(
//               child: Text('Submit',
//                   style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
