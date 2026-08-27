import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import 'package:login2/service/service.dart';

import '../../models/projectdetails/project_info_model.dart';

class ProjectInfoPage extends StatefulWidget {
  final NewProjectItem project;

  const ProjectInfoPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  ProjectInfo? _projectInfo;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProjectInfo();
  }

  Future<void> _fetchProjectInfo() async {
    try {
      final response = await HttpService.getProjectInfo(
        widget.project.id,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _projectInfo = response.data.project;
          _isLoading = false;
        });

        log('Project info loaded successfully');
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load project information';

          _isLoading = false;
        });
      }
    } catch (e) {
      log('ProjectInfoPage error: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeaderCard() {
    final info = _projectInfo!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _primary,
                  _primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.folder_special_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (info.projectNo.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Project No: ${info.projectNo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DETAIL ROW
  // ------------------------------------------------------------

  Widget _buildDetailRow(
    String label,
    String value,
  ) {
    final displayValue = value.trim().isEmpty ? '--' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CLIENT / PROJECT DETAILS
  // ------------------------------------------------------------

  Widget _buildClientDetails() {
    final info = _projectInfo!;

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
          _buildSectionTitle('CLIENT DETAILS'),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Client Name',
            info.clientName,
          ),
          _buildDetailRow(
            'Contact Number',
            info.contactNo,
          ),
          _buildDetailRow(
            'Project Name',
            info.projectName,
          ),
          _buildDetailRow(
            'Project No.',
            info.projectNo,
          ),
          _buildDetailRow(
            'Address',
            info.location,
          ),
          _buildDetailRow(
            'Site Address',
            info.siteAddress,
          ),
          _buildDetailRow(
            'LPO Number',
            info.lpoNo,
          ),
          _buildDetailRow(
            'Job Number',
            info.jobNumber,
          ),
          _buildDetailRow(
            'Main Contractor',
            info.mainContractor,
          ),
          _buildDetailRow(
            'Consultant',
            info.consultant,
          ),
          _buildDetailRow(
            'Contract Value',
            info.contractValue,
          ),
          _buildDetailRow(
            'Unit Wise Price Breakdown',
            info.unitPriceBreakdown,
          ),
          _buildDetailRow(
            'Number of Units',
            info.numberOfUnits,
          ),
          _buildDetailRow(
            'Project Manager',
            info.projectManager,
          ),
          _buildDetailRow(
            'Project Engineers',
            info.projectEngineers,
          ),
          _buildDetailRow(
            'Contract Start Date',
            info.startingDate,
          ),
          _buildDetailRow(
            'Completion Date',
            info.completionDate,
          ),
          _buildDetailRow(
            'Warranty Period',
            info.warrantyPeriod.isEmpty ? '--' : '${info.warrantyPeriod} Years',
          ),
          _buildDetailRow(
            'Defects Liability Period',
            info.defectsLiabilityPeriod.isEmpty
                ? '--'
                : '${info.defectsLiabilityPeriod} Months',
          ),
          _buildDetailRow(
            'Invoice Milestone',
            info.invoiceMilestone,
          ),
          _buildDetailRow(
            'Method of Installation',
            info.methodOfInstallation,
          ),
          _buildDetailRow(
            'Work Status',
            info.workStatus,
          ),
          _buildDetailRow(
            'Project Description',
            info.projectDescription,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROJECT STATUS
  // ------------------------------------------------------------

  Widget _buildStatusCard() {
    final info = _projectInfo!;

    final status = info.workStatus.trim().isEmpty ? 'Unknown' : info.workStatus;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('PROJECT STATUS'),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _capitalize(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (info.isPaid.isNotEmpty)
                Text(
                  info.isPaid == 'Y' ? 'Paid' : 'Not Paid',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: info.isPaid == 'Y' ? Colors.green : Colors.orange,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.orange;

      case 'completed':
        return Colors.green;

      case 'pending':
        return Colors.amber.shade700;

      case 'cancelled':
      case 'canceled':
        return Colors.red;

      default:
        return _primary;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _primary,
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                _fetchProjectInfo();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Project Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primary,
                _primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _projectInfo == null
                  ? _buildError()
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: _fetchProjectInfo,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          children: [
                            _buildHeaderCard(),
                            _buildClientDetails(),
                            _buildStatusCard(),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
