import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/models/lead_management/addModuleModel.dart';
import 'package:login2/models/lead_management/projectDetailsModel.dart';
import 'package:login2/models/lead_management/projectTraceModel.dart';
import 'package:login2/models/lead_management/moduleListModel.dart' as ml;
import 'package:login2/models/lead_management/getTaskListModel.dart' as tl;
import 'package:login2/service/service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class SingleProjectDashboard extends StatefulWidget {
  final ProjectExp project;
  final ProjectPermissions? permissions;
  const SingleProjectDashboard(
      {super.key, required this.project, this.permissions});

  @override
  State<SingleProjectDashboard> createState() => _SingleProjectDashboardState();
}

class _SingleProjectDashboardState extends State<SingleProjectDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  String _searchQuery = "";

  bool _isLoading = true;
  String? _errorMessage;
  ProjectData? _projectData;

  // Real modules from API
  List<ml.Module> _realModules = [];
  bool _isLoadingModules = false;
  String? _modulesError;
  
  // Cache for task counts per module
  Map<String, int> _taskCountCache = {};
  Map<String, int> _progressCache = {};

  // Trace Filters
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedModuleId;
  String? _selectedTaskId;
  bool _showAll = true;
  VoidCallback? _refreshTraceList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _fetchProjectDetails();
    _fetchModules();
  }

  Future<void> _fetchProjectDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await HttpService.projectDetailsDashboard(widget.project.id);
      if (response != null && response.status) {
        setState(() {
          _projectData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response?.message ?? "Failed to load project details";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchModules() async {
    setState(() {
      _isLoadingModules = true;
      _modulesError = null;
    });

    try {
      final response = await HttpService.getModuleList(widget.project.id);
      if (response != null && response.status) {
        setState(() {
          _realModules = response.data.moduleList;
          _isLoadingModules = false;
        });
        // Fetch task counts for each module
        await _fetchTaskCountsForModules();
      } else {
        setState(() {
          _modulesError = response?.message ?? "Failed to load modules";
          _isLoadingModules = false;
        });
      }
    } catch (e) {
      setState(() {
        _modulesError = "Error loading modules: $e";
        _isLoadingModules = false;
      });
    }
  }

  Future<void> _fetchTaskCountsForModules() async {
    final userId = _projectData?.getCustomerList.id ?? await Common.getSharedPref("userId");
    
    for (var module in _realModules) {
      await _fetchTaskCountAndProgress(module.moduleId, userId ?? '');
    }
    setState(() {});
  }

  Future<void> _fetchTaskCountAndProgress(String moduleId, String userId) async {
    try {
      final response = await HttpService.getTaskList(
        widget.project.id, 
        userId, 
        moduleId
      );
      
      if (response != null && response.status) {
        final tasks = response.data;
        final totalTasks = tasks.length;
     //   final completedTasks = tasks.where((task) => task.status == "1").length;
       // final progress = totalTasks > 0 ? (completedTasks * 100 ~/ totalTasks) : 0;
        
        setState(() {
          _taskCountCache[moduleId] = totalTasks;
      //    _progressCache[moduleId] = progress;
        });
      }
    } catch (e) {
      print("Error fetching tasks for module $moduleId: $e");
      setState(() {
        _taskCountCache[moduleId] = 0;
        _progressCache[moduleId] = 0;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProjectDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildModernTabs(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _selectedTabIndex == 0
                        ? _buildWorksGrid()
                        : _buildModulesGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 49, 161, 212),
                          const Color.fromARGB(255, 49, 161, 212)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 49, 161, 212),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.business, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.projectName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 6),
                            Text(
                              widget.project.customerName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildHeaderInfo(
                            Icons.phone,
                            _projectData?.getCustomerList.contactNo ??
                                "Not provided"),
                        const SizedBox(width: 12),
                        _buildHeaderInfo(
                            Icons.calendar_today,
                            _projectData?.getCustomerList.createdAt ??
                                widget.project.fromDate ??
                                "N/A"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHeaderInfo(
                            Icons.location_on,
                            _projectData?.getCustomerList.address ??
                                "No address"),
                        const SizedBox(width: 12),
                        _buildHeaderInfo(Icons.access_time,
                            _projectData?.totalProjectHours ?? "0 hrs"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Project handled staffs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildStaffList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    final staffs = _projectData?.projectHandledStaffs ?? [];
    if (staffs.isEmpty) return const SizedBox();

    final int maxAvatarsToShow = 4;
    final int avatarsCount = staffs.length > maxAvatarsToShow ? maxAvatarsToShow : staffs.length;
    final double avatarRadius = 20.0;
    final double overlap = 14.0;
    final double borderSize = 2.0;

    List<Widget> stackChildren = [];

    final List<Color> avatarColors = [
      const Color(0xFF4A90E2),
      const Color(0xFF50E3C2),
      const Color(0xFFF5A623),
      const Color(0xFF9013FE),
    ];

    for (int i = 0; i < avatarsCount; i++) {
      stackChildren.add(
        Positioned(
          left: i * (avatarRadius * 2 - overlap),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0F172A), width: borderSize),
            ),
            child: CircleAvatar(
              radius: avatarRadius - borderSize,
              backgroundColor: avatarColors[i % avatarColors.length].withOpacity(0.9),
              child: Text(
                staffs[i].staffName.isNotEmpty ? staffs[i].staffName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    stackChildren.add(
      Positioned(
        left: avatarsCount * (avatarRadius * 2 - overlap),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F172A), width: borderSize),
          ),
          child: CircleAvatar(
            radius: avatarRadius - borderSize,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ),
    );

    final double totalWidth = (avatarsCount + 1) * (avatarRadius * 2) - (avatarsCount * overlap);

    return GestureDetector(
      onTap: _showStaffPopup,
      child: SizedBox(
        height: avatarRadius * 2,
        width: totalWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: stackChildren,
        ),
      ),
    );
  }

  void _showStaffPopup() {
    final staffs = _projectData?.projectHandledStaffs ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Project Staff"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: staffs.length,
            itemBuilder: (context, index) {
              final staff = staffs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 49, 161, 212),
                  child: Text(
                      staff.staffName.isNotEmpty
                          ? staff.staffName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(staff.staffName),
                subtitle: Text("${staff.totalHours} hours assigned"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  void _showAddModuleDialog({ml.Module? module}) {
    final nameController = TextEditingController(text: module?.module);
    showDialog(
        context: context,
        builder: (context) {
          bool isSaving = false;
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(module != null ? "Edit Module" : "Add New Module"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Module Name",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter module name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Please enter a module name")));
                            return;
                          }

                          setDialogState(() => isSaving = true);
                          dynamic response;
                          if (module == null) {
                            response = await HttpService.addModule(
                                widget.project.id, nameController.text.trim());
                          } else {
                            response = await HttpService.updateModule(
                                module.moduleId, nameController.text.trim());
                          }

                          if (response != null && response.status) {
                            Navigator.pop(context);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(response.message),
                              backgroundColor: Colors.green,
                            ));
                            _fetchModules(); // Refresh modules list
                            _fetchProjectDetails(); // Refresh project details
                          } else {
                            setDialogState(() => isSaving = false);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  response?.message ?? "Failed to save module"),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 49, 161, 212),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(module != null ? "Update" : "Add"),
                ),
              ],
            );
          });
        });
  }

  void _deleteModule(String moduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Module"),
        content: const Text("Are you sure you want to delete this module?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await HttpService.deleteModule(moduleId);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Module deleted successfully"),
          backgroundColor: Colors.green,
        ));
        _fetchModules();
        _fetchProjectDetails();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to delete module"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Widget _buildModernTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem("Works", 0, Icons.work_outline),
          _buildTabItem("Modules", 1, Icons.grid_view_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 49, 161, 212)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = "";
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildWorksGrid() {
    final works = _projectData?.staffWorkList ?? [];
    final filteredWorks = works.where((work) {
      return work.staffName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredWorks.isEmpty) {
      return _buildEmptyState("No works found", "Try adjusting your search");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredWorks.length,
      itemBuilder: (context, index) {
        final work = filteredWorks[index];
        return _buildWorkCard(work);
      },
    );
  }

  Widget _buildWorkCard(StaffWorkInfo work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 49, 161, 212),
                  const Color.fromARGB(255, 49, 161, 212)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                work.staffName.isNotEmpty
                    ? work.staffName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.staffName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      work.totalWorkTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showProjectTraceDialog(work.userId, work.staffName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 16, color: Color(0xFF6366F1)),
                  SizedBox(width: 6),
                  Text(
                    "View",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    if (_isLoadingModules) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_modulesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_modulesError!, style: TextStyle(color: Colors.red[300])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchModules,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final filteredModules = _realModules.where((module) {
      return module.module.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        if (widget.permissions == null || widget.permissions!.addWorkModule)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddModuleDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Module"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 161, 212),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (filteredModules.isEmpty)
          _buildEmptyState("No modules found", "Try adjusting your search")
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredModules.length,
            itemBuilder: (context, index) {
              final module = filteredModules[index];
              return _buildRealModuleCard(module);
            },
          ),
      ],
    );
  }

  Widget _buildRealModuleCard(ml.Module module) {
    final taskCount = _taskCountCache[module.moduleId] ?? 0;
    final progress = _progressCache[module.moduleId] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(Icons.folder, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.module,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.task_alt,
                                  size: 12, color: const Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                "$taskCount tasks",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.permissions == null ||
                  widget.permissions!.editModule ||
                  widget.permissions!.deleteModule)
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.more_vert,
                        size: 18, color: Color(0xFF64748B)),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddModuleDialog(module: module);
                    } else if (value == 'delete') {
                      _deleteModule(module.moduleId);
                    }
                  },
                  itemBuilder: (context) => [
                    if (widget.permissions == null ||
                        widget.permissions!.editModule)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                    if (widget.permissions == null ||
                        widget.permissions!.deleteModule)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Progress",
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 70
                              ? const Color(0xFF10B981)
                              : progress > 30
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$progress%",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  void _showTraceFilterDialog(
      String userId, Function(void Function()) onUpdate) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: Color(0xFF6366F1)),
                  SizedBox(width: 12),
                  Text("Filter Trace"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Date Range",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setDialogState(() => _fromDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _fromDate == null
                                    ? "From Date"
                                    : DateFormat('dd-MM-yyyy')
                                        .format(_fromDate!),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _fromDate == null
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _toDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setDialogState(() => _toDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _toDate == null
                                    ? "To Date"
                                    : DateFormat('dd-MM-yyyy').format(_toDate!),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _toDate == null
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Module",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder<ml.ModuleListResponse?>(
                      future: HttpService.getModuleList(widget.project.id),
                      builder: (context, snapshot) {
                        final modules = snapshot.data?.data.moduleList ?? [];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text("Select Module"),
                              value: (_selectedModuleId != null &&
                                      modules.any((m) =>
                                          m.moduleId == _selectedModuleId))
                                  ? _selectedModuleId
                                  : null,
                              items: modules
                                  .map((m) => DropdownMenuItem<String>(
                                        value: m.moduleId,
                                        child: Text(m.module),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  _selectedModuleId = val;
                                  _selectedTaskId = null;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Task",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder<tl.GetTaskListResponse?>(
                      future: _selectedModuleId == null
                          ? Future.value(null)
                          : HttpService.getTaskList(
                              widget.project.id, userId, _selectedModuleId!),
                      builder: (context, snapshot) {
                        final tasks = snapshot.data?.data ?? [];

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(_selectedModuleId == null
                                  ? "Select a module first"
                                  : "Select Task"),
                              value: (_selectedTaskId != null &&
                                      tasks.any((t) => t.id == _selectedTaskId))
                                  ? _selectedTaskId
                                  : null,
                              items: tasks
                                  .map((t) => DropdownMenuItem<String>(
                                        value: t.id,
                                        child: Text(t.taskName),
                                      ))
                                  .toList(),
                              onChanged: _selectedModuleId == null
                                  ? null
                                  : (val) {
                                      setDialogState(
                                          () => _selectedTaskId = val);
                                    },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _showAll,
                          onChanged: (val) =>
                              setDialogState(() => _showAll = val ?? true),
                          activeColor: const Color.fromARGB(255, 48, 125, 189),
                        ),
                        const Text("Show All",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _fromDate = null;
                      _toDate = null;
                      _selectedModuleId = null;
                      _selectedTaskId = null;
                      _showAll = true;
                    });
                  },
                  child:
                      const Text("Reset", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    onUpdate(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 48, 125, 189),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Apply Filter"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadReport(String userId) async {
    final fromDateStr = _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
    final toDateStr = _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

    final pdfBytes = await HttpService.downloadStaffTask(
      userId: userId,
      projectId: widget.project.id,
      fromDate: fromDateStr,
      toDate: toDateStr,
    );

    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return pdfBytes;
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to download report or report is empty")),
        );
      }
    }
  }

  void _showProjectTraceDialog(String userId, String staffName) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.analytics_outlined,
                          color: Color(0xFF6366F1)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$staffName's Trace",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            "Work history & task timeline",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _downloadReport(userId),
                          icon: const Icon(Icons.download_rounded, color: Color(0xFF6366F1)),
                          tooltip: 'Download Report',
                        ),
                        StatefulBuilder(builder: (context, setIconState) {
                          return IconButton(
                            onPressed: () => _showTraceFilterDialog(userId, (fn) {
                              fn();
                              setIconState(() {});
                              if (_refreshTraceList != null) _refreshTraceList!();
                            }),
                            icon: Icon(
                              Icons.filter_list,
                              color: (_fromDate != null ||
                                      _toDate != null ||
                                      _selectedModuleId != null ||
                                      _selectedTaskId != null)
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF64748B),
                            ),
                          );
                        }),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StatefulBuilder(builder: (context, setListState) {
                  _refreshTraceList = () => setListState(() {});
                  return FutureBuilder<ProjectTraceResponse?>(
                    future: HttpService.projectTrace(
                      widget.project.id,
                      userId,
                      fromDate: _fromDate != null
                          ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                          : null,
                      toDate: _toDate != null
                          ? DateFormat('yyyy-MM-dd').format(_toDate!)
                          : null,
                      moduleId: _selectedModuleId,
                      taskId: _selectedTaskId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return _buildEmptyState(
                            "Error fetching trace", "Please try again later");
                      }

                      final traceData = snapshot.data!.data;
                      if (traceData.list.isEmpty) {
                        return _buildEmptyState("No trace found",
                            "No work logs available for the selected filters");
                      }

                      return ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: traceData.list.length,
                        itemBuilder: (context, index) {
                          String dateKey = traceData.list.keys.elementAt(index);
                          StaffTaskGroup group = traceData.list[dateKey]!;
                          return _buildTraceGroup(dateKey, group);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraceGroup(String date, StaffTaskGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                group.totalDuration,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
        ...group.tasks.map((task) => _buildTraceCard(task)),
      ],
    );
  }

  Widget _buildTraceCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.taskName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (task.status == "1" ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.status == "1" ? "Completed" : "In Progress",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: task.status == "1" ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTraceInfo(
                  Icons.access_time_filled, task.startTime, "Start"),
              const SizedBox(width: 24),
              _buildTraceInfo(
                  Icons.timer_outlined, task.totalDuration, "Duration"),
            ],
          ),
          if (task.remarks != null && task.remarks!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                const Icon(Icons.notes, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.remarks!,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTraceInfo(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6366F1).withOpacity(0.6)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Color _getModuleStatusColor(String status) {
    switch (status) {
      case "Active":
        return const Color(0xFF10B981);
      case "In Progress":
        return const Color.fromARGB(255, 49, 161, 212);
      case "Review":
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}