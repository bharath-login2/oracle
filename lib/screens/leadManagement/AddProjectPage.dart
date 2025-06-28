import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/service/service.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  List<ProjectExp> projects = [];
  List<ProjectExp> filteredProjects = [];
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];
  final TextEditingController searchController = TextEditingController();
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
    loadInitialData();
    searchController.addListener(() {
      filterProjects(searchController.text);
    });
  }

  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final projectResponse = await HttpService.getProjectsLists();
      final customerResponse = await HttpService.getCustomers();

      if (customerResponse != null && customerResponse.status) {
        customers = customerResponse.data;
        filteredCustomers = [...customers];
      }

      if (projectResponse != null) {
        projects = projectResponse.data;
        filteredProjects = List.from(projects);
      }
      setState(() => isLoading = false);
    } catch (e) {
      log("loadInitialData error: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void filterProjects(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredProjects = projects
          .where((p) => p.projectName.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  void filterCustomers(String query) {
    final lower = query.toLowerCase();
    setState(() {
      filteredCustomers =
          customers.where((c) => c.name.toLowerCase().contains(lower)).toList();
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
            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) => filterCustomers(value),
                      decoration: const InputDecoration(
                        labelText: 'Search...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
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

  void showAddOrEditDialog({ProjectExp? project}) {
    if (project != null) {
      selectedCustomerId = project.customerId;
      selectedCustomerController.text = project.customerName;
      projectNameController.text = project.projectName;
      startDate = DateTime.tryParse(project.fromDate);
      endDate = DateTime.tryParse(project.toDate);
      startDateController.text = project.fromDate;
      endDateController.text = project.toDate;
    } else {
      clearForm();
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(project != null ? "Edit Project" : "Add Project"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: selectedCustomerController,
                  readOnly: true,
                  onTap: () async {
                    final selected =
                        await dropDialogExisting(context, "Customers");
                    if (selected != null) {
                      setState(() {
                        selectedCustomerId = selected['id'];
                        selectedCustomerController.text = selected['name'];
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: projectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                        startDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                        endDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              // onPressed: () async {
              //   if (startDate == null && startDateController.text.isNotEmpty) {
              //     startDate = DateFormat('dd-MM-yyyy')
              //         .parseStrict(startDateController.text);
              //   }
              //   if (endDate == null && endDateController.text.isNotEmpty) {
              //     endDate = DateFormat('dd-MM-yyyy')
              //         .parseStrict(endDateController.text);
              //   }

              //   if (selectedCustomerId != null &&
              //       projectNameController.text.isNotEmpty &&
              //       startDate != null &&
              //       endDate != null) {
              //     bool result;
              //     if (project == null) {
              //       result = await HttpService.addProjectsCustomers(
              //         customerId: selectedCustomerId!,
              //         projectName: projectNameController.text,
              //         startDate: startDate!,
              //         endDate: endDate!,
              //       );
              //     } else {
              //       result = await HttpService.updateProject(
              //         id: project.id,
              //         customerId: selectedCustomerId!,
              //         projectName: projectNameController.text,
              //         startDate: startDate!,
              //         endDate: endDate!,
              //       );
              //     }

              //     if (result) {
              //       Navigator.pop(ctx);
              //       await loadInitialData();
              //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //         content: Text(project == null
              //             ? "Project added successfully"
              //             : "Project updated successfully"),
              //         backgroundColor: Colors.green,
              //       ));
              //       clearForm();
              //     } else {
              //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //         content: Text(project == null
              //             ? "Failed to add project"
              //             : "Failed to update project"),
              //         backgroundColor: Colors.red,
              //       ));
              //     }
              //   }
              // },
              onPressed: () async {
                if (startDate == null && startDateController.text.isNotEmpty) {
                  try {
                    startDate = DateFormat('dd-MM-yyyy')
                        .parseStrict(startDateController.text);
                  } catch (_) {}
                }
                if (endDate == null && endDateController.text.isNotEmpty) {
                  try {
                    endDate = DateFormat('dd-MM-yyyy')
                        .parseStrict(endDateController.text);
                  } catch (_) {}
                }

                if (selectedCustomerId != null &&
                    projectNameController.text.isNotEmpty) {
                  bool result;
                  if (project == null) {
                    result = await HttpService.addProjectsCustomers(
                      customerId: selectedCustomerId!,
                      projectName: projectNameController.text,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  } else {
                    result = await HttpService.updateProject(
                      id: project.id,
                      customerId: selectedCustomerId!,
                      projectName: projectNameController.text,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  }

                  if (result) {
                    Navigator.pop(ctx);
                    await loadInitialData();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(project == null
                          ? "Project added successfully"
                          : "Project updated successfully"),
                      backgroundColor: Colors.green,
                    ));
                    clearForm();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(project == null
                          ? "Failed to add project"
                          : "Failed to update project"),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },

              child: Text(project != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
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
        await loadInitialData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        backgroundColor: const Color.fromARGB(255, 81, 139, 238),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddOrEditDialog(),
            tooltip: "Add Project",
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text("Something went wrong!",
                        style: TextStyle(color: Colors.red)))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by project name...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredProjects.isEmpty
                            ? const Center(
                                child: Text("No project data found",
                                    style: TextStyle(fontSize: 16)))
                            : ListView.builder(
                                itemCount: filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final item = filteredProjects[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ListTile(
                                      leading: const Icon(Icons.work_outline,
                                          color: Colors.grey),
                                      title: Text(item.projectName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text("Client: ${item.customerName}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14)),
                                         item.fromDate.isEmpty ||
                                                  item.toDate.isEmpty
                                              ?SizedBox()
                                              :
                                          Text(
                                              "${item.fromDate} - ${item.toDate}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orange),
                                            onPressed: () =>
                                                showAddOrEditDialog(
                                                    project: item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                deleteProject(item.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
