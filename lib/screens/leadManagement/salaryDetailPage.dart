import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:login2/models/lead_management/salaryDetailsModel.dart';
import 'package:login2/service/service.dart';

class SalaryDetailPage extends StatelessWidget {
  final String staffName;
  final String Id;

  const SalaryDetailPage({
    super.key,
    required this.staffName,
    required this.Id,
  });

  Future<SalaryDetailsModel?> fetchDetails() {
    return HttpService.getSalaryDetails(Id);
  }

  Widget buildSectionCard(String title, IconData icon, List<Map<String, String>> items, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(item['value']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staffName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<SalaryDetailsModel?>(
        future: fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load salary details"));
          }

          final data = snapshot.data!.data;
          final working = data.workingDetails;
          final leave = data.leaveDetails;
          final salary = data.salaryDetails;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                buildSectionCard("Working Details", LucideIcons.briefcase, [
                  {"label": "Total Working Days", "value": working.totalWorkingDays.toString()},
                  {"label": "Full Day", "value": working.fullDays.toString()},
                  {"label": "Half Day", "value": working.halfDays.toString()},
                  {"label": "Total Worked Days", "value": working.totalWorkedDays.toStringAsFixed(2)},
                ], Colors.indigo),

                buildSectionCard("Leave Details", LucideIcons.calendarX, [
                  {"label": "Available Leave", "value": leave.availableLeave.toString()},
                  {"label": "Casual Leave", "value": leave.casualLeave.toString()},
                  {"label": "Saturday Leave", "value": leave.saturdayLeave.toString()},
                  {"label": "Total Leave", "value": leave.totalLeave.toStringAsFixed(2)},
                  {"label": "LOP", "value": leave.lop.toStringAsFixed(2)},
                ], Colors.orange),

                buildSectionCard("Salary Details", LucideIcons.wallet, [
                  {"label": "Salary Credit Days", "value": salary.salaryCreditDays.toStringAsFixed(2)},
                  {"label": "Monthly Salary", "value": "₹${salary.monthlySalary}"},
                  {"label": "Per Day", "value": "₹${salary.perDaySalary}"},
                  {"label": "Incentives/Addons", "value": "₹${salary.incentives}"},
                  {"label": "Deductions", "value": "₹${salary.deductions}"},
                  {"label": "Total Salary", "value": "₹${salary.netSalary}"},
                ], Colors.purple),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
