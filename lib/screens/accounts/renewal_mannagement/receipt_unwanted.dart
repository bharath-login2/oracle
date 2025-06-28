// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ReceiptScreen extends StatefulWidget {
//   const ReceiptScreen({super.key});

//   @override
//   State<ReceiptScreen> createState() => _ReceiptScreenState();
// }

// class _ReceiptScreenState extends State<ReceiptScreen> {
//   final TextEditingController date = TextEditingController();
//   final TextEditingController collectedBy = TextEditingController();
//   final TextEditingController paymentMethod = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize:
//             Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
//         child: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           decoration: const BoxDecoration(
//             gradient:
//                 LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(
//                 left: 10.0, top: 10.0, bottom: 10.0, right: 10),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                           height: 25,
//                           width: 25,
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.white),
//                               shape: BoxShape.circle),
//                           child: const Icon(
//                             Icons.arrow_back_ios_outlined,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 25,
//                       ),
//                       const Text(
//                         "Receipt",
//                         style: TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                     ],
//                   ),
//                 ]),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//             ),
//             child: const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 25,
//                         backgroundColor: Colors.amber,
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         "Mayoora",
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     "Reciept No: #REC0049",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   Text(
//                     "Invoice No: #0049",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextFormField(
//                   onTap: () async {
//                     DateTime? selectedEndDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     date.text =
//                         DateFormat('dd-MM-yyyy').format(selectedEndDate!);
//                   },
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "Please Select Date";
//                     }
//                     return null;
//                   },
//                   readOnly: true,
//                   controller: date,
//                   decoration: const InputDecoration(
//                       labelText: 'Date',
//                       prefixIcon:
//                           Icon(Icons.calendar_month, color: Colors.grey),
//                       border: OutlineInputBorder(),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       labelStyle: TextStyle(color: Colors.grey)),
//                 ),
//                 const SizedBox(height: 14.0),
//                 TextFormField(
//                   readOnly: true,
//                   controller: collectedBy,
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "please Enter";
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(
//                       labelText: 'Account Head',
//                       prefixIcon: Icon(Icons.person, color: Colors.grey),
//                       border: OutlineInputBorder(),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       labelStyle: TextStyle(color: Colors.grey)),
//                 ),
//                 const SizedBox(height: 14.0),

//                 TextFormField(
//                   readOnly: true,
//                   controller: paymentMethod,
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "please Enter";
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(
//                       labelText: 'Payment method',
//                       prefixIcon: Icon(Icons.payment, color: Colors.grey),
//                       border: OutlineInputBorder(),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       labelStyle: TextStyle(color: Colors.grey)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
