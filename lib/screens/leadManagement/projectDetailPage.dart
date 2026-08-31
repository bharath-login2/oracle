import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import 'package:login2/models/lead_management/projectDetailedModel.dart';
import 'package:login2/models/projectdetails/project_documents_models.dart';
import '../projectScreens/project_info.dart';
import '../projectScreens/unit_info.dart';
import '../projectScreens/delay_management.dart';
import '../projectScreens/project_documents.dart';
import 'package:login2/service/service.dart';

class ProjectDetailPage extends StatefulWidget {
  final NewProjectItem project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  ProjectDetailedData? _projectData;
  bool _isLoading = true;
  String? _errorMessage;

  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  @override
  void initState() {
    super.initState();
    _fetchProjectDetailed();
  }

  Future<void> _fetchProjectDetailed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await HttpService.getProjectDetailed(
        projectId: widget.project.id,
      );
      if (response != null && response.status && response.data != null) {
        setState(() {
          _projectData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = (response?.message.isNotEmpty == true)
              ? response!.message
              : 'Failed to load project details';
          _isLoading = false;
        });
      }
    } catch (e) {
      log('ProjectDetailPage error: $e');
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ── Header card (name / client / location) ──────────────────────────────
  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _primary.withOpacity(0.7)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ProjectDetailedData d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Blue top accent strip
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_primary, Color(0xFF64B5F6)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.folder_special_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.projectName.isNotEmpty
                            ? d.projectName
                            : widget.project.projectName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _buildInfoRow(Icons.person_outline, d.clientName),
                      _buildInfoRow(Icons.phone_outlined, d.contact1),
                      _buildInfoRow(Icons.location_on_outlined, d.location),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview card (dates + cost + issue counts) ──────────────────────────
  Widget _buildOverviewCard(ProjectDetailedData d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'OVERVIEW',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2-column overview grid
          // Table(
          //   columnWidths: const {
          //     0: FlexColumnWidth(),
          //     1: FlexColumnWidth(),
          //   },
          //   children: [
          //     TableRow(children: [
          //       _buildOverviewTile(
          //         icon: Icons.calendar_today_outlined,
          //         label: 'Start Date',
          //         value: d.startingDate.isNotEmpty ? d.startingDate : '—',
          //       ),
          //       _buildOverviewTile(
          //         icon: Icons.event_outlined,
          //         label: 'End Date',
          //         value: d.completionDate.isNotEmpty ? d.completionDate : '—',
          //       ),
          //     ]),
          //     TableRow(children: [
          //       _buildOverviewTile(
          //         icon: Icons.currency_rupee_rounded,
          //         label: 'Total Cost',
          //         value: '₹${d.totalEstimateAmount}',
          //         valueColor: _primaryDark,
          //       ),
          //       _buildOverviewTile(
          //         icon: Icons.person_off_outlined,
          //         label: 'Client Issues',
          //         value: d.clientIssueCount,
          //         valueColor: d.clientIssueCount != '0' ? Colors.orange : null,
          //       ),
          //     ]),
          //     TableRow(children: [
          //       _buildOverviewTile(
          //         icon: Icons.business_outlined,
          //         label: 'Company Issues',
          //         value: d.companyIssueCount,
          //         valueColor: d.companyIssueCount != '0' ? Colors.orange : null,
          //       ),
          //       _buildOverviewTile(
          //         icon: Icons.payment_outlined,
          //         label: 'Payment Delay',
          //         value: d.paymentPendingCount,
          //         valueColor: d.paymentPendingCount != '0' ? Colors.red : null,
          //       ),
          //     ]),
          //     TableRow(children: [
          //       _buildOverviewTile(
          //         icon: Icons.public_outlined,
          //         label: 'General Issues',
          //         value: d.generalIssueCount,
          //         valueColor: d.generalIssueCount != '0' ? Colors.orange : null,
          //       ),
          //       _buildOverviewTile(
          //         icon: Icons.work_history_outlined,
          //         label: 'Total Worked',
          //         value: d.totalWorked,
          //       ),
          //     ]),
          //   ],
          // ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.25,
            children: [
              _buildMetricCard(
                title: "Total Project Value",
                // count: totalProjectValue,
                icon: Icons.account_balance_wallet_rounded,
                gradientColors: const [
                  Color(0xFF2A86C9),
                  Color(0xFF6366F1),
                ],
                filterType: "Total Project Value",
              ),
              _buildMetricCard(
                title: "Total Amount Collected",
                // count: totalAmountCollected,
                icon: Icons.payments_rounded,
                gradientColors: const [
                  Color(0xFF2A86C9),
                  Color(0xFF6366F1),
                ],
                filterType: "Total Amount Collected",
              ),
              _buildMetricCard(
                title: "Balance to Claim",
                // count: balanceToClaim,
                icon: Icons.account_balance_rounded,
                gradientColors: const [
                  Color(0xFF2A86C9),
                  Color(0xFF6366F1),
                ],
                filterType: "Balance to Claim",
              ),
              _buildMetricCard(
                title: "Invoiced Claimed & Waiting for Collection",
                // count: invoicedClaimedWaiting,
                icon: Icons.receipt_long_rounded,
                gradientColors: const [
                  Color(0xFF2A86C9),
                  Color(0xFF6366F1),
                ],
                filterType: "Invoiced Claimed & Waiting for Collection",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section action buttons ───────────────────────────────────────────────
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: _primary.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary.withOpacity(0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.09),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onButtonTapped(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $section...'),
        backgroundColor: _primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    // TODO: Navigate to specific section page when available
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: Text(
          widget.project.projectName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchProjectDetailed,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: _primary, size: 52),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchProjectDetailed,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1 – Project identity card
                      _buildHeaderCard(_projectData!),

                      // 2 – Overview: dates + cost + issue counts
                      _buildOverviewCard(_projectData!),

                      // 3 – Section buttons label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Project Sections',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4 – 2×3 grid of action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            _buildActionButton(
                              label: 'Project Info',
                              icon: Icons.info_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectInfoPage(
                                      project: widget.project,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              label: 'Project Document',
                              icon: Icons.description_outlined,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDocumentsPage(
                                      project: widget.project,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              label: 'Delay Management',
                              icon: Icons.timer_off_outlined,
                              onTap: () {
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DelayManagementPage(
                                      projectId: widget.project.id.toString(),
                                      projectNo:
                                          widget.project.projectNo.toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // _buildActionButton(
                            //   label: 'Gallery',
                            //   icon: Icons.photo_library_outlined,
                            //   onTap: () => _onButtonTapped('Gallery'),
                            // ),
                            // _buildActionButton(
                            //   label: 'Site Drawings',
                            //   icon: Icons.architecture_outlined,
                            //   onTap: () => _onButtonTapped('Site Drawings'),
                            // ),
                            _buildActionButton(
                              label: 'Unit Info',
                              icon: Icons.home_work_outlined,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UnitInfoPage(
                                      projectId: widget.project.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    // required int count,
    required IconData icon,
    required List<Color> gradientColors,
    required String filterType,
  }) {
    return GestureDetector(
      // onTap: () => navigateToProjectList(filterType),
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
                // Text(
                //   count.toString(),
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
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
}
