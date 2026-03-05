import re

file_path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\screens\leadManagement\dashboardLeadsNewUpdated.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
content = content.replace(
    "import 'package:login2/models/lead_management/leadDashboardCountNewModel.dart';",
    "import 'package:login2/models/lead_management/dashboardLeadsCountsModel.dart';\nimport 'package:login2/models/expense/staffListModel.dart';"
)

# 2. State vars
content = content.replace(
    "  DashboardLeadCounts? dashboardCounts;\n  bool isDashboardCountsLoading = false;",
    "  DashboardLeadsCountsModel? dashboardCounts;\n  bool isDashboardCountsLoading = false;\n  String? targetStaffId;\n  List<Staff> staffList = [];"
)

# 3. getData additions
old_get_data = '''      // Get new dashboard counts
      setState(() => isDashboardCountsLoading = true);
      try {
        final countsData = await HttpService.newDashboardCount();
        if (countsData != null && countsData.status) {
          setState(() {
            dashboardCounts = countsData;
          });
        }
      } catch (e) {
        log("Error fetching dashboard counts: $e");
      } finally {
        setState(() => isDashboardCountsLoading = false);
      }'''
new_get_data = '''      // Get new dashboard counts
      setState(() => isDashboardCountsLoading = true);
      try {
        final fDate = DateFormat('yyyy-MM-dd').format(fromDate);
        final tDate = DateFormat('yyyy-MM-dd').format(toDate);
        final countsData = await HttpService.newDashboardCount(
            fromDate: fDate,
            toDate: tDate,
            staffId: targetStaffId ?? "");
            
        final staffResponse = await HttpService.getStaffs();
        if (staffResponse != null && staffResponse.status) {
          staffList = staffResponse.data;
        }

        if (countsData != null && countsData.status == true) {
          setState(() {
            dashboardCounts = countsData;
          });
        }
      } catch (e) {
        log("Error fetching dashboard counts: $e");
      } finally {
        setState(() => isDashboardCountsLoading = false);
      }'''
content = content.replace(old_get_data, new_get_data)

# 4. Header text (if any)
old_header = "'${_listTabFilter == 'New' ? (dashboardCounts?.data.leads.newLeads ?? 0) : _listTabFilter == 'Followup' ? (dashboardCounts?.data.leads.followupLeads ?? 0) : _listTabFilter == 'Missed' ? (dashboardCounts?.data.leads.missedLeads ?? 0) : _listTabFilter == 'Called' ? (dashboardCounts?.data.leads.calledCount ?? 0) : _listTabFilter == 'Transferred' ? (dashboardCounts?.data.leads.transferLeads ?? 0) : ((dashboardCounts?.data.leads.newLeads ?? 0) + (dashboardCounts?.data.leads.followupLeads ?? 0) + (dashboardCounts?.data.leads.missedLeads ?? 0) + (dashboardCounts?.data.leads.calledCount ?? 0) + (dashboardCounts?.data.leads.transferLeads ?? 0))} Leads',"
new_header = "'${_listTabFilter == 'New' ? (dashboardCounts?.data?.leads?.newLeads ?? 0) : _listTabFilter == 'Followup' ? (dashboardCounts?.data?.leads?.activeLeads ?? 0) : _listTabFilter == 'Missed' ? (dashboardCounts?.data?.leads?.closedLeads ?? 0) : _listTabFilter == 'Called' ? (dashboardCounts?.data?.leads?.rejectedLeads ?? 0) : _listTabFilter == 'Transferred' ? 0 : ((dashboardCounts?.data?.leads?.newLeads ?? 0) + (dashboardCounts?.data?.leads?.activeLeads ?? 0) + (dashboardCounts?.data?.leads?.closedLeads ?? 0) + (dashboardCounts?.data?.leads?.rejectedLeads ?? 0))} Leads',"
content = content.replace(old_header, new_header)

# 5. Dashboard boxes
content = re.sub(
    r"mainValue: dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.newLeads\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.newLeads\.toString\(\)\s*\?\?\s*'0'\),",
    "mainValue: dashboardCounts != null ? (dashboardCounts?.data?.leads?.newLeads ?? 0).toString() : (leadDashboard?.data.newLeads.toString() ?? '0'),",
    content
)
content = re.sub(
    r"dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.missedLeads\s*\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.missedLeads\.toString\(\)\s*\?\?\s*'0'\)",
    "dashboardCounts != null ? (dashboardCounts!.data?.leads?.newMissed ?? 0).toString() : (leadDashboard?.data.missedLeads.toString() ?? '0')",
    content, count=1
)
content = re.sub(
    r"mainValue: dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.followupLeads\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.followupLeads\.toString\(\)\s*\?\?\s*'0'\),",
    "mainValue: dashboardCounts != null ? (dashboardCounts?.data?.leads?.activeLeads ?? 0).toString() : (leadDashboard?.data.followupLeads.toString() ?? '0'),",
    content
)
content = re.sub(
    r"dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.missedLeads\s*\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.missedLeads\.toString\(\)\s*\?\?\s*'0'\)",
    "dashboardCounts != null ? (dashboardCounts!.data?.leads?.activeMissed ?? 0).toString() : (leadDashboard?.data.missedLeads.toString() ?? '0')",
    content, count=1
)
content = re.sub(
    r"mainValue: dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.missedLeads\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.missedLeads\.toString\(\)\s*\?\?\s*'0'\),",
    "mainValue: dashboardCounts != null ? (dashboardCounts?.data?.leads?.closedLeads ?? 0).toString() : (leadDashboard?.data.missedLeads.toString() ?? '0'),",
    content
)
content = re.sub(
    r"mainValue: dashboardCounts != null\s*\?\s*dashboardCounts!\.data\.leads\.calledCount\.toString\(\)\s*:\s*\(leadDashboard\?\.data\.totalCalled\.toString\(\)\s*\?\?\s*'0'\),",
    "mainValue: dashboardCounts != null ? (dashboardCounts?.data?.leads?.rejectedLeads ?? 0).toString() : (leadDashboard?.data.totalCalled.toString() ?? '0'),",
    content
)

content = content.replace(
    '''                          Text(
                            "0",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),''',
    '''                          Text(
                            dashboardCounts != null ? (dashboardCounts!.data?.leads?.newToday ?? 0).toString() : (leadDashboard?.data.newLeads.toString() ?? '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),''', 1
)

content = content.replace(
    '''                          Text(
                            "0",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),''',
    '''                          Text(
                            dashboardCounts != null ? (dashboardCounts!.data?.leads?.activeToday ?? 0).toString() : (leadDashboard?.data.followupLeads.toString() ?? '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),''', 1
)


# Target section replace
old_target = '''  Widget _buildTargetSection() {
    final double progress = 0.54;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.track_changes_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Performance tracker',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 12,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTargetStat('Target Amount', '₹50,000', Icons.outlined_flag),
              _buildTargetStat(
                  'Total Achieved', '₹27,000', Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }'''

new_target = '''  Widget _buildTargetSection() {
    List<Target> targets = dashboardCounts?.data?.target ?? [];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             const Text(
               'Targets',
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
               ),
             ),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: targetStaffId,
                  hint: const Text("Select Staff", style: TextStyle(fontSize: 12)),
                  icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),
                  onChanged: (val) {
                    setState(() {
                      targetStaffId = val;
                    });
                    getData(widget.token, fromDate, toDate);
                  },
                  items: [
                    const DropdownMenuItem(value: null, child: Text("All Staff", style: TextStyle(fontSize: 12))),
                    ...staffList.map((s) => DropdownMenuItem(
                      value: s.userIdStaff.toString(),
                      child: Text(s.name, style: const TextStyle(fontSize: 12)),
                    )).toList()
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (targets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No targets available"),
          )
        else
          ...targets.map((target) => _buildTargetItem(target)).toList(),
      ],
    );
  }

  Widget _buildTargetItem(Target target) {
    final double progress = double.tryParse(target.progressPercentage ?? "0.0") ?? 0.0;
    final double progressFraction = (progress / 100).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.track_changes_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.groupName ?? 'Target',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const Text(
                        'Performance tracker',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: borderLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: constraints.maxWidth * progressFraction,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTargetStat('Target Amount', '₹${target.maxAmount ?? "0"}', Icons.outlined_flag),
              _buildTargetStat(
                  'Total Achieved', '₹${target.achieved ?? "0"}', Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }'''

content = content.replace(old_target, new_target)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced!")
