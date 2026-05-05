import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/receiptListModel.dart';
import 'package:login2/models/staff_report/targetReportModel.dart';
import 'package:login2/screens/accounts/clients/viewReceipt.dart';
import 'package:login2/service/service.dart';

class AchievementDetailsPage extends StatefulWidget {
  final dynamic targetData;
  final DateTime? targetFromDate;
  final DateTime? targetToDate;

  const AchievementDetailsPage({
    super.key,
    required this.targetData,
    required this.targetFromDate,
    required this.targetToDate,
  });

  @override
  State<AchievementDetailsPage> createState() => _AchievementDetailsPageState();
}

class _AchievementDetailsPageState extends State<AchievementDetailsPage> {
  bool isLoading = true;
  List<Target> achievementList = [];
  List<ListElement> items = [];
  ReceiptListModel? receiptList;
  String token = "";
  Set<int> expandedIndexes = {}; 
  @override
  void initState() {
    super.initState();
    loadToken();
    getTargetDetailsOnLoad();
  }

  Future<void> loadToken() async {
    token = await Common.getSharedPref("token");
    setState(() {});
  }

  Future<void> getTargetDetailsOnLoad() async {
    try {
      final fromDateStr = widget.targetFromDate != null
          ? widget.targetFromDate!.toIso8601String().substring(0, 10)
          : '';
      final toDateStr = widget.targetToDate != null
          ? widget.targetToDate!.toIso8601String().substring(0, 10)
          : '';

      final response = await HttpService.getTargetDetails(
        widget.targetData.groupId,
        fromDateStr,
        toDateStr,
      );

      if (response != null && response.status) {
        setState(() {
          achievementList = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error getting target details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        double.tryParse(widget.targetData.progressPercentage.toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievement Details"),
        backgroundColor: const Color.fromARGB(255, 33, 130, 196),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.targetData.groupName ?? "Group",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "📅 ${formatDate(widget.targetFromDate)}  -  ${formatDate(widget.targetToDate)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "🎯 Target: ${widget.targetData.targetAmount}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "🏆 Achieved: ${widget.targetData.achieved}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      () {
                        double target = double.tryParse(widget.targetData.targetAmount.toString().replaceAll(',', '')) ?? 0.0;
                        double achieved = double.tryParse(widget.targetData.achieved.toString().replaceAll(',', '')) ?? 0.0;
                        bool isOverAchieved = achieved > target;
                        double pendingOrExtra = (target - achieved).abs();
                        return Text(
                          isOverAchieved 
                            ? "🏆 Over Achieved: ₹${NumberFormat("#,##0.00").format(pendingOrExtra)}" 
                            : "💰 Pending: ₹${NumberFormat("#,##0.00").format(pendingOrExtra)}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOverAchieved ? Colors.green : Colors.orange),
                        );
                      }(),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 22),
                      //   child: Text(
                      //     widget.targetData.achieved == 'Y'
                      //         ? "Tax Included"
                      //         : "Tax Not Included",
                      //     style: const TextStyle(fontSize: 12),
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 14,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${progress.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Achievements",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      widget.targetData.achieved != "0" &&
                              achievementList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: achievementList.length,
                                itemBuilder: (context, index) {
                                  final item = achievementList[index];
                                  final products = item.productName
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();
                                  final isExpanded =
                                      expandedIndexes.contains(index);
                                  final firstProduct = products.first;
                                  final remainingProducts =
                                      products.skip(1).toList();

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewReceipt(
                                            token,
                                            item.receiptId.toString(),
                                            item.clientId.toString(),
                                            item.receiptNumber.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        title: Text(
                                          item.clientName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  "Date: ${formatDate(item.receiptDate)}",
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "₹${item.recieptAmount}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("Product: $firstProduct"),
                                                if (remainingProducts
                                                    .isNotEmpty)
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.zero),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (isExpanded) {
                                                          expandedIndexes
                                                              .remove(index);
                                                        } else {
                                                          expandedIndexes
                                                              .add(index);
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      isExpanded
                                                          ? "  Show less"
                                                          : "  +${remainingProducts.length} more",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (isExpanded)
                                              ...remainingProducts.map(
                                                (p) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0),
                                                  child: Text(
                                                    "• $p",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black54),
                                                  ),
                                                ),
                                              ),
                                            Text(
                                              "Receipt Number: ${item.receiptNumber}",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  "No Achievements Yet",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
