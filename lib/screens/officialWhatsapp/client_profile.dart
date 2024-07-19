// import 'package:flutter/material.dart';

// class ClientProfile extends StatefulWidget {
//   String name;
//   ClientProfile({super.key, required this.name});

//   @override
//   State<ClientProfile> createState() => _ClientProfileState();
// }

// class _ClientProfileState extends State<ClientProfile> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize:
//             Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
//         child: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           decoration: const BoxDecoration(
//             gradient:
//                 LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
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
//                     Text(
//                       widget.name,
//                       style: const TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
