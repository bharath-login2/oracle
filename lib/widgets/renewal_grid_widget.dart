// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RenewalGridItem extends StatelessWidget {
  String title;
  String paidCount;
  String paidAmount;
  String totalCount;
  String totalAmount;
  Color color;
  RenewalGridItem(
      {super.key,
      required this.title,
      required this.paidCount,
      required this.paidAmount,
      required this.totalAmount,
      required this.totalCount,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                color: Colors.grey.shade600,
                offset: const Offset(0, 2.0),
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundImage: AssetImage(title == "Current Year"
                        ? "assets/main/Reports.png"
                        : title == "Expired"
                            ? "assets/main/Expired.png"
                            : "assets/main/Month.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          color: title == "Expired" ? Colors.red : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: title != "Expired",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("$paidCount / ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(totalCount,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .073,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: BoxDecoration(
                    color: title == "Expired"
                        ? Colors.red.shade50
                        : Colors.grey.shade300,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(22),
                        topRight: Radius.circular(22)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      mainAxisAlignment: title != "Expired"
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: title != "Expired",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text("  Paid: ₹",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                child: Text("$paidAmount /-",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text("  Total: ₹",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .25,
                              child: Text("$totalAmount /-",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 3,
            )
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 8, right: 8),
            //       child: CircleAvatar(
            //         radius: 15,
            //         backgroundColor: color,
            //         child: const Icon(
            //           Icons.arrow_forward,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
