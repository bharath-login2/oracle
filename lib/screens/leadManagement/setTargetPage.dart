import 'package:flutter/material.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/groupTargetModel.dart';
import 'package:login2/models/individualTargetModel.dart';
import 'package:login2/models/userManagement/companyTargetModel.dart';
import 'package:login2/service/service.dart';

class SetTargetPage extends StatefulWidget {
  const SetTargetPage({super.key});

  @override
  State<SetTargetPage> createState() => _SetTargetPageState();
}

class _SetTargetPageState extends State<SetTargetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Individual> individualTargets = [];
  List<Group> groupTargets = [];
  List<Company> companyTargets = [];
  bool isLoadingTargets = false;

  List<Staff> staffList = [];
  bool isLoadingStaff = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3
    _loadStaffList();
    _loadTargets();
  }

  Future<void> _loadStaffList() async {
    setState(() => isLoadingStaff = true);
    try {
      final staffData = await HttpService.getStaffs();
      if (staffData != null && staffData.status) {
        setState(() => staffList = staffData.data);
      }
    } catch (e) {
      debugPrint("Error loading staff: $e");
    } finally {
      setState(() => isLoadingStaff = false);
    }
  }

  Future<void> _loadTargets() async {
    setState(() => isLoadingTargets = true);
    try {
      final individualRes = await HttpService.getIndividualTargets();
      final groupRes = await HttpService.getGroupTargets();
      final companyRes = await HttpService.getCompanyTargets();

      if (individualRes != null && individualRes.status) {
        individualTargets = individualRes.data;
      }

      if (groupRes != null && groupRes.status) {
        groupTargets = groupRes.data;
      }

      if (companyRes != null && companyRes.status) {
        companyTargets = companyRes.data;
      }
    } catch (e) {
      debugPrint("Error loading targets: $e");
    } finally {
      setState(() => isLoadingTargets = false);
    }
  }

  List<CompanyTarget> _parseCompanyTargets(dynamic data) {
    if (data is List) {
      return data.map((item) => CompanyTarget.fromJson(item)).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Target"),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTargetDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Individual Target'),
            Tab(text: 'Group Target'),
            Tab(text: 'Company Target'),
          ],
        ),
      ),
      body: isLoadingTargets
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIndividualTargetsList(),
                _buildGroupTargetsList(),
                _buildCompanyTargetsList(),
              ],
            ),
    );
  }

  Widget _buildIndividualTargetsList() {
    if (individualTargets.isEmpty) {
      return const Center(
        child: Text(
          'No individual targets found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: individualTargets.length,
      itemBuilder: (context, index) {
        final target = individualTargets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.staffName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('🎯 Target Amount: ₹${target.targetAmount}'),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(text: '📅 Effective Date: '),
                      TextSpan(
                        text: target.effectiveDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (target.isActive == 'Y' &&
                          !target.effectiveDate.contains('-'))
                        const TextSpan(
                          text: ' - Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupTargetsList() {
    if (groupTargets.isEmpty) {
      return const Center(
        child: Text(
          'No group targets found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: groupTargets.length,
      itemBuilder: (context, index) {
        final target = groupTargets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.groupName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('👥 Staff: ${target.staffs}'),
                const SizedBox(height: 4),
                Text('🎯 Target Amount: ₹${target.targetAmount}'),
                const SizedBox(height: 4),
                Text('📅 Effective Date: ${target.effectiveDate}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyTargetsList() {
    if (companyTargets.isEmpty) {
      return const Center(
        child: Text(
          'No company targets found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: companyTargets.length,
      itemBuilder: (context, index) {
        final target = companyTargets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company Target',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('🎯 Target Amount: ₹${target.targetAmount}'),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(text: '📅 Effective Date: '),
                      TextSpan(
                        text: target.effectiveDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (target.isActive == 'Y' &&
                          !target.effectiveDate.contains('-'))
                        const TextSpan(
                          text: ' - Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTargetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddTargetDialog(
          staffList: staffList,
          isLoadingStaff: isLoadingStaff,
          onSubmitted: () {
            _loadTargets();
          },
        );
      },
    );
  }
}

// Add this CompanyTarget model class
class CompanyTarget {
  final String targetAmount;
  final String effectiveDate;
  final String isActive;

  CompanyTarget({
    required this.targetAmount,
    required this.effectiveDate,
    required this.isActive,
  });

  factory CompanyTarget.fromJson(Map<String, dynamic> json) {
    return CompanyTarget(
      targetAmount: json['target_amount']?.toString() ?? '0',
      effectiveDate: json['effective_date']?.toString() ?? '',
      isActive: json['is_active']?.toString() ?? 'N',
    );
  }
}

// Rest of your code for _AddTargetDialog and other classes...
class _AddTargetDialog extends StatefulWidget {
  final List<Staff> staffList;
  final bool isLoadingStaff;
  final VoidCallback onSubmitted;

  const _AddTargetDialog({
    required this.staffList,
    required this.isLoadingStaff,
    required this.onSubmitted,
  });

  @override
  _AddTargetDialogState createState() => _AddTargetDialogState();
}

class _AddTargetDialogState extends State<_AddTargetDialog> {
  late TextEditingController _amountController;
  late TextEditingController _groupNameController;
  String? _targetType;
  Staff? _selectedStaff;
  List<Staff> _selectedStaffs = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _groupNameController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_targetType == 'Individual' &&
        _selectedStaff != null &&
        _amountController.text.isNotEmpty) {
      final payload = {
        "type": "individual",
        "staff_id": _selectedStaff?.userIdStaff,
        "amount": _amountController.text,
      };

      final success = await HttpService.submitTarget(payload);
      if (success) {
        widget.onSubmitted();
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit individual target')),
          );
        }
      }
    }
    //  else if (_targetType == 'Group' &&
    //     _groupNameController.text.isNotEmpty &&
    //     _selectedStaffs.isNotEmpty &&
    //     _amountController.text.isNotEmpty) {
    //   final payload = {
    //     "type": "group",
    //     "group_name": _groupNameController.text,
    //     "staff_ids": _selectedStaffs.map((e) => e.id).toList(),
    //     "amount": _amountController.text,
    //   };

    //   final success = await HttpService.submitTarget(payload);
    //   if (success) {
    //     widget.onSubmitted();
    //     if (mounted) Navigator.pop(context);
    //   } else {
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Failed to submit group target')),
    //       );
    //     }
    //   }
    // }
    else if (_targetType == 'Group' &&
        _groupNameController.text.isNotEmpty &&
        _selectedStaffs.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final staffIdsString = _selectedStaffs.map((e) => e.id).join(',');

      final payload = {
        "type": "group",
        "group_name": _groupNameController.text,
        "staff_ids": staffIdsString,
        "amount": _amountController.text,
      };
      final success = await HttpService.submitTarget(payload);
      if (success) {
        widget.onSubmitted();
        if (mounted) Navigator.pop(context);
      }
    } else if (_targetType == 'Company' && _amountController.text.isNotEmpty) {
      final payload = {
        "type": "company",
        "amount": _amountController.text,
      };

      final success = await HttpService.submitTarget(payload);
      if (success) {
        widget.onSubmitted();
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit company target')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all fields')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Target"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Target Type',
                border: OutlineInputBorder(),
              ),
              value: _targetType,
              items: ['Individual', 'Group', 'Company'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _targetType = newValue;
                  _selectedStaff = null;
                  _selectedStaffs.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (widget.isLoadingStaff) const CircularProgressIndicator(),
            if (_targetType == 'Individual' && !widget.isLoadingStaff) ...[
              _buildSearchableStaffDropdown(),
              const SizedBox(height: 16),
            ],
            if (_targetType == 'Group' && !widget.isLoadingStaff) ...[
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildMultiSelectStaffDropdown(),
              const SizedBox(height: 16),
            ],
            if (_targetType != null) ...[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Target Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2a86c9),
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildSearchableStaffDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Staff',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () async {
          final selected = await showDialog<Staff>(
            context: context,
            builder: (context) => _StaffSelectionDialog(
              staffList: widget.staffList,
              selectedStaff: _selectedStaff,
            ),
          );

          if (selected != null && mounted) {
            setState(() {
              _selectedStaff = selected;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            _selectedStaff?.name ?? 'Select Staff',
            style: TextStyle(
              color: _selectedStaff == null ? Colors.grey[600] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectStaffDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Select Staff Members',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () async {
          final selected = await showDialog<List<Staff>>(
            context: context,
            builder: (context) => _MultiStaffSelectionDialog(
              staffList: widget.staffList,
              selectedStaffs: _selectedStaffs,
            ),
          );

          if (selected != null && mounted) {
            setState(() {
              _selectedStaffs = selected;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            _selectedStaffs.isEmpty
                ? 'Select Staff Members'
                : '${_selectedStaffs.length} selected',
          ),
        ),
      ),
    );
  }
}

class _StaffSelectionDialog extends StatefulWidget {
  final List<Staff> staffList;
  final Staff? selectedStaff;

  const _StaffSelectionDialog({
    required this.staffList,
    this.selectedStaff,
  });

  @override
  _StaffSelectionDialogState createState() => _StaffSelectionDialogState();
}

class _StaffSelectionDialogState extends State<_StaffSelectionDialog> {
  late TextEditingController _searchController;
  List<Staff> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredList = widget.staffList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Staff'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Staff',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _filteredList = widget.staffList
                    .where((s) =>
                        s.name.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final staff = _filteredList[index];
                return ListTile(
                  title: Text(staff.name),
                  onTap: () => Navigator.pop(context, staff),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiStaffSelectionDialog extends StatefulWidget {
  final List<Staff> staffList;
  final List<Staff> selectedStaffs;

  const _MultiStaffSelectionDialog({
    required this.staffList,
    required this.selectedStaffs,
  });

  @override
  _MultiStaffSelectionDialogState createState() =>
      _MultiStaffSelectionDialogState();
}

class _MultiStaffSelectionDialogState
    extends State<_MultiStaffSelectionDialog> {
  late TextEditingController _searchController;
  List<Staff> _filteredList = [];
  List<Staff> _tempSelected = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredList = widget.staffList;
    _tempSelected = List<Staff>.from(widget.selectedStaffs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Staff Members'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Staff',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _filteredList = widget.staffList
                    .where((staff) =>
                        staff.name.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final staff = _filteredList[index];
                final isSelected = _tempSelected.contains(staff);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(staff.name),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelected.add(staff);
                      } else {
                        _tempSelected.remove(staff);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, widget.selectedStaffs),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
