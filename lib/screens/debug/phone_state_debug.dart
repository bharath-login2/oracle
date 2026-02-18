// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:phone_state/phone_state.dart';

// class PhoneStateDebugScreen extends StatefulWidget {
//   const PhoneStateDebugScreen({Key? key}) : super(key: key);

//   @override
//   State<PhoneStateDebugScreen> createState() => _PhoneStateDebugScreenState();
// }

// class _PhoneStateDebugScreenState extends State<PhoneStateDebugScreen> {
//   List<String> logs = [];
//   StreamSubscription<PhoneState>? _phoneStateSubscription;
//   late PhoneState currentState;

//   @override
//   void initState() {
//     super.initState();
//     currentState = PhoneState(status: PhoneStateStatus.NOTHING);
//     _startListening();
//   }

//   @override
//   void dispose() {
//     _phoneStateSubscription?.cancel();
//     super.dispose();
//   }

//   void _startListening() {
//     _phoneStateSubscription = PhoneState.phoneStateStream.listen((event) {
//       setState(() {
//         currentState = event;
        
//         String logEntry = '''
// 📱 [${DateTime.now().toIso8601String()}]
// Status: ${event.status}
// Number: ${event.number ?? 'N/A'}
// Incoming: ${event.incoming}
// Extra: ${event.extra}
// Timestamp: ${event.timestamp}
// -----------------------------------
// ''';
        
//         logs.insert(0, logEntry);
//         if (logs.length > 20) {
//           logs.removeLast();
//         }
//       });
//     });
//   }

//   Future<void> _testOutgoingCall() async {
//     // Simulate an outgoing call
//     final fakeEvent = PhoneState(
//       status: PhoneStateStatus.CALL_STARTED,
//       number: '+1234567890',
//       incoming: false, // ✅ outgoing calls have incoming: false
//       extra: 'Simulated outgoing call',
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//     );
    
//     setState(() {
//       currentState = fakeEvent;
      
//       String logEntry = '''
// 🧪 [${DateTime.now().toIso8601String()}] TEST
// Status: ${fakeEvent.status}
// Number: ${fakeEvent.number}
// Incoming: ${fakeEvent.number}  (false = outgoing, true = incoming)
// Extra: ${fakeEvent.number}
// Timestamp: ${fakeEvent.number}
// -----------------------------------
// ''';
      
//       logs.insert(0, logEntry);
//     });
//   }

//   Future<void> _testIncomingCall() async {
//     // Simulate an incoming call
//     final fakeEvent = PhoneState(
//       status: PhoneStateStatus.CALL_INCOMING,
//       number: '+1234567890',
//       incoming: true, // ✅ incoming calls have incoming: true
//       extra: 'Simulated incoming call',
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//     );
    
//     setState(() {
//       currentState = fakeEvent;
      
//       String logEntry = '''
// 🧪 [${DateTime.now().toIso8601String()}] TEST
// Status: ${fakeEvent.status}
// Number: ${fakeEvent.number}
// Incoming: ${fakeEvent.number}  (false = outgoing, true = incoming)
// Extra: ${fakeEvent.number}
// Timestamp: ${fakeEvent.number}
// -----------------------------------
// ''';
      
//       logs.insert(0, logEntry);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone State Debug - v2.1.1'),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: Column(
//         children: [
//           // Current State Card
//           Card(
//             margin: const EdgeInsets.all(16),
//             color: Colors.blueGrey[50],
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Current Phone State',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildStateItem('Status', '${currentState.status}'),
//                   _buildStateItem('Number', currentState.number ?? 'N/A'),
//                   _buildStateItem('Incoming', '${currentState.number}'),
//                   _buildStateItem('Extra', currentState.number ?? 'N/A'),
//                   _buildStateItem('Timestamp', '${currentState.number}'),
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(currentState.status),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _getStatusText(currentState.status),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Logs Section
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Event Logs',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.file_download, size: 20),
//                               onPressed: _exportLogs,
//                               tooltip: 'Export logs',
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.clear_all, size: 20),
//                               onPressed: () => setState(() => logs.clear()),
//                               tooltip: 'Clear logs',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       reverse: true,
//                       itemCount: logs.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                           ),
//                           child: Text(
//                             logs[index],
//                             style: const TextStyle(
//                               fontFamily: 'monospace',
//                               fontSize: 12,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _testIncomingCall,
//             backgroundColor: Colors.red,
//             mini: true,
//             child: const Icon(Icons.call_received),
//             tooltip: 'Test incoming call',
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: _testOutgoingCall,
//             backgroundColor: Colors.orange,
//             mini: true,
//             child: const Icon(Icons.call_made),
//             tooltip: 'Test outgoing call',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStateItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.blue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _exportLogs() {
//     String allLogs = logs.join('\n');
//     print('=== PHONE STATE LOGS ===\n$allLogs\n=======================');
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${logs.length} logs printed to console'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Color _getStatusColor(PhoneStateStatus status) {
//     switch (status) {
//       case PhoneStateStatus.CALL_INCOMING:
//         return Colors.red;
//       case PhoneStateStatus.CALL_STARTED:
//         return Colors.green;
//       case PhoneStateStatus.CALL_ENDED:
//         return Colors.blue;
//       case PhoneStateStatus.NOTHING:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(PhoneStateStatus status) {
//     switch (status) {
//       case PhoneStateStatus.CALL_INCOMING:
//         return '📥 INCOMING CALL';
//       case PhoneStateStatus.CALL_STARTED:
//         return '📞 CALL STARTED';
//       case PhoneStateStatus.CALL_ENDED:
//         return '📞 CALL ENDED';
//       case PhoneStateStatus.NOTHING:
//         return '📱 NO CALL';
//     }
//   }
// }