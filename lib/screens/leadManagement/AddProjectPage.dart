import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/models/projectDashboardCountModel.dart';
import 'package:login2/screens/leadManagement/projectFormPage.dart';
import 'package:login2/screens/leadManagement/projectListPage.dart';
import 'package:login2/service/service.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  List<ProjectExp> projects = [];
  String username = "";
  String designation = "";
  ProjectPermissions? permissions;
  ProjectCounts? projectDashboardCounts;
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];

  final TextEditingController selectedCustomerController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedCustomerId;
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final projectDashboardResponse = await HttpService.getProjectDashboard();
      final customerResponse = await HttpService.getCustomers();
      final projectResponse = await HttpService.getProjectsLists();
      final projectListResp = await HttpService.getProjectLists();

      if (projectDashboardResponse != null && projectDashboardResponse.status) {
        projectDashboardCounts = projectDashboardResponse.data?.projectCounts;
      }

      if (customerResponse != null && customerResponse.status) {
        customers = customerResponse.data;
        filteredCustomers = List.from(customers);
      }

      if (projectResponse != null && projectResponse.status) {
        projects = projectResponse.data.list;
        permissions = projectResponse.data.permissions;
      }

      if (projectListResp != null &&
          projectListResp.status &&
          projectListResp.data != null) {
        username = projectListResp.data!.username;
        designation = projectListResp.data!.designation;
      }

      setState(() => isLoading = false);
    } catch (e) {
      log("loadDashboardData error: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String getProjectStatus(ProjectExp p) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? start;
    DateTime? end;

    if (p.fromDate != null && p.fromDate!.isNotEmpty) {
      try {
        if (p.fromDate!.contains('-')) {
          var parts = p.fromDate!.split('-');
          if (parts[0].length == 4) {
            start = DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            start = DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } catch (_) {}
    }

    if (p.toDate != null && p.toDate!.isNotEmpty) {
      try {
        if (p.toDate!.contains('-')) {
          var parts = p.toDate!.split('-');
          if (parts[0].length == 4) {
            end = DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            end = DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } catch (_) {}
    }

    if (start != null && start.isAfter(today)) {
      return 'Upcoming';
    }
    if (end != null && end.isBefore(today)) {
      return 'Completed';
    }
    return 'Running';
  }

  void filterCustomers(String query) {
    if (customers.isEmpty) return;
    final lower = query.toLowerCase();
    setState(() {
      filteredCustomers = query.isEmpty
          ? List.from(customers)
          : customers
              .where((c) => c.name.toLowerCase().contains(lower))
              .toList();
    });
  }

  void clearForm() {
    selectedCustomerId = null;
    selectedCustomerController.clear();
    projectNameController.clear();
    startDateController.clear();
    endDateController.clear();
    startDate = null;
    endDate = null;
  }

  void navigateToProjectList(String filterType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectListPage(initialFilter: filterType),
      ),
    );
    loadDashboardData();
  }

  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (filteredCustomers.isEmpty && customers.isNotEmpty) {
              filteredCustomers = List.from(customers);
            }
            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: filterCustomers,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: filteredCustomers.isEmpty
                    ? const Center(child: Text("No customers found"))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          if (index >= filteredCustomers.length) {
                            return const SizedBox();
                          }
                          final customer = filteredCustomers[index];
                          return ListTile(
                            title: Text(customer.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': customer.id,
                                'name': customer.name,
                              });
                            },
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void showAddProjectDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProjectFormPage()),
    );
    if (result == true) {
      loadDashboardData();
    }
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required List<Color> gradientColors,
    required String filterType,
  }) {
    return GestureDetector(
      onTap: () => navigateToProjectList(filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingCount = projectDashboardCounts != null
        ? projectDashboardCounts!.upcomingInt
        : projects.where((p) => getProjectStatus(p) == 'Upcoming').length;
    final runningCount = projectDashboardCounts != null
        ? projectDashboardCounts!.runningInt
        : projects.where((p) => getProjectStatus(p) == 'Running').length;
    final completedCount = projectDashboardCounts != null
        ? projectDashboardCounts!.completedInt
        : projects.where((p) => getProjectStatus(p) == 'Completed').length;
    final totalCount = projectDashboardCounts != null
        ? projectDashboardCounts!.allInt
        : projects.length;

    const primaryThemeColor = Color(0xFF2A86C9);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text("Something went wrong!",
                        style: TextStyle(color: Colors.red)))
                : RefreshIndicator(
                    onRefresh: () => loadDashboardData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Banner Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                            decoration: const BoxDecoration(
                              color: primaryThemeColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hi, ${username.isNotEmpty ? username : 'User'}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        designation.isNotEmpty
                                            ? designation
                                            : 'Company Admin',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: primaryThemeColor,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Overlapping Total Projects Hero Card with '+' button
                          Transform.translate(
                            offset: const Offset(0, -26),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Project Dashboard",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$totalCount Total Projects",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryThemeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (permissions == null ||
                                        permissions!.addProject)
                                      GestureDetector(
                                        onTap: () => showAddProjectDialog(),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: primaryThemeColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Project Overview",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // 2x2 Metric Cards Grid
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.25,
                                  children: [
                                    _buildMetricCard(
                                      title: "Upcoming",
                                      count: upcomingCount,
                                      icon: Icons.update_rounded,
                                      gradientColors: const [
                                        Color(0xFF4A90E2),
                                        Color(0xFF5C6BC0)
                                      ],
                                      filterType: "Upcoming",
                                    ),
                                    _buildMetricCard(
                                      title: "Running",
                                      count: runningCount,
                                      icon: Icons.play_circle_fill_rounded,
                                      gradientColors: const [
                                        Color(0xFF00B894),
                                        Color(0xFF00CEC9)
                                      ],
                                      filterType: "Running",
                                    ),
                                    _buildMetricCard(
                                      title: "Completed",
                                      count: completedCount,
                                      icon: Icons.check_circle_rounded,
                                      gradientColors: const [
                                        Color(0xFFF39C12),
                                        Color(0xFFE67E22)
                                      ],
                                      filterType: "Completed",
                                    ),
                                    _buildMetricCard(
                                      title: "Total Projects",
                                      count: totalCount,
                                      icon: Icons.assignment_rounded,
                                      gradientColors: const [
                                        Color(0xFF6C5CE7),
                                        Color(0xFFA29BFE)
                                      ],
                                      filterType: "All",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Full Project List Navigation Tile
                                GestureDetector(
                                  onTap: () => navigateToProjectList("All"),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: primaryThemeColor.withOpacity(0.3)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: primaryThemeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.list_alt_rounded,
                                            color: primaryThemeColor,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "View Project List",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "Search, filter and manage all projects",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: primaryThemeColor,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
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
