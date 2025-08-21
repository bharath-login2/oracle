import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/service/service.dart';

class SetDashboardPage extends StatefulWidget {
  final String id; // userId
  const SetDashboardPage({super.key, required this.id});

  @override
  State<SetDashboardPage> createState() => _SetDashboardPageState();
}

class _SetDashboardPageState extends State<SetDashboardPage> {
  List<Map<String, String>> dashboards = [];
  String? selectedDashboardId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    setState(() => isLoading = true);

    try {
      final dashboardRes = await HttpService.getDashboards();
      final selectedRes = await HttpService.getSelectedDashboard();

      setState(() {
        dashboards = List<Map<String, String>>.from(
          dashboardRes?['data'].map((item) => {
                'id': item['id'].toString(),
                'dashboard': item['dashboard'].toString(),
              }),
        );

        if (selectedRes?['data'].isNotEmpty ?? false) {
          selectedDashboardId = selectedRes!['data'].first['id'].toString();
        }
      });
    } catch (e) {
      print("Error loading dashboards: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Future<void> _updateSelectedDashboard() async {
  //   if (selectedDashboardId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select a dashboard")),
  //     );
  //     return;
  //   }

   
  //   final res = await HttpService.updateSelectedDashboard(
  //     widget.id,
  //     selectedDashboardId!,
  //   );
  //   if (res?['status'] == true) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text(
  //         "Dashboard updated successfully",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       backgroundColor: Colors.green,
  //     ),
  //   );

  //     //Navigator.pop(context, true);
  //   }
  // }

 Future<void> _updateSelectedDashboard() async {
  if (selectedDashboardId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a dashboard")),
    );
    return;
  }

  final res = await HttpService.updateSelectedDashboard(
    widget.id,
    selectedDashboardId!,
  );

  if (res?['status'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Dashboard updated successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    try {
      final token = await Common.getSharedPref("token");
      if (token != null) {
        final object1 = await HttpService.userPermissionCheck(token);

        if (object1.status == true) {
          // save updated permissions in shared prefs
          Common.saveSharedPref("ProjectDashboardPermission",
              object1.data!.ProjectDashboard.toString());
          Common.saveSharedPref("LeadDashboard",
              object1.data!.LeadDashboard.toString());
          Common.saveSharedPref("AccountsDashboardPermission",
              object1.data!.AccountsDashboard.toString());
          Common.saveSharedPref("MenuDashboard",
              object1.data!.MenuDashboard.toString());
          Common.saveSharedPref("RenewalDashboardPermission",
              object1.data!.RenewalDashboard.toString());
          if (object1.data!.ProjectDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ProjectDashboard()),
              (route) => false,
            );
            return;
          } else if (object1.data!.LeadDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  Dashboard(token)),
              (route) => false,
            );
            return;
          } else if (object1.data!.AccountsDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  AccountsDashboard(token:token)),
              (route) => false,
            );
            return;
          } else if (object1.data!.RenewalDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RenewalDashboard()),
              (route) => false,
            );
            return;
          } else if (object1.data!.MenuDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  HomePage(token)),
              (route) => false,
            );
            return;
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  Dashboard(token)),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      print("Error refreshing permissions after dashboard update: $e");
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          "Set Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF11ACF3),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: dashboards.length,
                itemBuilder: (context, index) {
                  final dash = dashboards[index];
                  final isSelected = dash['id'] == selectedDashboardId;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDashboardId = dash['id'];
                      });
                    },
                    child: Card(
                      elevation: isSelected ? 4 : 1,
                      color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Text(
                          dash['dashboard']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected ? Colors.green[800] : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 22)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.grey, size: 22),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateSelectedDashboard,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text(
          "Save",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
