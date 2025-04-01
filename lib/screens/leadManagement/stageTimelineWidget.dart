import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/lead_management/leadDetailsModel.dart';

class StageTimelineWidget extends StatefulWidget {
  final List<Calleddata> calleddata; // Now it's a List of Calleddata objects

  const StageTimelineWidget({Key? key, required this.calleddata})
      : super(key: key);

  @override
  _StageTimelineWidgetState createState() => _StageTimelineWidgetState();
}

class _StageTimelineWidgetState extends State<StageTimelineWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.calleddata.length,
      itemBuilder: (context, index) {
        var call = widget.calleddata[index]; // Access as an object

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50.0, bottom: 10),
              child: Card(
                margin: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: (call.durationTime != null &&
                            int.tryParse(call.durationTime!)! > 0)
                        ? const Color.fromARGB(255, 201, 246, 203)
                        : const Color.fromARGB(255, 242, 233, 219),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 6,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    call.callType == 'incoming'
                                        ? Icons.phone_callback_sharp
                                        : call.callType == 'outgoing'
                                            ? Icons.phone_forwarded_sharp
                                            : Icons.phone_missed,
                                    color: call.callType == 'incoming'
                                        ? const Color.fromARGB(
                                            255, 157, 162, 157)
                                        : call.callType == 'outgoing'
                                            ? Colors.blueAccent
                                            : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    call.callType ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 64),
                              child: Text(
                                call.formatteddateTime ?? "",
                                style: const TextStyle(
                                  fontSize: 10,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer, // Choose an appropriate icon
                                    size: 16, // Adjust the size if needed
                                    color: Colors
                                        .grey, // Change color as per your UI
                                  ),
                                  const SizedBox(
                                      width: 5), // Space between icon and text
                                  Text(
                                    call.formattedDuration??"",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: Text(
                                  (call.durationTime != null &&
                                          int.tryParse(call.durationTime!)! > 0)
                                      ? 'ANSWERED'
                                      : 'NOT ANSWERED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: (call.durationTime != null &&
                                            int.tryParse(call.durationTime!)! >
                                                0)
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                     Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.call, // You can change this to any relevant icon
                                  size: 16,
                                  color: Colors.grey, // Adjust color as needed
                                ),
                                const SizedBox(width: 5), // Space between icon and text
                                Text(
                                  'Called By ${call.companyName ?? "Unknown"}',
                                  style: const TextStyle(
                                    fontSize: 14, // Adjust size as needed
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Timeline Line
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 35.0,
              child: Container(
                width: 1.5,
                color: Colors.blue,
              ),
            ),

            // Profile Image
            Positioned(
              top: 20.0,
              left: 5.0,
              child: Column(
                children: [
                 CircleAvatar(
                radius: 30,
                backgroundImage: call.proPic != null && call.proPic!.isNotEmpty
                    ? NetworkImage(call.proPic!) as ImageProvider
                    : const AssetImage('assets/icons/profile_placeholder.png'),
              ),

                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      call.dateTime != null
                          ? DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(call.dateTime!))
                          : 'No Date',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              
            ),
          ],
        );
      },
    );
  }
}
