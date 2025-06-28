import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginSummaryPage extends StatefulWidget {
  final String staffId;
  final String token;
  final DateTime date;
  const LoginSummaryPage({
    super.key,
    required this.staffId,
    required this.token,
    required this.date,
  });
  @override
  State<LoginSummaryPage> createState() => _LoginSummaryPageState();
}

class _LoginSummaryPageState extends State<LoginSummaryPage> {
  List<Map<String, String>> _loginData = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    getLoginAndLogout(widget.staffId, selectedDate);
  }

  Future<void> getLoginAndLogout(String staffId, DateTime date) async {
    setState(() => isLoading = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final workStatusModel =
          await HttpService.getLoginAndLogout(staffId, formattedDate);
      final fetchedData = workStatusModel?.data
              .map((item) => {
                    "date": item.date ?? "--",
                    "login": item.loginTime ?? "--",
                    "logout": item.logoutTime ?? "--",
                    "login_lat": item.loginLatitude ?? "",
                    "login_lng": item.loginLongitude ?? "",
                    "logout_lat": item.logoutLatitude ?? "",
                    "logout_lng": item.logoutLongitude ?? "",
                  })
              .toList() ??
          [];
      setState(() {
        _loginData = fetchedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      getLoginAndLogout(widget.staffId, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedSelectedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final sortedData = [..._loginData];
    sortedData.sort((a, b) => (b["login"] ?? "").compareTo(a["login"] ?? ""));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Summary"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filter by date',
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loginData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          "No login data available for\n$formattedSelectedDate",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formattedSelectedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: sortedData.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 24),
                          itemBuilder: (context, index) {
                            final item = sortedData[index];
                            final loginTime = item["login"] ?? "--";
                            final logoutTime = item["logout"] ?? "--";

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTimelineCard(
                                  icon: Icons.login,
                                  label: "Login Time",
                                  time: item["login"] ?? "--",
                                  color: Colors.green,
                                  latitude: item["login_lat"],
                                  longitude: item["login_lng"],
                                ),
                                const SizedBox(height: 12),
                                _buildTimelineCard(
                                  icon: Icons.logout,
                                  label: "Logout Time",
                                  time: item["logout"] ?? "--",
                                  color: Colors.red,
                                  latitude: item["logout_lat"],
                                  longitude: item["logout_lng"],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTimelineCard({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    String? latitude,
    String? longitude,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Container(width: 2, height: 60, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(time),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (latitude != null &&
                      longitude != null &&
                      latitude.isNotEmpty &&
                      longitude.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        final url = Uri.parse(
                            "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: Image.asset('assets/main/mapimage.png',
                          width: 40, height: 40),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
