// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:login2/screens/clients/editRecipt.dart';
// import 'package:lottie/lottie.dart';
// import '../../core/common.dart';
// import '../../models/clients/customerListModel.dart';
// import '../../models/clients/receiptDeleteModel.dart';
// import '../../models/clients/receiptListModel.dart';
// import '../../service/service.dart';
// import '../leadManagement/dashboard.dart';
// import 'invoiceList.dart';
//
// class ReceiptList extends StatefulWidget {
//   String token;
//   ReceiptList(this.token,{Key? key}) : super(key: key);
//
//   @override
//   State<ReceiptList> createState() => _ReceiptListState();
// }
//
// class _ReceiptListState extends State<ReceiptList> {
//   var fromdate = DateTime.now();
//   var todate = DateTime.now();
//   dynamic client;
//   ReceiptListModel? receiptList;
//   CustomerListModel? customerList;
//   bool result=true;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getData();
//   }
//   getData() async {
//     final connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//       setState(() {
//         result = true;
//       });
//     } else {
//       setState(() {
//         result = false;
//       });
//     }
//
//     receiptList = await HttpService.receptList(widget.token,fromdate.toString(),todate.toString(),client);
//     if (receiptList != null) {
//       customerList=await HttpService.customerList(widget.token);
//       setState(() {});
//     }
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return result==true?WillPopScope(
//       onWillPop: () async {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => InvoiceList(widget.token)),
//         );
//         return true;
//       },
//       child: Scaffold(
//           backgroundColor: Colors.grey.shade200,
//           appBar: PreferredSize(
//             preferredSize:
//             Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
//             child: Container(
//               padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//               decoration: const BoxDecoration(
//                 gradient:
//                 LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     left: 10.0, top: 10.0, bottom: 10.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => InvoiceList(widget.token)),
//                             );
//                           },
//                           child: Container(
//                             height: 25,
//                             width: 25,
//                             decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.white),
//                                 shape: BoxShape.circle),
//                             child: const Icon(
//                               Icons.arrow_back_ios_outlined,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 25,
//                         ),
//                         const Text(
//                           'Receipt List',
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       ],
//                     ),
//
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           body: receiptList!=null && customerList!=null?
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 10,),
//                 Padding(
//                   padding:
//                   const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           const Text('From Date',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w500,
//                               )),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           SizedBox(
//                             width:
//                             MediaQuery.of(context).size.width *
//                                 0.45,
//                             child: Center(
//                               child: DateTimePicker(
//                                 decoration: InputDecoration(
//                                     contentPadding: const EdgeInsets.all(3),
//                                     filled: true,
//                                     //<-- SEE HERE
//                                     fillColor: Colors.white,
//                                     prefixIcon: const Icon(
//                                       Icons.arrow_right,
//                                       color: Colors.grey,
//                                     ),
//                                     counterText: "",
//                                     hintText: 'From Date',
//                                     isDense: true,
//                                     border: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors
//                                                 .purple.shade100),
//                                         borderRadius:
//                                         BorderRadius.circular(
//                                             5))),
//                                 initialValue: fromdate.toString(),
//                                 type: DateTimePickerType.date,
//
//                                 //controller: fromDate,
//                                 firstDate: DateTime(1995),
//                                 lastDate: DateTime.now()
//                                     .add(const Duration(days: 365)),
//                                 // This will add one year from current date
//                                 validator: (value) {
//                                   return null;
//                                 },
//                                 onChanged: (value) {
//                                   if (value.isNotEmpty) {
//                                     setState(() {
//                                       fromdate =
//                                           DateTime.parse(value);
//                                     });
//                                   }
//                                 },
//                                 // We can also use onSaved
//                                 onSaved: (value) {
//                                   if (value!.isNotEmpty) {
//                                     fromdate =
//                                         DateTime.parse(value);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         width: 12,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           const Text('To Date',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w500,
//                               )),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           SizedBox(
//                             width:
//                             MediaQuery.of(context).size.width *
//                                 0.45,
//                             child: Center(
//                               child: DateTimePicker(
//
//                                 decoration: InputDecoration(
//                                     contentPadding: const EdgeInsets.all(3),
//                                     filled: true,
//                                     //<-- SEE HERE
//                                     fillColor: Colors.white,
//                                     prefixIcon: const Icon(
//                                       Icons.arrow_right,
//                                       color: Colors.grey,
//                                     ),
//                                     counterText: "",
//                                     hintText: 'From Date',
//                                     isDense: true,
//                                     border: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors
//                                                 .purple.shade100),
//                                         borderRadius:
//                                         BorderRadius.circular(
//                                             5))),
//                                 initialValue: todate.toString(),
//                                 type: DateTimePickerType.date,
//
//                                 //controller: fromDate,
//                                 firstDate: DateTime(1995),
//                                 lastDate: DateTime.now()
//                                     .add(const Duration(days: 365)),
//                                 // This will add one year from current date
//                                 validator: (value) {
//                                   return null;
//                                 },
//                                 onChanged: (value) {
//                                   if (value.isNotEmpty) {
//                                     setState(() {
//                                       todate =
//                                           DateTime.parse(value);
//                                     });
//                                   }
//                                 },
//                                 // We can also use onSaved
//                                 onSaved: (value) {
//                                   if (value!.isNotEmpty) {
//                                     todate = DateTime.parse(value);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 15,),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width *
//                             0.45,
//                         child: FormField<
//                             String>(
//                           builder: (FormFieldState<
//                               String>
//                           state) {
//                             return Container(
//                               width: MediaQuery.of(context)
//                                   .size
//                                   .width *
//                                   0.43,
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Colors
//                                           .grey.shade900,
//                                       width:
//                                       0),
//                                   color: Colors
//                                       .white,
//                                   borderRadius: const BorderRadius
//                                       .all(
//                                       Radius.circular(5))),
//                               child:
//                               DropdownButtonHideUnderline(
//                                 child: DropdownButton<
//                                     String>(
//                                   isExpanded:
//                                   true,
//                                   hint:
//                                   const Padding(
//                                     padding:
//                                     EdgeInsets.only(left: 20),
//                                     child:
//                                     Text('Customer'),
//                                   ),
//                                   value: client,
//                                   items:customerList!.data!.map((data) {
//                                     return DropdownMenuItem(
//                                       value: data.id.toString(),
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(left: 20),
//                                         child: Text(data.name.toString()),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged:
//                                       (newValue1) {
//                                     setState(() {
//                                       client = newValue1;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 12,
//                       ),
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             // search = true;
//                             // isSearch = false;
//                             // Common.showProgressDialog(
//                             //     context, "Loading..");
//                             getData();
//                           });
//                         },
//                         child: Container(
//                           width: MediaQuery.of(context).size.width *
//                               0.45,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Center(
//                             child: Text('Search',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20,),
//                 receiptList!.data!.isNotEmpty?
//                 ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount:receiptList!.data!.length,
//                     itemBuilder:
//                         (context, ind) {
//                       return Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Container(
//                           width: MediaQuery.of(context).size.width * 1,
//                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.white,),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(receiptList!.data![ind].customerName.toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
//                                         const SizedBox(height: 4,),
//                                         Text('Receipt No :${receiptList!.data![ind].receiptNumber}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
//                                         const SizedBox(height: 4,),
//                                         Text('Invoice No : ${receiptList!.data![ind].invoiceNumber}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.normal,color: Colors.grey),),
//                                         const SizedBox(height: 4,),
//                                         Text('Date : ${receiptList!.data![ind].receiptDate}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.normal,color: Colors.grey),),
//                                         const SizedBox(height: 4,),
//                                         Text('Collected By : ${receiptList!.data![ind].collectedStaff}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.normal,color: Colors.grey),),
//                                       ],
//                                     ),
//                                     Container(
//                                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.grey.shade300),
//                                       child:   Padding(
//                                         padding: const EdgeInsets.all(10),
//                                         child: Column(
//
//                                           children: [
//                                             const Text('₹',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green)),
//                                             Text('${receiptList!.data![ind].recieptAmount}/-',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green)),
//                                           ],
//                                         ),
//                                       ),)
//                                   ],
//                                 ),
//                                 const SizedBox(height: 5,),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     InkWell(
//                                       onTap:(){
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => EditReceipt(widget.token,receiptList!.data![ind].id.toString())),
//                                         );
//                                       },
//                                       child: Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                               BorderRadius
//                                                   .circular(5),
//                                               border: Border.all(
//                                                   color: Colors.blue)),
//                                           child: const Padding(
//                                             padding: EdgeInsets.only(left: 7,right: 7,top: 7,bottom: 7),
//                                             child: Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.edit,
//                                                   color: Colors.blue,
//                                                   size: 18,
//                                                 ),
//                                                 SizedBox(width: 5,),
//                                                 Text('edit',style: TextStyle(
//                                                     color: Colors.blue, fontSize: 14, fontWeight: FontWeight.normal))
//                                               ],
//                                             ),
//                                           )),
//                                     ),
//                                     InkWell(
//                                       onTap: (){
//                                         showDialog(
//                                             context: context,
//                                             builder:
//                                                 (BuildContext context) {
//                                               return AlertDialog(
//                                                 scrollable: true,
//                                                 title: const Text(
//                                                     'Please Confirm'),
//                                                 content: const Text(
//                                                     'Are you sure to Delete?'),
//                                                 actions: [
//                                                   // The "Yes" button
//                                                   TextButton(
//                                                       onPressed: () async {
//                                                         Common.showProgressDialog(
//                                                             context, "Loading..");
//                                                         ReceiptDeleteModel deleteReceipt=await HttpService.deleteReceipt(widget.token,receiptList!.data![ind].id);
//                                                         if (deleteReceipt.data ==
//                                                             true) {
//                                                           Common.toastMessaage(
//                                                               deleteReceipt
//                                                                   .message,
//                                                               Colors.green);
//                                                           if (context
//                                                               .mounted) {
//                                                             Navigator.push(
//                                                               context,
//                                                               MaterialPageRoute(
//                                                                   builder:
//                                                                       (context) =>
//                                                                       ReceiptList(
//                                                                           widget.token)),
//                                                             );
//                                                           }
//                                                         }
//                                                         else {
//                                                           Common.toastMessaage(
//                                                               deleteReceipt
//                                                                   .message,
//                                                               Colors.red);
//                                                           if (context
//                                                               .mounted) {
//                                                             Navigator.of(
//                                                                 context)
//                                                                 .pop();
//                                                           }
//                                                         }
//                                                       },
//                                                       child: const Text(
//                                                           'Yes')),
//                                                   TextButton(
//                                                       onPressed: () {
//                                                         Navigator.of(
//                                                             context)
//                                                             .pop();
//                                                       },
//                                                       child:
//                                                       const Text('No'))
//                                                 ],
//                                               );
//                                             });
//                                       },
//                                       child: Container(
//
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                               BorderRadius
//                                                   .circular(5),
//                                               border: Border.all(
//                                                   color: Colors.red)),
//                                           child: const Padding(
//                                             padding: EdgeInsets.only(left: 7,right: 7,top: 7,bottom: 7),
//                                             child: Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.delete,
//                                                   color: Colors.red,
//                                                   size: 18,
//                                                 ),
//                                                 SizedBox(width: 5,),
//                                                 Text('Delete',style: TextStyle(
//                                                     color: Colors.red, fontSize: 14, fontWeight: FontWeight.normal))
//
//                                               ],
//                                             ),
//                                           )),
//                                     ),
//                                     Container(
//
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                             BorderRadius
//                                                 .circular(5),
//                                             border: Border.all(
//                                                 color: Colors.amber)),
//                                         child: const Padding(
//                                           padding: EdgeInsets.only(left: 7,right: 7,top: 7,bottom: 7),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.print,
//                                                 color: Colors.amber,
//                                                 size: 18,
//                                               ),
//                                               SizedBox(width: 5,),
//                                               Text('Print',style: TextStyle(
//                                                   color: Colors.amber, fontSize: 14, fontWeight: FontWeight.normal))
//
//                                             ],
//                                           ),
//                                         )),
//                                   ],
//                                 ),
//
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                 ):
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width:180,height: 180,
//                         child: Image.asset(
//                           "assets/icons/nodatafound.png",
//                         ),
//                       ),
//                       const Text('No Data Found',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ):
//           Center(
//             child: Lottie.asset('assets/main/loading.json',
//                 fit: BoxFit.fill),
//           )
//       ),
//     ):
//     Scaffold(
//         backgroundColor: Colors.white,
//         body: SizedBox(
//           width: MediaQuery.of(context).size.width * 1,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: 300,
//                 height: 300,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/icons/noNetwork.jpg'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const Text(
//                 'No Network Found !',
//                 style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               InkWell(
//                 onTap: () {
//                   getData();
//                 },
//                 child: SizedBox(
//                   width: 120,
//                   height: 35,
//                   child: Padding(
//                     padding: const EdgeInsets.all(1.5),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade400,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Try Again',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
// }
