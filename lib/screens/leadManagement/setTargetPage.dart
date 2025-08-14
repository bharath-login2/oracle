import 'package:flutter/material.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/groupTargetModel.dart';
import 'package:login2/models/individualTargetModel.dart';
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
  bool isLoadingTargets = false;

  List<Staff> staffList = []; // Store staff list here
  bool isLoadingStaff = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

      if (individualRes != null && individualRes.status) {
        individualTargets = individualRes.data;
      }

      if (groupRes != null && groupRes.status) {
        groupTargets = groupRes.data;
      }
    } catch (e) {
      debugPrint("Error loading targets: $e");
    } finally {
      setState(() => isLoadingTargets = false);
    }
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
          ],
        ),
      ),
      body: isLoadingTargets
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemCount: individualTargets.length,
                  itemBuilder: (context, index) {
                    final target = individualTargets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                ),
                ListView.builder(
                  itemCount: groupTargets.length,
                  itemBuilder: (context, index) {
                    final target = groupTargets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                ),
              ],
            ),
    );
  }

  void _showAddTargetDialog(BuildContext context) {
    String? targetType;
    Staff? selectedStaff;
    String groupName = '';
    List<Staff> selectedStaffs = [];
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      value: targetType,
                      items: ['Individual', 'Group'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          targetType = newValue;
                          selectedStaff = null;
                          selectedStaffs.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingStaff) const CircularProgressIndicator(),
                    if (targetType == 'Individual' && !isLoadingStaff) ...[
                      _buildSearchableStaffDropdown(
                        selectedStaff: selectedStaff,
                        staffList: staffList,
                        onSelected: (staff) {
                          setState(() {
                            selectedStaff = staff;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (targetType == 'Group' && !isLoadingStaff) ...[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => groupName = value,
                      ),
                      const SizedBox(height: 16),
                      _buildMultiSelectStaffDropdown(
                        staffList: staffList,
                        selectedStaffs: selectedStaffs,
                        onChanged: (staffs) {
                          setState(() {
                            selectedStaffs = staffs;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (targetType != null) ...[
                      TextFormField(
                        controller: amountController,
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
                  onPressed: () async {
                    if (targetType == 'Individual' &&
                        selectedStaff != null &&
                        amountController.text.isNotEmpty) {
                      final payload = {
                        "type": "individual",
                        "staff_id": selectedStaff?.userIdStaff,
                        "amount": amountController.text,
                      };

                      final success = await HttpService.submitTarget(payload);
                      if (success) {
                        await _loadTargets();

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Failed to submit individual target')),
                        );
                      }
                    } else if (targetType == 'Group' &&
                        groupName.isNotEmpty &&
                        selectedStaffs.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final payload = {
                        "type": "group",
                        "group_name": groupName,
                        "staff_ids": selectedStaffs.map((e) => e.id).toList(),
                        "amount": amountController.text,
                      };

                      final success = await HttpService.submitTarget(payload);
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to submit group target')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please complete all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => amountController.dispose());
  }

  Widget _buildSearchableStaffDropdown({
    required Staff? selectedStaff,
    required List<Staff> staffList,
    required Function(Staff) onSelected,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Staff',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () async {
          final selected = await showDialog<Staff>(
            context: context,
            builder: (context) {
              String searchQuery = '';
              List<Staff> filteredList = staffList;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Select Staff'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Staff',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              filteredList = staffList
                                  .where((s) => s.name
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final staff = filteredList[index];
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
                },
              );
            },
          );

          if (selected != null) {
            onSelected(selected);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            selectedStaff?.name ?? 'Select Staff',
            style: TextStyle(
              color: selectedStaff == null ? Colors.grey[600] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectStaffDropdown({
    required List<Staff> staffList,
    required List<Staff> selectedStaffs,
    required Function(List<Staff>) onChanged,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Select Staff Members',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () async {
          final selected = await showDialog<List<Staff>>(
            context: context,
            builder: (context) {
              List<Staff> tempSelected = List<Staff>.from(selectedStaffs);
              String searchQuery = '';

              return StatefulBuilder(
                builder: (context, setState) {
                  final filteredList = staffList
                      .where((staff) => staff.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  return AlertDialog(
                    title: const Text('Select Staff Members'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Staff',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final staff = filteredList[index];
                              final isSelected = tempSelected.contains(staff);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(staff.name),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      tempSelected.add(staff);
                                    } else {
                                      tempSelected.remove(staff);
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
                        onPressed: () => Navigator.pop(context, selectedStaffs),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, tempSelected),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          );

          if (selected != null) {
            onChanged(selected);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            selectedStaffs.isEmpty
                ? 'Select Staff Members'
                : '${selectedStaffs.length} selected',
          ),
        ),
      ),
    );
  }
}
