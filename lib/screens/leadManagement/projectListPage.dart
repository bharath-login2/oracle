import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import 'package:login2/screens/leadManagement/projectDetailPage.dart';
import 'package:login2/screens/leadManagement/projectFormPage.dart';
import 'package:login2/service/service.dart';

class ProjectListPage extends StatefulWidget {
  final String initialFilter;
  const ProjectListPage({super.key, this.initialFilter = 'All'});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<NewProjectItem> newProjects = [];
  List<NewProjectItem> filteredNewProjects = [];
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];
  ProjectPermissions? permissions;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController selectedCustomerController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedCustomerId;
  DateTime? startDate;
  DateTime? endDate;
  bool isListLoading = false;
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    loadData();
  }

  Future<void> loadData() async {
    await fetchCustomersAndPermissions();
    await fetchProjectsFromApi();
  }

  Future<void> fetchCustomersAndPermissions() async {
    try {
      final customerResponse = await HttpService.getCustomers();
      final projectResponse = await HttpService.getProjectsLists();

      if (customerResponse != null && customerResponse.status) {
        customers = customerResponse.data;
        filteredCustomers = List.from(customers);
      }
      if (projectResponse != null && projectResponse.status) {
        permissions = projectResponse.data.permissions;
      }
    } catch (e) {
      log("fetchCustomersAndPermissions error: $e");
    }
  }

  Future<void> fetchProjectsFromApi() async {
    setState(() {
      isListLoading = true;
    });
    try {
      String statusParam = '';
      if (selectedFilter == 'Upcoming') {
        statusParam = 'upcoming';
      } else if (selectedFilter == 'Running') {
        statusParam = 'running';
      } else if (selectedFilter == 'Completed') {
        statusParam = 'completed';
      }

      final response = await HttpService.getProjectLists(
        status: statusParam,
        searchkey: searchController.text.trim(),
      );

      if (response != null && response.status && response.data != null) {
        newProjects = response.data!.projectList;
        filteredNewProjects = List.from(newProjects);
      } else {
        newProjects = [];
        filteredNewProjects = [];
      }
    } catch (e) {
      log("fetchProjectsFromApi error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isListLoading = false;
        });
      }
    }
  }

  void onFilterSelected(String filterType) {
    setState(() {
      selectedFilter = filterType;
    });
    fetchProjectsFromApi();
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

  void showAddOrEditDialog({NewProjectItem? project}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFormPage(project: project),
      ),
    );
    if (result == true) {
      fetchProjectsFromApi();
    }
  }

  void deleteProject(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final result = await HttpService.deleteProject(id);
      if (result) {
        await fetchProjectsFromApi();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Project deleted successfully"),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to delete project"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => onFilterSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A86C9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2A86C9) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2A86C9).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryThemeColor = Color(0xFF2A86C9);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Project List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryThemeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: (permissions == null || permissions!.addProject)
          ? FloatingActionButton(
              onPressed: () => showAddOrEditDialog(),
              backgroundColor: primaryThemeColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => fetchProjectsFromApi(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar + Submit button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search projects...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => fetchProjectsFromApi(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryThemeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Upcoming'),
                    _buildFilterChip('Running'),
                    _buildFilterChip('Completed'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Project List Items
              isListLoading
                  ? const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()))
                  : filteredNewProjects.isEmpty
                      ? SizedBox(
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  "No projects found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredNewProjects.length,
                          itemBuilder: (context, index) {
                            final item = filteredNewProjects[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectDetailPage(project: item),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top Row: Avatar icon + Project name + Status badge
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: primaryThemeColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item.projectName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.03),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              item.workStatus,
                                              style: const TextStyle(
                                                color: primaryThemeColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                            height: 1,
                                            color: Color(0xFFEEEEEE)),
                                      ),
                                      // Bottom Row: Amount + Payment badge + Edit & Delete buttons
                                      Row(
                                        children: [
                                          Text(
                                            "${item.totalAmount} ₹",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: item.paymentStatus
                                                  ? Colors.green
                                                  : const Color(0xFF4CAF50),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.paymentStatus
                                                  ? "paid"
                                                  : "unpaid",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (permissions == null ||
                                              permissions!.editProject)
                                            InkWell(
                                              onTap: () {
                                                showAddOrEditDialog(
                                                    project: item);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.edit_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          if (permissions == null ||
                                              permissions!.deleteProject)
                                            InkWell(
                                              onTap: () {
                                                deleteProject(item.id);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade400,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.delete_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
