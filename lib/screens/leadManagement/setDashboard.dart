import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/roombooking/hotelDashboard.dart';
import 'package:login2/service/service.dart';

class SetDashboardPage extends StatefulWidget {
  final String id;
  const SetDashboardPage({super.key, required this.id});

  @override
  State<SetDashboardPage> createState() => _SetDashboardPageState();
}

class _SetDashboardPageState extends State<SetDashboardPage> {
  List<Map<String, dynamic>> dashboards = [];
  String? selectedDashboardId;
  bool isLoading = true;
  Map<String, bool> modulePermissions = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardsAndPermissions();
  }

  Future<void> _loadDashboardsAndPermissions() async {
    setState(() => isLoading = true);

    try {
      final [dashboardRes, permissionRes] = await Future.wait([
        HttpService.getDashboards(),
        _getUserPermissions(),
      ]);
      if (permissionRes != null) {
        modulePermissions = {
          'Renewal': permissionRes['renewalModule'] == 'true',
          'Lead': permissionRes['leadModule'] == 'true',
          'Accounts': permissionRes['accountsModule'] == 'true',
          'Project': permissionRes['workModule'] == 'true',
          'Quotation': permissionRes['quotationModule'] == 'true',
          'Room Booking': permissionRes['RoomModule'] == 'true',
          'Menu': true,
          'New Lead': permissionRes['leadModule'] == 'true',
          'Job Card': permissionRes['JobCard'] == 'true',
        };
      }

      final selectedRes = await HttpService.getSelectedDashboard();
      List<Map<String, dynamic>> allDashboards = [];
      if (dashboardRes?['data'] != null) {
        allDashboards = List<Map<String, dynamic>>.from(
          dashboardRes!['data'].map((item) {
            final dashboardName = item['dashboard'].toString();
            final isEnabled = modulePermissions[dashboardName] ?? true;
            return {
              'id': item['id'].toString(),
              'dashboard': dashboardName,
              'enabled': isEnabled,
            };
          }),
        );
      }

      final enabledDashboards =
          allDashboards.where((dash) => dash['enabled'] == true).toList();
      setState(() {
        dashboards = enabledDashboards;
        if (selectedRes?['data']?.isNotEmpty ?? false) {
          final selectedId = selectedRes!['data'].first['id'].toString();
          if (enabledDashboards.any((dash) => dash['id'] == selectedId)) {
            selectedDashboardId = selectedId;
          } else if (enabledDashboards.isNotEmpty) {
            selectedDashboardId = enabledDashboards.first['id'];
          }
        }
      });
    } catch (e) {
      print("Error loading dashboards: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, String>?> _getUserPermissions() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token != null) {
        final object1 = await HttpService.userPermissionCheck(token);
        if (object1 != null && object1.status == true && object1.data != null) {
          return {
            'renewalModule': object1.data!.renewalModule.toString(),
            'leadModule': object1.data!.leadModule.toString(),
            'accountsModule': object1.data!.accountsModule.toString(),
            'workModule': object1.data!.workModule.toString(),
            'quotationModule': object1.data!.quotationModule.toString(),
            'RoomModule': object1.data!.roomModule.toString(),
            'JobCard': object1.data!.JobCard.toString(),
          };
        }
      }
      return null;
    } catch (e) {
      print("Error fetching permissions: $e");
      return null;
    }
  }

  Future<void> _updateSelectedDashboard() async {
    final selectedDashboard = dashboards.firstWhere(
      (d) => d['id'] == selectedDashboardId,
      orElse: () => {},
    );

    String selectedDashboardName = selectedDashboard['dashboard'] ?? '';
    final token = await Common.getSharedPref("token");
    if (token != null) {
      final object1 = await HttpService.userPermissionCheck(token);
      if (object1 != null && object1.status == true && object1.data != null) {
        final permissionMap = {
          'Renewal': object1.data!.renewalModule == 'true',
          'Lead': object1.data!.leadModule == 'true',
          'Accounts': object1.data!.accountsModule == 'true',
          'Project': object1.data!.workModule == 'true',
          'Quotation': object1.data!.quotationModule == 'true',
          'Room Booking': object1.data!.roomModule == 'true',
          'Menu': true,
          'New Lead': object1.data!.leadModule == 'true',
          'Job Card': object1.data!.JobCard == 'true',
        };

        final hasPermission = permissionMap[selectedDashboardName] ?? false;

        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Permission denied for this dashboard"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

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

          if (object1 != null &&
              object1.status == true &&
              object1.data != null) {
            Common.saveSharedPref("ProjectDashboardPermission",
                object1.data!.ProjectDashboard.toString());
            Common.saveSharedPref(
                "LeadDashboard", object1.data!.LeadDashboard.toString());
            Common.saveSharedPref("AccountsDashboardPermission",
                object1.data!.AccountsDashboard.toString());
            Common.saveSharedPref(
                "MenuDashboard", object1.data!.MenuDashboard.toString());
            Common.saveSharedPref("RenewalDashboardPermission",
                object1.data!.RenewalDashboard.toString());
            Common.saveSharedPref("NewleadDashboardPermission",
                object1.data!.NewleadDashboard.toString());
            Common.saveSharedPref("QuotationDashboardPermission",
                object1.data!.QuotationDashboard.toString());
            Common.saveSharedPref(
                "RoomDashboard", object1.data!.RoomDashboard.toString());
            Common.saveSharedPref("JobCard", object1.data!.JobCard.toString());
            Common.saveSharedPref(
                "RoomModule", object1.data!.roomModule.toString());
            Common.saveSharedPref(
                "quotationModule", object1.data!.quotationModule.toString());
            Common.saveSharedPref(
                "workModule", object1.data!.workModule.toString());
            Common.saveSharedPref(
                "renewalModule", object1.data!.renewalModule.toString());
            Common.saveSharedPref(
                "accountsModule", object1.data!.accountsModule.toString());
            Common.saveSharedPref(
                "leadModule", object1.data!.leadModule.toString());
            Common.saveSharedPref("addApproveLeavePermission",
                object1.data!.addApproveLeave.toString());
            Common.saveSharedPref("rejectRequestLeavePermission",
                object1.data!.rejectRequestLeave.toString());
            Common.saveSharedPref("editLeaveRequestPermission",
                object1.data!.editLeaveRequest.toString());
            Common.saveSharedPref("deleteLeaveRequestPermission",
                object1.data!.deleteLeaveRequest.toString());

            if (object1.data!.ProjectDashboard == "true" &&
                object1.data!.workModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ProjectDashboard()),
                (route) => false,
              );
              return;
            }

            if (object1.data!.LeadDashboard == "true" &&
                object1.data!.leadModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => DashboardLeadNewUpdatedTwo(token)),
                (route) => false,
              );
              return;
            }
            if (object1.data!.AccountsDashboard == "true" &&
                object1.data!.accountsModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => AccountsDashboard(token: token)),
                (route) => false,
              );
              return;
            }
            if (object1.data!.RenewalDashboard == "true" &&
                object1.data!.renewalModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RenewalDashboard()),
                (route) => false,
              );
              return;
            }
            if (object1.data!.QuotationDashboard == "true" &&
                object1.data!.quotationModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const QuotationDashboard()),
                (route) => false,
              );
              return;
            }
            if (object1.data!.MenuDashboard == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage(token)),
                (route) => false,
              );
              return;
            }
            if (object1.data!.NewleadDashboard == "true" &&
                object1.data!.leadModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => MinimalDashboard(token)),
                (route) => false,
              );
              return;
            }
            if (object1.data!.JobCard == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => MinimalDashboard(token)),
                (route) => false,
              );
              return;
            }
            if (object1.data!.RoomDashboard == "true" &&
                object1.data!.roomModule == "true") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => RoomDashboard()),
                (route) => false,
              );
              return;
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => DashboardLeadNewUpdatedTwo(token)),
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
          : dashboards.isEmpty
              ? const Center(
                  child: Text(
                    "No dashboards available based on your permissions",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: dashboards.length,
                    itemBuilder: (context, index) {
                      final dash = dashboards[index];
                      final isSelected = dash['id'] == selectedDashboardId;
                      final isEnabled = dash['enabled'] ?? true;

                      return Opacity(
                        opacity: isEnabled ? 1.0 : 0.5,
                        child: AbsorbPointer(
                          absorbing: !isEnabled,
                          child: GestureDetector(
                            onTap: isEnabled
                                ? () {
                                    setState(() {
                                      selectedDashboardId = dash['id'];
                                    });
                                  }
                                : null,
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              color: !isEnabled
                                  ? Colors.grey[200]
                                  : isSelected
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: !isEnabled
                                      ? Colors.grey
                                      : isSelected
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
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: !isEnabled
                                        ? Colors.grey[600]
                                        : isSelected
                                            ? Colors.green[800]
                                            : Colors.black87,
                                  ),
                                ),
                                trailing: isSelected && isEnabled
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green, size: 22)
                                    : !isEnabled
                                        ? const Icon(Icons.lock_outline,
                                            color: Colors.grey, size: 22)
                                        : const Icon(Icons.circle_outlined,
                                            color: Colors.grey, size: 22),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: dashboards.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _updateSelectedDashboard,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.save),
              label: const Text(
                "Save",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
