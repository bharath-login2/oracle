import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/customers/customerProjectModel.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/screens/leadManagement/AddProjectPage.dart';
import 'package:login2/service/service.dart';
import 'package:shimmer/shimmer.dart';

class CustomerProjectPage extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerProjectPage({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  _CustomerProjectPageState createState() => _CustomerProjectPageState();
}

class _CustomerProjectPageState extends State<CustomerProjectPage> {
  late Future<CustomerwiseProjectModel?> _projectsFuture;
  List<ProjectData> _projects = [];
  List<ProjectExp> projects = [];
  List<ProjectExp> filteredProjects = [];
  ProjectPermissions? permissions;
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController selectedCustomerController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  bool _showSearchBar = false;
  String? selectedCustomerId;
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    _loadProjects();
    loadInitialData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _loadProjects() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _projectsFuture = HttpService.getCustomerProjects(widget.customerId);
    _projectsFuture.then((response) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response != null && response.status) {
            _projects = response.data.list;
          } else {
            _errorMessage = response?.message ?? 'Failed to load projects';
          }
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $error';
        });
      }
    });
  }

  List<ProjectData> get _filteredProjects {
    var filtered = _projects;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((p) => p.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.projectName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: _showSearchBar ? _buildSearchField() : _buildTitle(),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search projects...',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _showSearchBar = false;
              _searchController.clear();
              _searchQuery = '';
            });
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
           widget.customerName,
       
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
            'Customer Projects',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_showSearchBar) return [];

    return [
      IconButton(
        icon: Icon(Icons.search, color: Colors.white),
        onPressed: () {
          setState(() {
            _showSearchBar = true;
          });
        },
      ),
      _isLoading
          ? Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadProjects,
            ),
    ];
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildFilterChips(),
        _buildStatsCard(),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'New', 'Active', 'Completed', 'Pending'];

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Padding(
            padding: EdgeInsets.only(right: 8, top: 12, bottom: 12),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: _selectedFilter == filter
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: _selectedFilter == filter
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_isLoading || _errorMessage.isNotEmpty) return SizedBox.shrink();

    final total = _projects.length;
    final active = _projects.where((p) => p.status == 'Active').length;
    final completed = _projects.where((p) => p.status == 'Completed').length;
    final newProjects = _projects.where((p) => p.status == 'New').length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            count: total,
            label: 'Total',
            color: Theme.of(context).primaryColor,
          ),
          Container(height: 40, width: 1, color: Colors.grey[200]),
          _buildStatItem(
            count: newProjects,
            label: 'New',
            color: Colors.blue,
          ),
          Container(height: 40, width: 1, color: Colors.grey[200]),
          _buildStatItem(
            count: active,
            label: 'Active',
            color: Colors.green,
          ),
          Container(height: 40, width: 1, color: Colors.grey[200]),
          _buildStatItem(
            count: completed,
            label: 'Completed',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      {required int count, required String label, required Color color}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_filteredProjects.isEmpty && _projects.isNotEmpty) {
      return _buildNoResultsState();
    }

    if (_projects.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadProjects();
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: _filteredProjects.length,
        itemBuilder: (context, index) {
          final project = _filteredProjects[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProjects,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try changing your search or filter',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 56,
                color: Colors.blue[300],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Projects Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.customerName} doesn\'t have any projects yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            if (permissions == null || permissions!.addProject)
              ElevatedButton.icon(
                onPressed: showAddOrEditDialog,
                icon: Icon(Icons.add),
                label: Text('Create First Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectData project) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final daysRemaining = project.endDate.difference(DateTime.now()).inDays;
    final progress = _calculateProgress(project);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewProjectDetails(project),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.projectName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(project.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      project.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(project.status),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Staff: ${project.staffName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(project.status),
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    daysRemaining > 0
                        ? '$daysRemaining days left'
                        : 'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: daysRemaining > 0 ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    if (_isLoading || (permissions != null && !permissions!.addProject)) return SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: showAddOrEditDialog,
      child: Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.orange;
      case 'pending':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  double _calculateProgress(ProjectData project) {
    final totalDuration = project.endDate.difference(project.startDate).inDays;
    if (totalDuration == 0) return 0.0;

    final elapsedDuration = DateTime.now().difference(project.startDate).inDays;
    return elapsedDuration.clamp(0, totalDuration) / totalDuration;
  }

  void _viewProjectDetails(ProjectData project) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProjectDetailsPage(
    //       project: project,
    //       customerName: widget.customerName,
    //     ),
    //   ),
    // );
  }

  // void _addNewProject() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddProjectPage(
  //         // customerId: widget.customerId,
  //         // customerName: widget.customerName,
  //       ),
  //     ),
  //   ).then((value) {
  //     if (value == true) {
  //       _loadProjects();
  //     }
  //   });
  // }

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
        filteredCustomers = List.from(customers);
      }
      if (projectResponse != null && projectResponse.status) {
        projects = projectResponse.data.list;
        permissions = projectResponse.data.permissions;
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

  void showAddOrEditDialog({ProjectExp? project}) {
    if (project != null) {
      selectedCustomerId = project.customerId;
      selectedCustomerController.text = project.customerName;
      projectNameController.text = project.projectName;
      startDate = project.fromDate != null ? DateTime.tryParse(project.fromDate!) : null;
      endDate = project.toDate != null ? DateTime.tryParse(project.toDate!) : null;
      startDateController.text = project.fromDate ?? "";
      endDateController.text = project.toDate ?? "";
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
}
